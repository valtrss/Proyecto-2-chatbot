/*  productos.pl
    Hechos sobre los productos del catálogo de gourmitalia.cl.
    Fuente: catálogo público del sitio, precios tomados el 02-10-2026.

    Cada producto se describe con un bloque de hechos consecutivos:

      producto(Id, Nombre, Marca, PrecioCLP, Formato).
      tipo(Id, Tipo).            % clasificación; ver taxonomia.pl
      region(Id, Region).        % región italiana de origen; ver regiones.pl
      sello(Id, Sello).          % dop, igp, doc, docg, igt
      leche(Id, Animal).         % vaca, oveja, bufala
      maduracion(Id, Texto).
      uva(Id, Uva).              % cepas del vino
      grado_alcohol(Id, Grados).
      coccion(Id, Minutos).
      sin_gluten(Id).  sin_lactosa(Id).  picante(Id).  ahumado(Id).
      congelado(Id).   con_huevo(Id).    integral(Id).  trafilada_bronce(Id).
      agotado(Id).               % sin stock en la tienda
      carne(Id, Animal).         % solo si el embutido NO es de cerdo
      trazas_gluten(Id).         % el envase advierte posibles trazas
      dato(Id, Texto).           % descripción breve

    Para agregar un producto basta copiar un bloque y cambiar los valores.
*/
:- encoding(utf8).

:- discontiguous producto/5, tipo/2, region/2, sello/2, leche/2, maduracion/2,
                 uva/2, grado_alcohol/2, coccion/2, sin_gluten/1, sin_lactosa/1,
                 picante/1, ahumado/1, congelado/1, con_huevo/1, integral/1,
                 trafilada_bronce/1, agotado/1, carne/2, trazas_gluten/1, dato/2.

:- dynamic trazas_gluten/1, agotado/1, sin_gluten/1, sin_lactosa/1, picante/1, ahumado/1,
           congelado/1, con_huevo/1, integral/1, trafilada_bronce/1, carne/2,
           sello/2, leche/2, maduracion/2, uva/2, grado_alcohol/2, coccion/2,
           region/2, dato/2.

/* ===================================================================
   QUESOS
   =================================================================== */

producto(parmigiano_reggiano, "Parmigiano Reggiano D.O.P. 18 meses", "Boni", 20900, "360 g aprox.").
tipo(parmigiano_reggiano, queso_duro).
region(parmigiano_reggiano, emilia_romana).
sello(parmigiano_reggiano, dop).
leche(parmigiano_reggiano, vaca).
maduracion(parmigiano_reggiano, "18 meses").
dato(parmigiano_reggiano, "Queso duro de la familia de los grana, hecho con leche cruda de vaca parcialmente descremada y sin aditivos").

producto(grana_padano, "Grana Padano D.O.P.", "Albiero", 43800, "1 kg").
tipo(grana_padano, queso_duro).
region(grana_padano, lombardia).
sello(grana_padano, dop).
leche(grana_padano, vaca).
maduracion(grana_padano, "12 meses como mínimo (se recomiendan 16)").
dato(grana_padano, "Queso de corteza dura y dorada producido en el valle del Po, en el norte de Italia").

producto(pecorino_romano, "Pecorino Romano D.O.P.", "Pinna", 8365, "200 g").
tipo(pecorino_romano, pecorino).
tipo(pecorino_romano, queso_duro).
region(pecorino_romano, cerdena).
sello(pecorino_romano, dop).
leche(pecorino_romano, oveja).
dato(pecorino_romano, "Queso salado de leche entera de oveja; pese a su nombre hoy se produce sobre todo en Cerdeña. Es el queso de la carbonara").

producto(pecorino_sardo, "Pecorino 100% Sardo Barone", "Maoddi", 10800, "200 g aprox.").
tipo(pecorino_sardo, pecorino).
tipo(pecorino_sardo, queso_semiduro).
region(pecorino_sardo, cerdena).
leche(pecorino_sardo, oveja).
maduracion(pecorino_sardo, "60 días").
dato(pecorino_sardo, "Queso de mesa semicurado de leche pura de oveja, de sabor dulce y sabroso").

