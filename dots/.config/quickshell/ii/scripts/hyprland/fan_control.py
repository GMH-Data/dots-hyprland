#!/usr/bin/env python3
"""
Fan control for Acer Nitro AN515-57.
Output format: cpuTarget,cpuAuto,gpuTarget,gpuAuto,cpuActual,gpuActual
"""
import sys

EC_PATH = "/sys/kernel/debug/ec/ec0/io"

def read_status():
    try:
        with open(EC_PATH, "rb") as f:
            f.seek(34)
            cpu_mode_val = ord(f.read(1))
            cpu_auto = 0 if cpu_mode_val == 12 else 1

            f.seek(33)
            gpu_mode_val = ord(f.read(1))
            gpu_auto = 0 if gpu_mode_val == 48 else 1

            f.seek(55)
            cpu_target = ord(f.read(1))

            f.seek(58)
            gpu_target = ord(f.read(1))

            # Actual fan speed (read-only, always works without register 3)
            f.seek(19)
            cpu_actual = ord(f.read(1))

            f.seek(21)
            gpu_actual = ord(f.read(1))

            # Clamp actual values to 0-100 range
            cpu_actual = min(cpu_actual, 100)
            gpu_actual = min(gpu_actual, 100)

            print(f"{cpu_target},{cpu_auto},{gpu_target},{gpu_auto},{cpu_actual},{gpu_actual}")
    except Exception:
        print("0,1,0,1,0,0")

def set_fan(fan_type, speed_str):
    try:
        with open(EC_PATH, "rb+") as f:
            if fan_type == "both":
                # Set CPU
                if speed_str == "auto":
                    f.seek(34)
                    f.write(bytes([4]))
                else:
                    speed = max(0, min(100, int(speed_str)))
                    f.seek(3)
                    f.write(bytes([17]))
                    f.seek(34)
                    f.write(bytes([12]))
                    f.seek(55)
                    f.write(bytes([speed]))
                
                # Set GPU
                if speed_str == "auto":
                    f.seek(33)
                    f.write(bytes([16]))
                else:
                    speed = max(0, min(100, int(speed_str)))
                    f.seek(3)
                    f.write(bytes([17]))
                    f.seek(33)
                    f.write(bytes([48]))
                    f.seek(58)
                    f.write(bytes([speed]))

                # If both are auto, write 17 to register 3 (keep unlocked to prevent BIOS red reset)
                if speed_str == "auto":
                    f.seek(3)
                    f.write(bytes([17]))
            else:
                if speed_str == "auto":
                    if fan_type == "cpu":
                        f.seek(34)
                        f.write(bytes([4]))
                    elif fan_type == "gpu":
                        f.seek(33)
                        f.write(bytes([16]))

                    # Check if BOTH are now auto
                    f.seek(34)
                    cpu_mode = ord(f.read(1))
                    f.seek(33)
                    gpu_mode = ord(f.read(1))
                    if cpu_mode != 12 and gpu_mode != 48:
                        f.seek(3)
                        f.write(bytes([17]))
                else:
                    speed = max(0, min(100, int(speed_str)))
                    f.seek(3)
                    f.write(bytes([17]))

                    if fan_type == "cpu":
                        f.seek(34)
                        f.write(bytes([12]))
                        f.seek(55)
                        f.write(bytes([speed]))
                    elif fan_type == "gpu":
                        f.seek(33)
                        f.write(bytes([48]))
                        f.seek(58)
                        f.write(bytes([speed]))

        # Chờ 250ms để EC ổn định trạng thái trước khi cấu hình màu đèn
        import time
        time.sleep(0.25)

        # Re-apply keyboard color to Cyan
        import subprocess
        for z in [1, 2, 3, 4]:
            subprocess.run([
                "/usr/bin/python", 
                "/home/gmh/acer-predator-turbo-and-rgb-keyboard-linux-module/facer_rgb.py", 
                "-m", "0", "-z", str(z), "-cR", "255", "-cG", "255", "-cB", "255"
            ], capture_output=True)
    except Exception:
        sys.exit(1)

def maintain():
    """Re-apply current manual speeds. Called by QML timer every 3s."""
    try:
        with open(EC_PATH, "rb") as f:
            f.seek(34)
            cpu_mode = ord(f.read(1))
            f.seek(33)
            gpu_mode = ord(f.read(1))
            f.seek(55)
            cpu_speed = ord(f.read(1))
            f.seek(58)
            gpu_speed = ord(f.read(1))

        cpu_manual = (cpu_mode == 12)
        gpu_manual = (gpu_mode == 48)

        if not cpu_manual and not gpu_manual:
            return  # Both auto, nothing to maintain

        with open(EC_PATH, "rb+") as f:
            f.seek(3)
            f.write(bytes([17]))
            if cpu_manual:
                f.seek(34)
                f.write(bytes([12]))
                f.seek(55)
                f.write(bytes([cpu_speed]))
            if gpu_manual:
                f.seek(33)
                f.write(bytes([48]))
                f.seek(58)
                f.write(bytes([gpu_speed]))
    except Exception:
        pass

def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    action = sys.argv[1]
    if action == "status":
        read_status()
    elif action == "set" and len(sys.argv) >= 4:
        set_fan(sys.argv[2], sys.argv[3])
    elif action == "maintain":
        maintain()

if __name__ == "__main__":
    main()
