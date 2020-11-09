<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.sql.*"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>부서 목록</title>
	</head>
	
	<%
	// 1. 페이지 분할 작업을 위한 코드
		// SQL의 LIMIT 절을 이용하여 페이지 분할
		// : SELECT ... LIMIT (beginRow), (rowPerPage)		
		int beginRow = 0; // 테이블에서 보여질 시작 행
		int rowPerPage = 5; // 테이블에서 보여질 행 갯수
		int lastPage = 0; // 페이지 전환 버튼(다음)의 표시 여부를 결정하기 위한 마지막 페이지를 담은 변수
		
		int currentPage = 1; // 현재 페이지, 사용자의 입력을 받음
		if (request.getParameter("currentPage") != null) {
			currentPage = Integer.parseInt(request.getParameter("currentPage"));
		}
		
		// 간단한 알고리즘을 이용해 시작 행 계산
		beginRow = (currentPage-1)*rowPerPage;
		
	// 2. DB에 접속하는 코드
		Class.forName("org.mariadb.jdbc.Driver");
		Connection conn = DriverManager.getConnection("jdbc:mariadb://localhost/employees", "root", "java1004");
		
		// TODO: 동적 쿼리로 변환될 때, 이녀석들을 한번에 바꿔줌
		String sql = "SELECT dept_no, dept_name FROM departments ORDER BY dept_no ASC LIMIT ?, ?";
		String lastPageSql = "SELECT COUNT(*) FROM departments";
		
	// 2-1. DB에서 테이블 데이터 추출을 위한 코드
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, beginRow);
		stmt.setInt(2, rowPerPage);
		System.out.println("debug: PreparedStatement 쿼리: \n\t"+stmt.toString());
		
		ResultSet rs = stmt.executeQuery();
		
	// 2-2. 마지막 페이지를 구하기 위한 코드
		int rowCount = 0; // 행 갯수, 마지막 페이지를 구하는 데 사용
		
		PreparedStatement lastPageStmt = conn.prepareStatement(lastPageSql);
		ResultSet lastPageRs = lastPageStmt.executeQuery();
		if (lastPageRs.next()) {
			rowCount = lastPageRs.getInt("COUNT(*)");
		}
		
		// 간단한 알고리즘을 이용해 마지막 페이지 계산
		lastPage = rowCount/rowPerPage;
		if (rowCount%rowPerPage != 0) {
			lastPage += 1;
		}
		
		// 테스트용 출력
		System.out.println("debug: 현재 페이지: "+currentPage);
		System.out.println("debug: 쿼리 데이터 추출 시작 행: "+beginRow);
		System.out.println("debug: 마지막 페이지: "+lastPage);
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