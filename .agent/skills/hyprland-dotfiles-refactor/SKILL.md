---
name: hyprland-dotfiles-refactor
description: Skill chuyên biệt để kiểm tra, sửa lỗi, nâng cấp và biên tập các bộ cấu hình Hyprland Dotfiles (bao gồm hyprland.conf, hyprlock, hypridle, keybindings, và script cài đặt).
---

# Hyprland Dotfiles Refactoring & Maintenance Skill

Skill này cung cấp quy trình từng bước để kiểm soát và biên tập lại dự án Hyprland dotfiles.

## Quy Trình Biên Tập (Workflow)

### 1. Phân Tích & Rà Soát Cấu Hình Hyprland (`.config/hypr`)
- **Kiểm tra file chính**: `.config/hypr/hyprland.conf` và các file được `source` trong `.config/hypr/hyprland/`.
- **Rà soát cú pháp bị lỗi/cũ**:
  - `monitor`: Đảm bảo định dạng `monitor = NAME, RESOLUTION@REFRESH, POSITION, SCALE`.
  - `input`: Kiểm tra cấu hình bàn phím, touchpad, sensitivity.
  - `general`: Kiểm tra `gaps_in`, `gaps_out`, `border_size`, `col.active_border`.
  - `decoration`: Kiểm tra `rounding`, `blur`, `shadow` (chú ý cú pháp shadow v0.40+).
  - `misc`: Kiểm tra `disable_hyprland_logo`, `vfr`, `vrr`.
  - `windowrulev2`: Thay thế toàn bộ `windowrule` cũ bằng `windowrulev2`.

### 2. Kiểm Tra Cấu Hình Khóa & Chế Độ Chờ
- **`hyprlock.conf`**: Kiểm tra các widget background, input-field, label.
- **`hypridle.conf`**: Kiểm tra timeout ngắt màn hình, khóa màn hình, suspend.

### 3. Phân Tích Kịch Bản Cài Đặt (`install.sh`, `scriptdata/`)
- Rà soát danh sách phụ thuộc trong `scriptdata/dependencies.conf` và `arch-packages/`.
- Thay thế các gói AUR cũ bị hỏng bằng các gói chính thức hoặc AUR thay thế đang hoạt động.
