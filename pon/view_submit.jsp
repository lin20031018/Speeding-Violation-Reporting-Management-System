<%@ page import="java.sql.*" %>
<%@page pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>違規記錄查詢與送出</title>
    <style>
        body {
             font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f9f9f9;
            color: #333;
        }
		h1 {
            text-align: center;
            color: #4CAF50;
            margin-bottom: 20px;
        }
		
        .record {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .record label {
            margin-left: 10px;
        }
        .record input[type="checkbox"] {
            margin-right: 10px;
        }
		table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            margin-bottom: 20px;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: center;
        }

        th {
            background-color: #f4f4f4;
            font-weight: bold;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        tr:hover {
            background-color: #f1f1f1;
        }
        .submit-button {
            margin-top: 20px;
        }
		.container {
			width: 80%;
			margin: auto;
		}
		.back-button-container {
            text-align: center;
            margin-top: 20px;
        }

        .back-button {
            display: inline-block;
            padding: 12px 25px;
            font-size: 1.2em;
            color: white;
            background-color: #4CAF50;
            text-decoration: none;
            border-radius: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: background-color 0.3s, transform 0.3s;
        }

        .back-button:hover {
            background-color: #45a049;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
<div class="container">
    <%
    String employeeId = (String) session.getAttribute("employeeId");
    if (employeeId == null || employeeId.isEmpty()) {
        %><script>
                alert("請登入在試！");
                window.location.href = "login.jsp";
        </script><%
    }
    %>
    <h1>違規記錄查詢與送出</h1>
    <h3>登入帳號:<%=employeeId%></h3>
	
	<div class="record" >
            <table>
				<thead>
					<tr>
						<th>違規單號</th> 
						<th>車牌</th> 
						<th>違規時間</th> 
						<th>狀態</th> 
						<th>列印</th> 
						
					</tr>
				</thead>
				<tbody>
    
        <%
            // 資料庫連接參數
            String dbURL = "jdbc:mysql://localhost:3306/illegalvehical?serverTimezone=UTC";
            String dbUser = "root";
            String dbPassword = "1234";

            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                // 加載 MySQL JDBC 驅動
                Class.forName("com.mysql.cj.jdbc.Driver");

                // 建立連線
                conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

                // 執行查詢
                String query = "SELECT `違規單號`, `車牌號碼`, `違規時間`, `狀態` FROM illegalvehical.violation_of_speeding WHERE `狀態` = '未送出' AND `車牌確認狀態`='已確認'";
                stmt = conn.createStatement();
                rs = stmt.executeQuery(query);
				// 顯示查詢結果
                while (rs.next()) {
                    String violationID = rs.getString("違規單號");
                    String licensePlate = rs.getString("車牌號碼");
                    Timestamp violationTime = rs.getTimestamp("違規時間");
                    String status = rs.getString("狀態");
               
        %>
        
				
                <tr>
                    <td><%= violationID %></td>
                    <td><%= licensePlate %> </td>
					<td><%= violationTime %> </td>
					<td><%= status %></td>
					<td><a href="print.jsp?violationID=<%=violationID%>">罰單詳情</a></td>
                </tr>
  
				
        <%
                }
            } catch (Exception e) {
                out.println("<p>Error: " + e.getMessage() + "</p>");
            } finally {
                // 關閉資源
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
            }
        %>
		</tbody>
			</table>
        </div>
		<div class="back-button-container">
			<a href="loginout.jsp" class="back-button">登出</a>
		</div>
</div>
</body>
</html>