producto(gorgonzola_dolce, "Gorgonzola Dolce D.O.P.", "Ghidetti", 11390, "150 g").
tipo(gorgonzola_dolce, gorgonzola).
region(gorgonzola_dolce, lombardia).
sello(gorgonzola_dolce, dop).
leche(gorgonzola_dolce, vaca).
dato(gorgonzola_dolce, "Queso azul cremoso y mantecoso, con vetas de moho verde-gris llamadas erborinatura").

producto(gorgonzola_piccante, "Gorgonzola Piccante D.O.P.", "Ghidetti", 11390, "vaschetta").
tipo(gorgonzola_piccante, gorgonzola).
region(gorgonzola_piccante, lombardia).
sello(gorgonzola_piccante, dop).
leche(gorgonzola_piccante, vaca).
maduracion(gorgonzola_piccante, "80 días").
dato(gorgonzola_piccante, "Versión más curada del gorgonzola: sabor más intenso y pasta más firme").

producto(asiago, "Formaggio Asiago D.O.P.", "Albiero", 9850, "300 g aprox.").
tipo(asiago, queso_semiduro).
region(asiago, veneto).
sello(asiago, dop).
leche(asiago, vaca).
maduracion(asiago, "20 días como mínimo").
dato(asiago, "Queso de leche entera de vaca, delicado y ligeramente dulce. El único Asiago oficial se hace en el Véneto").

producto(taleggio, "Formaggio Taleggio D.O.P.", "Albiero", 10350, "200 g").
tipo(taleggio, queso_blando).
region(taleggio, lombardia).
sello(taleggio, dop).
leche(taleggio, vaca).
agotado(taleggio).
dato(taleggio, "Queso de corteza lavada, pasta suave y flexible y ligero moho gris-verde en la corteza").

producto(provolone_piccante, "Provolone Valpadana D.O.P. Piccante", "Albiero", 7500, "200 g").
tipo(provolone_piccante, queso_semiduro).
region(provolone_piccante, lombardia).
sello(provolone_piccante, dop).
leche(provolone_piccante, vaca).
dato(provolone_piccante, "Queso de pasta hilada de sabor fuerte; el tipo picante se cuaja con cuajo de cabrito y cordero").

producto(mozzarella_bufala, "Mozzarella di Bufala Campana (congelada)", "Corvino", 4550, "125 g").
tipo(mozzarella_bufala, mozzarella).
region(mozzarella_bufala, campania).
sello(mozzarella_bufala, dop).
leche(mozzarella_bufala, bufala).
congelado(mozzarella_bufala).
dato(mozzarella_bufala, "Mozzarella artesanal hecha 100% con leche de búfala de agua").

producto(burrata, "Burrata Murgella (congelada)", "Murgella", 4060, "120 g").
tipo(burrata, queso_fresco).
region(burrata, puglia).
leche(burrata, vaca).
congelado(burrata).
dato(burrata, "Bolsa de pasta hilada rellena de stracciatella: mozzarella deshilachada con crema").

producto(mascarpone, "Mascarpone Fresco UHT", "Virgilio", 11450, "500 ml").
tipo(mascarpone, mascarpone).
region(mascarpone, lombardia).
leche(mascarpone, vaca).
dato(mascarpone, "Queso crema de larga conservación, ingrediente base del tiramisú").

producto(ricotta, "Ricotta Fresca", "Ghidetti", 5300, "295 g").
tipo(ricotta, queso_fresco).
leche(ricotta, vaca).
dato(ricotta, "Ricota fresca de larga vida útil, sin aditivos ni conservantes").

