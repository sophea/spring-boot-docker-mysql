package com.sma.springboot.service;

import java.util.Collection;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.sma.springboot.dao.CategoryRepository;
import com.sma.springboot.domain.DCategory;
import com.sma.springboot.domain.ResponseList;

@Service("categorySevice")
public class CategoryServiceImpl implements CategoryService {
    private static final Logger logger = LoggerFactory.getLogger(CategoryServiceImpl.class);
    
    @Autowired
    private CategoryRepository dao;
    
    @Override
    public Iterable<DCategory> list() {
        return dao.findAll();
    }

    @Override
    public DCategory get(Long id) {
        return dao.findOne(id);
    }

    @Override
    public DCategory create(DCategory dCategory) {
        return dao.save(dCategory);
    }

    @Override
    public void delete(Long id) {
        dao.delete(id);
    }

    @Override
    public DCategory update(Long id, DCategory dCategory) {
        
        if (get(id) == null) {
            return null;
        }
        dCategory.setId(id);
        return dao.save(dCategory);
    }
    
    public ResponseList<DCategory> getPage(int pagesize, String offset) {
        
        if (offset == null) {
            offset = "0";
        }
        
        logger.debug(" getPage limit : {} offset : {}", pagesize, offset);
       // return dao.getPage(pagesize, cursorkey);
        final Pageable page = createPageRequest(pagesize, Integer.valueOf(offset)/pagesize
                );
        final Page<DCategory> results = dao.findAll(page);
        
     
        return  populatePages(results.getContent(), pagesize, offset, (int) results.getTotalElements());
    }
    
    private Pageable createPageRequest(int pagesize, int pageIndex) {
        return new PageRequest(pageIndex, pagesize );
    }
    
    
    protected ResponseList<DCategory> populatePages(final Collection<DCategory> items, final int pageSize, final String cursorKey, final Integer totalCount) {

        if (items == null || items.isEmpty()) {
            return new ResponseList<DCategory>(items);
        }

        int total = totalCount;

        if ("0".equals(cursorKey) && items.size() < pageSize) {
            total = items.size();
        }

        // limit = data.size();
        logger.debug(" total records count : {} : Integer.parseInt(cursorKey) + items.size() : {} ", total,
                Integer.parseInt(cursorKey) + items.size());
        String nextCursorKey = null;

        if (items.size() == pageSize && Integer.parseInt(cursorKey) + items.size() < total) {
            nextCursorKey = String.format("%s", Integer.parseInt(cursorKey) + items.size());
        }

        logger.debug("next cursorKey {}", nextCursorKey);

        final ResponseList<DCategory> page = new ResponseList<DCategory>(items, nextCursorKey);
        page.withTotal(total).withLimit(items.size());

        // populate previous
        if (!"0".equals(cursorKey)) {
            final int previousCursor = Math.abs(Integer.parseInt(cursorKey) - pageSize);
            page.withReverseCursor(String.format("%s", previousCursor));
        }

        return page;
    }

}
