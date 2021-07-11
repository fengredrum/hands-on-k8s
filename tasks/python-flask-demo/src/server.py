import platform
import time
from datetime import datetime
from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello_world():
    sleep_time = 0.2
    uname = platform.uname()
    time.sleep(sleep_time)
    curr_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    return "<p>Hello, World!</p>" + \
        f"</p>Node Name: {uname.node}</p>" + \
        f"</p>Current time: {curr_time}</p>" + \
        f"</p>Sleep: {sleep_time} s</p>"