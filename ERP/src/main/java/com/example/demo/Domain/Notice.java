package com.example.demo.Domain;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Notice {

    private Long          id;
    private String        title;
    private String        content;
    private String        importance;  // normal / important / urgent
    private String        writer;
    private int           is_active;
    private LocalDateTime created_at;
    private LocalDateTime updated_at;

    // 날짜 포맷 getter
    public String getCreatedAtFormatted() {
        if (created_at == null) return "";
        return created_at.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }
    
    public String getUpdatedAtFormatted() {
        if (updated_at == null) return "";
        return updated_at.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }

    // 수정 여부 확인 (created_at과 updated_at이 다르면 수정된 것)
    public boolean isModified() {
        if (created_at == null || updated_at == null) return false;
        return updated_at.isAfter(created_at.plusSeconds(1));
    }

    // 중요도 한글 getter
    public String getImportanceLabel() {
        if (importance == null) return "일반";
        switch (importance) {
            case "urgent":    return "긴급";
            case "important": return "중요";
            default:          return "일반";
        }
    }

    public Long          getId()                         { return id; }
    public void          setId(Long id)                  { this.id = id; }
    public String        getTitle()                      { return title; }
    public void          setTitle(String title)          { this.title = title; }
    public String        getContent()                    { return content; }
    public void          setContent(String content)      { this.content = content; }
    public String        getImportance()                 { return importance; }
    public void          setImportance(String importance){ this.importance = importance; }
    public String        getWriter()                     { return writer; }
    public void          setWriter(String writer)        { this.writer = writer; }
    public int           getIs_active()                  { return is_active; }
    public void          setIs_active(int is_active)     { this.is_active = is_active; }
    public LocalDateTime getCreated_at()                 { return created_at; }
    public void          setCreated_at(LocalDateTime v)  { this.created_at = v; }
    public LocalDateTime getUpdated_at()                 { return updated_at; }
    public void          setUpdated_at(LocalDateTime v)  { this.updated_at = v; }
}
