package com.example.demo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import jakarta.servlet.DispatcherType;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final LoginSuccessHandler loginSuccessHandler;

    public SecurityConfig(LoginSuccessHandler loginSuccessHandler) {
        this.loginSuccessHandler = loginSuccessHandler;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .dispatcherTypeMatchers(DispatcherType.FORWARD).permitAll()
                .requestMatchers("/login", "/regist", "/css/**", "/images/**", "/ocr/**").permitAll()
                // 공지 등록/수정/삭제 → 점장/스탭만
                .requestMatchers("/notice/register", "/notice/update", "/notice/delete/**")
                    .hasAnyRole("OWNER")
                // 공지 조회 → 전체 인증 사용자
                .requestMatchers("/notice", "/notice/**").authenticated()
                // ERP 사용자 관리
                .requestMatchers("/hr/users/**").hasAnyRole("OWNER")
                // 분석용 API — Python(FastAPI) 내부 호출이므로 인증 제외
                .requestMatchers("/api/**").permitAll()
                // FastAPI → Spring 결과 수신 엔드포인트 — 인증 제외
                .requestMatchers("/analysis/journal", "/analysis/statement",
                                 "/analysis/forecast/result", "/analysis/inventory/result",
                                 "/analysis/ai-report/result",
                                 "/analysis/excel/register", "/api/revenue/excel-available").permitAll()
                .anyRequest().authenticated()
            )
            .formLogin(login -> login
                .loginPage("/login")
                .loginProcessingUrl("/login")
                .successHandler(loginSuccessHandler)
                .failureHandler((request, response, exception) -> {
                    String errorMsg = "아이디 또는 비밀번호 오류";
                    if (exception instanceof org.springframework.security.authentication.DisabledException) {
                        errorMsg = "비활성화된 계정입니다.";
                    }
                    request.getSession().setAttribute("loginError", errorMsg);
                    response.sendRedirect("/login");
                })
                .permitAll()
            )
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/")
            );
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}