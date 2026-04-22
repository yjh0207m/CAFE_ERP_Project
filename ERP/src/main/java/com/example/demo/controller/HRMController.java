package com.example.demo.controller;

import java.io.File;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import jakarta.servlet.http.HttpSession;

import com.example.demo.Domain.Attendances;
import com.example.demo.Domain.Employees;
import com.example.demo.Domain.User;
import com.example.demo.Service.HRMService;
import com.example.demo.Service.UserService;

@Controller
@RequestMapping("/hr")
public class HRMController {

	private final HRMService hrmService;
	private final UserService userService;

	public HRMController(HRMService hrmService, UserService userService) {
		this.hrmService = hrmService;
		this.userService = userService;
	}

	/* ===== 직원 목록 ===== */
	@GetMapping("/employees")
	public String listEmployees(@RequestParam(required = false, defaultValue = "all") String status,
			@RequestParam(required = false) String name, @RequestParam(required = false) String position,

			/* ===== [추가] 페이징 파라미터 ===== */
			@RequestParam(defaultValue = "1") int page, @RequestParam(defaultValue = "10") int size,

			Model model) {
		Integer isActive = null;
		if ("active".equals(status))
			isActive = 1;
		if ("leave".equals(status))
			isActive = 2;
		if ("resigned".equals(status))
			isActive = 0;

		/* ===== [추가] offset 계산 ===== */
		int offset = (page - 1) * size;

//        model.addAttribute("employees", hrmService.searchEmployees(name, position, isActive));

		/* ===== [변경] 기존 → 페이징 적용 메서드 호출 ===== */
		model.addAttribute("employees", hrmService.searchEmployeesWithPaging(name, position, isActive, offset, size));

		/* ===== [추가] 전체 개수 (페이지 계산용) ===== */
		int totalCount = hrmService.countEmployees(name, position, isActive);

		int totalPages = (int) Math.ceil((double) totalCount / size);

		/* ===== [추가] 페이지 정보 JSP 전달 ===== */
		model.addAttribute("currentPage", page);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("size", size);

		return "hr/employees";
	}

	/* ===== 직원 등록 폼 ===== */
	@GetMapping("/employees/register")
	public String registerPage(Model model) {
		model.addAttribute("employees", hrmService.getAllEmployees());
		return "hr/employees/register";
	}

	/* ===== 프로필 사진 전용 업로드 ===== */
	@PostMapping("/employees/profile-upload")
	@ResponseBody
	public ResponseEntity<Map<String, String>> uploadProfile(
			@RequestParam("file") MultipartFile file) {
		try {
			String uploadDir = System.getProperty("user.dir") + "/src/main/resources/static/uploads/profiles/";
			new File(uploadDir).mkdirs();
			String ext = file.getOriginalFilename() != null && file.getOriginalFilename().contains(".")
					? file.getOriginalFilename().substring(file.getOriginalFilename().lastIndexOf('.'))
					: ".jpg";
			String saved = UUID.randomUUID().toString() + ext;
			file.transferTo(new File(uploadDir + saved));
			return ResponseEntity.ok(Map.of("path", "/uploads/profiles/" + saved));
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.internalServerError().body(Map.of("error", "업로드 실패"));
		}
	}

	/* ===== 직원 등록 처리 ===== */
	@PostMapping("/employees/register")
	public String registerEmployee(Employees employee) {
		hrmService.addEmployee(employee);
		return "redirect:/hr/employees?status=all";
	}

	/* ===== 직원 수정 폼 ===== */
	@GetMapping("/employees/edit/{emp_num}")
	public String editEmployee(@PathVariable String emp_num, Model model) {
		model.addAttribute("employee", hrmService.getEmployeeById(emp_num));
		return "hr/employees/edit";
	}

	/* ===== 직원 단건 JSON 조회 (팝업용 AJAX) ===== */
	@GetMapping("/employees/json/{emp_num}")
	@ResponseBody
	public ResponseEntity<Employees> getEmployeeJson(@PathVariable String emp_num) {
		Employees emp = hrmService.getEmployeeById(emp_num);
		if (emp == null) return ResponseEntity.notFound().build();
		return ResponseEntity.ok(emp);
	}

	/* ===== 직원 수정 처리 ===== */
	@PostMapping("/employees/update")
	public String updateEmployee(Employees employee) {
		hrmService.updateEmployee(employee);
		return "redirect:/hr/employees?status=all";
	}

	/* ===== 직원 삭제 ===== */
	@PostMapping("/employees/delete")
	public String deleteEmployee(@RequestParam String emp_num) {
		hrmService.deleteEmployee(emp_num);
		return "redirect:/hr/employees?status=all";
	}

	/* ===== 근태 관리 ===== */
	@GetMapping("/attendance")
	public String attendancePage(@RequestParam(required = false) Integer year,
			@RequestParam(required = false) Integer month, Model model) {
		if (year == null || month == null) {
			LocalDate now = LocalDate.now();
			year = now.getYear();
			month = now.getMonthValue();
		}
		model.addAttribute("attendanceCount", hrmService.getAttendanceCountByMonth(year, month));
		return "hr/attendance";
	}

