USE TBDGrupo2;

#CONSULTA 1 (ESCULTURA MÁS CARA VENDIDA POR GALERÍA EL ÚLTIMO MES)
SELECT 
    g.nombreLocal AS Galeria, 
    MAX(p.precio) AS Precio_Maximo_Escultura
FROM galeria g
JOIN producto p ON g.idLocal = p.idLocal
JOIN detalle_venta dv ON p.idProducto = dv.idProducto
JOIN venta v ON dv.idVenta = v.idVenta
WHERE p.tipoProducto = 'Escultura' 
  AND v.fechaVenta >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY g.idLocal, g.nombreLocal;

#CONSULTA 2 (PINTURA MÁS ECONÓMICA VENDIDA EL AÑO PASADO)

SELECT 
    p.idProducto, 
    p.tipoProducto,
    p.precio AS Precio_Mas_Economico, 
    v.fechaVenta,
    g.nombreLocal AS Vendida_En
FROM producto p
JOIN detalle_venta dv ON p.idProducto = dv.idProducto
JOIN venta v ON dv.idVenta = v.idVenta
JOIN galeria g ON p.idLocal = g.idLocal
WHERE p.tipoProducto = 'Pintura' 
  AND YEAR(v.fechaVenta) = YEAR(CURDATE()) - 1
ORDER BY p.precio ASC
LIMIT 1;

-- CONSULTA 3 (Vendedor con más ventas por galería)
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


-- CONSULTA 4 (Cliente que ha invertido más en arte por año)

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


-- CONSULTA 5 (Tipo de arte más vendido por año)
 
 -- creacion de una tabla virtual temporal para guardar los datos
 WITH arteVendido AS (
	SELECT p.tipoProducto as TipoArte,
    YEAR(v.fechaVenta) as Anio,
	COUNT(*) AS TotalVentas,
    /* 
    la funcion row_number le asigna un numero de posicion a cada fila
    partition by year divide los datos por año 
    order by count ordena los productos de cierto año de mayor a menor segun la cantidad
    de ventas
    */
    ROW_NUMBER() OVER (
            PARTITION BY YEAR(v.fechaVenta) 
            ORDER BY COUNT(*) DESC
        ) AS Ranking
	FROM detalle_venta dv
    INNER JOIN venta v ON dv.idVenta = v.idVenta
    INNER JOIN producto p ON dv.idProducto = p.idProducto
    GROUP BY YEAR(v.fechaVenta), p.tipoProducto
)
SELECT Anio, TipoArte, TotalVentas
FROM arteVendido
WHERE Ranking = 1
ORDER BY Anio DESC;


-- CONSULTA 6 (Lista de regiones y sus galerías por comuna)

	SELECT r.nombreRegion AS Region,
    c.nombreComuna AS Comuna,
    g.nombreLocal AS Galeria
FROM region r
INNER JOIN comuna c ON r.idRegion = c.idRegion
INNER JOIN galeria g ON c.idComuna = g.idComuna
ORDER BY Region, Comuna, Galeria