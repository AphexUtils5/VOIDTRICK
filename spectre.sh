#!/system/bin/sh
# ================================================================
#   ███████╗██████╗ ███████╗ ██████╗████████╗██████╗ ███████╗
#   ██╔════╝██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝
#   ███████╗██████╔╝█████╗  ██║        ██║   ██████╔╝█████╗
#   ╚════██║██╔═══╝ ██╔══╝  ██║        ██║   ██╔══██╗██╔══╝
#   ███████║██║     ███████╗╚██████╗   ██║   ██║  ██║███████╗
#   ╚══════╝╚═╝     ╚══════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
#
#       S P E C T R E   U L T R A   ·   v1.2
#           Dual File Injector & Optimizer
# ================================================================

FF_NORMAL="com.dts.freefireth"
TARGET=""
TARGET_NAME=""
TAG="SPECTRE_ULTRA"
ROOT_AVAILABLE=0

# Path deteksi folder module tempat script ini berada
MODULE_DIR="${0%/*}"
[ "$MODULE_DIR" = "$0" ] && MODULE_DIR="$(pwd)"

# Nama file sumber yang ada di folder module
SRC_FILE_1="$MODULE_DIR/Assembly-CSharp-patch.bytes"
SRC_FILE_2="$MODULE_DIR/localConfig.json"

# Nama file yang bakal ditaruh di folder FreeFire
DEST_FILE_1="Assembly-CSharp-patch.bytes"
DEST_FILE_2="localConfig.json"

# ================================================================
# UI COMPONENTS (SIMPLE MENU)
# ================================================================
banner() {
clear 2>/dev/null
echo ""
echo "  =============================================="
echo "       S P E C T R E   U L T R A   v1.2        "
echo "     Dual File Injector & System Optimizer     "
echo "  =============================================="
echo ""
}

notify() { cmd notification post -S bigtext -t "$1" "$TAG" "$2" >/dev/null 2>&1; }
ok()   { printf "  [\033[32mOK\033[0m] %s\n" "$1"; }
warn() { printf "  [\033[33m!!\033[0m] %s\n" "$1"; }
err()  { printf "  [\033[31mXX\033[0m] %s\n" "$1"; }

load_step() {
  printf "  [*] %-35s" "$1"
  for i in 1 2 3; do printf "."; sleep 0.1; done
  printf " DONE\n"
}

# ================================================================
# SYSTEM PRIVILEGES
# ================================================================
check_privileges() {
  if pm list packages >/dev/null 2>&1; then
    ok "Shell Access  : Granted (Brevent/Shizuku)"
  else
    err "Shell Access  : Denied. Jalanin via Brevent!"
    exit 1
  fi

  if [ "$(id -u)" -eq 0 ] || command -v su >/dev/null 2>&1 && su -c id >/dev/null 2>&1; then
    ok "Root Access   : Granted"
    ROOT_AVAILABLE=1
  else
    warn "Root Access   : Denied (Bypass via Brevent)"
    ROOT_AVAILABLE=0
  fi
  echo ""
}

safe_setprop() {
  local prop="$1" val="$2"
  if setprop "$prop" "$val" 2>/dev/null; then return 0
  elif [ "$ROOT_AVAILABLE" -eq 1 ]; then su -c "setprop $prop $val" >/dev/null 2>&1; return $?
  fi; return 1
}

safe_write() {
  local path="$1" val="$2"
  if echo "$val" > "$path" 2>/dev/null; then return 0
  elif [ "$ROOT_AVAILABLE" -eq 1 ]; then su -c "echo $val > $path" >/dev/null 2>&1; return $?
  fi; return 1
}

# ================================================================
# GAME DETECTION (FREEFIRE BIASA ONLY)
# ================================================================
detect_game() {
  echo "  [ GAME DETECTION ]"
  if pm list packages 2>/dev/null | grep -q "$FF_NORMAL"; then
    TARGET="$FF_NORMAL"; TARGET_NAME="FreeFire"
    ok "FreeFire terdeteksi"
  else
    err "FreeFire tidak terinstall!"
    exit 1
  fi
  echo ""
}