producto(provola_ahumada, "Provola dei Monti Affumicata", "Latteria Sorrentina", 20950, "780 g").
tipo(provola_ahumada, provola).
region(provola_ahumada, campania).
leche(provola_ahumada, vaca).
ahumado(provola_ahumada).
congelado(provola_ahumada).
dato(provola_ahumada, "Queso de pasta hilada de los montes Lattari, ahumado con paja").

/* ===================================================================
   EMBUTIDOS Y FIAMBRES
   =================================================================== */

producto(prosciutto_san_daniele, "Prosciutto Crudo San Daniele D.O.P. 16 meses", "Principe", 450000, "pieza entera de 7,5 kg").
tipo(prosciutto_san_daniele, prosciutto).
region(prosciutto_san_daniele, friuli).
sello(prosciutto_san_daniele, dop).
maduracion(prosciutto_san_daniele, "16 meses").
dato(prosciutto_san_daniele, "Jamón crudo con notas de corteza de pan, frutos secos y malta").

producto(prosciutto_classico, "Prosciutto Crudo Classico Friuli", "Principe", 6000, "100 g laminado").
tipo(prosciutto_classico, prosciutto).
region(prosciutto_classico, friuli).
sin_gluten(prosciutto_classico).
sin_lactosa(prosciutto_classico).
dato(prosciutto_classico, "Jamón crudo curado de pierna de cerdo italiana y sal, con envejecimiento tradicional").

producto(speck, "Prosciutto Affumicato Gispeck", "Negrini", 5850, "100 g laminado").
tipo(speck, prosciutto).
region(speck, trentino_alto_adige).
ahumado(speck).
sin_gluten(speck).
dato(speck, "Jamón deshuesado, curado con sal y especias (enebro, laurel, ajo) y luego ahumado. Originario del Tirol").

producto(guanciale, "Guanciale Stagionato", "Negrini", 10900, "300 g aprox.").
tipo(guanciale, guanciale).
region(guanciale, lazio).
dato(guanciale, "Mejilla de cerdo curada. Es la base de la carbonara y la amatriciana").

producto(pancetta, "Pancetta Delicattesse", "Negrini", 10650, "300 g aprox.").
tipo(pancetta, pancetta).
sin_gluten(pancetta).
sin_lactosa(pancetta).
dato(pancetta, "Panceta: vientre de cerdo curado con sal, pimienta y vino cocido").

producto(nduja, "'Nduja Piccante", "Corte Buona", 12600, "400 g").
tipo(nduja, nduja).
region(nduja, calabria).
picante(nduja).
dato(nduja, "Embutido untable y picante de cerdo con peperoncino calabrés. Se come sobre pan tostado o en pizza").

producto(salame_finocchiona, "Salame Finocchiona", "Negrini", 5300, "100 g laminado").
tipo(salame_finocchiona, salame).
region(salame_finocchiona, toscana).
dato(salame_finocchiona, "Salame toscano condimentado con semillas de hinojo y bañado en vino tinto").

producto(salame_spianata_piccante, "Salame Spianata Piccante", "Negrini", 5550, "100 g laminado").
tipo(salame_spianata_piccante, salame).
region(salame_spianata_piccante, calabria).
picante(salame_spianata_piccante).
sin_gluten(salame_spianata_piccante).
sin_lactosa(salame_spianata_piccante).
dato(salame_spianata_piccante, "Salame calabrés de molienda fina con peperoncino").

producto(salame_peperoni, "Salame Peperoni Piccante", "Negrini", 12350, "300 g pieza entera").
tipo(salame_peperoni, salame).
region(salame_peperoni, toscana).
picante(salame_peperoni).
sin_gluten(salame_peperoni).
sin_lactosa(salame_peperoni).
dato(salame_peperoni, "Salame de lomo y papada de cerdo con ají picante; se usa en la pizza Diavola").

producto(salame_milano, "Salame Milano", "Corte Buona", 5050, "100 g laminado").
tipo(salame_milano, salame).
region(salame_milano, lombardia).
dato(salame_milano, "Salame de receta ambrosiana (milanesa), de grano fino").

