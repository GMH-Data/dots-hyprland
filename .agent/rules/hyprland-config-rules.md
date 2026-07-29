# Quy Tắc Cấu Hình Hyprland (Hyprland Configuration Rules)

Quy tắc biên tập và kiểm tra cấu hình Hyprland trong dự án `dots-hyprland`:

## 1. Cấu Trúc File & Tách Biệt Modularity
- Tất cả cấu hình cốt lõi nằm ở `.config/hypr/hyprland/*.conf`.
- Tất cả tùy chỉnh cá nhân hóa của người dùng phải nằm ở `.config/hypr/custom/*.conf` để tránh xung đột khi update.
- Cấu hình chính `.config/hypr/hyprland.conf` chỉ chứa các câu lệnh `source=...`.

## 2. Kiểm Tra Cú Pháp Bị Deprecated (Cú Pháp Cũ)
Khi rà soát các file `.conf`, chú ý các thay đổi cú pháp Hyprland gần đây:
- **Window Rules**: Sử dụng cú pháp `windowrulev2` thay vì `windowrule` cũ bất cứ khi nào có thể.
- **Decorations**: Kiểm tra thuộc tính `drop_shadow` (đã chuyển thành `shadow:enabled` trong các bản mới).
- **Animations**: Đảm bảo cú pháp `animation = NAME, ONOFF, SPEED, CURVE [,STYLE]` đúng định dạng.
- **Keybindings**: Kiểm tra các dispatcher như `exec`, `workspace`, `movetoworkspace`, `togglefloating`, `fullscreen`.

## 3. Kiểm Tra Trước Khi Commit
- Luôn chạy thử câu lệnh kiểm tra cú pháp (nếu đang ở trên môi trường Hyprland): `hyprctl reload` hoặc lướt qua để đảm bảo không có từ khóa không hợp lệ.
