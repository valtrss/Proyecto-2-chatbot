// El chatbot Prolog corre dentro del navegador con SWI-Prolog compilado a
// WebAssembly (swipl-wasm). Así la página funciona sin servidor, por ejemplo
// en GitHub Pages. Los archivos .pl se descargan de la carpeta prolog/.

const SWIPL_CDN = "https://cdn.jsdelivr.net/npm/swipl-wasm@8.2.1/dist/swipl/";
const CARPETA_PROLOG = "../prolog/";
const ARCHIVOS_PROLOG = [
  "chatbot.pl",
  "base.pl",
  "reglas.pl",
  "lenguaje.pl",
  "respuestas.pl",
  "base/productos.pl",
  "base/taxonomia.pl",
  "base/regiones.pl",
  "base/recetas.pl",
  "base/maridajes.pl",
  "base/combinaciones.pl",
  "base/sinonimos.pl",
];

const conversacion = document.getElementById("conversacion");
const formulario = document.getElementById("formulario");
const campo = document.getElementById("pregunta");
const boton = formulario.querySelector("button");

let swipl = null;

function agregarMensaje(texto, clase) {
  const div = document.createElement("div");
  div.className = `mensaje ${clase}`;
  div.textContent = texto;
  conversacion.appendChild(div);
  conversacion.scrollTop = conversacion.scrollHeight;
  return div;
}

// Descarga los .pl, los copia al sistema de archivos virtual de Prolog y
// carga chatbot.pl (que a su vez carga el resto).
async function cargarProlog() {
  const motor = await SWIPL({
    arguments: ["-q"],
    locateFile: (archivo) => SWIPL_CDN + archivo,
  });
  motor.FS.mkdir("/app");
  motor.FS.mkdir("/app/base");

  const contenidos = await Promise.all(
    ARCHIVOS_PROLOG.map(async (archivo) => {
      const res = await fetch(CARPETA_PROLOG + archivo, { cache: "no-store" });
      if (!res.ok) throw new Error(`No se pudo descargar ${archivo}`);
      return res.text();
    })
  );
  ARCHIVOS_PROLOG.forEach((archivo, i) => {
    motor.FS.writeFile("/app/" + archivo, contenidos[i]);
  });

  const carga = motor.prolog.query("consult('/app/chatbot.pl')").once();
  if (!carga.success) throw new Error("Prolog no pudo cargar la base de conocimiento");
  return motor;
}

function responder(pregunta) {
  const resultado = swipl.prolog.query("responder(P, R)", { P: pregunta }).once();
  if (!resultado.success) return "No pude armar una respuesta.";
  return typeof resultado.R === "string" ? resultado.R : resultado.R.v;
}

function preguntar(pregunta) {
  agregarMensaje(pregunta, "yo");
  try {
    agregarMensaje(responder(pregunta), "bot");
  } catch (e) {
    console.error(e);
    agregarMensaje("Ocurrió un error al consultar Prolog.", "bot error");
  }
  campo.focus();
}

formulario.addEventListener("submit", (e) => {
  e.preventDefault();
  const pregunta = campo.value.trim();
  if (!pregunta || !swipl) return;
  campo.value = "";
  preguntar(pregunta);
});

document.getElementById("sugerencias").addEventListener("click", (e) => {
  if (e.target.tagName === "BUTTON" && swipl) preguntar(e.target.textContent);
});

async function iniciar() {
  boton.disabled = true;
  const cargando = agregarMensaje("Cargando la base de conocimiento…", "bot pensando");
  try {
    swipl = await cargarProlog();
    cargando.remove();
    agregarMensaje(responder("hola"), "bot");
    boton.disabled = false;
    campo.focus();
  } catch (e) {
    console.error(e);
    cargando.remove();
    agregarMensaje("No se pudo cargar Prolog. Revisa tu conexión y recarga la página.", "bot error");
  }
}

iniciar();
