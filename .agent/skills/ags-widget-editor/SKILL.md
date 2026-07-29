---
name: ags-widget-editor
description: Skill chuyên biệt để biên tập, sửa lỗi JavaScript và tùy biến giao diện GTK Widgets cho AGS (Aylur's GTK Shell) trong hệ sinh thái Hyprland.
---

# AGS Widget Editing & Maintenance Skill

Skill này hướng dẫn quy trình kiểm tra và biên tập hệ thống Widget AGS (`.config/ags`).

## Danh Sách Các Mô-đun Cốt Lõi (`.config/ags/modules/`)
1. **`bar/`**: Thanh trạng thái hiển thị Workspace, Workactive, Đồng hồ, System Tray, Âm lượng, Pin.
2. **`overview/`**: Màn hình Tổng quan ứng dụng & Tìm kiếm.
3. **`sideleft/`**: Bảng điều khiển trái tích hợp Trợ lý AI (ChatGPT, Gemini).
4. **`sideright/`**: Bảng điều khiển phải chứa Cài đặt nhanh, Thông báo, Lịch.
5. **`wallselect/`**: Bộ chọn hình nền giao diện.

## Các Bước Khắc Phục Lỗi AGS
1. **Kiểm tra JavaScript Syntax**: Kiểm tra các file `.js` trong `.config/ags/` xem có cú pháp ES6+ không tương thích với GJS (Gnome JavaScript engine) hay không.
2. **Kiểm tra Material Colors Service**: Rà soát script sinh màu trong `.config/ags/scripts/color_generation/` để đảm bảo lệnh `python` và `material-color-utilities` hoạt động.
3. **Tối ưu SCSS**: Đảm bảo file `.config/ags/scss/` được biên dịch sạch bằng `sass`.
