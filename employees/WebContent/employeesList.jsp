<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.sql.*"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>사원 목록</title>
	</head>
	
	<%
		Class.forName("org.mariadb.jdbc.Driver");
		Connection conn = DriverManager.getConnection("jdbc:mariadb://localhost/employees", "root", "java1004");
		
		final String EMP_NAME = "CONCAT(first_name, ' ', last_name)";
		
		PreparedStatement selectListStmt = conn.prepareStatement("SELECT emp_no, "+EMP_NAME+" emp_name, birth_date, gender, hire_date FROM employees ORDER BY emp_no ASC LIMIT 0, 100");
		System.out.println("debug: PreparedStatement 쿼리: \n\t"+selectListStmt.toString());
		
		ResultSet selectListRs = selectListStmt.executeQuery();
	%>
	
	<body>
		<!-- 네비게이션 -->
		<div>
			<a href="./index.jsp">메인</a>
			<a href="./departmentsList.jsp">부서 목록</a>
			<a href="./deptManagerList.jsp">부서 근무자 목록</a>
			<a href="./deptManagerList.jsp">부서장 목록</a>
			<a href="./employeesList.jsp">사원 목록</a>
			<a href="./salariesList.jsp">급여 목록</a>
			<a href="./titlesList.jsp">직책 목록</a>
		</div>
		
		<h1>사원 목록</h1>
		
		<!-- 컨텐츠 -->
		<table border="1">
			<thead>
				<tr>
					<th>사원번호</th>
					<th>이름</th>
					<th>생년월일</th>
					<th>성별</th>
					<th>고용일</th>
				</tr>
			</thead>
			<tbody>
				<%
					while (selectListRs.next()) {
				%>
						<tr>
							<td><%=selectListRs.getString("emp_no") %></td>
							<td><%=selectListRs.getString("emp_name") %></td>
							<td><%=selectListRs.getString("birth_date") %></td>
							<td>
								<%
									// 성별이 M이면 남자, F이면 여자
									String gender = selectListRs.getString("gender");
									if (gender.equals("M") == true) {
										out.print("남");
									} else if (gender.equals("F") == true) {
										out.print("여");
									}
								%>
							</td>
							<td><%=selectListRs.getString("hire_date") %></td>
						</tr>
				<%
					}
				%>
			</tbody>
		</table>
	</body>
	
	<%
		conn.close();
	%>
</html>