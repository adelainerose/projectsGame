import time
import socket
from mfrc522 import SimpleMFRC522
#import RPi.GPIO as GPIO

#reader object
reader = SimpleMFRC522()

HOST = "127.0.0.1"
PORT = 12345


with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    conn, addr = s.accept()
 
    with conn:
        print("connected by", addr)
        while True:
            data = conn.recv(1024).decode('utf-8').strip()
            print(data)
            if not data:
                break
            if data == "RFID": 
                print("hold card to reader")
                id, text = reader.read()
                print(text)
                conn.sendall((str(text) + '\n').encode('utf-8'))
                print("sent!")
            else:
                break
            
'''
try:
    pass
    while True:
        cmd=input("Read or Write? (R/W)")
        if cmd == "W":
            txt = input("Input your text: ")
            print("place card on reader")
            reader.write(txt)
            time.sleep(1)
        if cmd == "R":
            print("place card on reader")
            id, text = reader.read()
            print(id)
            print(text)
            time.sleep(1)

except:
    GPIO.cleanup()
    print("GPIO!")
'''