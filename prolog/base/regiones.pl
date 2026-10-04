/*  regiones.pl
    Conocimiento geográfico de Italia y de los sellos de origen.

      region_italiana(Region, Nombre, Zona, Capital).
      significado_sello(Sello, Sigla, Explicacion).
*/
:- encoding(utf8).

% --- Regiones (zona: norte, centro, sur, islas) -------------------------
region_italiana(lombardia,           "Lombardía",           norte,  "Milán").
region_italiana(piemonte,            "Piamonte",            norte,  "Turín").
region_italiana(veneto,              "Véneto",              norte,  "Venecia").
region_italiana(friuli,              "Friuli-Venecia Julia", norte, "Trieste").
region_italiana(trentino_alto_adige, "Trentino-Alto Adigio", norte, "Trento").
region_italiana(liguria,             "Liguria",             norte,  "Génova").
region_italiana(emilia_romana,       "Emilia-Romaña",       norte,  "Bolonia").
region_italiana(toscana,             "Toscana",             centro, "Florencia").
region_italiana(lazio,               "Lacio",               centro, "Roma").
region_italiana(abruzzo,             "Abruzos",             centro, "L'Aquila").
region_italiana(campania,            "Campania",            sur,    "Nápoles").
region_italiana(puglia,              "Apulia",              sur,    "Bari").
region_italiana(calabria,            "Calabria",            sur,    "Catanzaro").
region_italiana(sicilia,             "Sicilia",             islas,  "Palermo").
region_italiana(cerdena,             "Cerdeña",             islas,  "Cagliari").

% --- Sellos de calidad y origen ----------------------------------------
significado_sello(dop,  "D.O.P.",
    "Denominación de Origen Protegida: todo el proceso (producción, elaboración y maduración) ocurre en una zona geográfica delimitada y sigue un reglamento oficial").
significado_sello(igp,  "I.G.P.",
    "Indicación Geográfica Protegida: al menos una etapa de la producción ocurre en la zona geográfica que da nombre al producto").
significado_sello(docg, "D.O.C.G.",
    "Denominación de Origen Controlada y Garantizada: la categoría más alta de los vinos italianos, con controles de calidad más estrictos que la D.O.C.").
significado_sello(doc,  "D.O.C.",
    "Denominación de Origen Controlada: vino de una zona delimitada que cumple un reglamento de uvas, rendimiento y elaboración").
significado_sello(igt,  "I.G.T.",
    "Indicación Geográfica Típica: vino de una región amplia con reglas más flexibles que la D.O.C.").

% Jerarquía de los sellos de vino (de mayor a menor exigencia).
nivel_sello(docg, 3).
nivel_sello(doc,  2).
nivel_sello(igt,  1).
