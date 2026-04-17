package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.demo.Domain.User;

@Mapper
public interface UserMapper {

    // PK 기준 사용자 조회
    User findById(@Param("id") Long id);

    // emp_num 기준 단일 조회
    User findByEmpNum(@Param("emp_num") String emp_num);

    // 전체 조회
    List<User> findAll();

    // 활성/비활성 토글
    int updateUserActive(@Param("id") Long id, @Param("is_active") int is_active);

    // 비밀번호 변경
    void updatePassword(@Param("id") Long id, @Param("user_pw") String user_pw);

    // 신규 사용자 저장 (쿼리는 User.xml)
    void save(User user);

    // 계정 삭제 (쿼리는 User.xml)
    void deleteById(@Param("id") Long id);

    /* ===== 페이징 조회 ===== */
    List<User> findWithPaging(@Param("offset") int offset, @Param("size") int size);

    /* ===== 전체 개수 ===== */
    int count();
}