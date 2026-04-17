package com.example.demo.Domain;

import java.time.LocalDate;

public class Employees {

	private Long id;
	private String emp_num; // 이건 회원 수정할 떄 사용 평소엔 안보이게
	private String name; // Users 다르게 본래 고유
	private Integer age;
	private String phone;
	private String position;
	private String contract_type;
	private Long hourly_wage;
	private Long monthly_salary;
	private LocalDate hire_date;
	private LocalDate resign_date;
	private String profile;
	private String bank_name;
	private String account_no;
	private int is_active;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getEmp_num() {
		return emp_num;
	}

	public void setEmp_num(String emp_num) {
		this.emp_num = emp_num;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Integer getAge() {
		return age;
	}

	public void setAge(Integer age) {
		this.age = age;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getPosition() {
		return position;
	}

	public void setPosition(String position) {
		this.position = position;
	}

	public String getContract_type() {
		return contract_type;
	}

	public void setContract_type(String contract_type) {
		this.contract_type = contract_type;
	}

	public Long getHourly_wage() {
		return hourly_wage;
	}

	public void setHourly_wage(Long hourly_wage) {
		this.hourly_wage = hourly_wage;
	}

	public Long getMonthly_salary() {
		return monthly_salary;
	}

	public void setMonthly_salary(Long monthly_salary) {
		this.monthly_salary = monthly_salary;
	}

	public LocalDate getHire_date() {
		return hire_date;
	}

	public void setHire_date(LocalDate hire_date) {
		this.hire_date = hire_date;
	}

	public LocalDate getResign_date() {
		return resign_date;
	}

	public void setResign_date(LocalDate resign_date) {
		this.resign_date = resign_date;
	}

	public String getProfile() {
		return profile;
	}

	public void setProfile(String profile) {
		this.profile = profile;
	}

	public String getBank_name() {
		return bank_name;
	}

	public void setBank_name(String bank_name) {
		this.bank_name = bank_name;
	}

	public String getAccount_no() {
		return account_no;
	}

	public void setAccount_no(String account_no) {
		this.account_no = account_no;
	}

	public int getIs_active() {
		return is_active;
	}

	public void setIs_active(int is_active) {
		this.is_active = is_active;
	}

}