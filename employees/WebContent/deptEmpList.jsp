<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.sql.*"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>부서 근무자 목록</title>
	</head>
	
	<%
	// 1. 페이지 분할 작업을 위한 코드
		// SQL의 LIMIT 절을 이용하여 페이지 분할
		// : SELECT ... LIMIT (listBeginIndex), (listPageSize)	
		int listBeginIndex = -1; // 목록에서 보여질 시작 인덱스(0부터 시작)
		int listPageSize = 5; // 목록에서 보여질 항목 갯수
		int listLastPage = -1; // 페이지 전환 버튼(다음)의 표시 여부를 결정하기 위한 마지막 페이지를 담은 변수
		
		int listPage = 1; // 현재 페이지, 사용자의 입력을 받음
		
		// 사용자가 요청한 값을 받아와서 처리
		String inputListPage = request.getParameter("listPage");
		if (inputListPage != null && inputListPage.matches("^\\d+$")) { // 숫자값인지 검사하기 위해 정규표현식을 사용
			listPage = Integer.parseInt(inputListPage);
		}
		
		// 간단한 알고리즘을 이용해 시작 행 계산
		listBeginIndex = (listPage-1)*listPageSize;
		
	// 2. DB에 접속하는 코드
		Class.forName("org.mariadb.jdbc.Driver");
		Connection conn = DriverManager.getConnection("jdbc:mariadb://localhost/employees", "root", "java1004");
		
		PreparedStatement selectListStmt = conn.prepareStatement("SELECT dept_emp.emp_no, CONCAT(employees.first_name, ' ', employees.last_name) 'name', departments.dept_name, dept_emp.from_date, dept_emp.to_date FROM dept_emp INNER JOIN employees ON dept_emp.emp_no = employees.emp_no INNER JOIN departments ON dept_emp.dept_no = departments.dept_no ORDER BY emp_no ASC LIMIT ?, ?");
		selectListStmt.setInt(1, listBeginIndex);
		selectListStmt.setInt(2, listPageSize);
		
		PreparedStatement selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM dept_emp");
		
		System.out.println("debug: PreparedStatement 쿼리: \n\t"+selectListStmt.toString());
		System.out.println("debug: PreparedStatement 쿼리: \n\t"+selectListSizeStmt.toString());
		
	// 2-1. DB에서 테이블 데이터 추출을 위한 코드
		ResultSet selectListRs = selectListStmt.executeQuery();
	
	// 2-2. 마지막 페이지를 구하기 위한 코드
		int listSize = -1; // 전체 목록 아이템 갯수, 마지막 페이지를 구하는 데 사용
		
		ResultSet selectListSizeRs = selectListSizeStmt.executeQuery();
		if (selectListSizeRs.next()) {
			listSize = selectListSizeRs.getInt("COUNT(*)");
		}
		
		// 간단한 알고리즘을 이용해 마지막 페이지 계산
		listLastPage = listSize/listPageSize;
		if (listSize%listPageSize != 0) {
			listLastPage += 1;
		}
		
		// 테스트용 출력
		System.out.println("debug: 현재 페이지: "+listPage);
		System.out.println("debug: 쿼리 데이터 추출 시작 행: "+listBeginIndex);
		System.out.println("debug: 마지막 페이지: "+listLastPage);
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
		<h1>부서 근무자 목록</h1>
		
		<!-- 컨텐츠 -->
		<table border="1">
			<thead>
				<tr>
					<th>사원번호</th>
					<th>이름</th>
					<th>부서명</th>
					<th>부서로 들어온 날짜</th>
					<th>부서에서 나간 날짜</th>
				</tr>
			</thead>
			<tbody>
				<%
					while (selectListRs.next()) {
				%>
						<tr>
							<td><%=selectListRs.getString("dept_emp.emp_no") %></td>
							<td><%=selectListRs.getString("name") %></td>
							<td><%=selectListRs.getString("departments.dept_name") %></td>
							<td><%=selectListRs.getString("dept_emp.from_date") %></td>
							<td>
								<%
									// 부서에서 나간 날짜가 9999-01-01이라는 것은 아직 부서에서 나가지 않았다는 뜻이므로 표시하지 않음
									if (!selectListRs.getString("dept_emp.to_date").equals("9999-01-01")) {
										out.print(selectListRs.getString("dept_emp.to_date"));
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