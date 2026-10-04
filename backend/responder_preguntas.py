"""Responde las preguntas del informe con ambos motores y guarda el resultado.

    $ python backend/responder_preguntas.py

Lee docs/preguntas.txt (una pregunta por línea) y escribe
docs/respuestas_generadas.md con la respuesta de Prolog y la del LLM para
cada una. Ese archivo es la base del informe de desempeño.
"""
import time
from datetime import date
from pathlib import Path

import motor_llm
import motor_prolog

RAIZ = Path(__file__).resolve().parent.parent
PREGUNTAS = RAIZ / "docs" / "preguntas.txt"
SALIDA = RAIZ / "docs" / "respuestas_generadas.md"

# El plan gratis de Gemini acepta pocas consultas por minuto: se espera entre
# preguntas y se reintenta si el servicio responde "cuota excedida" (429) o
# "sobrecargado" (503).
PAUSA_SEGUNDOS = 15
REINTENTOS = 4


def responder_con(motor, pregunta):
    try:
        return motor(pregunta)
    except (motor_prolog.ErrorProlog, motor_llm.ErrorLLM) as e:
        return f"[ERROR] {e}"


def responder_llm(pregunta):
    for intento in range(1, REINTENTOS + 1):
        respuesta = responder_con(motor_llm.responder, pregunta)
        temporal = "429" in respuesta or "503" in respuesta
        if not (respuesta.startswith("[ERROR]") and temporal):
            return respuesta
        espera = 30 * intento
        print(f"    servicio ocupado, reintento {intento} en {espera} s")
        time.sleep(espera)
    return respuesta


def main():
    preguntas = [p.strip() for p in PREGUNTAS.read_text(encoding="utf-8").splitlines() if p.strip()]
    lineas = [f"# Respuestas generadas ({date.today().isoformat()}, modelo {motor_llm.MODELO})", ""]
    for i, pregunta in enumerate(preguntas, start=1):
        print(f"[{i}/{len(preguntas)}] {pregunta}")
        lineas += [
            f"## {i}. {pregunta}",
            "",
            "**Prolog:**",
            "",
            "```text",
            responder_con(motor_prolog.responder, pregunta),
            "```",
            "",
            "**LLM:**",
            "",
            "```text",
            responder_llm(pregunta),
            "```",
            "",
        ]
        if i < len(preguntas):
            time.sleep(PAUSA_SEGUNDOS)
    SALIDA.write_text("\n".join(lineas), encoding="utf-8")
    print(f"Listo: {SALIDA}")


if __name__ == "__main__":
    main()
