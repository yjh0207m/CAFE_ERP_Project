package com.example.demo.Domain;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class Attendances {

	private Long id;
	private int employee_id;
	private LocalDate work_date;
	private LocalTime clock_in;
	private LocalTime clock_out;
	private Double work_hours;
	private String note;
	private LocalDateTime created_at;

	// form용 String 필드
	private String work_date_str;
	private String clock_in_str;
	private String clock_out_str;
	private String work_hours_str;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public int getEmployee_id() {
		return employee_id;
	}

	public void setEmployee_id(int employee_id) {
		this.employee_id = employee_id;
	}

	public LocalDate getWork_date() {
		return work_date;
	}

	public void setWork_date(LocalDate work_date) {
		this.work_date = work_date;
	}

	public LocalTime getClock_in() {
		return clock_in;
	}

	public void setClock_in(LocalTime clock_in) {
		this.clock_in = clock_in;
	}

	public LocalTime getClock_out() {
		return clock_out;
	}

	public void setClock_out(LocalTime clock_out) {
		this.clock_out = clock_out;
	}

	public Double getWork_hours() {
		return work_hours;
	}

	public void setWork_hours(Double work_hours) {
		this.work_hours = work_hours;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public LocalDateTime getCreated_at() {
		return created_at;
	}

	public void setCreated_at(LocalDateTime created_at) {
		this.created_at = created_at;
	}

	public String getWork_date_str() {
		return work_date_str;
	}

	public void setWork_date_str(String work_date_str) {
		this.work_date_str = work_date_str;
	}

	public String getClock_in_str() {
		return clock_in_str;
	}

	public void setClock_in_str(String clock_in_str) {
		this.clock_in_str = clock_in_str;
	}

	public String getClock_out_str() {
		return clock_out_str;
	}

	public void setClock_out_str(String clock_out_str) {
		this.clock_out_str = clock_out_str;
	}

	public String getWork_hours_str() {
		return work_hours_str;
	}

	public void setWork_hours_str(String work_hours_str) {
		this.work_hours_str = work_hours_str;
	}

}