/*  recetas.pl
    Recetas del blog "Recetas de la Famiglia" de gourmitalia.cl, más dos
    clásicos de conocimiento general (amatriciana y tiramisú).

      receta(Id, Nombre, Region, Fuente).      % Region = ninguna si no aplica
      ingrediente(Receta, Ingrediente, Cantidad).
      perfil(Receta, Perfil).                  % usado para maridar
      basico(Ingrediente, Nombre).             % no se vende en la tienda
      sustituto(Ingrediente, Alternativa).

    Un Ingrediente puede ser:
      - un producto concreto del catálogo  (p. ej. pecorino_romano),
      - un tipo de la taxonomía            (p. ej. spaghetti, aceite_oliva),
      - un ingrediente básico que la tienda no vende (huevo, sal, ajo...).
    reglas.pl decide qué productos de la tienda sirven para cada ingrediente.
*/
:- encoding(utf8).

:- discontiguous receta/4, ingrediente/3, perfil/2.

% --- Ingredientes básicos (no se venden en la tienda) -------------------
basico(huevo,          "huevos").
basico(sal,            "sal").
basico(pimienta,       "pimienta").
basico(ajo,            "ajo").
basico(cebolla,        "cebolla").
basico(cebolla_morada, "cebolla morada").
basico(albahaca,       "albahaca fresca").
basico(almendras,      "almendras peladas").
basico(nueces,         "nueces").
basico(mantequilla,    "mantequilla").
basico(caldo_verduras, "caldo de verduras").
basico(papas,          "papas").
basico(apio,           "apio").
basico(zanahoria,      "zanahoria").
basico(hierbas,        "laurel y romero").
basico(azucar,         "azúcar").
basico(cacao,          "cacao amargo").

% --- Sustitutos que mencionan las recetas del blog ----------------------
sustituto(guanciale, pancetta).      % carbonara: "Guanciale o Pancetta"
sustituto(pinoli, nueces).           % pesto: "Pinoli (alternativa: nueces)"

% --- Spaghetti alla carbonara (blog) -----------------------------------
receta(carbonara, "Spaghetti alla Carbonara", lazio, blog).
ingrediente(carbonara, spaghetti,       "300 g").
ingrediente(carbonara, guanciale,       "300 g").
ingrediente(carbonara, pecorino_romano, "50 g").
ingrediente(carbonara, huevo,           "4 unidades (3 yemas y 1 entero)").
ingrediente(carbonara, sal,             "a gusto").
ingrediente(carbonara, pimienta,        "a gusto").
perfil(carbonara, graso).
perfil(carbonara, cerdo).

% --- Bucatini all'amatriciana (conocimiento general) --------------------
receta(amatriciana, "Bucatini all'Amatriciana", lazio, general).
ingrediente(amatriciana, bucatini,        "400 g").
ingrediente(amatriciana, guanciale,       "150 g").
ingrediente(amatriciana, pecorino_romano, "70 g").
ingrediente(amatriciana, tomate_pelado,   "400 g").
ingrediente(amatriciana, vino_blanco,     "1/2 copa").
ingrediente(amatriciana, peperoncino,     "una pizca").
ingrediente(amatriciana, sal,             "a gusto").
perfil(amatriciana, tomate).
perfil(amatriciana, cerdo).

% --- Risotto ai funghi porcini (blog) -----------------------------------
receta(risotto_porcini, "Risotto ai Funghi Porcini", ninguna, blog).
ingrediente(risotto_porcini, arroz_arborio,  "500 g").
ingrediente(risotto_porcini, aceite_oliva,   "30 ml").
ingrediente(risotto_porcini, vino_blanco,    "1/2 copa").
ingrediente(risotto_porcini, cebolla,        "1/4 de cebolla grande").
ingrediente(risotto_porcini, grana_padano,   "80 g").
ingrediente(risotto_porcini, mantequilla,    "80 g").
ingrediente(risotto_porcini, funghi_porcini, "100 g").
ingrediente(risotto_porcini, caldo_verduras, "2 litros").
ingrediente(risotto_porcini, sal,            "a gusto").
perfil(risotto_porcini, hongos).

% --- Pasta e patate alla napoletana (blog) ------------------------------
receta(pasta_e_patate, "Pasta e Patate alla Napoletana", campania, blog).
ingrediente(pasta_e_patate, pasta_mista,        "500 g").
ingrediente(pasta_e_patate, papas,              "500 g en cubitos").
ingrediente(pasta_e_patate, apio,               "150 g").
ingrediente(pasta_e_patate, zanahoria,          "150 g").
ingrediente(pasta_e_patate, cebolla_morada,     "50 g").
ingrediente(pasta_e_patate, aceite_oliva,       "60 ml").
ingrediente(pasta_e_patate, concentrado_tomate, "50 g").
ingrediente(pasta_e_patate, pancetta,           "200 g").
ingrediente(pasta_e_patate, grana_padano,       "corteza, a gusto").
ingrediente(pasta_e_patate, provola,            "200 g").
ingrediente(pasta_e_patate, hierbas,            "a gusto").
ingrediente(pasta_e_patate, sal,                "a gusto").
perfil(pasta_e_patate, contundente).

