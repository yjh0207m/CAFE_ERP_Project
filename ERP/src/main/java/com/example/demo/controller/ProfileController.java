package com.example.demo.controller;

import com.example.demo.Service.HRMService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.Map;
import java.util.UUID;

@Controller
public class ProfileController {

    private final HRMService hrmService;

    public ProfileController(HRMService hrmService) {
        this.hrmService = hrmService;
    }

    /**
     * 사이드바 프로필 사진 변경
     * - 파일 저장 → DB 업데이트 → 세션 갱신
     */
    @PostMapping("/profile/update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateProfile(
            @RequestParam("file") MultipartFile file,
            HttpSession session) {

        String empNum = (String) session.getAttribute("loginEmpNum");
        if (empNum == null || empNum.equals("-")) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "로그인 정보를 찾을 수 없습니다."));
        }

        if (file == null || file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "파일이 없습니다."));
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "이미지 파일만 업로드 가능합니다."));
        }

        try {
            String uploadDir = System.getProperty("user.dir") + "/src/main/resources/static/uploads/profiles/";
            new File(uploadDir).mkdirs();

            String originalName = file.getOriginalFilename();
            String ext = (originalName != null && originalName.contains("."))
                    ? originalName.substring(originalName.lastIndexOf('.'))
                    : ".jpg";
            String savedName = UUID.randomUUID().toString() + ext;

            file.transferTo(new File(uploadDir + savedName));
            String profilePath = "/uploads/profiles/" + savedName;

            hrmService.updateProfile(empNum, profilePath);
            session.setAttribute("loginProfile", profilePath);

            return ResponseEntity.ok(Map.of("success", true, "path", profilePath));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of("success", false, "message", "업로드 중 오류가 발생했습니다."));
        }
    }
}