	/* ===== 근태 상세 ===== */
	@GetMapping("/attendanceIn")
	public String attendanceInPage(@RequestParam String date,
			@RequestParam(defaultValue = "1") int page,
			@RequestParam(defaultValue = "10") int size,
			Model model) {

		int offset     = (page - 1) * size;
		int totalCount = hrmService.countAttendanceWithEmployees(date);
		int totalPages = (int) Math.ceil((double) totalCount / size);
		if (totalPages == 0) totalPages = 1;

		// 페이지 블록 (5개씩)
		int block      = 5;
		int startPage  = ((page - 1) / block) * block + 1;
		int endPage    = Math.min(startPage + block - 1, totalPages);

		model.addAttribute("attendance",  hrmService.getAttendanceWithEmployeesPaged(date, offset, size));
		model.addAttribute("date",        date);
		model.addAttribute("currentPage", page);
		model.addAttribute("totalPages",  totalPages);
		model.addAttribute("startPage",   startPage);
		model.addAttribute("endPage",     endPage);
		model.addAttribute("size",        size);
		model.addAttribute("totalCount",  totalCount);
		return "hr/attendance/attendanceIn";
	}

	/* ===== 근태 저장 ===== */
	@PostMapping("/saveAttendance")
	public String saveAttendance(@RequestParam Map<String, String> param) {
		int i = 0;
		while (param.containsKey("list[" + i + "].employee_id")) {
			Attendances a = new Attendances();
			a.setEmployee_id(Integer.parseInt(param.get("list[" + i + "].employee_id")));
			String dateStr = param.get("list[" + i + "].work_date_str");
			if (dateStr != null && !dateStr.isEmpty())
				a.setWork_date(LocalDate.parse(dateStr));
			String clockInStr = param.get("list[" + i + "].clock_in_str");
			if (clockInStr != null && !clockInStr.isEmpty())
				a.setClock_in(LocalTime.parse(clockInStr));
			String clockOutStr = param.get("list[" + i + "].clock_out_str");
			if (clockOutStr != null && !clockOutStr.isEmpty())
				a.setClock_out(LocalTime.parse(clockOutStr));
			a.setNote(param.get("list[" + i + "].note"));
			if (a.getClock_in() != null)
				hrmService.saveOrUpdate(a);
			i++;
		}
		return "redirect:/hr/attendanceIn?date=" + param.get("list[0].work_date_str");
	}

//    /* ===== ERP 사용자 관리 목록 ===== */
//    @GetMapping("/users")
//    public String usersPage(
//    		/* ===== [수정] users 페이징 ===== */
//    		@RequestParam(defaultValue = "1") int page,
//            @RequestParam(defaultValue = "10") int size,
//    		Model model) {
//    	
//    	int offset = (page - 1) * size;
//    	
//    	 /* ===== [추가] users 페이징 ===== */
//        List<User> users = userService.getUsersWithPaging(offset, size);
//        int totalCount   = userService.countUsers();
//        
//        int totalPages = (int) Math.ceil((double) totalCount / size);
//        
//        List<Employees> employees = hrmService.getAllEmployees();
////        List<User>      users     = userService.getAllUsers();
//        Map<Long, Employees> empMapById = employees.stream()
//                .collect(Collectors.toMap(Employees::getId, e -> e));
//        model.addAttribute("users",      users);
//        model.addAttribute("employees",  employees);
//        model.addAttribute("empMapById", empMapById);
//               
//        /* ===== [추가] pagination ===== */
//        model.addAttribute("currentPage", page);
//        model.addAttribute("totalPages", totalPages);
//        model.addAttribute("size", size);
//        
//        return "hr/users";
//    }

	/* ===== ERP 사용자 관리 목록 ===== */
	@GetMapping("/users")
	public String usersPage(
			@RequestParam(defaultValue = "1") int userPage,   // 등록된 계정 페이지
			@RequestParam(defaultValue = "1") int empPage,    // 전체 직원 페이지
			Model model) {

		final int PAGE_SIZE = 5;  // 두 테이블 모두 5개씩

		// ── 등록된 계정 페이징 ──────────────────────────
		int userOffset  = (userPage - 1) * PAGE_SIZE;
		List<User> users = userService.getUsersWithPaging(userOffset, PAGE_SIZE);
		int userTotal   = userService.countUsers();
		int userTotalPages = (int) Math.ceil((double) userTotal / PAGE_SIZE);

		// ── 전체 직원 페이징 ────────────────────────────
		int empOffset = (empPage - 1) * PAGE_SIZE;
		List<Employees> employees = hrmService.searchEmployeesWithPaging(
				null, null, null, empOffset, PAGE_SIZE);
		int empTotal  = hrmService.countEmployees(null, null, null);
		int empTotalPages = (int) Math.ceil((double) empTotal / PAGE_SIZE);

		// empMapById 는 전체 직원 기준으로 만들어야 계정 테이블에서 조인 가능
		// (계정 테이블 행은 users 기준, 직원 정보는 employees 테이블에서)
		// 전체 직원 Map 은 별도로 조회 (페이징된 employees 와 별개)
		List<Employees> allEmployees = hrmService.getAllEmployees();
		Map<Long, Employees> empMapById = allEmployees.stream()
				.collect(Collectors.toMap(Employees::getId, e -> e));

		// ── 등록 모달용: 전체 직원 + 계정 등록된 id Set ──────────
		List<User> allUsers = userService.getAllUsers();
		java.util.Set<Long> registeredIds = allUsers.stream()
				.map(User::getId).collect(java.util.stream.Collectors.toSet());

		model.addAttribute("users",          users);
		model.addAttribute("employees",      employees);     // 페이징된 직원 목록
		model.addAttribute("empMapById",     empMapById);    // 계정 테이블 조인용 (전체)
		model.addAttribute("allEmployees",   allEmployees);  // 등록 모달용 전체 직원
		model.addAttribute("registeredIds",  registeredIds); // 등록 모달용 계정 등록 여부

		// 등록된 계정 페이징 정보
		model.addAttribute("userPage",       userPage);
		model.addAttribute("userTotalPages", userTotalPages);
		model.addAttribute("userTotalCount", userTotal);

		// 전체 직원 페이징 정보
		model.addAttribute("empPage",        empPage);
		model.addAttribute("empTotalPages",  empTotalPages);
		model.addAttribute("empTotalCount",  empTotal);

		return "hr/users";
	}

