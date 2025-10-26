#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# QR Profile Generator - Hacker Style (Termux)
# by RAZAQHI
# ============================================

# --- warna ANSI ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
RESET='\033[0m'

# helper print warna
cecho() { printf "%b\n" "$1$2$RESET"; }

clear

# Banner ASCII (gaya hacker)
cecho "$RED" "      __  ___  ____    ____  ____  ____  __"
cecho "$RED" "     /  |/  / / __ \  / __ \/ __ \/ __ \/ /"
cecho "$YELLOW" "    / /|_/ / / /_/ / / /_/ / /_/ / /_/ / / "
cecho "$YELLOW" "   /_/  /_/  \____/  \____/\____/\____/_/  "
cecho "$MAGENTA" ""
cecho "$MAGENTA" "   ____  ____  _____  _    ____  ____  __  __"
cecho "$CYAN"    "  / __ \/ __ \/ ___/ / |  / / / / / / / / /"
cecho "$CYAN"    " / /_/ / /_/ /\__ \  /  |/ / / / / / /_/ / "
cecho "$GREEN"   "/ .___/\____/____/ /_/|_/_/_/ /_/  \__, /  "
cecho "$GREEN"   "/_/                              /____/   "
cecho "$YELLOW" ""
cecho "$YELLOW" "      QR PROFILE GENERATOR  -  Hacker Style"
cecho "$BLUE"   "      https://github.com/Boiescylosh | Razaqhi"
printf "\n"

# cek Python & qrcode
if ! command -v python >/dev/null 2>&1; then
  cecho "$YELLOW" "[*] Python tidak ditemukan. Menginstall..."
  pkg update -y >/dev/null 2>&1
  pkg install python -y >/dev/null 2>&1
fi

if ! python -c "import qrcode" >/dev/null 2>&1; then
  cecho "$YELLOW" "[*] Menginstall modul Python qrcode (pip)..."
  pip install qrcode[pil] >/dev/null 2>&1 || {
    cecho "$RED" "[!] Gagal install qrcode via pip. Coba manual: pip install qrcode[pil]"
  }
fi

# Input user (sekali)
cecho "$CYAN" "[?] Isi data profil sebelum masuk menu"
read -p "  Nama lengkap: " NAME
read -p "  Tanggal Lahir: " BIRTH
read -p "  Alamat: " ADDRESS
read -p "  Fans Club: " FANS

DATA="Nama: $NAME
Tanggal Lahir: $BIRTH
Alamat: $ADDRESS
Fans Club: $FANS"

DATA_DIR="${HOME}/qr_profiles"
mkdir -p "$DATA_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PROFILE_FILE="$DATA_DIR/profile_${TIMESTAMP}.txt"
echo "$DATA" > "$PROFILE_FILE"

# Info author
AUTHOR_NAME="RAZAQHI"
AUTHOR_NOTE="Script by $AUTHOR_NAME - Bandung"

# fungsi pembuatan QR (python)
create_qr_png() {
  OUTFILE="$DATA_DIR/qr_profile_${TIMESTAMP}.png"
  echo "$DATA" > "$DATA_DIR/temp_data.txt"

  python - <<PYEND
import qrcode, sys
try:
    data = open("$DATA_DIR/temp_data.txt", "r").read()
    img = qrcode.make(data)
    img.save("$OUTFILE")
    print("OK")
except Exception as e:
    sys.stderr.write(str(e))
    sys.exit(1)
PYEND

  if [ $? -eq 0 ]; then
    cecho "$GREEN" "[+] QR berhasil dibuat: $OUTFILE"
    if command -v termux-open >/dev/null 2>&1; then
      termux-open "$OUTFILE" >/dev/null 2>&1 &
    fi
  else
    cecho "$RED" "[-] Gagal membuat QR. Pastikan modul qrcode terinstall."
  fi
}

# opsi tampil QR ASCII di terminal (menggunakan python qrcode terminal)
show_qr_terminal() {
  python - <<PYEND
import qrcode, sys
try:
    import qrcode.console_scripts as qc
except:
    pass
from qrcode import QRCode
data = open("$DATA_DIR/temp_data.txt").read()
qr = QRCode(border=1)
qr.add_data(data)
qr.make()
matrix = qr.get_matrix()
# print as blocks
for row in matrix:
    line = ''.join(['██' if c else '  ' for c in row])
    print(line)
PYEND
}

# Clear small helper to mimic KitHack look
small_header() {
  cecho "$GREEN" "=============================================="
}

# Menu bergaya hacker
while true; do
  printf "\n"
  small_header
  cecho "$MAGENTA" " [01]${RESET} ${YELLOW}Pembuatan barcode (QR) otomatis"
  cecho "$MAGENTA" " [02]${RESET} ${YELLOW}Informasi penting tentang QR ini"
  cecho "$MAGENTA" " [03]${RESET} ${YELLOW}Biodata pembuat codenya"
  cecho "$MAGENTA" " [04]${RESET} ${YELLOW}Tampilkan QR di terminal (ASCII)"
  cecho "$MAGENTA" " [0] ${RESET} ${YELLOW}Keluar"
  small_header
  read -p "$(cecho "$CYAN" " KitHack >> " >/dev/null; printf "Pilih nomor [01/02/03/04/0]: ")" CHOICE

  case "$CHOICE" in
    1|01)
      cecho "$CYAN" "\n[*] Membuat QR Code profil..."
      create_qr_png
      printf "\n"
      cecho "$YELLOW" "---- Isi QR ----"
      printf "%s\n" "$DATA"
      cecho "$YELLOW" "-----------------"
      ;;
    2|02)
      cecho "$CYAN" "\n[*] Informasi penting saat scan:"
      cecho "$YELLOW" " - QR ini menampilkan teks: Nama / TTL / Alamat / Fans Club"
      cecho "$YELLOW" " - Jangan masukkan data sensitif (KTP / No. Rekening / Password)"
      cecho "$YELLOW" " - File TXT & PNG: $DATA_DIR"
      ;;
    3|03)
      cecho "$CYAN" "\n[*] Biodata Pembuat Script:"
      cecho "$GREEN" " Nama  : $AUTHOR_NAME"
      cecho "$GREEN" " Asal  : Bandung"
      cecho "$GREEN" " Note  : $AUTHOR_NOTE"
      cecho "$GREEN" " IG    : @_razaqhi"
      ;;
    4|04)
      cecho "$CYAN" "\n[*] Menampilkan QR di terminal (ASCII):"
      # pastikan file temp ada
      echo "$DATA" > "$DATA_DIR/temp_data.txt"
      show_qr_terminal
      ;;
    0)
      cecho "$MAGENTA" "\nTerima Kasih Sudah Pakai Ya Kocak..."
      exit 0
      ;;
    *)
      cecho "$RED" "Isian Yang Baleg"
      ;;
  esac
done

