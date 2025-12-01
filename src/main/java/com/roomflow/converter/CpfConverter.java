package com.roomflow.converter;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;

@FacesConverter("cpfConverter")
public class CpfConverter implements Converter {

    @Override
    public Object getAsObject(FacesContext context, UIComponent component, String value) {
        if (value == null || value.isEmpty()) {
            return null;
        }
        return value.replaceAll("[^0-9]", "");
    }

    @Override
    public String getAsString(FacesContext context, UIComponent component, Object value) {
        if (value == null || value.toString().isEmpty()) {
            return "";
        }
        
        String cpf = value.toString().replaceAll("[^0-9]", "");
        if (cpf.length() == 11) {
            return cpf.substring(0, 3) + "." + 
                   cpf.substring(3, 6) + "." + 
                   cpf.substring(6, 9) + "-" + 
                   cpf.substring(9, 11);
        }
        
        return cpf;
    }
}
