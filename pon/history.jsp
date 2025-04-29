<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>歷史紀錄查詢</title>
    <link rel="stylesheet" href="history.css">
    <script>
        function togglePaymentStatus(status) {
            document.getElementById("unpaid-section").style.display = status === 'unpaid' ? 'block' : 'none';
            document.getElementById("paid-section").style.display = status === 'paid' ? 'block' : 'none';
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>歷史紀錄查詢</h1>
        <% 
            
            String ownerId = request.getParameter("ownerId");
            String plateNumber = request.getParameter("plateNumber");
            String dbURL = "jdbc:mysql://localhost:3306/illegalvehical?serverTimezone=UTC";
            String dbUser = "root";
            String dbPassword = "1234";

            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            String ownername = "";

            try {
                // 加載 MySQL JDBC 驅動
                Class.forName("com.mysql.cj.jdbc.Driver");

                // 建立連線
                conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

                // 驗證身分證字號和車牌號碼是否匹配
                String validationQuery = "SELECT `車主姓名` FROM 車輛行照資料表 WHERE `身分證字號` = ? AND `車牌號碼` = ?";
                PreparedStatement validationStmt = conn.prepareStatement(validationQuery);
                validationStmt.setString(1, ownerId);
                validationStmt.setString(2, plateNumber);
                ResultSet validationRs = validationStmt.executeQuery();

                if (!validationRs.next()) {
                    
                %>
                <script>
                alert("無效身份證字號或車牌號碼");
                window.location.href = "search.jsp";
                </script>
                <%    
                    
                } else {
                    ownername = validationRs.getString("車主姓名");
                }

                validationRs.close();
                validationStmt.close();

                // 查詢未繳費資料
                String unpaidQuery = "SELECT * FROM violationpaymentstatus WHERE `身分證字號` = ? AND `車牌號碼` = ? AND `繳費狀態` = '未繳費'";
                stmt = conn.prepareStatement(unpaidQuery);
                stmt.setString(1, ownerId);
                stmt.setString(2, plateNumber);
                rs = stmt.executeQuery();
        %>

        <h2>車主姓名：<%= ownername %></h2>
        <h2>車牌號碼：<%= plateNumber %></h2>

        <button onclick="togglePaymentStatus('unpaid')">未繳費資料</button>
        <button onclick="togglePaymentStatus('paid')">已繳費資料</button>

        <!-- 未繳費資料 -->
        <div id="unpaid-section" style="display: block;">
            <h3>未繳費資料</h3>
            <%
                if (!rs.isBeforeFirst()) {
            %>
                <p>無未繳費紀錄。</p>
            <%
                } else {
            %>
                <table>
                    <thead>
                        <tr>
                            <th>案件編號</th>
                            <th>違規時間</th>
                            <th>繳費期間</th>
                            <th>罰金</th>
                            <th>繳費狀態</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                                String violationid = rs.getString("違規單號");
                                String violationTime = rs.getString("違規時間");
                                String timeset = rs.getString("繳費時限");
                                String fineAmount = rs.getString("罰單金額");
                                String finestatus = rs.getString("繳費狀態");
                        %>
                        <tr>
                            <td><%= violationid %></td>
                            <td><%= violationTime %></td>
                            <td><%= timeset %></td>
                            <td><%= fineAmount %></td>
                            <td><%= finestatus %></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            <%
                }
            %>
        </div>

        <!-- 已繳費資料 -->
        <div id="paid-section" style="display: none;">
            <h3>已繳費資料</h3>
            <%
                String paidQuery = "SELECT * FROM violationpaymentstatus WHERE `身分證字號` = ? AND `車牌號碼` = ? AND `繳費狀態` = '已繳費'";
                stmt = conn.prepareStatement(paidQuery);
                stmt.setString(1, ownerId);
                stmt.setString(2, plateNumber);
                rs = stmt.executeQuery();

                if (!rs.isBeforeFirst()) {
            %>
                <p>無已繳費紀錄。</p>
            <%
                } else {
            %>
                <table>
                    <thead>
                        <tr>
                            <th>案件編號</th>
                            <th>違規時間</th>
                            <th>繳費時間</th>
                            <th>罰金</th>
                            <th>繳費狀態</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                                String violationid = rs.getString("違規單號");
                                String violationTime = rs.getString("違規時間");
                                String payTime = rs.getString("繳費時間");
                                String fineAmount = rs.getString("罰單金額");
                                String finestatus = rs.getString("繳費狀態");
                        %>
                        <tr>
                            <td><%= violationid %></td>
                            <td><%= violationTime %></td>
                            <td><%= payTime %></td>
                            <td><%= fineAmount %></td>
                            <td><%= finestatus %></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            <%
                }
            %>
        </div>

        <%
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        %>
    </div>
</body>
</html>