# ================================================================
# DUAL MODULAR INJECTOR SYSTEM
# ================================================================
inject_files() {
  local target_dir="/storage/emulated/0/Android/data/$FF_NORMAL/files"

  echo "  [ DUAL FILE INJECTOR ]"
  
  # 1. Cek file sumber di folder module
  if [ ! -f "$SRC_FILE_1" ]; then
    err "File 'Assembly-CSharp-patch.bytes' tidak ada di folder module!"
    echo ""
    return 1
  fi
  if [ ! -f "$SRC_FILE_2" ]; then
    err "File 'localConfig.json' tidak ada di folder module!"
    echo ""
    return 1
  fi

  load_step "Membaca file sumber"
  
  # 2. Cek/Buat folder target
  if [ ! -d "$target_dir" ]; then
    load_step "Membuat folder FreeFire"
    mkdir -p "$target_dir" 2>/dev/null
    [ "$ROOT_AVAILABLE" -eq 1 ] && su -c "mkdir -p $target_dir" 2>/dev/null
    
    if [ ! -d "$target_dir" ]; then
      err "Gagal buat folder. Buka FreeFire manual sekali dulu."
      echo ""
      return 1
    fi
  else
    load_step "Folder FreeFire ditemukan"
  fi

  # 3. Inject File 1 (Assembly-CSharp-patch.bytes)
  load_step "Menginjeksi file 1 (Bytes)"
  if cp "$SRC_FILE_1" "$target_dir/$DEST_FILE_1" 2>/dev/null; then
    ok "$DEST_FILE_1 (cp)"
  elif [ "$ROOT_AVAILABLE" -eq 1 ] && su -c "cp $SRC_FILE_1 $target_dir/$DEST_FILE_1" 2>/dev/null; then
    ok "$DEST_FILE_1 (su)"
  elif cat "$SRC_FILE_1" > "$target_dir/$DEST_FILE_1" 2>/dev/null; then
    ok "$DEST_FILE_1 (cat)"
  else
    err "Gagal inject file 1 (Blokir OS)"
  fi

  # 4. Inject File 2 (localConfig.json)
  load_step "Menginjeksi file 2 (Json)"
  if cp "$SRC_FILE_2" "$target_dir/$DEST_FILE_2" 2>/dev/null; then
    ok "$DEST_FILE_2 (cp)"
  elif [ "$ROOT_AVAILABLE" -eq 1 ] && su -c "cp $SRC_FILE_2 $target_dir/$DEST_FILE_2" 2>/dev/null; then
    ok "$DEST_FILE_2 (su)"
  elif cat "$SRC_FILE_2" > "$target_dir/$DEST_FILE_2" 2>/dev/null; then
    ok "$DEST_FILE_2 (cat)"
  else
    err "Gagal inject file 2 (Blokir OS)"
  fi

  # 5. Verifikasi akhir
  if [ -f "$target_dir/$DEST_FILE_1" ] && [ -f "$target_dir/$DEST_FILE_2" ]; then
    echo ""
    ok "2 FILE BERHASIL DITANAM KE FREEFIRE!"
  else
    echo ""
    warn "Beberapa file gagal masuk."
  fi
  echo ""
}

# ================================================================
# OPTIMIZATIONS
# ================================================================
calibrate_resolution() {
  local w density slop
  w=$(wm size 2>/dev/null | awk -F'x' '/Physical/{print $1}' | awk '{print $NF}'); [ -z "$w" ] && w=1080
  density=$(wm density 2>/dev/null | awk '/Physical/{print $NF}'); [ -z "$density" ] && density=420

  if   [ "$w" -lt 720 ];  then slop=0.30
  elif [ "$w" -lt 1080 ]; then slop=0.22
  elif [ "$w" -lt 1440 ]; then slop=0.14
  else                         slop=0.08
  fi

  if [ "$density" -ge 480 ]; then slop=$(awk "BEGIN{printf \"%.2f\", $slop+0.04}")
  elif [ "$density" -le 320 ]; then slop=$(awk "BEGIN{printf \"%.2f\", $slop-0.02}")
  fi

  printf "  [*] Resolusi : %s @ %sdpi\n" "$w" "$density"
  printf "  [*] Touch    : %s\n" "$slop"
  TOUCH_SLOP="$slop"
}

