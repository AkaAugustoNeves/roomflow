package com.roomflow.core.service;

import java.util.List;

public interface IBaseService<E> {
    
    List<E> getAll();
    E getById(Long id);

}
