from datetime import datetime
from flask import Flask, redirect, render_template, request, session, url_for
import mysql.connector
import os
from werkzeug.utils import secure_filename
import subprocess
from flask import jsonify
from flask import send_from_directory
import requests


app = Flask(__name__)
# 初始化 Flask 應用並修改靜態目錄
app = Flask(__name__, static_folder='uploaded_photos')
app.secret_key = 'your_secret_key'


# Google Maps API 金鑰
GOOGLE_MAPS_API_KEY = ""#自行填寫

def get_coordinates_from_address(address):
    """
    使用 Google Maps Geocoding API 將地址轉換為經緯度
    """
    url = f"https://maps.googleapis.com/maps/api/geocode/json"
    params = {
        "address": address,
        "key": GOOGLE_MAPS_API_KEY
    }
    response = requests.get(url, params=params)
    if response.status_code == 200:
        data = response.json()
        if data["status"] == "OK":
            location = data["results"][0]["geometry"]["location"]
            return location["lat"], location["lng"]
        else:
            raise ValueError(f"Geocoding API 回應錯誤：{data['status']}")
    else:
        raise ConnectionError(f"無法連接到 Geocoding API，狀態碼：{response.status_code}")




# 提供 uploaded_photos 資料夾中的靜態文件
@app.route('/uploaded_photos/<path:filename>')
def uploaded_photos(filename):
    return send_from_directory('uploaded_photos', filename)

# 資料庫配置
db_config = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', '1234'),
    'database': os.getenv('DB_NAME', 'illegalvehical')
}

# 圖片保存目錄
UPLOAD_FOLDER = 'uploaded_photos'  # 使用相對路徑
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# 允許的文件格式
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

# OpenALPR 執行檔路徑
ALPR_PATH = r"C:\Program Files\openalpr_64\alpr.exe"

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/submit_violation', methods=['POST'])
def submit_violation():
    if request.method != 'POST':
        return redirect(url_for('index'))
    
    try:
        # 檢查是否有文件
        if 'violation_photo' not in request.files:
            return '沒有上傳文件', 400
        
        violation_photo = request.files['violation_photo']
        if violation_photo.filename == '':
            return '沒有選擇文件', 400
            
        if not allowed_file(violation_photo.filename):
            return '不允許的文件格式', 400

        # 接收表單數據
        violation_id = request.form.get('violation_id')
        violation_place = request.form.get('violation_location')
        violation_time = request.form.get('violation_time')
        equipment_id = request.form.get('equipment_id')
        speed_limit = request.form.get('speed_limit')
        vehicle_speed = request.form.get('vehicle_speed')
        status = request.form.get('status', '未送出')

        # 呼叫 Geocoding API 獲取經緯度
        latitude, longitude = get_coordinates_from_address(violation_place)

        # 保存違規照片
        photo_filename = secure_filename(violation_photo.filename)
        photo_path = os.path.join(app.config['UPLOAD_FOLDER'], photo_filename)
        violation_photo.save(photo_path)

        # 資料庫操作
        with mysql.connector.connect(**db_config) as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO `violation_of_speeding` (
                        `違規單號`, `違規照片`, `車牌號碼`, `違規地點`, `違規時間`, 
                        `紀錄設備ID`, `道路速限`, `車輛時速`, `經度`, `緯度`, `狀態`
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    violation_id, photo_path, '', violation_place, violation_time,
                    equipment_id, speed_limit, vehicle_speed, longitude, latitude, status
                ))
                conn.commit()

        return render_template('submit_success.html', latitude=latitude, longitude=longitude)
        
    except Exception as e:
        print(f"Error in submit_violation: {str(e)}")
        return f"發生錯誤：{str(e)}", 500



