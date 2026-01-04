#!/bin/bash

sudo apt-get update
sudo apt-get install -y python3-flask

cat <<EOF > /app.py
from flask import Flask
app = Flask(__name__)

@app.route('/account')
def home():
   return '<body style="margin:0; background-color:green; color:black; display:flex; justify-content:center; align-items:center; height:100vh;"><h1 style="white-space:nowrap;">The User Account Service served from Zonal NEG.</h1></body>'



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

python3 /app.py > /dev/null 2>&1 &