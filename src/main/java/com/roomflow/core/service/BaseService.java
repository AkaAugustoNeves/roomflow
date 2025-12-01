package com.roomflow.core.service;

import java.util.List;
import com.roomflow.core.dao.BaseDAO;
import com.roomflow.core.model.BaseEntity;

public abstract class BaseService<E extends BaseEntity, DAO extends BaseDAO<E>> implements IBaseService<E> {
    
    private DAO DAO;

    public BaseService(DAO DAO) {
        this.DAO = DAO;
    }

    @Override
    public List<E> getAll() {
        return DAO.getAll();
    }

    @Override
    public E getById(Long id) {
        return DAO.getById(id);
    }

    @Override
    public E create(E entity) {
        beforeCreate(entity);
        return DAO.create(entity);
    }
    
    public void beforeCreate(E entity) {}
    
}
