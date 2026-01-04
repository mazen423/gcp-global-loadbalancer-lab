#!/bin/bash

sudo apt-get update
sudo apt-get install -y python3-flask

cat <<EOF > /app.py
from flask import Flask
app = Flask(__name__)

@app.route('/checkout')
def home():
   return '<body style="margin:0; background-color:blue; color:black; display:flex; justify-content:center; align-items:center; height:100vh;"><h1 style="white-space:nowrap;">The Checkout Service served from MIG.</h1></body>'



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
EOF

nohup python3 /app.py > /var/log/app.log 2>&1 &