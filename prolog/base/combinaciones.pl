/*  combinaciones.pl
    Productos que tradicionalmente se comen juntos.

      combina(Producto1, Producto2).

    Cada par se escribe UNA sola vez. La regla se_combinan/2 de reglas.pl
    se encarga de que la relación funcione en ambos sentidos.
*/
:- encoding(utf8).

combina(parmigiano_reggiano, balsamico).        % clásico de Emilia-Romaña
combina(mozzarella_bufala, pelati_san_marzano).  % base de la pizza margherita
combina(burrata, datterini_mutti).               % burrata con tomates cherry
combina(pecorino_romano, guanciale).             % base de carbonara y amatriciana
combina(savoiardi, cafe_borbone).                % base del tiramisú
combina(gorgonzola_dolce, vin_santo).            % contraste dulce-salado
combina(prosciutto_classico, burrata).           % antipasto típico
