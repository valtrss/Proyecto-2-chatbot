"""Motor Prolog: envía la pregunta a SWI-Prolog y devuelve la respuesta.

Cada consulta lanza `swipl prolog/cli.pl "<pregunta>"`. La pregunta viaja
como argumento del proceso (no se interpreta como código Prolog), así que
no hay riesgo de inyección.
"""
import shutil
import subprocess
from pathlib import Path

CLI = Path(__file__).resolve().parent.parent / "prolog" / "cli.pl"
TIMEOUT_SEGUNDOS = 10


class ErrorProlog(RuntimeError):
    """El proceso de Prolog falló o no está instalado."""


def responder(pregunta: str) -> str:
    swipl = shutil.which("swipl")
    if swipl is None:
        raise ErrorProlog("No se encontró SWI-Prolog (swipl) en el PATH.")

    try:
        resultado = subprocess.run(
            [swipl, str(CLI), pregunta],
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=TIMEOUT_SEGUNDOS,
        )
    except subprocess.TimeoutExpired as e:
        raise ErrorProlog("Prolog tardó demasiado en responder.") from e

    if resultado.returncode != 0:
        raise ErrorProlog(resultado.stderr.strip() or "Prolog terminó con error.")
    return resultado.stdout.strip()
