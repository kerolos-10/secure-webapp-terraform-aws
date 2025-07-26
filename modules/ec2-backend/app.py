from flask import Flask
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    hostname = socket.gethostname()
    html_content = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Kerolos EC2</title>
        <style>
            * {{
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }}

            body {{
                height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                background: linear-gradient(-45deg, #1e3c72, #2a5298, #1e3c72, #0f2027);
                background-size: 400% 400%;
                animation: gradientBG 15s ease infinite;
            }}

            @keyframes gradientBG {{
                0% {{ background-position: 0% 50%; }}
                50% {{ background-position: 100% 50%; }}
                100% {{ background-position: 0% 50%; }}
            }}

            .card {{
                background: rgba(255, 255, 255, 0.15);
                border-radius: 15px;
                padding: 40px;
                text-align: center;
                box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
                backdrop-filter: blur(10px);
                -webkit-backdrop-filter: blur(10px);
                border: 1px solid rgba(255, 255, 255, 0.18);
                color: white;
                max-width: 500px;
                width: 90%;
            }}

            h1 {{
                font-size: 2.5em;
                margin-bottom: 20px;
            }}

            p {{
                font-size: 1.2em;
                line-height: 1.6;
            }}

            .hostname {{
                color: #ffd700;
                font-weight: bold;
                font-size: 1.3em;
            }}

            .footer {{
                margin-top: 30px;
                font-size: 0.9em;
                color: #ccc;
            }}
        </style>
    </head>
    <body>
        <div class="card">
            <h1>🚀 Welcome, Kerolos!</h1>
            <p>This app is running from your EC2 instance:</p>
            <p class="hostname">{hostname}</p>
            <div class="footer">Flask Web App with Love ❤️</div>
        </div>
    </body>
    </html>
    """
    return html_content

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
