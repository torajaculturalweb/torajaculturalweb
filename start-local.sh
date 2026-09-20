#!/usr/bin/env sh
set -e
cd "$(dirname "$0")"

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js belum terpasang. Instal Node.js LTS dari https://nodejs.org"
  exit 1
fi

if [ ! -d node_modules ]; then
  echo "Menginstal dependency untuk pertama kali..."
  npm install
fi

echo "Website tersedia di http://localhost:5173"
npm run dev
