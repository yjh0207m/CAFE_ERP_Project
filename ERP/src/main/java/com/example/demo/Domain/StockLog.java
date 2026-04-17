package com.example.demo.Domain;

import java.time.LocalDateTime;

public class StockLog {
    private Long          id;
    private long          ingredient_id;
    private String        change_type;   // in / out / adjust
    private double        change_qty;    // 변동 수량 (항상 양수)
    private double        before_qty;    // 변동 전 재고량
    private double        after_qty;     // 변동 후 재고량
    private String        ref_type;      // order / purchase / adjust
    private Long          ref_id;        // 참조 레코드 ID
    private String        note;
    private LocalDateTime created_at;

    public Long          getId()                          { return id; }
    public void          setId(Long id)                   { this.id = id; }
    public long          getIngredient_id()               { return ingredient_id; }
    public void          setIngredient_id(long v)         { this.ingredient_id = v; }
    public String        getChange_type()                 { return change_type; }
    public void          setChange_type(String v)         { this.change_type = v; }
    public double        getChange_qty()                  { return change_qty; }
    public void          setChange_qty(double v)          { this.change_qty = v; }
    public double        getBefore_qty()                  { return before_qty; }
    public void          setBefore_qty(double v)          { this.before_qty = v; }
    public double        getAfter_qty()                   { return after_qty; }
    public void          setAfter_qty(double v)           { this.after_qty = v; }
    public String        getRef_type()                    { return ref_type; }
    public void          setRef_type(String v)            { this.ref_type = v; }
    public Long          getRef_id()                      { return ref_id; }
    public void          setRef_id(Long v)                { this.ref_id = v; }
    public String        getNote()                        { return note; }
    public void          setNote(String v)                { this.note = v; }
    public LocalDateTime getCreated_at()                  { return created_at; }
    public void          setCreated_at(LocalDateTime v)   { this.created_at = v; }
}
