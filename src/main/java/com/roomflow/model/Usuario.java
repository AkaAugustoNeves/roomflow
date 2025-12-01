package com.roomflow.model;

import com.roomflow.core.model.BaseEntity;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "USUARIO")
public class Usuario extends BaseEntity {

    @Column(name = "NOME", nullable = false, length = 200)
    private String nome;

    @Column(name = "EMAIL", nullable = false, length = 100, unique = true)
    private String email;

    @Column(name = "CPF", nullable = false, length = 11, unique = true)
    private String cpf;

    @Column(name = "PERIODO_CADASTRO", nullable = false)
    private LocalDateTime periodoCadastro;

    public Usuario() {
        super();
    }

    public Usuario(String nome, String email, String cpf, LocalDateTime periodoCadastro) {
        this.nome = nome;
        this.email = email;
        this.cpf = cpf;
        this.periodoCadastro = periodoCadastro;
    }

    @PrePersist
    private void prePersistUsuario() {
        if (this.periodoCadastro == null) {
            this.periodoCadastro = LocalDateTime.now();
        }
    }

    // Getters and Setters
    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public LocalDateTime getPeriodoCadastro() {
        return periodoCadastro;
    }

    public void setPeriodoCadastro(LocalDateTime periodoCadastro) {
        this.periodoCadastro = periodoCadastro;
    }

    @Override
    public String toString() {
        return "Usuario{" +
                "id=" + getId() +
                ", nome='" + nome + '\'' +
                ", email='" + email + '\'' +
                ", cpf='" + cpf + '\'' +
                ", periodoCadastro=" + periodoCadastro +
                ", dataCadastro=" + getDataCadastro() +
                '}';
    }
}
