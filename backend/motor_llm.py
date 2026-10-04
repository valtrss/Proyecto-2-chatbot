"""Motor LLM: responde preguntas con Gemini usando la misma base de conocimiento.

En vez de reglas, al modelo se le entrega como contexto el contenido de los
archivos de hechos de prolog/base/ y se le pide responder solo con esa
información. Así ambas versiones del chatbot usan exactamente el mismo
conocimiento recopilado.

Uso por consola:
    $ python backend/motor_llm.py "¿Qué vino va con la carbonara?"
    $ python backend/motor_llm.py          # conversación interactiva

Requiere la variable GEMINI_API_KEY (o un archivo .env en la raíz del
proyecto con la línea GEMINI_API_KEY=...).
"""
import logging
import os
import sys
from pathlib import Path

from google import genai
from google.genai import types

RAIZ = Path(__file__).resolve().parent.parent
BASE = RAIZ / "prolog" / "base"
ARCHIVOS_CONOCIMIENTO = [
    "productos.pl",
    "taxonomia.pl",
    "regiones.pl",
    "recetas.pl",
    "maridajes.pl",
    "combinaciones.pl",
]
MODELO = os.environ.get("GEMINI_MODEL", "gemini-3.5-flash-lite")

# El SDK avisa por cada respuesta que trae partes de "razonamiento"; no aporta.
logging.getLogger("google_genai.types").setLevel(logging.ERROR)

INSTRUCCIONES = """Eres "La Dispensa", un asistente que responde preguntas sobre productos y
cocina italiana de la tienda chilena gourmitalia.cl.

Tu única fuente de información es la BASE DE CONOCIMIENTO que viene abajo,
escrita como hechos de Prolog. Cómo leerla:
- producto(Id, Nombre, Marca, PrecioCLP, Formato): los precios están en pesos chilenos.
- tipo/2 y subtipo/2 forman una jerarquía (por ejemplo gorgonzola -> queso_azul -> queso).
- agotado(Id) significa que el producto no tiene stock.
- receta/4 e ingrediente/3 describen recetas; basico/2 son ingredientes que la tienda no vende.
- marida_perfil/3 y marida_tipo/3 indican qué clase de vino acompaña cada plato o producto.

Reglas para responder:
1. Responde en español, de forma breve y clara.
2. Usa solo la base de conocimiento. Si la respuesta no está ahí, dilo
   ("No tengo esa información en el catálogo") en vez de inventar.
3. Nunca inventes productos, precios ni marcas que no estén en la base.
4. Escribe los precios como $20.900 y usa el nombre del producto, no su identificador.
5. Si un producto está agotado, avísalo.
6. No uses formato Markdown (nada de asteriscos ni #). Para listas usa líneas que empiecen con "• ".

BASE DE CONOCIMIENTO:
"""


class ErrorLLM(RuntimeError):
    """No se pudo consultar el LLM (falta la API key o falló la conexión)."""


def cargar_env():
    """Lee el archivo .env de la raíz, si existe, sin pisar variables ya definidas."""
    archivo = RAIZ / ".env"
    if not archivo.exists():
        return
    for linea in archivo.read_text(encoding="utf-8").splitlines():
        linea = linea.strip()
        if linea and not linea.startswith("#") and "=" in linea:
            clave, valor = linea.split("=", 1)
            os.environ.setdefault(clave.strip(), valor.strip().strip('"'))


def base_de_conocimiento():
    partes = []
    for nombre in ARCHIVOS_CONOCIMIENTO:
        texto = (BASE / nombre).read_text(encoding="utf-8")
        partes.append(f"% ===== {nombre} =====\n{texto}")
    return "\n\n".join(partes)


_cliente = None


def cliente():
    global _cliente
    if _cliente is None:
        cargar_env()
        clave = os.environ.get("GEMINI_API_KEY")
        if not clave:
            raise ErrorLLM("Falta la API key: crea un archivo .env con la línea GEMINI_API_KEY=...")
        _cliente = genai.Client(api_key=clave)
    return _cliente


def responder(pregunta: str) -> str:
    try:
        respuesta = cliente().models.generate_content(
            model=MODELO,
            contents=pregunta,
            config=types.GenerateContentConfig(
                system_instruction=INSTRUCCIONES + base_de_conocimiento(),
                temperature=0.2,
            ),
        )
    except ErrorLLM:
        raise
    except Exception as e:
        raise ErrorLLM(f"Error al consultar {MODELO}: {e}") from e
    return (respuesta.text or "").strip()


def main():
    if len(sys.argv) > 1:
        print(responder(" ".join(sys.argv[1:])))
        return
    print("La Dispensa (LLM). Escribe «salir» para terminar.")
    while True:
        pregunta = input("\nTú: ").strip()
        if pregunta.lower() in ("salir", "exit"):
            break
        if pregunta:
            print("Bot:", responder(pregunta))


if __name__ == "__main__":
    main()
