package com.roomflow.core.dao;

import com.roomflow.core.model.BaseEntity;
import com.roomflow.util.JPAUtil;

import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Root;
import java.util.List;

public abstract class BaseDAO<E extends BaseEntity> implements IBaseDAO<E> {

    private final Class<E> entityClass;

    public BaseDAO(Class<E> entityClass) {
        this.entityClass = entityClass;
    }

    @Override
    public List<E> getAll() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            CriteriaBuilder cb = em.getCriteriaBuilder();
            CriteriaQuery<E> cq = cb.createQuery(entityClass);
            Root<E> root = cq.from(entityClass);
            cq.select(root);
            TypedQuery<E> query = em.createQuery(cq);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    protected EntityManager getEntityManager() {
        return JPAUtil.getEntityManager();
    }
}
