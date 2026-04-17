package com.example.demo.Service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.example.demo.Domain.Attendances;
import com.example.demo.Domain.Employees;
import com.example.demo.mapper.HRMMapper;

@Service
public class HRMService {

    private final HRMMapper hrmMapper;

    public HRMService(HRMMapper hrmMapper) {
        this.hrmMapper = hrmMapper;
    }

    // npm_num 기준 직원 조회
    public Employees getEmployeeByNpmNum(String npmNum) {
        return hrmMapper.selectEmployeeByNpmNum(npmNum);
    }

    // 전체 직원 조회
    public List<Employees> getAllEmployees() {
        return hrmMapper.selectAllEmployees();
    }

    // 프로필 사진 업데이트
    public void updateProfile(String empNum, String profile) {
        hrmMapper.updateProfile(empNum, profile);
    }

    // 단일 직원 조회
    public Employees getEmployeeById(String emp_num) {
        return hrmMapper.selectEmployeeById(emp_num);
    }

    // 직원 검색
    public List<Employees> searchEmployees(String name, String position, Integer isActive) {
        return hrmMapper.searchEmployees(name, position, isActive);
    }

    // 달력 근태 조회
    public List<Attendances> getAttendanceByDate(String date) {
        return hrmMapper.getAttendanceByDate(date);
    }

    // 달력 월별 출근 집계
    public List<Map<String, Object>> getAttendanceCountByMonth(int year, int month) {
        return hrmMapper.getAttendanceCountByMonth(year, month);
    }

    // 직원 등록
    public void addEmployee(Employees employee) {
        hrmMapper.insertEmployee(employee);
    }

    // 직원 정보 수정
    public void updateEmployee(Employees employee) {
        hrmMapper.updateEmployee(employee);
    }

    /**
     * 직원 삭제 (FK 순서 고려)
     * users.id      → employees.id  (FK)
     * attendances.employee_id → employees.id  (FK)
     *
     * 삭제 순서:
     * 1. employees.id 조회
     * 2. users 삭제       (employees 참조)
     * 3. attendances 삭제 (employees 참조)
     * 4. employees 삭제
     */
    public void deleteEmployee(String emp_num) {
        Long employeeId = hrmMapper.selectEmployeeIdByEmpNum(emp_num);

        if (employeeId != null) {
            hrmMapper.deleteUserByEmployeeId(employeeId);       // 2. users 먼저
            hrmMapper.deleteAttendancesByEmployeeId(employeeId); // 3. attendances
        }

        hrmMapper.deleteEmployee(emp_num); // 4. employees
    }

    // 근태 상세 페이지 데이터
    public List<Map<String, Object>> getAttendanceWithEmployees(String date) {
        return hrmMapper.getAttendanceWithEmployees(date);
    }

    // 근태 상세 페이징
    public List<Map<String, Object>> getAttendanceWithEmployeesPaged(String date, int offset, int size) {
        return hrmMapper.getAttendanceWithEmployeesPaged(date, offset, size);
    }

    // 근태 상세 전체 인원 수
    public int countAttendanceWithEmployees(String date) {
        return hrmMapper.countAttendanceWithEmployees(date);
    }

    /* ===== 페이징 직원 조회 ===== */
    public List<Employees> searchEmployeesWithPaging(String name, String position,
            Integer isActive, int offset, int size) {
        return hrmMapper.searchEmployeesWithPaging(name, position, isActive, offset, size);
    }

    /* ===== 전체 개수 조회 ===== */
    public int countEmployees(String name, String position, Integer isActive) {
        return hrmMapper.countEmployees(name, position, isActive);
    }

    // 근태 저장 (insert or update)
    public void saveOrUpdate(Attendances a) {
        int count = hrmMapper.existsAttendance(a.getEmployee_id(), a.getWork_date());
        if (count == 0) {
            hrmMapper.insertAttendance(a);
        } else {
            hrmMapper.updateAttendance(a);
        }
    }
}