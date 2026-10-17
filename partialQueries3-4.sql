USE TBDGrupo2;

-- Vendedor con más ventas por galería

SELECT nombreLocal AS galeria, vendedor, total_ventas
FROM (
    SELECT g.nombreLocal,
    	   -- no creo que deba explicar que hace CONCAT, pero porsiaca, es concatenar
           CONCAT(e.nombreEmpleado, ' ', e.apellidoEmpleado) AS vendedor,
           COUNT(*) AS total_ventas,
           -- Aqui explico que es eso del RANK() OVER(PARTITION BY ....)
           -- RANK() OVER ( asigna un puesto a cada fila segun un criterio de orden
           -- dentro del OVER van dos partes:
           -- PARTITION BY g.idLocal, el cual reinicia el ranking en cada galeria (ya que cada galería es un grupo)
           -- y ORDER BY COUNT(*) DESC, el cual define el criterio, o sea mas ventas = mejor puesto
           -- el PARTITION BY es completamente opcional, pero en este caso es necesario para separar los grupos de galerias
           -- con eso, la consulta rankea a los vendedores de cada galeria segun su cantidad de ventas
           -- y guarda el puesto en la columna "posicion"
           -- si dos vendedores empatan, ambos reciben el puesto 1 
           -- (RANK no discrimina empates, pero la siguiente posicion va a ser "ignorada", por lo cual puede pasar que quede top 1, 1, 3)
           -- finalmente, WHERE posicion = 1 filtra y deja solo al mejor vendedor de cada galería
           -- que nos ahorra esto? un having completo teniendo que ordenarlo de esa forma
           RANK() OVER (PARTITION BY g.idLocal ORDER BY COUNT(*) DESC) AS posicion
    FROM venta v
    JOIN empleado e ON e.idEmpleado = v.idEmpleado
    JOIN galeria g  ON g.idLocal = e.idLocal
    GROUP BY g.idLocal, g.nombreLocal, e.idEmpleado, e.nombreEmpleado, e.apellidoEmpleado
) t
WHERE posicion = 1
ORDER BY galeria;


-- Cliente que ha invertido más en arte por año

SELECT anio, cliente, total_invertido
FROM (
    SELECT YEAR(v.fechaVenta) AS anio,
           CONCAT(c.nombreCliente, ' ', c.apellidoCliente) AS cliente,
           SUM(p.precio) AS total_invertido,
           RANK() OVER (PARTITION BY YEAR(v.fechaVenta) ORDER BY SUM(p.precio) DESC) AS posicion
    FROM venta v
    JOIN cliente c        ON c.idCliente = v.idCliente
    JOIN detalle_venta d  ON d.idVenta = v.idVenta
    JOIN producto p       ON p.idProducto = d.idProducto
    GROUP BY YEAR(v.fechaVenta), c.idCliente, c.nombreCliente, c.apellidoCliente
) t
WHERE posicion = 1
ORDER BY anio;