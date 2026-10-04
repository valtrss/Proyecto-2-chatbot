const conversacion = document.getElementById("conversacion");
const formulario = document.getElementById("formulario");
const campo = document.getElementById("pregunta");
const boton = formulario.querySelector("button");

// Por ahora solo existe el motor Prolog; el LLM llega en la Entrega 2.
const MOTOR = "prolog";

function agregarMensaje(texto, clase, etiqueta) {
  const div = document.createElement("div");
  div.className = `mensaje ${clase}`;
  if (etiqueta) {
    const span = document.createElement("span");
    span.className = "etiqueta";
    span.textContent = etiqueta;
    div.appendChild(span);
  }
  div.appendChild(document.createTextNode(texto));
  conversacion.appendChild(div);
  conversacion.scrollTop = conversacion.scrollHeight;
  return div;
}

async function preguntar(pregunta) {
  agregarMensaje(pregunta, "yo");
  const pensando = agregarMensaje("Pensando…", "bot pensando");
  boton.disabled = true;

  try {
    const res = await fetch("/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ pregunta, motor: MOTOR }),
    });
    const datos = await res.json();
    pensando.remove();
    if (!res.ok) {
      agregarMensaje(datos.error || "Error desconocido.", "bot error");
    } else {
      agregarMensaje(datos.respuesta, "bot");
    }
  } catch {
    pensando.remove();
    agregarMensaje("No me pude conectar con el servidor.", "bot error");
  } finally {
    boton.disabled = false;
    campo.focus();
  }
}

formulario.addEventListener("submit", (e) => {
  e.preventDefault();
  const pregunta = campo.value.trim();
  if (!pregunta) return;
  campo.value = "";
  preguntar(pregunta);
});

document.getElementById("sugerencias").addEventListener("click", (e) => {
  if (e.target.tagName === "BUTTON") preguntar(e.target.textContent);
});

preguntar("hola");
