package com.example.demo.Service;

import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.example.demo.Domain.Employees;
import com.example.demo.Domain.User;
import com.example.demo.mapper.UserMapper;

/**
 * 로그인 흐름:
 * 사용자 입력(emp_num) → employees 조회 → users.id로 계정 조회 → 비밀번호/권한 반환
 *
 * Role 매핑 (SecurityConfig의 hasAnyRole과 맞춰야 함):
 *   점장  → ROLE_MANAGER  → hasRole("MANAGER")
 *   스탭  → ROLE_STAFF    → hasRole("STAFF")
 *   매니저 → ROLE_USER    → hasRole("USER")
 */
@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserMapper userMapper;
    private final HRMService hrmService;

    public UserDetailsServiceImpl(UserMapper userMapper, HRMService hrmService) {
        this.userMapper  = userMapper;
        this.hrmService  = hrmService;
    }

    @Override
    public UserDetails loadUserByUsername(String emp_num) throws UsernameNotFoundException {

        // 1. emp_num → 직원 조회
        Employees emp = hrmService.getEmployeeById(emp_num);
        if (emp == null) {
            throw new UsernameNotFoundException("존재하지 않는 직원: " + emp_num);
        }

        // 2. 직원 id → users 조회
        User user = userMapper.findById(emp.getId());
        if (user == null) {
            throw new UsernameNotFoundException("계정이 없는 직원: " + emp_num);
        }

        // 3. 비활성 계정 차단
        if (user.getIs_active() != 1) {
            throw new DisabledException("비활성 계정");
        }

        // 4. 직위 → Role 매핑
        String role = resolveRole(emp.getPosition());

        // 5. UserDetails 생성
        return org.springframework.security.core.userdetails.User
                .withUsername(emp.getEmp_num())
                .password(user.getUser_pw())
                .roles(role)
                .build();
    }

    /**
     * 직위 → Spring Security Role 매핑
     * 점장  → MANAGER  (/hr/users/** 접근 가능)
     * 스탭  → STAFF    (/hr/users/** 접근 가능)
     * 매니저 → USER    (/hr/users/** 접근 불가)
     */
    private String resolveRole(String position) {
        if (position == null) return "USER";
        switch (position) {
            case "점장": return "MANAGER";
            case "스탭": return "STAFF";
            default:    return "USER";
        }
    }
}