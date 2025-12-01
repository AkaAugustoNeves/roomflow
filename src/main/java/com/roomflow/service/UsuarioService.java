package com.roomflow.service;

import com.roomflow.core.service.BaseService;
import com.roomflow.dao.UsuarioDAO;
import com.roomflow.model.Usuario;

public class UsuarioService extends BaseService<Usuario, UsuarioDAO> {

    public UsuarioService() {
        super(new UsuarioDAO());
    }
    
}
