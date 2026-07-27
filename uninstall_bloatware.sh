#!/usr/bin/env bash
# =============================================================================
#  uninstall_bloatware.sh — Redmi / Xiaomi Bloatware Remover
#  Dibuat untuk: Semua Seri HP Redmi / Xiaomi / POCO (MIUI / HyperOS / Android)
#  Cara pakai  : bash uninstall_bloatware.sh
#  Dependensi  : adb (Android Debug Bridge)
#
#  Logika:
#    1. Coba uninstall paket (--user 0, tidak hapus permanen dari sistem)
#    2. Jika gagal → otomatis disable paket
#    3. Semua hasil dicatat di bloatware_log.txt
# =============================================================================

# --------------------------------------------------------------------------- #
# KONFIGURASI
# --------------------------------------------------------------------------- #
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/bloatware_log.txt"
USER_ID=0          # 0 = pengguna utama
DELAY=0.3          # jeda antar perintah (detik)

# Warna terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# --------------------------------------------------------------------------- #
# DAFTAR PAKET AMAN UNTUK DIUNINSTALL
# --------------------------------------------------------------------------- #

# --- Google Bloatware ---
GOOGLE_PACKAGES=(
#    "com.google.android.apps.bard"                     # Gemini / Bard AI 
#    "com.google.android.apps.docs"                     # Google Docs 
    "com.google.android.apps.subscriptions.red"        # YouTube Premium
    "com.google.android.apps.turbo"                    # Device Health Services
    "com.google.android.apps.walletnfcrel"             # Google Wallet
    "com.google.android.gm"                            # Gmail
    "com.google.android.gms.location.history"          # Riwayat lokasi Google
    "com.google.android.marvin.talkback"               # TalkBack aksesibilitas
    "com.google.android.printservice.recommendation"   # Rekomendasi print
    "com.google.android.syncadapters.calendar"         # Sinkronisasi kalender
#    "com.google.android.syncadapters.contacts"         # Sinkronisasi kontak
#    "com.google.android.youtube"                       # YouTube
    "com.google.ar.lens"                               # Google Lens
    "com.google.android.tts"                           # Text-to-Speech Google
    "com.google.android.apps.wellbeing"                # Digital Wellbeing
    "com.google.android.apps.maps"                     # Google Maps
    "com.google.android.apps.tachyon"                  # Google Meet
    "com.google.android.apps.photos"                   # Google Photos
    "com.google.android.videos"                        # Google TV
    "com.google.android.apps.youtube.music"            # YouTube Music
    "com.google.android.apps.nbu.paisa.user"           # Google Pay
    "com.google.android.accessibility.soundamplifier"  # Sound Amplifier / Penguat Suara Google
    "com.google.android.apps.googleassistant"          # Google Assistant 
)

