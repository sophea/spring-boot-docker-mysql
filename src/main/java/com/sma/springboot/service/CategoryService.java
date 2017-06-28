package com.sma.springboot.service;

import com.sma.springboot.domain.DCategory;
import com.sma.springboot.domain.ResponseList;

public interface CategoryService {
    Iterable<DCategory> list();
    DCategory get(Long id);
    DCategory create(DCategory dCategory);
    void delete(Long id);
    DCategory update(Long id, DCategory dCategory);
    ResponseList<DCategory> getPage(int pagesize, String cursorkey);
}
