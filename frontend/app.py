from flask import Flask

app = Flask(__name__)

@app.route('/')
@app.route('/home')
def display_home_page():
    return '<body style="margin:0; background-color:black; color:white; display:flex; justify-content:center; align-items:center; height:100vh;"><h1 style="white-space:nowrap;">The Frontend Service served from Serverless NEG (Cloud Run).</h1></body>'


if __name__ == '__main__':
     app.run(host="0.0.0.0", port=8080)