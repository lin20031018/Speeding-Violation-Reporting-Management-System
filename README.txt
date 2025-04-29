桌面/
├── car                  # app.py是後端,Dump20250108.sql是MySQL資料庫
├── Taipei-City-Dashboard-main        # 臺北城市儀表板，用docker開啟
├── run_process_board_data.bat # 自動化將app.py輸入的地點資料(geojson檔案)放到臺北城市儀表板前端>public>mapdata中
├── camera.csv #預先放的超速檔案，透過docker進入postgre SQL，匯入到speeding表格中
└── 期末說明.pptx.pdf 


D/
├── pon/ #透過JSP開啟，開罰單的JSP



C/
├── 使用者/mray3/process_board_data.py #run_process_board_data.bat所執行的程式