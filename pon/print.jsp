<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalDate" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.4.0/jspdf.umd.min.js"></script>
    <style>
        body {
    font-family: "Microsoft JhengHei", Arial, sans-serif;
    background-color: #ffffff;
    margin: 0;
    padding: 20px;
}
h1,h2 {
     text-align: center;
     color:#333;
     margin-bottom: 2px;
}
.row {
  display: flex;
  justify-content: space-between; /* 左右分開對齊 */
  align-items: center;           /* 垂直置中 */
  margin: 2px;
}

.left {
  text-align: left; /* 左對齊 (可選) */
}

.right {
  text-align: right; /* 右對齊 (可選) */
}

.print-container {
            width: 90%;
            max-width: 800px;
            background: white;
            border: 1px solid black;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .print-table {
            display: grid;
            grid-template-columns: 1fr 1fr;
            grid-template-rows: repeat(9, 1fr);
            gap: 0;
            border: 1px solid black;
        }

        .print-table div {
            border: 1px solid black;
            padding: 10px;
            font-size: 16px;
            text-align: left;
        }
		.inchun{
		    grid-row: span 2;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 14px;
		}
        .photo-content {
            grid-row: span 4;
            display: flex;
            justify-content: center;
        }
        .photo-content img {
            width:100%;
            height:100%;
        }

        .three-split {
            grid-column: span 1;
        }

        .full-width {
            grid-column: span 2;
        }
.data-container {
    width: 50%;
    height: 40%;
    margin: 0 auto;
    background-color:#f9cdcd;
    border: 2px solid #000;
    padding: 20px;
    box-sizing: border-box;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
}

.data-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
}
.data-row {
    display: flex;
    justify-content: space-between;
    padding: 8px 0;
    border-bottom: 1px solid #ddd;
}
.data-row:last-child {
    border-bottom: none;
}

.button-container {
    text-align: center;
    margin-top: 20px;
}
.button {
     background-color: #4CAF50;
     color: white;
     padding: 8px 15px;
     border: none;
     border-radius: 4px;
     cursor: pointer;
     transition: background-color 0.3s ease, transform 0.2s ease;
	 text-decoration: none; /* 去除按鈕底線 */
}
.button:hover {
   background-color: #45a049;
   transform: translateY(-2px);
}
.no-data {
    color: red;
    text-align: center;
    margin: 20px 0;
}
@media print {
    /* 隱藏按鈕區域 */
    .button-container {
        display: none;
    }
    /* 取消頁面背景顏色 */
    body {
        background-color: white;
    }
}

    </style>
</head>
<body>
    
    <%
    String employeeId = (String) session.getAttribute("employeeId");
    if (employeeId == null || employeeId.isEmpty()) {
        // 如果 session 中沒有 employeeId，提示錯誤訊息
        response.getWriter().write("ERROR: Employee ID is missing in the session");
        return;
    }
    String violationid = request.getParameter("violationID");
    LocalDate paymentDeadline = LocalDate.now().plusDays(30);

            String ownerName = ""; 
            String plateNumber = "";
            String vehicleType = "";
            String address = "";
            String violationTime = "";
            String fineAmount = "";
            String violationPlace = "";
            String violationPhoto = "";
            String roadlimit = "";
            String speed = "";

        if (violationid != null && !violationid.trim().isEmpty()) {
            String dbURL = "jdbc:mysql://localhost:3306/illegalvehical?serverTimezone=UTC";
            String dbUser = "root";
            String dbPassword = "1234";

            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                // 加載 MySQL JDBC 驅動
                Class.forName("com.mysql.cj.jdbc.Driver");

                // 建立連線
                conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

                // 執行查詢
                String query = "SELECT * FROM speedingfines WHERE 違規單號= ?";
                stmt = conn.prepareStatement(query);
                stmt.setString(1, violationid);
                rs = stmt.executeQuery();

                if (rs.next()) {
                        ownerName = rs.getString("車主姓名");
                        plateNumber = rs.getString("車牌號碼");
                        vehicleType = rs.getString("車輛類型");
                        address = rs.getString("寄送地址");
                        violationTime = rs.getString("違規時間");
                        fineAmount = rs.getString("fine_amount");
                        violationPlace = rs.getString("違規地點");
                        violationPhoto = rs.getString("違規照片");
                        roadlimit = rs.getString("道路速限");
                        speed = rs.getString("車輛時速");


						}

            
        // 模擬列印時間
        String printTime = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());

    %>
<div class="data-container" ID="data-container">
	<h1>中原大學</h1>
	<h2>違反道路交通管理事件通知單</h2>
	<div class="row">
	  <h3 class="left">(通知聯) 資管三甲 第九組</h3>
	  <h3 class="right">違規單號: <%= violationid %></h3>
	</div>
		<div class="print-table">
			<div>駕駛人:<%= ownerName%></div>
			<div class="inchun">印章</div>
			<div class="three-split">車牌號碼:<%= plateNumber%></div>
			
			<div class="three-split">登記車主:<%= ownerName%></div>
			<div class="three-split">車輛類型:<%= vehicleType%></div>
			<div class="full-width">登記地址:<%= address%></div>
			<div>違規地點:<%= violationPlace %></div>
			<div>道路速限:<%= roadlimit %></div>
			<div>違規時間:<%= violationTime %></div>
			<div>違規時速:<%= speed %></div>
			<div>處罰金額:<%= fineAmount %></div>
			<div class="photo-content"> <img src=<%= violationPhoto%> crossorigin="anonymous" alt="照片顯示"></div>
			<div>繳費期限:<%= paymentDeadline %></div>
			<div>列印人員編號:<%= employeeId %></div>
			<div>列印時間:<%= printTime %></div>
		</div>
	
</div>

	<div class="button-container">
        <a href="javascript:updateAndPrint()" class="button">列印</a>
        <a href="view_submit.jsp" class="button">返回</a>
    </div>
    <script>
            function updateAndPrint() {
            fetch(`updateDatabase.jsp?violationid=<%=violationid%>`, { method: 'GET' }) 
                .then(response => response.text()) 
                .then(data => { 
                    if (data.trim() === 'SUCCESS') {
                        const element = document.getElementById('data-container'); 
                        html2canvas(element, {
                            scale: 2, // 提高清晰度
                            useCORS: true, // 支持跨域資源
                            scrollX: 0, // 確保渲染時不受視窗滾動影響
                            scrollY: 0,
                            windowWidth: element.scrollWidth, // 渲染完整寬度
                            windowHeight: element.scrollHeight // 渲染完整高度
                        }).then(canvas => {
                            const imgData = canvas.toDataURL('D:\pon\pdf');
                            const { jsPDF } = window.jspdf;
                            const pdf = new jsPDF({
                                orientation: 'portrait',
                                unit: 'px',
                                format: [canvas.width, canvas.height]
                            });
                            pdf.addImage(imgData, 'PNG', 0, 0, canvas.width, canvas.height);
                            pdf.save(`違規單_<%= violationid %>.pdf`);
                            alert("PDF 已生成並下載完成！");
							window.location.href = "view_submit.jsp";
                        }).catch(error => {
                            console.error('Error generating PDF:', error);
                            alert('生成 PDF 時發生錯誤，請稍後重試。');
                        });
                    } else { 
                        alert('資料更新失敗：' + data); 
                    }
                })
                /*.catch(error => { 
                    console.error('Fetch error:', error); 
                    alert('資料更新失敗，請稍後重試。'); 
                });*/
        }
    </script>

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
        }
    %>

</body>
</html>