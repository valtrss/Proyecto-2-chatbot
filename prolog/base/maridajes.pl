/*  maridajes.pl
    Conocimiento de maridaje (qué vino acompaña a qué).

      marida_perfil(PerfilPlato, ClaseVino, Razon).
          Para recetas: el perfil del plato (ver perfil/2 en recetas.pl)
          sugiere una clase de vino. La clase puede ser un tipo de la
          taxonomía (vino_blanco) o una uva (sangiovese).

      marida_tipo(TipoProducto, ClaseVino, Razon).
          Para productos sueltos, como quesos y embutidos.
*/
:- encoding(utf8).

marida_perfil(graso,         vino_espumante, "la burbuja y la acidez limpian la grasa del plato").
marida_perfil(cerdo,         lambrusco,      "el lambrusco es el compañero clásico del cerdo y los embutidos").
marida_perfil(tomate,        sangiovese,     "la acidez del Sangiovese equilibra la del tomate").
marida_perfil(hongos,        vino_tinto,     "los tintos con cuerpo acompañan el sabor terroso de los hongos").
marida_perfil(contundente,   vino_tinto,     "un plato contundente pide un tinto con estructura").
marida_perfil(hierbas,       vino_blanco,    "un blanco fresco no tapa los aromas de la albahaca").
marida_perfil(fresco,        vino_espumante, "un espumante acompaña bien los platos fríos y veraniegos").
marida_perfil(pescado,       vino_blanco,    "el blanco seco realza el pescado y los sabores salinos").
marida_perfil(queso_intenso, vino_tinto,     "un tinto con taninos resiste el sabor intenso del queso").
marida_perfil(postre,        vino_dulce,     "el vino debe ser al menos tan dulce como el postre").

marida_tipo(queso_azul,     vino_dulce,     "el contraste dulce-salado es un clásico con los quesos azules").
marida_tipo(queso_duro,     vino_tinto,     "los quesos curados acompañan bien a los tintos con cuerpo").
marida_tipo(queso_semiduro, vino_tinto,     "un tinto de cuerpo medio acompaña los quesos semicurados").
marida_tipo(queso_fresco,   vino_blanco,    "los quesos frescos piden vinos blancos ligeros").
marida_tipo(queso_blando,   vino_blanco,    "un blanco con buena acidez equilibra la cremosidad").
marida_tipo(embutido,       lambrusco,      "el lambrusco limpia la grasa de los embutidos").
marida_tipo(postre,         vino_dulce,     "el vino debe ser al menos tan dulce como el postre").