tune_vm() { safe_write /proc/sys/vm/swappiness 10; safe_write /proc/sys/vm/vfs_cache_pressure 50; safe_write /proc/sys/vm/dirty_ratio 80; }
boost_cpu() {
  for cpu in /sys/devices/system/cpu/cpu[0-7]; do
    [ -d "$cpu" ] || continue
    gov="$cpu/cpufreq/scaling_governor"
    if [ -w "$gov" ] || [ "$ROOT_AVAILABLE" -eq 1 ]; then safe_write "$gov" "performance"; fi
  done
}
tune_fps() {
  settings put global window_animation_scale 0.0 2>/dev/null
  settings put global transition_animation_scale 0.0 2>/dev/null
  settings put global animator_duration_scale 0.0 2>/dev/null
  safe_setprop debug.hwui.renderer opengl
  safe_setprop debug.sf.latch_unsignaled 1
}
touch_tuning() {
  for f in /sys/class/touchscreen/*/jitter_filter /sys/class/touchscreen/*/sensitivity; do [ -w "$f" ] && safe_write "$f" 1; done
  safe_setprop persist.sys.input.touch.filter 0
  settings put secure three_gesture_screenshot 0 2>/dev/null
  safe_setprop persist.vendor.qti.inputopts.enable true
  safe_setprop persist.vendor.qti.inputopts.movetouchslop "$TOUCH_SLOP"
  safe_setprop persist.vendor.qti.inputopts.horizontalslop "$TOUCH_SLOP"
}
protect_brevent() {
  am set-standby-bucket me.piebridge.brevent active 2>/dev/null
  am set-standby-bucket moe.shizuku.privileged.api active 2>/dev/null
  cmd deviceidle whitelist +me.piebridge.brevent >/dev/null 2>&1
  cmd deviceidle whitelist +moe.shizuku.privileged.api >/dev/null 2>&1
  local pid_brevent=$(pidof me.piebridge.brevent)
  [ -n "$pid_brevent" ] && safe_write "/proc/$pid_brevent/oom_score_adj" "-1000"
}

# ================================================================
# LAUNCH GAME
# ================================================================
launch_game() {
  echo "  [ LAUNCH ]"
  am force-stop "$TARGET" >/dev/null 2>&1; sleep 0.5
  local act=$(cmd package resolve-activity --brief "$TARGET" 2>/dev/null | tail -n 1)
  printf "  [*] Membuka %s...\n" "$TARGET_NAME"
  monkey -p "$TARGET" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || am start -n "$act" >/dev/null 2>&1
  ok "$TARGET_NAME dibuka."
  echo ""
}

# ================================================================
# MAIN EXECUTION
# ================================================================
main() {
  banner
  check_privileges
  detect_game

  # 1. INJECT 2 FILES
  inject_files

  # 2. CALIBRATION
  echo "  [ CALIBRATION ]"
  calibrate_resolution
  echo ""

  # 3. OPTIMIZATIONS
  echo "  [ OPTIMIZING SYSTEM ]"
  load_step "Mengamankan Brevent";      protect_brevent
  load_step "Membersihkan cache memory"; sync; safe_write /proc/sys/vm/drop_caches 3
  load_step "Tuning parameter VM";       tune_vm
  load_step "Boost performa CPU";        boost_cpu
  load_step "Optimasi FPS & Render";     tune_fps
  load_step "Kalibrasi sentuhan (Drag)"; touch_tuning
  echo ""

  # 4. NOTIF & LAUNCH
  notify "SPECTRE ULTRA" "Payload berhasil diinjeksi. Sistem siap tempur!"
  launch_game

  # 5. STATUS
  echo "  =============================================="
  echo "         S P E C T R E   U L T R A   O N L I N E"
  echo "         Dual Files Injected · Cache Cleared      "
  echo "  =============================================="
  echo ""
}

main