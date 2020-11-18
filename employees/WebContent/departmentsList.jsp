<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.sql.*"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>부서 목록</title>
	</head>
	
	<%
	// 1. 테이블 내용 검색 코드
		// SQL의 WHERE 절을 이용하여 테이블 내용 검색
		// 클라이언트가 요청한 검색 내용을 가져옴
		String searchDeptName = null; // 부서명 검색 조건, 사용자의 입력을 받음
		
		// 사용자가 요청한 값을 받아와서 처리
		String inputDeptName = request.getParameter("deptName");
		if (inputDeptName == null) {
			// 받아온 문자열이 null값이면 빈 문자열로 처리
			// 검색 폼에서 value HTML 속성을 좀 더 쉽게 작성하고 null이 들어가지 않게끔 하여 NullPointerException이 발생하지 않게 하기 위함
			inputDeptName = "";
		} else {
			// 폼을 통한 검색 시 아무것도 입력하지 않으면 검색하지 않음
			if (inputDeptName.equals("") == false) {
				searchDeptName = "%"+inputDeptName+"%";
			}
		}
		
	// 2. 페이지 분할 작업을 위한 코드
		// SQL의 LIMIT 절을 이용하여 페이지 분할
		// : SELECT ... LIMIT (listBeginIndex), (listPageSize)
		int listBeginIndex = -1; // 목록에서 보여질 시작 인덱스(0부터 시작)
		int listPageSize = 25; // 목록에서 보여질 항목 갯수
		int listLastPage = -1; // 페이지 전환 버튼(다음)의 표시 여부를 결정하기 위한 마지막 페이지를 담은 변수
		
		int listPage = 1; // 현재 페이지, 사용자의 입력을 받음
		
		// 사용자가 요청한 값을 받아와서 처리
		String inputListPage = request.getParameter("listPage");
		if (inputListPage != null && inputListPage.matches("^\\d+$")) { // 숫자값인지 검사하기 위해 정규표현식을 사용
			listPage = Integer.parseInt(inputListPage);
		}
		
		// 간단한 알고리즘을 이용해 시작 행 계산
		listBeginIndex = (listPage-1)*listPageSize;
		
	// 3. DB에 접속하는 코드
		Class.forName("org.mariadb.jdbc.Driver");
		Connection conn = DriverManager.getConnection("jdbc:mariadb://localhost/employees", "root", "java1004");
		
		// 검색에 따른 동적 쿼리 구현
		PreparedStatement selectListStmt = null;
		PreparedStatement selectListSizeStmt = null;
		if (searchDeptName == null) {
			selectListStmt = conn.prepareStatement("SELECT dept_no, dept_name FROM departments ORDER BY dept_no ASC LIMIT ?, ?");
			selectListStmt.setInt(1, listBeginIndex);
			selectListStmt.setInt(2, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM departments");
		} else if (searchDeptName != null) {
			selectListStmt = conn.prepareStatement("SELECT dept_no, dept_name FROM departments WHERE dept_name LIKE ? ORDER BY dept_no ASC LIMIT ?, ?");
			selectListStmt.setString(1, searchDeptName);
			selectListStmt.setInt(2, listBeginIndex);
			selectListStmt.setInt(3, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM departments WHERE dept_name LIKE ?");
			selectListSizeStmt.setString(1, searchDeptName);
		}
		
		System.out.println("debug: selectListStmt 쿼리: \n\t"+selectListStmt.toString());
		System.out.println("debug: selectListSizeStmt 쿼리: \n\t"+selectListSizeStmt.toString());
		
	// 3-1. DB에서 테이블 데이터 추출을 위한 코드
		ResultSet selectListRs = selectListStmt.executeQuery();
		
	// 3-2. 마지막 페이지를 구하기 위한 코드
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
//		System.out.println("debug: 현재 페이지: "+listPage);
//		System.out.println("debug: 쿼리 데이터 추출 시작 행: "+listBeginIndex);
//		System.out.println("debug: 마지막 페이지: "+listLastPage);
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
		
		<!-- 검색 기능 -->
		<form method="POST" action="./departmentsList.jsp">
			검색할 부서명: <input type="text" name="deptName" value="<%=inputDeptName %>">
			<button type="submit">검색</button>
		</form>
		
		<!-- 페이지 관리 기능 -->
		<div>
			<%
				if (listPage > 1) { // 이전 페이지가 표시가능한 상태 (첫 페이지가 아니라면)
					if (searchDeptName == null) { // 사용자가 입력한 값이 없을 때
			%>
						<a href="./departmentsList.jsp">처음으로</a>
						<a href="./departmentsList.jsp?listPage=<%=listPage-1 %>">이전</a>
			<%
					} else if (searchDeptName != null) { // 사용자가 입력한 값이 있을 때
			%>
						<a href="./departmentsList.jsp?deptName=<%=inputDeptName %>">처음으로</a>
						<a href="./departmentsList.jsp?listPage=<%=listPage-1 %>&deptName=<%=inputDeptName %>">이전</a>
			<%		
					}
				}
			%>
			
			<span>현재 <%=listPage %> 페이지 / 총 <%=listLastPage %> 페이지</span>
			
			<%
				if (listPage < listLastPage) { // 다음 페이지가 표시가능한 상태 (마지막 페이지가 아니라면)
					if (searchDeptName == null) { // 사용자가 입력한 값이 없을 때
			%>
						<a href="./departmentsList.jsp?listPage=<%=listPage+1 %>">다음</a>
						<a href="./departmentsList.jsp?listPage=<%=listLastPage %>">마지막으로</a>
			<%
					} else if (searchDeptName != null) { // 사용자가 입력한 값이 있을 때
			%>
						<a href="./departmentsList.jsp?listPage=<%=listPage+1 %>&deptName=<%=inputDeptName %>">다음</a>
						<a href="./departmentsList.jsp?listPage=<%=listLastPage %>&deptName=<%=inputDeptName %>">마지막으로</a>
			<%		
					}
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