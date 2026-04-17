package com.example.demo.controller;

import com.example.demo.Domain.Notice;
import com.example.demo.Service.NoticeService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/notice")
public class NoticeController {

    private final NoticeService noticeService;

    public NoticeController(NoticeService noticeService) {
        this.noticeService = noticeService;
    }

    // ============================================================
    // 공지 목록 페이지 (페이징 + 중요도 필터)
    // ============================================================
    @GetMapping
    public String list(Model model,
                       @RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "10") int size,
                       @RequestParam(required = false) String importance) {
        int offset     = (page - 1) * size;
        int total      = noticeService.getCount(importance);
        int totalPages = (int) Math.ceil((double) total / size);
        if (totalPages == 0) totalPages = 1;

        model.addAttribute("list",             noticeService.getPaged(importance, offset, size));
        model.addAttribute("currentPage",      page);
        model.addAttribute("totalPages",       totalPages);
        model.addAttribute("totalCount",       total);
        model.addAttribute("size",             size);
        model.addAttribute("selectedImportance", importance);
        return "Notice/notice";
    }

    // ============================================================
    // 단건 조회 (모달용 JSON)
    // ============================================================
    @GetMapping("/{id}")
    @ResponseBody
    public Notice getOne(@PathVariable Long id) {
        return noticeService.getById(id);
    }

    // ============================================================
    // 헤더 드롭다운용 최근 5개 + 뱃지 수 (JSON)
    // ============================================================
    @GetMapping("/recent")
    @ResponseBody
    public java.util.Map<String, Object> recent() {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        result.put("list",  noticeService.getRecent(5));
        result.put("count", noticeService.getRecentCount());
        return result;
    }

    // ============================================================
    // 등록
    // ============================================================
    @PostMapping("/register")
    public String register(@ModelAttribute Notice notice, HttpSession session) {
        String writer = (String) session.getAttribute("loginName");
        notice.setWriter(writer != null ? writer : "관리자");
        noticeService.register(notice);
        return "redirect:/notice";
    }

    // ============================================================
    // 수정
    // ============================================================
    @PostMapping("/update")
    public String update(@ModelAttribute Notice notice) {
        noticeService.modify(notice);
        return "redirect:/notice";
    }

    // ============================================================
    // 삭제
    // ============================================================
    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id) {
        noticeService.remove(id);
        return "redirect:/notice";
    }
}
