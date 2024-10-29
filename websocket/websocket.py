#https://github.com/Fesantt


import asyncio
import websockets
import ctypes
import tkinter as tk
from tkinter import scrolledtext
import threading
import queue

IP = "0.0.0.0" #deixar assim para pegar o ip do seu computador automaticamente
PORT = 6789 #porta que o websocket vai funcionar
connected_devices = set()

def minimize_console():
    kernel32 = ctypes.windll.kernel32
    user32 = ctypes.windll.user32
    hWnd = kernel32.GetConsoleWindow()
    if hWnd:
        user32.ShowWindow(hWnd, 6)

async def handler(websocket, path, log_queue):
    connected_devices.add(websocket)
    log_queue.put(f"Dispositivo conectado: {websocket.remote_address}")

    try:
        async for message in websocket:
            log_queue.put(f"Mensagem recebida de {websocket.remote_address}: {message}")
            for device in connected_devices:
                if device != websocket:
                    await device.send(message)
    finally:
        connected_devices.remove(websocket)
        log_queue.put(f"Dispositivo desconectado: {websocket.remote_address}")

async def start_server(log_queue):
    print(f"Iniciando o servidor WebSocket em {IP}:{PORT}")
    server = await websockets.serve(lambda ws, path: handler(ws, path, log_queue), IP, PORT)
    await server.wait_closed()

def run_server(log_queue):
    asyncio.run(start_server(log_queue))

class ServerApp:
    def __init__(self, root):
        self.root = root
        self.log_queue = queue.Queue()
        self.server_thread = None

        self.root.title("MAP-OS CONNECT")
        self.root.geometry("400x300")

        self.log_area = scrolledtext.ScrolledText(root, width=50, height=10)
        self.log_area.pack(pady=10)

        self.start_button = tk.Button(root, text="Iniciar Servidor", command=self.start_server)
        self.start_button.pack(pady=5)

        self.stop_button = tk.Button(root, text="Encerrar Servidor", command=self.stop_server)
        self.stop_button.pack(pady=5)

        self.root.after(100, self.update_logs)

    def start_server(self):
        if self.server_thread is None or not self.server_thread.is_alive():
            self.server_thread = threading.Thread(target=run_server, args=(self.log_queue,))
            self.server_thread.start()
            self.log_area.insert(tk.END, "Servidor iniciado...\n")
        else:
            self.log_area.insert(tk.END, "Servidor já está em execução.\n")

    def update_logs(self):
        while not self.log_queue.empty():
            log_message = self.log_queue.get()
            self.log_area.insert(tk.END, log_message + "\n")
        self.root.after(100, self.update_logs)  # Atualiza logs periodicamente

    def stop_server(self):
        if self.server_thread and self.server_thread.is_alive():
            self.server_thread.join()
            self.server_thread = None
            self.log_area.insert(tk.END, "Servidor encerrado...\n")
        else:
            self.log_area.insert(tk.END, "Servidor já está parado.\n")

if __name__ == "__main__":
    minimize_console()

    root = tk.Tk()
    app = ServerApp(root)
    root.mainloop()