producto(salame_cacciatore, "Salame Cacciatore D.O.P.", "Negrini", 10350, "200 g").
tipo(salame_cacciatore, salame).
sello(salame_cacciatore, dop).
sin_gluten(salame_cacciatore).
dato(salame_cacciatore, "Salame pequeño de aroma delicado y sabor dulce").

producto(mortadella_pistacchio, "Mortadella Bologna I.G.P. con Pistacchio", "Corte Buona", 3850, "100 g laminado").
tipo(mortadella_pistacchio, mortadella).
region(mortadella_pistacchio, emilia_romana).
sello(mortadella_pistacchio, igp).
sin_gluten(mortadella_pistacchio).
dato(mortadella_pistacchio, "Embutido cocido de cerdo, rosado y aromático, con pistachos").

producto(bresaola, "Fior di Bresaola della Valtellina", "Corte Buona", 8750, "100 g laminado").
tipo(bresaola, bresaola).
region(bresaola, lombardia).
carne(bresaola, vacuno).
dato(bresaola, "Carne de vacuno curada y secada según receta alpina. Fuente natural de hierro").

producto(cotechino, "Cotechino di Modena I.G.P.", "Negrini", 15000, "500 g").
tipo(cotechino, cotechino).
region(cotechino, emilia_romana).
sello(cotechino, igp).
dato(cotechino, "Embutido de cerdo que se cuece. La tradición manda comerlo en Año Nuevo con lentejas").

/* ===================================================================
   VINOS Y LICORES
   =================================================================== */

producto(chianti_classico, "Chianti Borghetto Classico D.O.C.G.", "Bonacchi", 18900, "750 ml").
tipo(chianti_classico, vino_tinto).
region(chianti_classico, toscana).
sello(chianti_classico, docg).
uva(chianti_classico, sangiovese).
uva(chianti_classico, canaiolo).
grado_alcohol(chianti_classico, 12.5).
dato(chianti_classico, "Tinto toscano fresco y frutal: 90% Sangiovese y 10% Canaiolo").

producto(chianti_riserva, "Chianti Riserva D.O.C.G.", "Bonacchi", 17900, "750 ml").
tipo(chianti_riserva, vino_tinto).
region(chianti_riserva, toscana).
sello(chianti_riserva, docg).
uva(chianti_riserva, sangiovese).
grado_alcohol(chianti_riserva, 13).
dato(chianti_riserva, "Tinto toscano 100% Sangiovese con crianza prolongada").

producto(amarone, "Amarone della Valpolicella D.O.C.G.", "Zonin", 59960, "750 ml").
tipo(amarone, vino_tinto).
region(amarone, veneto).
sello(amarone, docg).
uva(amarone, corvina).
uva(amarone, rondinella).
uva(amarone, molinara).
grado_alcohol(amarone, 15.5).
dato(amarone, "Tinto de gran cuerpo elaborado con uvas deshidratadas (appassimento), envejecido al menos 2 años").

producto(nero_davola, "Amìra Nero d'Avola Sicilia D.O.C.", "Principi di Butera", 15900, "750 ml").
tipo(nero_davola, vino_tinto).
region(nero_davola, sicilia).
sello(nero_davola, doc).
uva(nero_davola, nero_davola).
grado_alcohol(nero_davola, 13.5).
dato(nero_davola, "Tinto con la uva más emblemática de Sicilia; su nombre viene del árabe amîr (príncipe)").

producto(primitivo, "Altemura Primitivo di Manduria D.O.C.", "Masseria Altemura", 34950, "750 ml").
tipo(primitivo, vino_tinto).
region(primitivo, puglia).
sello(primitivo, doc).
uva(primitivo, primitivo).
grado_alcohol(primitivo, 14.5).
dato(primitivo, "Tinto insignia de la bodega, 100% Primitivo de la península de Salento").