# --- MIUI / Xiaomi Bloatware ---
MIUI_PACKAGES=(
    "com.miui.android.fashiongallery"    # Komedi Putar Wallpaper / Glance
    "com.miui.audiomonitor"              # Monitor audio MIUI
    "com.miui.analytics"                 # Analitik MIUI (tracking)
    "com.miui.bugreport"                 # Laporan bug MIUI
    "com.miui.cleanmaster"               # Fitur Pembersih bawaan MIUI (iklan)
    "com.miui.cloudbackup"               # Backup cloud Mi
    "com.miui.cloudservice"              # Layanan cloud Mi
    "com.miui.calculator"                # Kalkulator MIUI
    "com.miui.fm"                        # Radio FM
    "com.miui.fmservice"                 # Service Radio FM
    "com.miui.freeform"                  # Mode jendela bebas
    "com.miui.gallery"                   # Galeri bawaan Xiaomi
    "com.miui.hybrid"                    # Hybrid service MIUI
    "com.miui.hybrid.accessory"          # Hybrid accessory MIUI
    "com.miui.micloudsync"               # Sinkronisasi Mi Cloud
    "com.miui.miservice"                 # Layanan Bantuan Xiaomi
    "com.miui.miwallpaper"               # Wallpaper MIUI
    "com.miui.msa.global"                # MSA (iklan MIUI)
    "com.miui.phrase"                    # Frasa pintar MIUI
    "com.miui.qr"                        # Pemindai QR
    "com.miui.touchassistant"            # Tombol asisten sentuh
    "com.miui.videoplayer"               # Pemutar video MIUI
    "com.miui.vsimcore"                  # Virtual SIM
    "com.miui.weather2"                  # Cuaca MIUI
    "com.miui.yellowpage"                # Yellow Pages MIUI
#    "com.xiaomi.finddevice"              # Temukan perangkat Mi # JANGAN DIHAPUS, HAPE BISA GAGAL BOOTING (BOOTLOOP)
    "com.xiaomi.calendar"                # Kalender Xiaomi
    "com.xiaomi.discover"                # Mi Discover (iklan/rekomendasi)
    "com.xiaomi.glgm"                    # Games / Service Game Xiaomi
    "com.xiaomi.midrop"                  # ShareMe (berbagi file Xiaomi)
    "com.xiaomi.miplay_client"           # Mi Play streaming
    "com.xiaomi.mipicks"                 # GetApps / Mi Picks
    "com.xiaomi.mircs"                   # RCS Xiaomi
    "com.xiaomi.payment"                 # Mi Pay
#    "com.xiaomi.scanner"                 # Scanner Mi
    "com.xiaomi.upnp"                    # UPnP Xiaomi
    "com.xiaomi.bttester"                # Bluetooth tester (alat uji)
    "com.facemoji.lite.xiaomi"           # Facemoji keyboard
    "com.mi.android.globalminusscreen"   # Layar minus Mi (feed berita)
    "com.micredit.in"                    # Mi Credit
    "com.milink.service"                 # Mi Share / Cast
    "com.mipay.wallet.id"                # Mi Pay Indonesia
    "com.mipay.wallet.in"                # Mi Pay India
    "com.debug.loggerui"                 # Debug Logger UI
)

# --- Aplikasi Bawaan Android ---
ANDROID_PACKAGES=(
    "com.android.calendar"              # Kalender bawaan
#    "com.android.chrome"               # Chrome
#    "com.android.deskclock"            # Jam/Alarm bawaan
    "com.android.egg"                  # Easter egg Android
    "com.android.printspooler"         # Print spooler
    "com.android.soundrecorder"        # Perekam suara
    "com.android.wallpaper.livepicker" # Wallpaper live
    "com.android.dreams.basic"         # Screen saver / Daydream
    "com.android.traceur"              # Alat tracing (developer)
)

# --- Aplikasi Pihak Ketiga Pra-install ---
THIRD_PARTY_PACKAGES=(
    # Facebook
    "com.facebook.katana"               # Facebook
    "com.facebook.appmanager"           # Facebook App Manager
    "com.facebook.services"             # Facebook Services
    "com.facebook.system"               # Facebook System

    # Amazon
    "com.amazon.appmanager"             # Amazon App Manager
    "com.amazon.mShop.android.shopping" # Amazon Shopping

    # Lainnya
    "com.linkedin.android"              # LinkedIn
    "com.netflix.mediaclient"           # Netflix
    "cn.wps.xiaomi.abroad.lite"         # WPS Office Lite
)

# --- Theme MIUI ---
THEME_PACKAGES=(
    "com.android.thememanager"                              # Theme Manager MIUI
    "com.android.thememanager.module"                       # Modul Theme Manager
    "com.android.theme.color.black"                         # Tema warna hitam
    "com.android.theme.color.cinnamon"                      # Tema warna cinnamon
    "com.android.theme.color.green"                         # Tema warna hijau
    "com.android.theme.color.ocean"                         # Tema warna ocean
    "com.android.theme.color.orchid"                        # Tema warna orchid
    "com.android.theme.color.purple"                        # Tema warna ungu
    "com.android.theme.color.space"                         # Tema warna space
    "com.android.theme.font.notoserifsource"                # Font Noto Serif
    "com.android.theme.icon_pack.circular.android"          # Icon pack circular
    "com.android.theme.icon_pack.circular.launcher"         # Icon pack circular launcher
    "com.android.theme.icon_pack.circular.settings"         # Icon pack circular settings
    "com.android.theme.icon_pack.circular.systemui"         # Icon pack circular sysui
    "com.android.theme.icon_pack.circular.themepicker"      # Icon pack circular themepicker
    "com.android.theme.icon_pack.filled.android"            # Icon pack filled android
    "com.android.theme.icon_pack.filled.launcher"           # Icon pack filled launcher
    "com.android.theme.icon_pack.filled.settings"           # Icon pack filled settings
    "com.android.theme.icon_pack.filled.systemui"           # Icon pack filled sysui
    "com.android.theme.icon_pack.filled.themepicker"        # Icon pack filled themepicker
    "com.android.theme.icon_pack.rounded.android"           # Icon pack rounded android
    "com.android.theme.icon_pack.rounded.launcher"          # Icon pack rounded launcher
    "com.android.theme.icon_pack.rounded.settings"          # Icon pack rounded settings
    "com.android.theme.icon_pack.rounded.systemui"          # Icon pack rounded sysui
    "com.android.theme.icon.roundedrect"                    # Ikon bentuk rounded rect
    "com.android.theme.icon.square"                         # Ikon bentuk kotak
    "com.android.theme.icon.squircle"                       # Ikon bentuk squircle
    "com.android.theme.icon.teardrop"                       # Ikon bentuk teardrop
)

