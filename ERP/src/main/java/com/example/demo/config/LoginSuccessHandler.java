package com.example.demo.config;

import com.example.demo.Domain.Employees;
import com.example.demo.Service.HRMService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

    private final HRMService hrmService;

    public LoginSuccessHandler(HRMService hrmService) {
        this.hrmService = hrmService;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication)
            throws IOException, ServletException {

        // 로그인한 사용자의 emp_num (UserDetailsServiceImpl에서 setUsername으로 설정한 값)
        String emp_num = authentication.getName();

        // employees 테이블에서 직원 정보 조회
        Employees emp = hrmService.getEmployeeById(emp_num);

        if (emp != null) {
            HttpSession session = request.getSession();
            session.setAttribute("loginName",    emp.getName());      // 이름
            session.setAttribute("loginEmpNum",  emp.getEmp_num());   // 사원번호
            session.setAttribute("loginPosition",emp.getPosition());  // 직책
            session.setAttribute("loginProfile", emp.getProfile());   // 프로필 사진 경로
        }

        response.sendRedirect("/MainPage");
    }
}
