package com.roomflow.core.dao;

import java.util.List;

import com.roomflow.core.model.BaseEntity;

public interface IBaseDAO<E extends BaseEntity> {
    
    List<E> getAll();

}