# --- Browser ---
BROWSER_PACKAGES=(
    "com.mi.globalbrowser"               # Mi Browser Global
)

# --- Notes ---
NOTES_PACKAGES=(
    "com.miui.notes"                     # Mi Notes / Catatan MIUI
)

# --- Music ---
MUSIC_PACKAGES=(
    "com.miui.player"                    # Mi Music / Pemutar Musik MIUI
)

# Gabungkan semua paket
ALL_PACKAGES=(
    "${GOOGLE_PACKAGES[@]}"
    "${MIUI_PACKAGES[@]}"
    "${ANDROID_PACKAGES[@]}"
    "${THIRD_PARTY_PACKAGES[@]}"
    "${THEME_PACKAGES[@]}"
    "${BROWSER_PACKAGES[@]}"
    "${NOTES_PACKAGES[@]}"
    "${MUSIC_PACKAGES[@]}"
)

# --------------------------------------------------------------------------- #
# FUNGSI
# --------------------------------------------------------------------------- #

banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     Redmi / Xiaomi Bloatware Remover — via ADB      ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

log() {
    local status="$1"
    local package="$2"
    local msg="$3"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$status] $package — $msg" >> "$LOG_FILE"
}

check_adb() {
    if ! command -v adb &>/dev/null; then
        echo -e "${RED}[ERROR]${RESET} ADB tidak ditemukan. Install dengan:"
        echo "        sudo apt install adb"
        exit 1
    fi
}

check_device() {
    echo -e "${CYAN}[*]${RESET} Memeriksa koneksi perangkat..."
    local devices
    devices=$(adb devices | grep -v "List of devices" | grep "device$")
    if [[ -z "$devices" ]]; then
        echo -e "${RED}[ERROR]${RESET} Tidak ada perangkat ADB terdeteksi!"
        echo ""
        echo "  Pastikan:"
        echo "  1. USB Debugging aktif di perangkat"
        echo "  2. Kabel USB terhubung"
        echo "  3. Izin debugging sudah diterima di ponsel"
        exit 1
    fi
    echo -e "${GREEN}[OK]${RESET} Perangkat terdeteksi."
    adb devices
    echo ""
}

is_installed() {
    local pkg="$1"
    adb shell pm list packages --user "$USER_ID" 2>/dev/null | grep -q "package:${pkg}$"
}

uninstall_or_disable() {
    local pkg="$1"

    # Cek apakah paket ada di perangkat
    if ! is_installed "$pkg"; then
        echo -e "  ${YELLOW}[SKIP]${RESET}  $pkg ${YELLOW}(tidak ditemukan)${RESET}"
        log "SKIP" "$pkg" "Paket tidak ditemukan di perangkat"
        return
    fi

    # Coba UNINSTALL dulu
    local uninstall_result
    uninstall_result=$(adb shell pm uninstall -k --user "$USER_ID" "$pkg" 2>&1)

    if echo "$uninstall_result" | grep -qi "success"; then
        echo -e "  ${GREEN}[UNINSTALL]${RESET} $pkg ${GREEN}✓${RESET}"
        log "UNINSTALL" "$pkg" "Berhasil di-uninstall"
    else
        # Jika gagal → coba DISABLE
        local disable_result
        disable_result=$(adb shell pm disable-user --user "$USER_ID" "$pkg" 2>&1)

        if echo "$disable_result" | grep -qi "disabled"; then
            echo -e "  ${YELLOW}[DISABLED]${RESET} $pkg ${YELLOW}(uninstall gagal, paket di-disable)${RESET}"
            log "DISABLED" "$pkg" "Uninstall gagal → di-disable | Detail: $uninstall_result"
        else
            echo -e "  ${RED}[GAGAL]${RESET}   $pkg ${RED}✗ (uninstall & disable gagal)${RESET}"
            log "GAGAL" "$pkg" "Uninstall: $uninstall_result | Disable: $disable_result"
        fi
    fi

    sleep "$DELAY"
}

