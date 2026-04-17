package com.example.demo.Service;

import com.example.demo.Domain.OCRResult;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class OCRService {

    @Value("${clova.ocr.url}")
    private String ocrUrl;

    @Value("${clova.ocr.secret}")
    private String secretKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper  = new ObjectMapper();

    public OCRResult analyzeReceipt(MultipartFile imageFile) {
        try {
            String ext = getExtension(imageFile.getOriginalFilename());

            String messageJson = "{"
                + "\"version\":\"V2\","
                + "\"requestId\":\"" + UUID.randomUUID() + "\","
                + "\"timestamp\":" + System.currentTimeMillis() + ","
                + "\"images\":[{\"format\":\"" + ext + "\",\"name\":\"receipt\"}]"
                + "}";

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("message", messageJson);
            ByteArrayResource fileResource = new ByteArrayResource(imageFile.getBytes()) {
                @Override public String getFilename() { return imageFile.getOriginalFilename(); }
            };
            body.add("file", fileResource);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);
            headers.set("X-OCR-SECRET", secretKey);

            ResponseEntity<String> response = restTemplate.postForEntity(
                ocrUrl, new HttpEntity<>(body, headers), String.class);

            if (response.getStatusCode() != HttpStatus.OK) {
                return OCRResult.fail("OCR API 오류: " + response.getStatusCode());
            }

            return parseFields(response.getBody());

        } catch (Exception e) {
            e.printStackTrace();
            return OCRResult.fail("OCR 처리 중 오류: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────
    // fields 배열 전체 텍스트 수집 후 패턴으로 추출
    // ─────────────────────────────────────────────────────────
    private OCRResult parseFields(String json) {
        try {
            JsonNode root   = objectMapper.readTree(json);
            JsonNode images = root.path("images");
            if (images.isMissingNode() || images.isEmpty()) {
                return OCRResult.fail("인식된 내용이 없습니다.");
            }

            JsonNode image = images.get(0);

            // ── 모든 inferText 수집 ──────────────────────────
            JsonNode fields = image.path("fields");
            List<String> texts = new ArrayList<>();
            if (fields.isArray()) {
                for (JsonNode f : fields) {
                    String t = f.path("inferText").asText("").trim();
                    if (!t.isEmpty()) texts.add(t);
                }
            }

            System.out.println("=== OCR FIELDS: " + texts + " ===");

            // ── 1. 가맹점명: 첫 번째 텍스트 ─────────────────
            String storeName = texts.isEmpty() ? "" : texts.get(0);

            // ── 2. 날짜: yyyy-MM-dd 또는 yyyy.MM.dd 패턴 ────
            String date = "";
            Pattern datePattern = Pattern.compile(
                "(20\\d{2})[.\\-/](0?[1-9]|1[0-2])[.\\-/](0?[1-9]|[12]\\d|3[01])");
            for (String t : texts) {
                Matcher m = datePattern.matcher(t);
                if (m.find()) {
                    date = m.group(1)
                         + "-" + padTwo(m.group(2))
                         + "-" + padTwo(m.group(3));
                    break;
                }
            }

            // ── 3. 금액: 우선순위대로 탐색 ───────────────────
            int amount = 0;

            // 우선순위 1: "받을금액" 바로 다음 숫자
            amount = findAmountAfterKeyword(texts, "받을금액:");
            // 우선순위 2: "매출금액" 바로 다음 숫자
            if (amount == 0) amount = findAmountAfterKeyword(texts, "매출금액:");
            // 우선순위 3: "판매총액" 바로 다음 숫자
            if (amount == 0) amount = findAmountAfterKeyword(texts, "판매총액:");
            // 우선순위 4: "합계" 바로 다음 숫자
            if (amount == 0) amount = findAmountAfterKeyword(texts, "합계");
            // 우선순위 5: 가장 큰 금액 (최후 수단)
            if (amount == 0) amount = findLargestAmount(texts);

            System.out.println("=== OCR PARSED: storeName=" + storeName
                + ", date=" + date + ", amount=" + amount + " ===");

            return OCRResult.success(storeName, date, amount);

        } catch (Exception e) {
            e.printStackTrace();
            return OCRResult.fail("응답 파싱 오류: " + e.getMessage());
        }
    }

    // ── 키워드 바로 다음 항목에서 금액 추출 ─────────────────
    private int findAmountAfterKeyword(List<String> texts, String keyword) {
        for (int i = 0; i < texts.size() - 1; i++) {
            if (texts.get(i).contains(keyword)) {
                // 같은 텍스트 안에 숫자가 있으면 바로 추출
                int inSame = parseAmount(texts.get(i));
                if (inSame > 0) return inSame;
                // 다음 텍스트에서 추출
                return parseAmount(texts.get(i + 1));
            }
        }
        return 0;
    }

    // ── 전체 텍스트 중 가장 큰 금액 ─────────────────────────
    private int findLargestAmount(List<String> texts) {
        int max = 0;
        Pattern p = Pattern.compile("^[\\d,]+원?$");
        for (String t : texts) {
            if (p.matcher(t.trim()).matches()) {
                int v = parseAmount(t);
                if (v > max) max = v;
            }
        }
        return max;
    }

    // ── 금액 문자열 → 숫자 ──────────────────────────────────
    private int parseAmount(String text) {
        String digits = text.replaceAll("[^0-9]", "");
        if (digits.isEmpty() || digits.length() > 9) return 0;
        try { return Integer.parseInt(digits); } catch (Exception e) { return 0; }
    }

    private String getExtension(String filename) {
        if (filename == null) return "jpg";
        int dot = filename.lastIndexOf('.');
        return dot < 0 ? "jpg" : filename.substring(dot + 1).toLowerCase();
    }

    private String padTwo(String s) {
        if (s == null || s.isEmpty()) return "01";
        return s.length() == 1 ? "0" + s : s;
    }
}