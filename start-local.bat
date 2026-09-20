@echo off
setlocal
cd /d "%~dp0"

echo ========================================
echo   TORAJA PUSAKA - LOCAL DEVELOPMENT
echo ========================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js belum terpasang.
  echo Download versi LTS dari https://nodejs.org
  echo Setelah instalasi selesai, jalankan file ini kembali.
  pause
  exit /b 1
)

if not exist "node_modules" (
  echo Menginstal dependency untuk pertama kali...
  call npm install
  if errorlevel 1 (
    echo Instalasi dependency gagal. Periksa koneksi internet.
    pause
    exit /b 1
  )
)

echo.
echo Website akan dibuka di http://localhost:5173
echo Jangan tutup jendela ini selama website digunakan.
echo Tekan Ctrl+C untuk menghentikan server.
echo.

start "" cmd /c "timeout /t 3 /nobreak >nul && start "" http://localhost:5173/"
call npm run dev
endlocal
