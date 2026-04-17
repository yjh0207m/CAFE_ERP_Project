package com.example.demo.mapper;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.demo.Domain.Attendances;
import com.example.demo.Domain.Employees;

@Mapper
public interface HRMMapper {

    // npm_num 기준으로 직원 가져오기
    Employees selectEmployeeByNpmNum(@Param("npm_num") String npm_num);

    // 전체 직원 조회
    List<Employees> selectAllEmployees();

    // 단일 직원 조회
    Employees selectEmployeeById(@Param("emp_num") String emp_num);

    // 재직자만 조회
    List<Employees> selectActiveEmployees();

    // 퇴사자만 조회
    List<Employees> selectResignedEmployees();

    // 직원 검색 (이름, 직책, 재직여부 필터)
    List<Employees> searchEmployees(@Param("name") String name,
                                    @Param("position") String position,
                                    @Param("is_active") Integer is_active);

    // 직원 등록
    void insertEmployee(Employees employee);

    // emp_num → employees.id 조회
    Long selectEmployeeIdByEmpNum(@Param("emp_num") String emp_num);

    // 직원 정보 수정
    void updateEmployee(Employees employee);
    void updateProfile(@Param("empNum") String empNum, @Param("profile") String profile);

    // users 삭제 (FK 해제용)
    void deleteUserByEmployeeId(@Param("employee_id") Long employee_id);

    // attendances 삭제 (FK 해제용)
    void deleteAttendancesByEmployeeId(@Param("employee_id") Long employee_id);

    // 직원 물리 삭제
    void deleteEmployee(@Param("emp_num") String emp_num);

    // 달력 근태 조회
    List<Attendances> getAttendanceByDate(String date);

    // 달력 월별 출근 집계
    List<Map<String, Object>> getAttendanceCountByMonth(@Param("year") int year,
                                                         @Param("month") int month);

    // 근태 상세 — 재직 직원 전체 + 해당 날짜 LEFT JOIN
    List<Map<String, Object>> getAttendanceWithEmployees(String date);

    // 근태 상세 페이징
    List<Map<String, Object>> getAttendanceWithEmployeesPaged(@Param("date") String date,
                                                              @Param("offset") int offset,
                                                              @Param("size") int size);

    // 근태 상세 전체 인원 수 (페이징용)
    int countAttendanceWithEmployees(String date);

    // 근태 상세 구버전
    List<Map<String, Object>> getAttendanceDetail(String date);

    // 존재 여부 확인
    int existsAttendance(@Param("employee_id") int employee_id,
                          @Param("work_date") LocalDate work_date);

    // 근태 INSERT
    void insertAttendance(Attendances a);

    // 근태 UPDATE
    void updateAttendance(Attendances a);

    /* ===== 페이징 조회 ===== */
    List<Employees> searchEmployeesWithPaging(@Param("name") String name,
                                              @Param("position") String position,
                                              @Param("is_active") Integer is_active,
                                              @Param("offset") int offset,
                                              @Param("size") int size);

    /* ===== 전체 개수 ===== */
    int countEmployees(@Param("name") String name,
                       @Param("position") String position,
                       @Param("is_active") Integer is_active);
}