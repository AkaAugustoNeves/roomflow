package com.roomflow.dao;

import com.roomflow.core.dao.BaseDAO;
import com.roomflow.model.Usuario;

public class UsuarioDAO extends BaseDAO<Usuario> {

    public UsuarioDAO() {
        super(Usuario.class);
    }

}
