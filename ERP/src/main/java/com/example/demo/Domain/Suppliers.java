package com.example.demo.Domain;

import java.time.LocalDateTime;

public class Suppliers {
    private long          id;
    private String        supplier_name;
    private String        supplier_type;
    private String        ceo_name;
    private String        address;
    private String        contract_file;
    private String        note;
    private int           is_active;
    private LocalDateTime created_at;

    public long          getId()                                    { return id; }
    public void          setId(long id)                             { this.id = id; }
    public String        getSupplier_name()                         { return supplier_name; }
    public void          setSupplier_name(String supplier_name)     { this.supplier_name = supplier_name; }
    public String        getSupplier_type()                         { return supplier_type; }
    public void          setSupplier_type(String supplier_type)     { this.supplier_type = supplier_type; }
    public String        getCeo_name()                              { return ceo_name; }
    public void          setCeo_name(String ceo_name)               { this.ceo_name = ceo_name; }
    public String        getAddress()                               { return address; }
    public void          setAddress(String address)                 { this.address = address; }
    public String        getContract_file()                         { return contract_file; }
    public void          setContract_file(String contract_file)     { this.contract_file = contract_file; }
    public String        getNote()                                  { return note; }
    public void          setNote(String note)                       { this.note = note; }
    public int           getIs_active()                             { return is_active; }
    public void          setIs_active(int is_active)                { this.is_active = is_active; }
    public LocalDateTime getCreated_at()                            { return created_at; }
    public void          setCreated_at(LocalDateTime created_at)    { this.created_at = created_at; }
}