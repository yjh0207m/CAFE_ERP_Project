package com.example.demo.Domain;

import java.util.List;

public class PageResult<T> {
    private List<T> list;        // 현재 페이지 데이터
    private int totalCount;      // 전체 데이터 수
    private int page;            // 현재 페이지
    private int size;            // 페이지당 항목 수
    private int totalPages;      // 전체 페이지 수
    private int startPage;       // 페이지 블록 시작
    private int endPage;         // 페이지 블록 끝

    public PageResult(List<T> list, int totalCount, PageRequest req) {
        this.list       = list;
        this.totalCount = totalCount;
        this.page       = req.getPage();
        this.size       = req.getSize();
        this.totalPages = (int) Math.ceil((double) totalCount / size);
        if (this.totalPages == 0) this.totalPages = 1;

        // 페이지 블록 (5개씩)
        int block      = 5;
        this.startPage = ((page - 1) / block) * block + 1;
        this.endPage   = Math.min(startPage + block - 1, totalPages);
    }

    public List<T> getList()       { return list; }
    public int getTotalCount()     { return totalCount; }
    public int getPage()           { return page; }
    public int getSize()           { return size; }
    public int getTotalPages()     { return totalPages; }
    public int getStartPage()      { return startPage; }
    public int getEndPage()        { return endPage; }

    public boolean hasPrev()       { return startPage > 1; }
    public boolean hasNext()       { return endPage < totalPages; }
}