producto(negroamaro, "Negroamaro Salento I.G.T.", "Masseria Altemura", 15500, "750 ml").
tipo(negroamaro, vino_tinto).
region(negroamaro, puglia).
sello(negroamaro, igt).
uva(negroamaro, negroamaro).
grado_alcohol(negroamaro, 13.5).
dato(negroamaro, "Tinto redondo y mediterráneo, 100% Negroamaro").

producto(pinot_grigio, "Pinot Grigio Friuli Aquileia D.O.C.", "Ca' Vescovo", 14900, "750 ml").
tipo(pinot_grigio, vino_blanco).
region(pinot_grigio, friuli).
sello(pinot_grigio, doc).
uva(pinot_grigio, pinot_grigio).
grado_alcohol(pinot_grigio, 12.5).
dato(pinot_grigio, "Blanco seco con notas de acacia, pera y manzana verde. Muy bueno como aperitivo").

producto(prosecco, "Prosecco Extra Dry D.O.C.", "Cavicchioli", 18800, "750 ml").
tipo(prosecco, vino_espumante).
region(prosecco, veneto).
sello(prosecco, doc).
uva(prosecco, glera).
dato(prosecco, "Espumante 100% Glera de la provincia de Treviso").

producto(lambrusco_grasparossa, "Lambrusco Grasparossa di Castelvetro D.O.C. Secco", "Cavicchioli", 10050, "750 ml").
tipo(lambrusco_grasparossa, lambrusco).
region(lambrusco_grasparossa, emilia_romana).
sello(lambrusco_grasparossa, doc).
uva(lambrusco_grasparossa, lambrusco_grasparossa).
grado_alcohol(lambrusco_grasparossa, 11).
dato(lambrusco_grasparossa, "Tinto espumoso y seco de Módena; se sirve frío, entre 8 y 10 °C").

producto(vin_santo, "Vin Santo del Chianti D.O.C.", "Bonacchi", 40190, "500 ml").
tipo(vin_santo, vino_dulce).
region(vin_santo, toscana).
sello(vin_santo, doc).
uva(vin_santo, trebbiano).
uva(vin_santo, malvasia).
grado_alcohol(vin_santo, 15.5).
dato(vin_santo, "Vino dulce ámbar de uvas secadas lentamente, con notas de damasco, pasas y miel").

producto(limoncello, "Limoncello di Sorrento", "Strega", 29050, "700 ml").
tipo(limoncello, digestivo).
region(limoncello, campania).
grado_alcohol(limoncello, 30).
dato(limoncello, "Licor de limones de Sorrento y Amalfi I.G.P.").

producto(grappa, "Grappa Bianca Morbida", "Caffo", 36900, "700 ml").
tipo(grappa, digestivo).
grado_alcohol(grappa, 40).
dato(grappa, "Aguardiente suave de orujo de uvas blancas como Pinot, Prosecco, Chardonnay y Moscato").

producto(amaro_del_capo, "Vecchio Amaro del Capo", "Caffo", 31300, "750 ml").
tipo(amaro_del_capo, digestivo).
region(amaro_del_capo, calabria).
grado_alcohol(amaro_del_capo, 35).
dato(amaro_del_capo, "Licor de hierbas de Calabria de receta antigua; se bebe helado como bajativo").

/* ===================================================================
   PASTAS
   =================================================================== */

producto(spaghetti_gragnano, "Spaghetti I.G.P. (Pasta di Gragnano)", "Di Martino", 4050, "500 g").
tipo(spaghetti_gragnano, spaghetti).
region(spaghetti_gragnano, campania).
sello(spaghetti_gragnano, igp).
coccion(spaghetti_gragnano, 8).

producto(paccheri_gragnano, "Paccheri I.G.P. (Pasta di Gragnano)", "Di Martino", 8100, "500 g").
tipo(paccheri_gragnano, paccheri).
region(paccheri_gragnano, campania).
sello(paccheri_gragnano, igp).
coccion(paccheri_gragnano, 13).

