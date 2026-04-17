package com.example.demo.Service;

import com.example.demo.Domain.Notice;
import com.example.demo.mapper.NoticeMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NoticeService {

    private final NoticeMapper noticeMapper;

    public NoticeService(NoticeMapper noticeMapper) {
        this.noticeMapper = noticeMapper;
    }

    // 전체 목록
    public List<Notice> getAll() {
        return noticeMapper.findAll();
    }

    // 페이징 목록
    public List<Notice> getPaged(String importance, int offset, int size) {
        return noticeMapper.findPaged(importance, offset, size);
    }

    // 개수 (페이징용)
    public int getCount(String importance) {
        return noticeMapper.countAll(importance);
    }

    // 최근 N개 (헤더 드롭다운)
    public List<Notice> getRecent(int limit) {
        return noticeMapper.findRecent(limit);
    }

    // 최근 7일 새 공지 수 (헤더 뱃지)
    public int getRecentCount() {
        return noticeMapper.countRecent();
    }

    // 단건 조회
    public Notice getById(Long id) {
        return noticeMapper.findById(id);
    }

    // 등록
    public void register(Notice notice) {
        noticeMapper.insert(notice);
    }

    // 수정
    public void modify(Notice notice) {
        noticeMapper.update(notice);
    }

    // 삭제
    public void remove(Long id) {
        noticeMapper.delete(id);
    }
}
