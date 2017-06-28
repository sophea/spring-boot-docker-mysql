package com.sma.springboot.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sma.springboot.domain.DCategory;

@Repository
public interface CategoryRepository extends JpaRepository<DCategory, Long> {

}