producto(bucatini_gragnano, "Bucatini I.G.P. (Pasta di Gragnano)", "Di Martino", 4300, "500 g").
tipo(bucatini_gragnano, bucatini).
region(bucatini_gragnano, campania).
sello(bucatini_gragnano, igp).
coccion(bucatini_gragnano, 10).

producto(linguine_granoro, "Linguine Dedicato Nº182", "Granoro", 2850, "500 g").
tipo(linguine_granoro, linguine).
region(linguine_granoro, puglia).
trafilada_bronce(linguine_granoro).
coccion(linguine_granoro, 12).

producto(orecchiette, "Orecchiette Baresi Dedicato Nº90", "Granoro", 3200, "500 g").
tipo(orecchiette, orecchiette).
region(orecchiette, puglia).
trafilada_bronce(orecchiette).
coccion(orecchiette, 11).

producto(rigatoni, "Rigatoni Nº17", "Granoro", 2250, "500 g").
tipo(rigatoni, rigatoni).
region(rigatoni, puglia).
coccion(rigatoni, 10).

producto(fusilli, "Fusilli Dedicato Nº260", "Granoro", 2850, "500 g").
tipo(fusilli, fusilli).
region(fusilli, puglia).
trafilada_bronce(fusilli).
coccion(fusilli, 8).

producto(tagliatelle_huevo, "Tagliatelle all'uovo Nº116", "Granoro", 4050, "500 g").
tipo(tagliatelle_huevo, tagliatelle).
region(tagliatelle_huevo, puglia).
con_huevo(tagliatelle_huevo).
coccion(tagliatelle_huevo, 5).

producto(spaghetti_sin_gluten, "Spaghetti Sin Gluten", "Granoro", 4650, "400 g").
tipo(spaghetti_sin_gluten, spaghetti).
region(spaghetti_sin_gluten, puglia).
sin_gluten(spaghetti_sin_gluten).
coccion(spaghetti_sin_gluten, 10).

producto(fusilli_sin_gluten, "Fusilli Sin Gluten", "Granoro", 4700, "400 g").
tipo(fusilli_sin_gluten, fusilli).
region(fusilli_sin_gluten, puglia).
sin_gluten(fusilli_sin_gluten).
coccion(fusilli_sin_gluten, 9).

producto(spaghetti_integral, "Spaghetti BIO Integrale Nº12", "Granoro", 2750, "500 g").
tipo(spaghetti_integral, spaghetti).
region(spaghetti_integral, puglia).
integral(spaghetti_integral).
coccion(spaghetti_integral, 8).

producto(pasta_mista, "Pasta Mista Dedicato Nº48", "Granoro", 2200, "500 g").
tipo(pasta_mista, pasta_mista).
region(pasta_mista, puglia).
coccion(pasta_mista, 8).
agotado(pasta_mista).

/* ===================================================================
   TOMATES, SALSAS Y CONDIMENTOS
   =================================================================== */

producto(pelati_san_marzano, "Pomodori Pelati San Marzano D.O.P.", "Solania", 4200, "400 g").
tipo(pelati_san_marzano, tomate_pelado).
region(pelati_san_marzano, campania).
sello(pelati_san_marzano, dop).
dato(pelati_san_marzano, "Tomates enteros pelados San Marzano; proveedor oficial de la Asociación Verdadera Pizza Napoletana").

producto(passata_gargano, "Passata di Puglia", "Rosso Gargano", 3750, "690 g").
tipo(passata_gargano, passata).
region(passata_gargano, puglia).

producto(concentrado_mutti, "Doppio Concentrato di Pomodoro", "Mutti", 3950, "200 g").
tipo(concentrado_mutti, concentrado_tomate).
region(concentrado_mutti, emilia_romana).

producto(datterini_mutti, "Pomodorini Datterini", "Mutti", 3500, "400 g").
tipo(datterini_mutti, tomate_cherry).
region(datterini_mutti, emilia_romana).

