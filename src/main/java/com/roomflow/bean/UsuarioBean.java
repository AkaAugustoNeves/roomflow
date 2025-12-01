package com.roomflow.bean;

import com.roomflow.model.Usuario;
import com.roomflow.service.UsuarioService;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.Serializable;
import java.util.List;

@ManagedBean(name = "usuarioBean")
@ViewScoped
public class UsuarioBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private UsuarioService usuarioService;
    private List<Usuario> usuarios;
    private Usuario usuarioSelecionado;

    public UsuarioBean() {
        this.usuarioService = new UsuarioService();
    }

    @PostConstruct
    public void init() {
        carregarUsuarios();
    }

    public void carregarUsuarios() {
        this.usuarios = usuarioService.getAll();
    }

    public void detalharUsuario(Usuario usuario) {
        this.usuarioSelecionado = usuario;
    }

    public List<Usuario> getUsuarios() {
        return usuarios;
    }

    public void setUsuarios(List<Usuario> usuarios) {
        this.usuarios = usuarios;
    }

    public Usuario getUsuarioSelecionado() {
        return usuarioSelecionado;
    }

    public void setUsuarioSelecionado(Usuario usuarioSelecionado) {
        this.usuarioSelecionado = usuarioSelecionado;
    }
}