process_category() {
    local category_name="$1"
    shift
    local packages=("$@")

    if [[ ${#packages[@]} -gt 0 ]]; then
        echo -e "${CYAN}[$category_name]${RESET}"
        for pkg in "${packages[@]}"; do
            uninstall_or_disable "$pkg"
        done
        echo ""
    fi
}

print_summary() {
    echo ""
    echo -e "${BOLD}══════════════════════════════════════${RESET}"
    echo -e "${BOLD}  RINGKASAN HASIL${RESET}"
    echo -e "${BOLD}══════════════════════════════════════${RESET}"

    local uninstalled disabled skipped failed total
    uninstalled=$(grep -c "\[UNINSTALL\]" "$LOG_FILE" 2>/dev/null || true)
    disabled=$(grep -c "\[DISABLED\]" "$LOG_FILE" 2>/dev/null || true)
    skipped=$(grep -c "\[SKIP\]" "$LOG_FILE" 2>/dev/null || true)
    failed=$(grep -c "\[GAGAL\]" "$LOG_FILE" 2>/dev/null || true)

    uninstalled=${uninstalled:-0}
    disabled=${disabled:-0}
    skipped=${skipped:-0}
    failed=${failed:-0}

    total=$(( uninstalled + disabled + skipped + failed ))

    echo -e "  Total paket diproses : ${BOLD}$total${RESET}"
    echo -e "  ${GREEN}✓ Berhasil uninstall ${RESET}: $uninstalled"
    echo -e "  ${YELLOW}⚠ Di-disable         ${RESET}: $disabled"
    echo -e "  ${YELLOW}↷ Di-skip            ${RESET}: $skipped"
    echo -e "  ${RED}✗ Gagal total        ${RESET}: $failed"
    echo ""
    echo -e "  Log lengkap tersimpan di: ${CYAN}$LOG_FILE${RESET}"
    echo ""
}

# --------------------------------------------------------------------------- #
# MAIN
# --------------------------------------------------------------------------- #

banner

# Inisialisasi log
{
    echo "======================================"
    echo " Bloatware Remover Log — $(date '+%Y-%m-%d %H:%M:%S')"
    echo "======================================"
} > "$LOG_FILE"

check_adb
check_device

# Konfirmasi sebelum mulai
echo -e "${YELLOW}[!] PERINGATAN:${RESET} Skrip akan menghapus/menonaktifkan ${BOLD}${#ALL_PACKAGES[@]} paket${RESET}."
echo -e "    Gunakan ${CYAN}--user 0${RESET} (aman, tidak hapus permanen dari ROM)."
echo ""

printf "${BOLD}Lanjutkan? (y/N): ${RESET}"
read -r confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Dibatalkan."
    exit 0
fi

echo ""

# Proses per kategori
process_category "Google Bloatware" "${GOOGLE_PACKAGES[@]}"
process_category "MIUI / Xiaomi Bloatware" "${MIUI_PACKAGES[@]}"
process_category "Aplikasi Bawaan Android" "${ANDROID_PACKAGES[@]}"
process_category "Aplikasi Pihak Ketiga Pra-install" "${THIRD_PARTY_PACKAGES[@]}"
process_category "Theme MIUI" "${THEME_PACKAGES[@]}"
process_category "Browser" "${BROWSER_PACKAGES[@]}"
process_category "Notes" "${NOTES_PACKAGES[@]}"
process_category "Music" "${MUSIC_PACKAGES[@]}"

print_summary
