<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>民眾查詢罰待紀錄</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .form-container {
           background-color: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
            max-width: 400px;
            width: 100%;
        }
        h1 {
            font-size: 28px;
            margin-bottom: 20px;
            text-align: center;
            color: #4CAF50;
            font-weight: bold;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
            font-size: 14px;
        }
         input {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
            transition: border-color 0.3s ease;
        }

        input:focus {
            border-color: #4CAF50;
            outline: none;
        }

        button {
            width: 100%;
            padding: 12px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.2s ease;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        button:hover {
            background-color: #45a049;
            transform: translateY(-2px);
        }

        button:active {
            transform: translateY(0);
        }
        .error-message {
            color: red;
            font-size: 14px;
            margin-top: -10px;
            margin-bottom: 15px;
            text-align: center;
        }
    </style>
    <script>
        function validateForm() {
            // 取得輸入的值
            const ownerId = document.getElementById("ownerId").value;
            const plateNumber = document.getElementById("plateNumber").value;

            // 身分證字號格式：1個大寫英文字母 + 9個數字
            const ownerIdRegex = /^[A-Z][0-9]{9}$/;
            // 車牌號碼格式：僅允許大寫英文字母和數字
            const plateNumberRegex = /^[A-Z0-9]+$/;

            // 錯誤訊息容器
            const errorMessage = document.getElementById("error-message");
            errorMessage.textContent = ""; // 清空錯誤訊息

            // 驗證身分證字號
            if (!ownerIdRegex.test(ownerId)) {
                errorMessage.textContent = "身分證字號格式錯誤，需為 1 個大寫英文字母加 9 個數字。";
                return false;
            }

            // 驗證車牌號碼
            if (!plateNumberRegex.test(plateNumber)) {
                errorMessage.textContent = "車牌號碼格式錯誤，僅允許大寫英文字母和數字。";
                return false;
            }

            return true; // 格式正確，允許提交
        }
    </script>
</head>
<body>
    <div class="form-container">
        <h1>民眾查詢</h1>
        <form action="history.jsp" method="POST" onsubmit="return validateForm()">
            <div id="error-message" class="error-message"></div>
            <label for="ownerId">身分證字號</label>
            <input type="text" id="ownerId" name="ownerId" placeholder="輸入身分證字號" required>
            <br>
            <label for="plateNumber">車牌號碼</label>
            <input type="text" id="plateNumber" name="plateNumber" placeholder="輸入車牌號碼" required>
            <br>
            <button type="submit">查詢</button>
        </form>

    </div>
</body>
</html>
