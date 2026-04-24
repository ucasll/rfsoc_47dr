import socket
import time

class LedController:
    def __init__(self, ip='192.168.1.10', port=6001):
        self.ip = ip
        self.port = port
        self.sock = None

    def connect(self):
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.settimeout(5) # 防止死等
            self.sock.connect((self.ip, self.port))
            print(f"Successfully connected to {self.ip}:{self.port}")
            return True
        except Exception as e:
            print(f"Connection failed: {e}")
            return False

    def send_val(self, val):
        """发送 0-15 的整数控制 LED"""
        if not (0 <= val <= 15):
            print("Value out of range (0-15)")
            return

        try:
            msg = str(val).encode('utf-8')
            self.sock.sendall(msg)
            
            # 等待板子回传 ACK (如果在 C 端写了回复逻辑)
            # data = self.sock.recv(1024)
            # print(f"Board response: {data.decode()}")
            
            print(f"Sent: {val:2d} (Binary: {val:04b})")
        except Exception as e:
            print(f"Send failed: {e}")

    def close(self):
        if self.sock:
            self.sock.close()

if __name__ == "__main__":
    ctrl = LedController()
    
    if ctrl.connect():
        # 跑一个简单的循环测试
        test_sequence = [15, 0, 10, 5, 1, 2, 4, 8, 15]
        for v in test_sequence:
            ctrl.send_val(v)
            time.sleep(0.5) # 半秒切一次灯
            
        print("Sequence complete. Closing connection.")
        ctrl.close()