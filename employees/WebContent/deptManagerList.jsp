<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.sql.*"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>부서장 목록</title>
	</head>
	
	<%
	// 1. 테이블 내용 검색 코드
		// SQL의 WHERE 절을 이용하여 테이블 내용 검색
		// 클라이언트가 요청한 검색 내용을 가져옴
		boolean searchWorking = false; // 재직중인 사람만 검색할 것인지 묻는 검색 조건, 사용자의 입력을 받음
		String searchDeptNo = null; // 부서번호 검색 조건, 사용자의 입력을 받음
		String searchEmpName = null; // 사원명 검색 조건, 사용자의 입력을 받음
		
		// 사용자가 요청한 값을 받아와서 처리
		String inputWorking = request.getParameter("working");
		if (inputWorking == null) {
			// 받아온 문자열이 null값이면 빈 문자열로 처리
			// 검색 폼에서 value HTML 속성을 좀 더 쉽게 작성하고 null이 들어가지 않게끔 하여 NullPointerException이 발생하지 않게 하기 위함
			inputWorking = "";
		} else {
			// 폼을 통한 검색 시 on이라고 입력해야만 검색함
			if (inputWorking.equals("on") == true) {
				searchWorking = true;
				inputWorking = "checked";
			}
		}
		
		// 사용자가 요청한 값을 받아와서 처리
		String inputDeptNo = request.getParameter("deptNo");
		if (inputDeptNo == null) {
			// 받아온 문자열이 null값이면 빈 문자열로 처리
			// null이 들어가지 않게끔 하여 NullPointerException이 발생하지 않게 하기 위함
			inputDeptNo = "";
		} else {
			// 폼을 통한 검색 시 아무것도 입력하지 않으면 검색하지 않음
			if (inputDeptNo.equals("") == false) {
				searchDeptNo = inputDeptNo;
			}
		}
		
		// 사용자가 요청한 값을 받아와서 처리
		String inputEmpName = request.getParameter("empName");
		if (inputEmpName == null) {
			// 받아온 문자열이 null값이면 빈 문자열로 처리
			// 검색 폼에서 value HTML 속성을 좀 더 쉽게 작성하고 null이 들어가지 않게끔 하여 NullPointerException이 발생하지 않게 하기 위함
			inputEmpName = "";
		} else {
			// 폼을 통한 검색 시 아무것도 입력하지 않으면 검색하지 않음
			if (inputEmpName.equals("") == false) {
				searchEmpName = "%"+inputEmpName+"%";
			}
		}
	
	// 2. 페이지 분할 작업을 위한 코드
		// SQL의 LIMIT 절을 이용하여 페이지 분할
		// : SELECT ... LIMIT (listBeginIndex), (listPageSize)	
		int listBeginIndex = -1; // 목록에서 보여질 시작 인덱스(0부터 시작)
		int listPageSize = 2; // 목록에서 보여질 항목 갯수
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
		
		PreparedStatement selectListStmt = null;
		PreparedStatement selectListSizeStmt = null;
		
		final String EMP_NAME = "CONCAT(e.first_name, ' ', e.last_name)";
		final String BASE_QUERY = "SELECT dm.dept_no, d.dept_name, "+EMP_NAME+" emp_name, dm.from_date, dm.to_date FROM dept_manager dm INNER JOIN departments d ON dm.dept_no = d.dept_no INNER JOIN employees e ON dm.emp_no = e.emp_no";
		if (searchWorking == false && searchDeptNo == null && searchEmpName == null) {
			selectListStmt = conn.prepareStatement(BASE_QUERY+" ORDER BY dm.dept_no ASC LIMIT ?, ?");
			selectListStmt.setInt(1, listBeginIndex);
			selectListStmt.setInt(2, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM dept_manager");
		} else if (searchWorking == true && searchDeptNo == null && searchEmpName == null) {
			selectListStmt = conn.prepareStatement(BASE_QUERY+" WHERE dm.to_date = '9999-01-01' ORDER BY dm.dept_no ASC LIMIT ?, ?");
			selectListStmt.setInt(1, listBeginIndex);
			selectListStmt.setInt(2, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM dept_manager WHERE to_date = '9999-01-01'");
		} else if (searchWorking == false && searchDeptNo != null && searchEmpName == null) {
			selectListStmt = conn.prepareStatement(BASE_QUERY+" WHERE d.dept_no = ? ORDER BY dm.dept_no ASC LIMIT ?, ?");
			selectListStmt.setString(1, searchDeptNo);
			selectListStmt.setInt(2, listBeginIndex);
			selectListStmt.setInt(3, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM dept_manager WHERE dept_no = ?");
			selectListSizeStmt.setString(1, searchDeptNo);
		} else if (searchWorking == false && searchDeptNo == null && searchEmpName != null) {
			selectListStmt = conn.prepareStatement(BASE_QUERY+" WHERE "+EMP_NAME+" LIKE ? ORDER BY dm.dept_no ASC LIMIT ?, ?");
			selectListStmt.setString(1, searchEmpName);
			selectListStmt.setInt(2, listBeginIndex);
			selectListStmt.setInt(3, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM dept_manager dm INNER JOIN employees e ON dm.emp_no = e.emp_no WHERE "+EMP_NAME+" LIKE ?");
			selectListSizeStmt.setString(1, searchEmpName);
		} else if (searchWorking == true && searchDeptNo != null && searchEmpName == null) {
			selectListStmt = conn.prepareStatement(BASE_QUERY+" WHERE dm.to_date = '9999-01-01' AND d.dept_no = ? ORDER BY dm.dept_no ASC LIMIT ?, ?");
			selectListStmt.setString(1, searchDeptNo);
			selectListStmt.setInt(2, listBeginIndex);
			selectListStmt.setInt(3, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM dept_manager WHERE to_date = '9999-01-01' AND dept_no = ?");
			selectListSizeStmt.setString(1, searchDeptNo);
		} else if (searchWorking == true && searchDeptNo == null && searchEmpName != null) {
			selectListStmt = conn.prepareStatement(BASE_QUERY+" WHERE dm.to_date = '9999-01-01' AND "+EMP_NAME+" LIKE ? ORDER BY dm.dept_no ASC LIMIT ?, ?");
			selectListStmt.setString(1, searchEmpName);
			selectListStmt.setInt(2, listBeginIndex);
			selectListStmt.setInt(3, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM dept_manager dm INNER JOIN employees e ON dm.emp_no = e.emp_no WHERE dm.to_date = '9999-01-01' AND "+EMP_NAME+" LIKE ?");
			selectListSizeStmt.setString(1, searchEmpName);
		} else if (searchWorking == false && searchDeptNo != null && searchEmpName != null) {
			selectListStmt = conn.prepareStatement(BASE_QUERY+" WHERE d.dept_no = ? AND "+EMP_NAME+" LIKE ? ORDER BY dm.dept_no ASC LIMIT ?, ?");
			selectListStmt.setString(1, searchDeptNo);
			selectListStmt.setString(2, searchEmpName);
			selectListStmt.setInt(3, listBeginIndex);
			selectListStmt.setInt(4, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM dept_manager dm INNER JOIN employees e ON dm.emp_no = e.emp_no WHERE dm.dept_no = ? AND "+EMP_NAME+" LIKE ?");
			selectListSizeStmt.setString(1, searchDeptNo);
			selectListSizeStmt.setString(2, searchEmpName);
		} else if (searchWorking == true && searchDeptNo != null && searchEmpName != null) {
			selectListStmt = conn.prepareStatement(BASE_QUERY+" WHERE dm.to_date = '9999-01-01' AND d.dept_no = ? AND "+EMP_NAME+" LIKE ? ORDER BY dm.dept_no ASC LIMIT ?, ?");
			selectListStmt.setString(1, searchDeptNo);
			selectListStmt.setString(2, searchEmpName);
			selectListStmt.setInt(3, listBeginIndex);
			selectListStmt.setInt(4, listPageSize);
			
			selectListSizeStmt = conn.prepareStatement("SELECT COUNT(*) FROM dept_manager dm INNER JOIN employees e ON dm.emp_no = e.emp_no WHERE dm.to_date = '9999-01-01' AND dm.dept_no = ? AND "+EMP_NAME+" LIKE ?");
			selectListSizeStmt.setString(1, searchDeptNo);
			selectListSizeStmt.setString(2, searchEmpName);
		}
		
		System.out.println("debug: PreparedStatement 쿼리: \n\t"+selectListStmt.toString());
		System.out.println("debug: PreparedStatement 쿼리: \n\t"+selectListSizeStmt.toString());
		
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
		System.out.println("debug: 현재 페이지: "+listPage);
		System.out.println("debug: 쿼리 데이터 추출 시작 행: "+listBeginIndex);
		System.out.println("debug: 마지막 페이지: "+listLastPage);
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
		
		<!-- 페이지 관리 기능 -->
		<div>
			<%
				if (listPage > 1) {
					if (searchWorking == false && searchDeptNo == null && searchEmpName == null) {
			%>
						<a href="./deptManagerList.jsp">처음으로</a>
						<a href="./deptManagerList.jsp?listPage=<%=listPage-1 %>">이전</a>
			<%
					} else if (searchWorking == true && searchDeptNo == null && searchEmpName == null) {
			%>
						<a href="./deptManagerList.jsp?working=on">처음으로</a>
						<a href="./deptManagerList.jsp?listPage=<%=listPage-1 %>&working=on">이전</a>
			<%
					} else if (searchWorking == false && searchDeptNo != null && searchEmpName == null) {
			%>
						<a href="./deptManagerList.jsp?deptNo=<%=inputDeptNo %>">처음으로</a>
						<a href="./deptManagerList.jsp?listPage=<%=listPage-1 %>&deptNo=<%=inputDeptNo %>">이전</a>
			<%
					} else if (searchWorking == false && searchDeptNo == null && searchEmpName != null) {
			%>
						<a href="./deptManagerList.jsp?empName=<%=inputEmpName %>">처음으로</a>
						<a href="./deptManagerList.jsp?listPage=<%=listPage-1 %>&empName=<%=inputEmpName %>">이전</a>
			<%
					} else if (searchWorking == true && searchDeptNo != null && searchEmpName == null) {
			%>
						<a href="./deptManagerList.jsp?working=on&deptNo=<%=inputDeptNo %>">처음으로</a>
						<a href="./deptManagerList.jsp?listPage=<%=listPage-1 %>&working=on&deptNo=<%=inputDeptNo %>">이전</a>
			<%
					} else if (searchWorking == true && searchDeptNo == null && searchEmpName != null) {
			%>
						<a href="./deptManagerList.jsp?working=on&empName=<%=inputEmpName %>">처음으로</a>
						<a href="./deptManagerList.jsp?listPage=<%=listPage-1 %>&working=on&empName=<%=inputEmpName %>">이전</a>
			<%
					} else if (searchWorking == false && searchDeptNo != null && searchEmpName != null) {
			%>
						<a href="./deptManagerList.jsp?deptNo=<%=inputDeptNo %>&empName=<%=inputEmpName %>">처음으로</a>
						<a href="./deptManagerList.jsp?listPage=<%=listPage-1 %>&deptNo=<%=inputDeptNo %>&empName=<%=inputEmpName %>">이전</a>
			<%
					} else if (searchWorking == true && searchDeptNo != null && searchEmpName != null) {
			%>
						<a href="./deptManagerList.jsp?working=on&deptNo=<%=inputDeptNo %>&empName=<%=inputEmpName %>">처음으로</a>
						<a href="./deptManagerList.jsp?listPage=<%=listPage-1 %>&working=on&deptNo=<%=inputDeptNo %>&empName=<%=inputEmpName %>">이전</a>
			<%
					}
				}
			%>
			
			<span>현재 <%=listPage %> 페이지 / 총 <%=listLastPage %> 페이지</span>
			
			<%
				if (listPage < listLastPage) {
					if (searchWorking == false && searchDeptNo == null && searchEmpName == null) {
			%>
						<a href="./deptManagerList.jsp?listPage=<%=listPage+1 %>">다음</a>
						<a href="./deptManagerList.jsp?listPage=<%=listLastPage %>">마지막으로</a>
			<%
					} else if (searchWorking == true && searchDeptNo == null && searchEmpName == null) {
			%>
						<a href="./deptManagerList.jsp?listPage=<%=listPage+1 %>&working=on">다음</a>
						<a href="./deptManagerList.jsp?listPage=<%=listLastPage %>&working=on">마지막으로</a>
			<%
					} else if (searchWorking == false && searchDeptNo != null && searchEmpName == null) {
			%>
						<a href="./deptManagerList.jsp?listPage=<%=listPage+1 %>&deptNo=<%=inputDeptNo %>">다음</a>
						<a href="./deptManagerList.jsp?listPage=<%=listLastPage %>&deptNo=<%=inputDeptNo %>">마지막으로</a>
			<%
					} else if (searchWorking == false && searchDeptNo == null && searchEmpName != null) {
			%>
						<a href="./deptManagerList.jsp?listPage=<%=listPage+1 %>&empName=<%=inputEmpName %>">다음</a>
						<a href="./deptManagerList.jsp?listPage=<%=listLastPage %>&empName=<%=inputEmpName %>">마지막으로</a>
			<%
					} else if (searchWorking == true && searchDeptNo != null && searchEmpName == null) {
			%>
						<a href="./deptManagerList.jsp?listPage=<%=listPage+1 %>&working=on&deptNo=<%=inputDeptNo %>">다음</a>
						<a href="./deptManagerList.jsp?listPage=<%=listLastPage %>&working=on&deptNo=<%=inputDeptNo %>">마지막으로</a>
			<%
					} else if (searchWorking == true && searchDeptNo == null && searchEmpName != null) {
			%>
						<a href="./deptManagerList.jsp?listPage=<%=listPage+1 %>&working=on&empName=<%=inputEmpName %>">다음</a>
						<a href="./deptManagerList.jsp?listPage=<%=listLastPage %>&working=on&empName=<%=inputEmpName %>">마지막으로</a>
			<%
					} else if (searchWorking == false && searchDeptNo != null && searchEmpName != null) {
			%>
						<a href="./deptManagerList.jsp?listPage=<%=listPage+1 %>&deptNo=<%=inputDeptNo %>&empName=<%=inputEmpName %>">다음</a>
						<a href="./deptManagerList.jsp?listPage=<%=listLastPage %>&deptNo=<%=inputDeptNo %>&empName=<%=inputEmpName %>">마지막으로</a>
			<%
					} else if (searchWorking == true && searchDeptNo != null && searchEmpName != null) {
			%>
						<a href="./deptManagerList.jsp?listPage=<%=listPage+1 %>&working=on&deptNo=<%=inputDeptNo %>&empName=<%=inputEmpName %>">다음</a>
						<a href="./deptManagerList.jsp?listPage=<%=listLastPage %>&working=on&deptNo=<%=inputDeptNo %>&empName=<%=inputEmpName %>">마지막으로</a>
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