% --- Orecchiette al pesto trapanese (blog) ------------------------------
receta(orecchiette_trapanese, "Orecchiette al Pesto Trapanese", sicilia, blog).
ingrediente(orecchiette_trapanese, orecchiette,     "500 g").
ingrediente(orecchiette_trapanese, tomate_pelado,   "200 g").
ingrediente(orecchiette_trapanese, albahaca,        "50 g").
ingrediente(orecchiette_trapanese, almendras,       "50 g").
ingrediente(orecchiette_trapanese, pecorino_romano, "15 g").
ingrediente(orecchiette_trapanese, ajo,             "1 diente").
ingrediente(orecchiette_trapanese, aceite_oliva,    "a gusto").
ingrediente(orecchiette_trapanese, pimienta,        "a gusto").
perfil(orecchiette_trapanese, tomate).
perfil(orecchiette_trapanese, hierbas).

% --- Pesto alla genovese (blog) -----------------------------------------
receta(pesto_casero, "Pesto alla Genovese casero", liguria, blog).
ingrediente(pesto_casero, aceite_oliva,        "60 g").
ingrediente(pesto_casero, parmigiano_reggiano, "30 g").
ingrediente(pesto_casero, albahaca,            "25 g").
ingrediente(pesto_casero, pinoli,              "10 g").
ingrediente(pesto_casero, pecorino_sardo,      "10 g").
ingrediente(pesto_casero, ajo,                 "1 diente").
ingrediente(pesto_casero, sal,                 "sal de mar gruesa").
perfil(pesto_casero, hierbas).

% --- Trofie al pesto genovese (blog) ------------------------------------
receta(trofie_pesto, "Trofie al Pesto Genovese", liguria, blog).
ingrediente(trofie_pesto, trofie,              "500 g").
ingrediente(trofie_pesto, aceite_oliva,        "60 g").
ingrediente(trofie_pesto, parmigiano_reggiano, "30 g").
ingrediente(trofie_pesto, albahaca,            "25 g").
ingrediente(trofie_pesto, pinoli,              "10 g").
ingrediente(trofie_pesto, pecorino_sardo,      "10 g").
ingrediente(trofie_pesto, ajo,                 "1 diente").
ingrediente(trofie_pesto, sal,                 "sal de mar gruesa").
perfil(trofie_pesto, hierbas).

% --- Pasta corta en ensalada de pesto y tomates cherry (blog) ------------
receta(ensalada_pesto, "Pasta en ensalada de pesto y tomates cherry", ninguna, blog).
ingrediente(ensalada_pesto, pasta_corta,         "380 g").
ingrediente(ensalada_pesto, tomate_cherry,       "200 g").
ingrediente(ensalada_pesto, albahaca,            "25 g").
ingrediente(ensalada_pesto, pinoli,              "10 g").
ingrediente(ensalada_pesto, pecorino_romano,     "15 g").
ingrediente(ensalada_pesto, parmigiano_reggiano, "30 g").
ingrediente(ensalada_pesto, ajo,                 "1 diente").
ingrediente(ensalada_pesto, aceite_oliva,        "50 g").
ingrediente(ensalada_pesto, sal,                 "a gusto").
perfil(ensalada_pesto, hierbas).
perfil(ensalada_pesto, fresco).

% --- Linguine con anchoas y piñones (blog) -------------------------------
receta(linguine_anchoas, "Linguine con Anchoas y Piñones", ninguna, blog).
ingrediente(linguine_anchoas, linguine,     "400 g").
ingrediente(linguine_anchoas, pinoli,       "70 g").
ingrediente(linguine_anchoas, anchoas,      "12 filetes").
ingrediente(linguine_anchoas, alcaparras,   "100 g").
ingrediente(linguine_anchoas, aceite_oliva, "3 cucharadas").
ingrediente(linguine_anchoas, ajo,          "2 o 3 dientes").
ingrediente(linguine_anchoas, aceitunas,    "200 g sin cuesco").
ingrediente(linguine_anchoas, sal,          "a gusto").
ingrediente(linguine_anchoas, pimienta,     "a gusto").
perfil(linguine_anchoas, pescado).

% --- Linguine integrales con pecorino y nueces (blog) --------------------
receta(linguine_pecorino, "Linguine Integrales con Pecorino y Nueces", ninguna, blog).
ingrediente(linguine_pecorino, linguine_integral, "240 g").
ingrediente(linguine_pecorino, nueces,            "100 g").
ingrediente(linguine_pecorino, pecorino,          "100 g").
ingrediente(linguine_pecorino, aceite_oliva,      "1 cucharada").
ingrediente(linguine_pecorino, sal,               "a gusto").
ingrediente(linguine_pecorino, pimienta,          "a gusto").
perfil(linguine_pecorino, queso_intenso).

% --- Tiramisú (conocimiento general) ------------------------------------
receta(tiramisu, "Tiramisù", veneto, general).
ingrediente(tiramisu, mascarpone, "500 g").
ingrediente(tiramisu, savoiardi,  "300 g").
ingrediente(tiramisu, huevo,      "4 unidades").
ingrediente(tiramisu, azucar,     "100 g").
ingrediente(tiramisu, cafe,       "300 ml de café espresso").
ingrediente(tiramisu, cacao,      "para espolvorear").
perfil(tiramisu, postre).
