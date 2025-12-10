from flask import Flask, render_template, request
import requests

app = Flask(__name__)
BACKEND_URL = "http://express-backend:3000"  # Use 'http://localhost:3000' for run locally

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
        except:
            greeting = "Backend not reachable"
    return render_template("index.html", greeting=greeting)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000)
