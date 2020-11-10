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
		
		// TODO: 동적 쿼리로 변환될 때, 이녀석들을 한번에 바꿔줌
		String selectListSql = "SELECT dept_no, dept_name FROM departments ORDER BY dept_no ASC LIMIT ?, ?";
		String selectListSizeSql = "SELECT COUNT(*) FROM departments";
		
	// 2-1. DB에서 테이블 데이터 추출을 위한 코드
		PreparedStatement selectListStmt = conn.prepareStatement(selectListSql);
		selectListStmt.setInt(1, listBeginIndex);
		selectListStmt.setInt(2, listPageSize);
		System.out.println("debug: selectListStmt 쿼리: \n\t"+selectListStmt.toString());
		
		ResultSet selectListRs = selectListStmt.executeQuery();
		
	// 2-2. 마지막 페이지를 구하기 위한 코드
		int listSize = -1; // 전체 목록 아이템 갯수, 마지막 페이지를 구하는 데 사용
		
		PreparedStatement selectListSizeStmt = conn.prepareStatement(selectListSizeSql);
		System.out.println("debug: selectListSizeStmt 쿼리: \n\t"+selectListSizeStmt.toString());
		
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
//		System.out.println("debug: 현재 페이지: "+currentPage);
//		System.out.println("debug: 쿼리 데이터 추출 시작 행: "+beginRow);
//		System.out.println("debug: 마지막 페이지: "+lastPage);
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
					while (selectListRs.next()) {
				%>
						<tr>
							<td><%=selectListRs.getString("dept_no") %></td>
							<td><%=selectListRs.getString("dept_name") %></td>
						</tr>
				<%
					}
				%>
			</tbody>
		</table>
		
		<!-- 페이지 관리 기능 -->
		<div>
			<%
				if (listPage > 1) {
			%>
					<a href="./departmentsList.jsp?listPage=<%=listPage-1 %>">이전</a>
			<%
				}
			%>
			
			<span>현재 <%=listPage %> 페이지 / 총 <%=listLastPage %> 페이지</span>
			
			<%
				if (listPage < listLastPage) {
			%>
					<a href="./departmentsList.jsp?listPage=<%=listPage+1 %>">다음</a>
			<%
				}
			%>
		</div>
	</body>
	
	<%
		selectListSizeRs.close();
		selectListSizeStmt.close();
		selectListRs.close();
		selectListStmt.close();
		conn.close();
	%>
</html>