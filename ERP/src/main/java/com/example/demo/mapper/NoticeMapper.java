package com.example.demo.mapper;

import com.example.demo.Domain.Notice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NoticeMapper {
    List<Notice> findAll();                          // 전체 목록 (최신순)
    List<Notice> findPaged(@Param("importance") String importance,
                           @Param("offset") int offset,
                           @Param("size") int size);
    int countAll(@Param("importance") String importance);
    List<Notice> findRecent(@Param("limit") int limit); // 최근 N개 (헤더 드롭다운용)
    int countRecent();                               // 최근 7일 새 공지 수 (뱃지용)
    Notice findById(@Param("id") Long id);
    void insert(Notice notice);
    void update(Notice notice);
    void delete(@Param("id") Long id);              // is_active = 0
}
