<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.sql.*"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>부서 목록</title>
	</head>
	
	<%
		Class.forName("org.mariadb.jdbc.Driver");
		Connection conn = DriverManager.getConnection("jdbc:mariadb://localhost/employees", "root", "java1004");
		
		String sql = "SELECT dept_no, dept_name FROM departments ORDER BY dept_no ASC";
		PreparedStatement stmt = conn.prepareStatement(sql);
		System.out.println("debug: PreparedStatement 쿼리: \n\t"+stmt.toString());
		
		ResultSet rs = stmt.executeQuery();
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
		<h1>부서 목록</h1>
		
		<!-- 컨텐츠 -->
		<table border="1">
			<thead>
				<tr>
					<th>부서번호</th>
					<th>부서명</th>
				</tr>
			</thead>
			<tbody>
				<%
					while (rs.next()) {
				%>
						<tr>
							<td><%=rs.getString("dept_no") %></td>
							<td><%=rs.getString("dept_name") %></td>
						</tr>
				<%
					}
				%>
			</tbody>
		</table>
	</body>
	
	<%
		rs.close();
		stmt.close();
		conn.close();
	%>
</html>