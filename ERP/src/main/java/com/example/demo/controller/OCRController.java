package com.example.demo.controller;

import com.example.demo.Domain.OCRResult;
import com.example.demo.Service.OCRService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/ocr")
public class OCRController {

    private final OCRService ocrService;

    public OCRController(OCRService ocrService) {
        this.ocrService = ocrService;
    }

    /**
     * POST /ocr/analyze
     * F_register.jsp 에서 영수증 이미지 업로드 시 호출
     * 응답: OcrResult JSON
     */
    @PostMapping("/analyze")
    public ResponseEntity<OCRResult> analyze(@RequestParam("image") MultipartFile image) {
        if (image == null || image.isEmpty()) {
            return ResponseEntity.badRequest().body(OCRResult.fail("파일이 없습니다."));
        }
        OCRResult result = ocrService.analyzeReceipt(image);
        return ResponseEntity.ok(result);
    }
}