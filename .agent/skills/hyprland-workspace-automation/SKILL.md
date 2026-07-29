---
name: hyprland-workspace-automation
description: Hyprland automation with hyprctl - create/close named workspaces, open standard 3-window dev layouts (Codex/AI + Shell + Neovim), and manage windows via hyprctl dispatch.
---

# Hyprland Workspace & Window Automation Skill

Skill này tự động hóa công việc quản lý cửa sổ và Workspace trong Hyprland thông qua công cụ CLI chính thức `hyprctl` (kế thừa ý tưởng từ skill `mainliufeng-dotfiles-hyprland`).

---

## 🚀 1. Quản Lý Workspace Có Đặt Tên (Named Workspaces)

Sử dụng `hyprctl` để điều hướng và tạo các Workspace theo tên dự án:

```bash
# Di chuyển đến một named workspace (ví dụ: 'dev-project')
hyprctl dispatch workspace name:dev-project

# Di chuyển cửa sổ hiện tại sang named workspace
hyprctl dispatch movetoworkspace name:dev-project

# Di chuyển cửa sổ sang named workspace nhưng không chuyển góc nhìn
hyprctl dispatch movetoworkspacesilent name:dev-project
```

---

## 💻 2. Tự Động Dựng Bố Cục Lập Trình 3 Cửa Sổ (Standard 3-Window Dev Layout)

Dựng tự động môi trường làm việc 3 cửa sổ chuẩn cho một dự án:

```bash
#!/usr/bin/env bash
# Usage: ./setup-dev-layout.sh <project_name> <project_path>

PROJECT_NAME="${1:-default-dev}"
PROJECT_PATH="${2:-$HOME}"

# 1. Chuyển sang workspace riêng cho dự án
hyprctl dispatch workspace name:"$PROJECT_NAME"

# 2. Mở Neovim / Code Editor chính
hyprctl dispatch exec "[workspace name:$PROJECT_NAME] foot -D '$PROJECT_PATH' -e nvim"

# 3. Mở Terminal thứ hai cho Shell / Server / Build log
hyprctl dispatch exec "[workspace name:$PROJECT_NAME] foot -D '$PROJECT_PATH'"

# 4. Mở trình duyệt / AI Assistant
hyprctl dispatch exec "[workspace name:$PROJECT_NAME] firefox"
```
