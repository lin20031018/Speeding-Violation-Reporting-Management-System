import pymysql
import json
import os
import csv
from decimal import Decimal
from datetime import datetime

# 配置 MySQL 連線參數
MYSQL_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "1234",
    "database": "illegalvehical"
}

# GeoJSON 輸出目錄
GEOJSON_OUTPUT_DIR = r"your_file\Taipei-City-Dashboard-main\Taipei-City-Dashboard-FE\public\mapData"

# CSV 輸出檔案路徑
desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")
CSV_OUTPUT_PATH = os.path.join(desktop_path, "Speeding.csv")

def fetch_mysql_data():
    """從 MySQL View 讀取資料"""
    try:
        connection = pymysql.connect(**MYSQL_CONFIG)
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        cursor.execute("SELECT * FROM board")
        data = cursor.fetchall()

        # 標準化資料格式
        for row in data:
            for key, value in row.items():
                if isinstance(value, Decimal):
                    row[key] = float(value)  # 確保數值類型
                elif isinstance(value, datetime):  # 格式化日期時間
                    row[key] = value.strftime('%Y-%m-%d %H:%M:%S')
                elif value is None:  # 替換空值
                    row[key] = "未分類" if key == "超速級距" else ""

        cursor.close()
        connection.close()
        print("成功從 MySQL View 讀取資料")
        return data
    except pymysql.MySQLError as e:
        print(f"從 MySQL 讀取資料時發生錯誤: {e}")
        return []

def append_to_csv(data):
    """將資料追加至 CSV 檔案"""
    if not data:
        print("沒有資料可供追加至 CSV")
        return

    # 檢查 CSV 檔案是否存在，若不存在則建立新檔案
    file_exists = os.path.exists(CSV_OUTPUT_PATH)
    os.makedirs(os.path.dirname(CSV_OUTPUT_PATH), exist_ok=True)

    fieldnames = data[0].keys()
    with open(CSV_OUTPUT_PATH, mode="a", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        if not file_exists:  # 若為新檔案，寫入欄位名稱
            writer.writeheader()
        writer.writerows(data)  # 追加資料

    print(f"資料已追加至 CSV 檔案 {CSV_OUTPUT_PATH}")

def convert_csv_to_geojson():
    """將 CSV 檔案轉換為 GeoJSON 格式"""
    if not os.path.exists(CSV_OUTPUT_PATH):
        print("CSV 檔案不存在，無法進行轉換")
        return

    geojson_data = {
        "type": "FeatureCollection",
        "features": []
    }

    with open(CSV_OUTPUT_PATH, mode="r", encoding="utf-8") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            feature = {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [float(row["經度"]), float(row["緯度"])]
                },
                "properties": {key: row[key] for key in row if key not in ["經度", "緯度"]}
            }
            geojson_data["features"].append(feature)

    geojson_path = os.path.join(GEOJSON_OUTPUT_DIR, "Speeding.geojson")
    os.makedirs(os.path.dirname(geojson_path), exist_ok=True)

    with open(geojson_path, "w", encoding="utf-8") as geojson_file:
        json.dump(geojson_data, geojson_file, ensure_ascii=False, indent=4)

    print(f"GeoJSON 檔案已儲存至 {geojson_path}")

def main():
    # 步驟 1: 從 MySQL 讀取資料並追加至 CSV
    data = fetch_mysql_data()
    append_to_csv(data)

    # 步驟 2: 將 CSV 轉換為 GeoJSON
    convert_csv_to_geojson()

if __name__ == "__main__":
    main()