@app.route('/view_license_plate', methods=['GET'])
def view_license_plate():
    try:
        # 連接資料庫
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        # 查詢最新的違規紀錄
        cursor.execute("SELECT `違規單號`, `違規照片` FROM `violation_of_speeding` ORDER BY `違規時間` DESC LIMIT 1")
        result = cursor.fetchone()

        if not result:
            return "資料庫中沒有可處理的紀錄。"

        violation_id, image_path = result
        print(f"從資料庫讀取的圖片路徑：{image_path}")

        # 標準化路徑並檢查文件是否存在
        image_path = os.path.normpath(image_path.strip())
        if not os.path.exists(image_path):
            return f"圖片文件不存在，路徑：{image_path}"

        # 執行 OpenALPR 命令
        result = subprocess.run(
            [ALPR_PATH, "-c", "us", image_path],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return f"車牌辨識失敗：{result.stderr}"

        # 處理辨識結果
        lines = result.stdout.splitlines()
        print(f"OpenALPR 返回值：{lines}")

        if len(lines) > 1:
            # 提取第一個有效結果
            first_result = lines[1].strip()  # 第二行為第一個結果
            parts = first_result.split("\t")  # 根據制表符分割
            if len(parts) == 2:  # 確保有車牌號碼和信心水準字段
                license_plate = parts[0].strip()  # 提取車牌號碼部分
                if license_plate.startswith('-'):  # 如果車牌號碼以 '-' 開頭，去掉它
                    license_plate = license_plate[1:].strip()
                confidence_str = parts[1].replace('confidence:', '').strip()  # 提取信心水準
                try:
                    confidence = float(confidence_str)  # 轉換為浮點數
                except ValueError:
                    return "無法解析信心水準，格式錯誤。"
                # 確保車牌號碼和信心水準有效
                if not license_plate:
                    return "提取的車牌號碼為空，請檢查輸出格式或圖片質量。"
            else:
                return "OpenALPR 返回的結果無法解析，結構不正確。"
        else:
            current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            cursor.execute("""
                            INSERT INTO `人工辨識資料表` (
                                `違規單號`, `交通佐理員員工ID`, `時間`, `處理機IP位置`,
                                `事件類型`, `辨識車牌號碼`, `處理時間`
                            )
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """, (violation_id, '', current_time, '', '未處理', '辨識錯誤', ''))
            conn.commit()
            return render_template('manual_fail.html', violation_id=violation_id)





                # 判斷信心水準
        if confidence < 85.0:
                        # 信心水準偏低，插入人工辨識資料表
                        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                        cursor.execute("""
                            INSERT INTO `人工辨識資料表` (
                                `違規單號`, `交通佐理員員工ID`, `時間`, `處理機IP位置`,
                                `事件類型`, `辨識車牌號碼`, `處理時間`
                            )
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """, (violation_id, '', current_time, '', '未處理', license_plate, ''))
                        conn.commit()
                        return render_template('low_confidence.html', license_plate=license_plate, confidence=confidence)
        else:
                        # 信心水準足夠，插入 AI 辨識資料表並更新車牌號碼
                        ai_model_version = "OpenALPR v1.0"
                        cursor.execute("""
                            UPDATE `violation_of_speeding` 
                            SET `車牌號碼` = %s 
                            WHERE `違規單號` = %s
                        """, (license_plate, violation_id))
                        cursor.execute("""
                            INSERT INTO `ai辨識資料表` (`違規單號`, `AI辨識信心水準`, `AI模型版本`) 
                            VALUES (%s, %s, %s)
                        """, (violation_id, confidence, ai_model_version))
                        conn.commit()
                        return render_template(
                            'view_license_plate.html',
                            violation_id=violation_id,
                            license_plate=license_plate,
                            confidence=confidence,
                            ai_model_version=ai_model_version
                        )


    except Exception as e:
        print(f"資料庫操作錯誤：{e}")
        return f"資料庫操作錯誤：{e}", 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()




@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        # 從表單接收資料
        employee_id = request.form.get('employee_id')
        password = request.form.get('password')

        # 連接資料庫驗證帳號密碼
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        try:
            cursor.execute("""
                SELECT * FROM `交通部管理帳號資料表`
                WHERE `員工編號` = %s AND `密碼` = %s
            """, (employee_id, password))
            user = cursor.fetchone()

            if user:
                # 登入成功，保存員工編號到 session
                session['employee_id'] = employee_id
                return render_template('view.html')  # 必須加上 return
            else:
                # 登入失敗，返回錯誤提示
                return render_template('login.html', error='員工編號或密碼不正確')
        except mysql.connector.Error as e:
            return f"資料庫操作錯誤：{e}"
        finally:
            cursor.close()
            conn.close()
    else:
        # GET 請求顯示登入頁面
        return render_template('login.html')
    


@app.route('/ai_results')
def ai_results():
    try:
        # 連接資料庫
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        # 查詢數據
        query = """
            SELECT 
                ai.`AI辨識資料表ID` AS ai_id,
                v.`違規單號` AS violation_id,
                v.`違規照片` AS violation_photo,
                v.`車牌號碼` AS license_plate,
                v.`違規時間` AS violation_time
            FROM `AI辨識資料表` ai
            INNER JOIN `violation_of_speeding` v
            ON ai.`違規單號` = v.`違規單號`
        """
        cursor.execute(query)
        ai_results = cursor.fetchall()

        # 修正圖片路徑
        for result in ai_results:
            if result['violation_photo']:
                # 確保返回的路徑正確，不含 /static
                result['violation_photo'] = '/' + result['violation_photo'].lstrip('/')

        # 傳遞數據到前端模板
        return render_template('ai.html', ai_results=ai_results)
    except mysql.connector.Error as e:
        return f"資料庫錯誤：{e}"
    finally:
        cursor.close()
        conn.close()



@app.route('/update_status', methods=['POST'])
def update_status():
    violation_id = request.form.get('violation_id')  # 從表單接收違規單號

    try:
        # 連接資料庫
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        # 檢查欄位是否已存在
        cursor.execute("""
            SELECT COUNT(*)
            FROM information_schema.COLUMNS
            WHERE TABLE_NAME = 'violation_of_speeding'
              AND TABLE_SCHEMA = DATABASE()
              AND COLUMN_NAME = '車牌確認狀態'
        """)
        column_exists = cursor.fetchone()[0]

        # 如果欄位不存在，則新增欄位
        if column_exists == 0:
            cursor.execute("""
                ALTER TABLE `violation_of_speeding`
                ADD COLUMN `車牌確認狀態` VARCHAR(50) DEFAULT NULL
            """)

        # 更新資料表中的車牌確認狀態
        query = """
            UPDATE `violation_of_speeding`
            SET `車牌確認狀態` = '未確認'
            WHERE `違規單號` = %s
        """
        cursor.execute(query, (violation_id,))
        conn.commit()

        # 返回成功訊息
        return jsonify({"message": "車牌確認狀態更新成功"}), 200
    except mysql.connector.Error as e:
        return jsonify({"message": f"資料庫操作錯誤：{e}"}), 500
    finally:
        cursor.close()
        conn.close()




#返回按鈕動作
@app.route('/view', methods=['GET'])
def view():
    if 'employee_id' not in session:
        return redirect('/login')  # 如果未登入，跳轉到登入頁面
    return render_template('view.html')


@app.route('/manual_results', methods=['GET'])
def manual_results():
    if 'employee_id' not in session:
        return redirect(url_for('login'))  # 如果 session 中沒有員工 ID，跳轉到登入頁

    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        # 抓取未處理的數據
        cursor.execute("""
            SELECT 
                ai.id人工辨識資料表 AS manual_id,
                ai.違規單號 AS violation_id,
                ai.事件類型 AS event_status
            FROM 人工辨識資料表 ai
            WHERE ai.事件類型 = '未處理'
        """)
        unprocessed_data = cursor.fetchall()

        # 抓取已處理的數據
        cursor.execute("""
            SELECT 
                ai.id人工辨識資料表 AS manual_id,
                ai.違規單號 AS violation_id,
                vs.違規照片 AS violation_photo,
                vs.車牌號碼 AS license_plate,
                vs.違規時間 AS violation_time,
                ai.處理機IP位置 AS processed_ip,
                ai.事件類型 AS event_status
            FROM 人工辨識資料表 ai
            JOIN violation_of_speeding vs ON ai.違規單號 = vs.違規單號
            WHERE ai.事件類型 = '已處理'
        """)
        processed_data = cursor.fetchall()

        # 傳遞員工 ID 和數據到模板
        return render_template('manual.html', 
                               employee_id=session['employee_id'],
                               unprocessed_data=unprocessed_data, 
                               processed_data=processed_data)
    except mysql.connector.Error as e:
        return f"資料庫操作錯誤：{e}"
    finally:
        cursor.close()
        conn.close()

@app.route('/manual_input/<violation_id>', methods=['GET'])
def manual_input(violation_id):
    if 'employee_id' not in session:
        return redirect(url_for('login'))  # 如果未登入，重定向到登入頁面

    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        # 查詢違規單號對應的數據
        cursor.execute("""
            SELECT 
                vs.違規單號 AS violation_id,
                vs.違規照片 AS violation_photo,
                ai.辨識車牌號碼 AS ai_result
            FROM violation_of_speeding vs
            LEFT JOIN 人工辨識資料表 ai ON vs.違規單號 = ai.違規單號
            WHERE vs.違規單號 = %s
        """, (violation_id,))
        data = cursor.fetchone()

        if not data:
            return "未找到相關違規數據", 404

        # 修正圖片路徑為 "/uploaded_photos\A02.png" 格式
        if data['violation_photo']:
            data['violation_photo'] = "/" + data['violation_photo'].lstrip("\\/")

        return render_template('manual_input.html', 
                               employee_id=session['employee_id'],
                               data=data)
    except mysql.connector.Error as e:
        return f"資料庫操作錯誤：{e}"
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()


@app.route('/submit_manual_input', methods=['POST'])
def submit_manual_input():
    if 'employee_id' not in session:
        return redirect(url_for('login'))  # 如果未登入，重定向到登入頁面

    try:
        # 從 session 中獲取 employee_id
        employee_id = session['employee_id']

        # 獲取表單數據
        violation_id = request.form.get('violation_id')
        manual_result = request.form.get('manual_result')
        processed_ip = request.form.get('processed_ip')

        if not violation_id or not manual_result or not processed_ip:
            return "所有欄位均為必填", 400

        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        # 更新人工辨識資料表，新增交通佐理員員工ID的插入
        cursor.execute("""
            UPDATE 人工辨識資料表
            SET 事件類型 = '已處理', 辨識車牌號碼 = %s, 處理機IP位置 = %s, 交通佐理員員工ID = %s
            WHERE 違規單號 = %s
        """, (manual_result, processed_ip, employee_id, violation_id))
        conn.commit()
        # 更新 violation_of_speeding 表中的車牌號碼欄位
        cursor.execute("""
            UPDATE violation_of_speeding
            SET 車牌號碼 = %s
            WHERE 違規單號 = %s
        """, (manual_result, violation_id))
        conn.commit()

        return redirect(url_for('manual_results'))  # 返回人工辨識總覽
    except mysql.connector.Error as e:
        return f"資料庫操作錯誤：{e}"
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()





@app.route('/vehicle_status', methods=['GET'])
def vehicle_status():
    try:
        # 獲取查詢條件
        status = request.args.get('status', '未確認')  # 預設為未確認
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)

        if status == '未確認':
            # 查詢未確認的資料
            cursor.execute("""
                SELECT 違規單號, 車牌號碼, 車牌確認狀態
                FROM violation_of_speeding
                WHERE 車牌確認狀態 = %s
            """, (status,))
        elif status == '已確認':
            # 查詢已確認或無效車牌的資料
            cursor.execute("""
                SELECT 違規單號, 違規照片, 車牌號碼, 違規時間, 違規地點, 紀錄設備ID, 車輛時速, 道路速限, 車牌確認狀態
                FROM violation_of_speeding
                WHERE 車牌確認狀態 IN ('已確認', '無效車牌')
            """)

        results = cursor.fetchall()

        # 修正路徑為 "/uploaded_photos\A01.png" 格式
        for row in results:
            if '違規照片' in row and row['違規照片']:
                # 移除多餘的目錄部分
                filename = os.path.basename(row['違規照片'])
                row['違規照片'] = f"/uploaded_photos\\{filename}"

        return render_template('vehicle_status.html', results=results, selected_status=status)
    except mysql.connector.Error as e:
        return f"資料庫操作錯誤：{e}", 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()



