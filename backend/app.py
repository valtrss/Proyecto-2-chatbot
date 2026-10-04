"""Servidor web del chatbot de gastronomía italiana.

    $ python backend/app.py
    Abrir http://localhost:5000
"""
from pathlib import Path

from flask import Flask, jsonify, request, send_from_directory

import motor_prolog

WEB = Path(__file__).resolve().parent.parent / "web"
LARGO_MAXIMO = 500
MOTORES = {
    "prolog": motor_prolog.responder,
    # "llm": motor_llm.responder,   # Entrega 2
}

app = Flask(__name__, static_folder=None)


@app.get("/")
def index():
    return send_from_directory(WEB, "index.html")


@app.get("/<path:archivo>")
def estaticos(archivo):
    return send_from_directory(WEB, archivo)


@app.get("/api/motores")
def motores():
    return jsonify(sorted(MOTORES))


@app.post("/api/chat")
def chat():
    datos = request.get_json(silent=True) or {}
    pregunta = str(datos.get("pregunta", "")).strip()
    motor = datos.get("motor", "prolog")

    if not pregunta:
        return jsonify(error="La pregunta está vacía."), 400
    if len(pregunta) > LARGO_MAXIMO:
        return jsonify(error=f"La pregunta supera los {LARGO_MAXIMO} caracteres."), 400
    if motor not in MOTORES:
        return jsonify(error=f"Motor desconocido: {motor}."), 400

    try:
        respuesta = MOTORES[motor](pregunta)
    except motor_prolog.ErrorProlog as e:
        app.logger.error("Error de Prolog: %s", e)
        return jsonify(error="El motor Prolog no pudo responder."), 500

    return jsonify(motor=motor, respuesta=respuesta)


if __name__ == "__main__":
    app.run(debug=True, port=5000)
