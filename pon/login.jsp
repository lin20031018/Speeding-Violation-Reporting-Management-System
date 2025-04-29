<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>登入介面</title>
    <link rel="stylesheet" href="login.css">
</head>
<body>
    <div class="login-container">
        <h1>開單人員登入</h1>
        <form action="authenticate.jsp" method="post">
            <label for="username">人員編號</label>
            <input type="text" id="username" name="username" placeholder="輸入人員編號" required>
            <label for="password">密碼</label>
            <input type="password" id="password" name="password" placeholder="輸入密碼" required>
            <button type="submit">登入</button>
        </form>

    </div>
</body>
</html>