@app.route('/vehicle_process', methods=['GET', 'POST'])
def vehicle_process():
    if request.method == 'GET':
        violation_id = request.args.get('violation_id')
        if not violation_id:
            return "缺少違規單號參數", 400

        try:
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor(dictionary=True)

            # 從違規資料中查詢車牌號碼
            cursor.execute("""
                SELECT 車牌號碼
                FROM violation_of_speeding
                WHERE 違規單號 = %s
            """, (violation_id,))
            violation_data = cursor.fetchone()

            if not violation_data:
                return "找不到該違規單號相關資料", 404

            plate_number = violation_data['車牌號碼']

            # 從車輛行照資料表中查詢相關車輛資料
            cursor.execute("""
                SELECT *
                FROM 車輛行照資料表
                WHERE 車牌號碼 = %s
            """, (plate_number,))
            vehicle_data = cursor.fetchone()

            return render_template(
                'vehicle_process.html',
                violation_id=violation_id,
                plate_number=plate_number,
                vehicle_data=vehicle_data
            )
        except mysql.connector.Error as e:
            return f"資料庫操作錯誤：{e}", 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()

    elif request.method == 'POST':
        # 接收表單數據
        violation_id = request.form.get('violation_id')
        action = request.form.get('action')  # '確認' 或 '無效車牌'

        if not violation_id or not action:
            return "缺少必要參數", 400

        status = '已確認' if action == '確認' else '無效車牌'

        try:
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor()

            # 更新車牌確認狀態
            cursor.execute("""
                UPDATE violation_of_speeding
                SET 車牌確認狀態 = %s
                WHERE 違規單號 = %s
            """, (status, violation_id))
            conn.commit()

            return redirect(url_for('vehicle_status'))  # 返回上一頁
        except mysql.connector.Error as e:
            return f"資料庫操作錯誤：{e}", 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5001, debug=True)
