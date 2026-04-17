package com.example.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.demo.Service.HRMService;
import com.example.demo.Service.UserService;

import jakarta.servlet.http.HttpSession;

@Controller
public class UserController {
	private final UserService userService;
	private final HRMService hrmService;

	UserController(UserService userService, HRMService hrmService) {
		this.userService = userService;
		this.hrmService = hrmService;
	}

	// 로그인 폼
	@GetMapping({ "/", "/login" })
	public String loginForm() {
		return "login"; // JSP 그대로 사용
	}

	// 로그아웃 처리
	@GetMapping("/logout")
	public String logout(HttpSession session) {
		session.invalidate(); // ✅ 세션 초기화
		return "redirect:/login";
	}

}