	/* ===== 사용자 활성/비활성 토글 ===== */
	@PostMapping("/users/toggle")
	public String toggleUserActive(@RequestParam String emp_num) {
		Employees emp = hrmService.getEmployeeById(emp_num);
		if (emp != null)
			userService.toggleUserActive(emp.getId());
		return "redirect:/hr/users";
	}

	/* ===== ERP 계정 등록 폼 ===== */
	@GetMapping("/users/register")
	public String registerForm(Model model) {
		// 전체 직원 목록 — JSP에서 이미 계정 있는 직원 필터링
		List<Employees> employees = hrmService.getAllEmployees();
		List<User> users = userService.getAllUsers();

		// 계정 등록된 id Set → JSP에서 비교용
		java.util.Set<Long> registeredIds = users.stream().map(User::getId)
				.collect(java.util.stream.Collectors.toSet());

		model.addAttribute("employees", employees);
		model.addAttribute("registeredIds", registeredIds);
		return "hr/users/users_register";
	}

	/* ===== ERP 계정 등록 처리 ===== */
	@PostMapping("/users/register")
	public String registerUser(@RequestParam String emp_num, @RequestParam String user_pw, Model model) {
		Employees emp = hrmService.getEmployeeById(emp_num);
		if (emp == null) {
			model.addAttribute("error", "존재하지 않는 직원입니다.");
			model.addAttribute("employees", hrmService.getAllEmployees());
			return "hr/users/register";
		}
		if (emp.getIs_active() == 0) {
			model.addAttribute("error", "퇴사자는 계정 생성 불가합니다.");
			model.addAttribute("employees", hrmService.getAllEmployees());
			return "hr/users/register";
		}
		if (userService.existsByUserId(emp_num)) {
			model.addAttribute("error", "이미 계정이 존재하는 직원입니다.");
			model.addAttribute("employees", hrmService.getAllEmployees());
			return "hr/users/register";
		}
		userService.registerByEmployee(emp_num, user_pw);
		return "redirect:/hr/users?msg=registered";
	}

	/* ===== 비밀번호 변경 처리 ===== */
	@PostMapping("/users/pw-change")
	public String pwChange(@RequestParam String emp_num, @RequestParam String new_pw) {
		try {
			userService.changePassword(emp_num, new_pw);
		} catch (Exception e) {
			return "redirect:/hr/users?msg=pw_error";
		}
		return "redirect:/hr/users?msg=pw_changed";
	}

	/* ===== ERP 계정 삭제 처리 ===== */
	@PostMapping("/users/delete")
	public String deleteUser(@RequestParam String emp_num) {
		try {
			userService.deleteUserAccount(emp_num);
		} catch (Exception e) {
			return "redirect:/hr/users?msg=del_error";
		}
		return "redirect:/hr/users?msg=del_done";
	}

	/* ===== 관리자 인증 (users 전용 AJAX) ===== */
	@PostMapping("/users/auth")
	@ResponseBody
	public ResponseEntity<String> usersAuth(@RequestParam String userId,
	                                        @RequestParam String userPw,
	                                        HttpSession session) {
		String loginEmpNum = (String) session.getAttribute("loginEmpNum");
		if (loginEmpNum == null || !loginEmpNum.equals(userId)) return ResponseEntity.ok("fail");
		boolean ok = userService.authenticate(userId, userPw);
		return ResponseEntity.ok(ok ? "ok" : "fail");
	}

	/* ===== ERP 사용자 관리 ===== */
	@GetMapping("/users/register-form")
	public String registerFormDirect(Model model) {
		return "redirect:/hr/users/register";
	}

	/* ===== ERP 계정 등록 폼 (구형 호환) ===== */
	@GetMapping("/users/registerPage")
	public String registerFormPage(Model model) {
		return "redirect:/hr/users/user_register";
	}
}