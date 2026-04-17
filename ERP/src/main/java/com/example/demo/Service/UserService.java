package com.example.demo.Service;

import java.util.List;

import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.demo.Domain.Employees;
import com.example.demo.Domain.User;
import com.example.demo.mapper.UserMapper;

@Service
public class UserService {

    private final UserMapper      userMapper;
    private final PasswordEncoder passwordEncoder;
    private final HRMService      hrmService;

    UserService(UserMapper userMapper, PasswordEncoder passwordEncoder, HRMService hrmService) {
        this.userMapper      = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.hrmService      = hrmService;
    }

    // 전체 사용자 조회
    public List<User> getAllUsers() {
        return userMapper.findAll();
    }

    // emp_num 기준 사용자 조회
    public User getUserById(String emp_num) {
        Employees emp = hrmService.getEmployeeById(emp_num);
        if (emp == null) return null;
        return userMapper.findById(emp.getId());
    }

    // 활성/비활성 토글
    public void toggleUserActive(Long id) {
        User user = userMapper.findById(id);
        if (user != null) {
            int newStatus = (user.getIs_active() == 1 ? 0 : 1);
            userMapper.updateUserActive(id, newStatus);
        }
    }

    // 로그인 검증
    public boolean login(String emp_num_or_userId, String rawPassword) {
        Employees emp = hrmService.getEmployeeById(emp_num_or_userId);
        User user = null;
        if (emp != null) {
            user = userMapper.findById(emp.getId());
        } else {
            user = userMapper.findByEmpNum(emp_num_or_userId);
        }
        if (user == null) return false;
        if (user.getIs_active() != 1) return false;
        return BCrypt.checkpw(rawPassword, user.getUser_pw());
    }

    // 관리자 인증 (payroll/auth, users/auth 공통으로 사용)
    public boolean authenticate(String userId, String rawPw) {
        return login(userId, rawPw);
    }

    // 로그인 후 User 객체 반환
    public User loginAndGetUser(String emp_num_or_userId, String rawPassword) {
        Employees emp = hrmService.getEmployeeById(emp_num_or_userId);
        User user = null;
        if (emp != null) {
            user = userMapper.findById(emp.getId());
        } else {
            user = userMapper.findByEmpNum(emp_num_or_userId);
        }
        if (user == null) return null;
        if (user.getIs_active() != 1) throw new RuntimeException("비활성화된 계정입니다.");
        if (BCrypt.checkpw(rawPassword, user.getUser_pw())) return user;
        return null;
    }

    // ERP 계정 등록
    public void registerByEmployee(String emp_num, String user_pw) {
        Employees emp = hrmService.getEmployeeById(emp_num);
        if (emp == null) throw new RuntimeException("존재하지 않는 직원입니다.");
        if (userMapper.findById(emp.getId()) != null) throw new RuntimeException("이미 계정이 존재하는 직원입니다.");

        User user = new User();
        user.setId(emp.getId());           // users.id = employees.id
        user.setUser_pw(passwordEncoder.encode(user_pw));
        user.setIs_active(1);
        userMapper.save(user);
    }

    // 비밀번호 변경
    public void changePassword(String emp_num, String new_pw) {
        Employees emp = hrmService.getEmployeeById(emp_num);
        if (emp == null) throw new RuntimeException("존재하지 않는 직원입니다.");
        User user = userMapper.findById(emp.getId());
        if (user == null) throw new RuntimeException("계정이 존재하지 않는 직원입니다.");
        userMapper.updatePassword(emp.getId(), passwordEncoder.encode(new_pw));
    }

    // ERP 계정만 삭제 (employees는 유지)
    public void deleteUserAccount(String emp_num) {
        Employees emp = hrmService.getEmployeeById(emp_num);
        if (emp == null) throw new RuntimeException("존재하지 않는 직원입니다.");
        userMapper.deleteById(emp.getId());
    }

    /* ===== 페이징 사용자 조회 ===== */
    public List<User> getUsersWithPaging(int offset, int size) {
        return userMapper.findWithPaging(offset, size);
    }

    /* ===== 전체 사용자 수 ===== */
    public int countUsers() {
        return userMapper.count();
    }

    // 중복 체크
    public boolean existsByUserId(String emp_num) {
        Employees emp = hrmService.getEmployeeById(emp_num);
        if (emp == null) return false;
        return userMapper.findById(emp.getId()) != null;
    }
}