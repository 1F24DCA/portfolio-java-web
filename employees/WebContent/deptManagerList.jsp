<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.sql.*"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>부서장 목록</title>
	</head>
	
	<%
		Class.forName("org.mariadb.jdbc.Driver");
		Connection conn = DriverManager.getConnection("jdbc:mariadb://localhost/employees", "root", "java1004");
		
		final String EMP_NAME = "CONCAT(e.first_name, ' ', e.last_name)";
		final String BASE_QUERY = "SELECT dm.dept_no, d.dept_name, "+EMP_NAME+" emp_name, dm.from_date, dm.to_date FROM dept_manager dm INNER JOIN departments d ON dm.dept_no = d.dept_no INNER JOIN employees e ON dm.emp_no = e.emp_no";
		
		PreparedStatement selectListStmt = conn.prepareStatement(BASE_QUERY+" ORDER BY dm.dept_no ASC LIMIT 0, 100");
		System.out.println("debug: PreparedStatement 쿼리: \n\t"+selectListStmt.toString());
		
		ResultSet selectListRs = selectListStmt.executeQuery();
	%>
	
	<body>
		<!-- 네비게이션 -->
		<div>
			<a href="./index.jsp">메인</a>
			<a href="./departmentsList.jsp">부서 목록</a>
			<a href="./deptEmpList.jsp">부서 근무자 목록</a>
			<a href="./deptManagerList.jsp">부서장 목록</a>
			<a href="./employeesList.jsp">사원 목록</a>
			<a href="./salariesList.jsp">급여 목록</a>
			<a href="./titlesList.jsp">직책 목록</a>
		</div>
		
		<!-- 제목 -->
		<h1>부서장 목록</h1>
		
		<!-- 컨텐츠 -->
		<table border="1">
			<thead>
				<tr>
					<th>부서번호</th>
					<th>부서명</th>
					<th>이름</th>
					<th>부서로 들어온 날짜</th>
					<th>부서에서 나간 날짜</th>
				</tr>
			</thead>
			<tbody>
				<%
					while (selectListRs.next()) {
				%>
						<tr>
							<td><%=selectListRs.getString("dept_no") %></td>
							<td><%=selectListRs.getString("dept_name") %></td>
							<td><%=selectListRs.getString("emp_name") %></td>
							<td><%=selectListRs.getString("from_date") %></td>
							<td>
								<%
									// 부서에서 나간 날짜가 9999-01-01이라는 것은 아직 부서에서 나가지 않았다는 뜻이므로 표시하지 않음
									String toDate = selectListRs.getString("to_date");
									if (toDate.equals("9999-01-01") == false) {
										out.print(toDate);
									}
								%>
							</td>
						</tr>
				<%
					}
				%>
			</tbody>
		</table>
	</body>
	
	<%
		selectListRs.close();
		selectListStmt.close();
		conn.close();
	%>
</html>