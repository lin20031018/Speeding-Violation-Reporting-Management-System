<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalDate" %>
<%
    String violationid = request.getParameter("violationid");

    if (violationid == null || violationid.isEmpty()) {
        response.getWriter().write("ERROR: Violation ID is missing");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    PreparedStatement printRecordStmt = null;
    PreparedStatement fineStmt = null;
    ResultSet rs = null;

    try {
        String dbURL = "jdbc:mysql://localhost:3306/illegalvehical?serverTimezone=UTC";
        String dbUser = "root";
        String dbPassword = "1234";

        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        String updateQuery = "UPDATE violation_of_speeding SET 狀態 = '已送出' WHERE 違規單號 = ?";
        pstmt = conn.prepareStatement(updateQuery);
        pstmt.setString(1, violationid);

        int rowsUpdated = pstmt.executeUpdate();
        if (rowsUpdated > 0) {
            
            String employeeId = (String) session.getAttribute("employeeId");
            String ipAddress = InetAddress.getLocalHost().getHostAddress(); 
            String printTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
            String fineAmount = "";

            String fineQuery = "SELECT * FROM speedingfines WHERE 違規單號 = ?";
            fineStmt = conn.prepareStatement(fineQuery);
            fineStmt.setString(1, violationid);
            rs = fineStmt.executeQuery();
            
            if (rs.next()) {
                fineAmount = rs.getString("fine_amount");
            }

            LocalDate paymentDeadline = LocalDate.now().plusDays(30);
            String paymentStatus = "未繳費"; 

            String insertPrintRecordQuery = "INSERT INTO 罰單列印紀錄資料表 (違規單號, 列印員工ID, 列印時間, 處理機IP位置, 罰單金額, 繳費時限, 繳費狀態) VALUES (?, ?, ?, ?, ?, ?, ?)";
            printRecordStmt = conn.prepareStatement(insertPrintRecordQuery);
            printRecordStmt.setString(1, violationid);
            printRecordStmt.setString(2, employeeId);
            printRecordStmt.setString(3, printTime);
            printRecordStmt.setString(4, ipAddress);
            printRecordStmt.setString(5, fineAmount);
            printRecordStmt.setDate(6, java.sql.Date.valueOf(paymentDeadline));
            printRecordStmt.setString(7, paymentStatus);

            int printRecordInserted = printRecordStmt.executeUpdate();
            if (printRecordInserted > 0) {
                response.getWriter().write("SUCCESS");
            } else {
                response.getWriter().write("ERROR: Failed to insert print record");
            }
        } else {
            response.getWriter().write("ERROR: No rows updated");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.getWriter().write("ERROR: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (printRecordStmt != null) printRecordStmt.close();
        if (fineStmt != null) fineStmt.close();
        if (conn != null) conn.close();
    }
%>

