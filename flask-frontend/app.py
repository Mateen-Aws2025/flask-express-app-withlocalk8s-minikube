from flask import Flask, render_template, request
import requests
import os

app = Flask(__name__)

# Backend URL (Express)
BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:3000")

@app.route("/", methods=["GET", "POST"])
def home():
    greeting = None

    if request.method == "POST":
        data = {
            "name": request.form.get("name"),
            "age": request.form.get("age"),
            "email": request.form.get("email"),
            "profession": request.form.get("profession"),
            "gender": request.form.get("gender")
        }

        try:
            response = requests.post(f"{BACKEND_URL}/greet", json=data)
            greeting = response.json().get("message")
        except Exception:
            greeting = "Express backend not reachable"

    return render_template("index.html", greeting=greeting)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