producto(pesto_genovese, "Pesto alla Genovese", "Gourmitalia", 7050, "190 g").
tipo(pesto_genovese, pesto).
region(pesto_genovese, liguria).
dato(pesto_genovese, "Pesto de albahaca listo para usar").

producto(tartufata, "Tartufata di Bosco (salsa de trufa)", "Bosco D'oro", 22400, "90 g").
tipo(tartufata, salsa_trufa).

producto(aceite_oliva, "Olio di Oliva Extra Vergine", "Basso", 10550, "500 ml").
tipo(aceite_oliva, aceite_oliva).
region(aceite_oliva, campania).
dato(aceite_oliva, "Aceite de oliva extra virgen extraído en frío, de acidez 0,6%").

producto(balsamico, "Aceto Balsamico di Modena I.G.P. Invecchiato 3 Anni", "Monari Federzoni", 15950, "250 ml").
tipo(balsamico, aceto_balsamico).
region(balsamico, emilia_romana).
sello(balsamico, igp).

producto(peperoncino, "Peperoncino con molinillo", "Cannamela", 4500, "15 g").
tipo(peperoncino, peperoncino).
picante(peperoncino).

/* ===================================================================
   ARROZ, HONGOS, CONSERVAS Y OTROS
   =================================================================== */

producto(arroz_arborio, "Riso Arborio", "Curtiriso", 8400, "1 kg").
tipo(arroz_arborio, arroz_arborio).
coccion(arroz_arborio, 15).

producto(arroz_carnaroli, "Riso Carnaroli", "Curtiriso", 8600, "1 kg").
tipo(arroz_carnaroli, arroz_carnaroli).
coccion(arroz_carnaroli, 15).

producto(funghi_porcini, "Funghi Porcini Secchi", "Di Biase", 6300, "20 g").
tipo(funghi_porcini, funghi_porcini).

producto(alcaparras, "Capperi Medi in Aceto di Vino", "Neri", 5650, "200 g").
tipo(alcaparras, alcaparras).
region(alcaparras, puglia).

producto(aceitunas_negras, "Olive Nere Denocciolate", "Neri", 5100, "314 g").
tipo(aceitunas_negras, aceitunas).

producto(anchoas, "Filetti di Acciughe", "Zarotti", 8400, "140 g").
tipo(anchoas, anchoas).

producto(pinoli, "Pinoli Italiani", "Gourmitalia", 11900, "50 g").
tipo(pinoli, pinoli).

producto(harina_pizza, "Farina Tipo 00 per Pizza Napoletana", "Le 5 Stagioni", 3450, "1 kg").
tipo(harina_pizza, harina).

producto(cafe_borbone, "Caffè en Grano Borbone Classica", "Caffè Borbone", 34200, "1 kg").
tipo(cafe_borbone, cafe).
region(cafe_borbone, campania).
dato(cafe_borbone, "Mezcla 50% arábica y 50% robusta, tostado medio").

/* ===================================================================
   DULCES Y POSTRES
   =================================================================== */

producto(savoiardi, "Savoiardi", "Marini", 3400, "200 g").
tipo(savoiardi, savoiardi).
dato(savoiardi, "Galletas de champaña de textura friable, ideales para el tiramisú").

producto(tiramisu_listo, "Tiramisù Classico Individuale (pack 4)", "Cremducale", 21200, "4 porciones de 110 g").
tipo(tiramisu_listo, postre).

producto(cannoli, "Cannoli Siciliani Classici (pack 6)", "Dolciaria Acquaviva", 32700, "6 unidades de 120 g").
tipo(cannoli, postre).
region(cannoli, sicilia).
agotado(cannoli).

producto(crema_pistacchio, "Crema di Pistacchio di Bronte", "Brontedolci", 9485, "190 g").
tipo(crema_pistacchio, crema_untable).
trazas_gluten(crema_pistacchio).
region(crema_pistacchio, sicilia).
dato(crema_pistacchio, "Crema con 40,5% de pistacho de Bronte").
