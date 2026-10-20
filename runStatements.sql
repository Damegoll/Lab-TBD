USE TBDGrupo2;

#CONSULTA 1 (ESCULTURA MÁS CARA VENDIDA POR GALERÍA EL ÚLTIMO MES)
SELECT "ESCULTURA MÁS CARA VENDIDA POR GALERÍA EL ÚLTIMO MES" AS "--------CONSULTA 1-------";
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

SELECT "PINTURA MÁS ECONÓMICA VENDIDA EL AÑO PASADO" AS "--------CONSULTA 2-------";
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

SELECT "Vendedor con más ventas por galería" AS "--------CONSULTA 3-------";
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

SELECT "Cliente que ha invertido más en arte por año" AS "--------CONSULTA 4-------";
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
 
 SELECT "Tipo de arte más vendido por año" AS "--------CONSULTA 5-------";
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

SELECT "Lista de regiones y sus galerías por comuna" AS "--------CONSULTA 6-------";
	SELECT r.nombreRegion AS Region,
    c.nombreComuna AS Comuna,
    g.nombreLocal AS Galeria
FROM region r
INNER JOIN comuna c ON r.idRegion = c.idRegion
INNER JOIN galeria g ON c.idComuna = g.idComuna
ORDER BY Region, Comuna, Galeria;


# Consulta 7: Venta más cara por mes, por galería en el 2019.
SELECT "Venta más cara por mes, por galería en el 2019" AS "--------CONSULTA 7-------";
# Crear una tabla temporal con la información relevante de una venta, y particularmente el total comprado en dinero,
# para despues poder obtener la venta mas cara de cada mes.
WITH VentaTotal AS (
SELECT 
    v.idVenta,
    MONTH(v.fechaVenta) AS mes,
    g.idLocal,
    g.nombreLocal,
    # Suma del costo de los items comprados en la venta
    SUM(p.precio) AS totalVenta
# Unir varios datos relevantes de la venta (unir columnas de varias tablas)
FROM venta v
JOIN empleado e ON v.idEmpleado = e.idEmpleado
JOIN galeria g ON e.idLocal = g.idLocal
JOIN detalle_venta dv ON v.idVenta = dv.idVenta
JOIN producto p ON dv.idProducto = p.idProducto
# Que la tabla solo tenga las ventas del año 2019
WHERE YEAR(v.fechaVenta) = 2019
# Juntar compras que se hayan hecho en la misma venta (o sea, filas que tengan el mismo idVenta)
GROUP BY v.idVenta, MONTH(v.fechaVenta), g.idLocal, g.nombreLocal
),

# Seleccionar la venta mas cara de cada mes, por cada galeria (Queda solo el valor, despues se junta para devolver el resto de la info)
MaxVenta AS (
SELECT 
    mes,
    idLocal,
    MAX(totalVenta) AS maxMonto
FROM VentaTotal
GROUP BY mes, idLocal
)

# Volver a unir la tabla de mayores ventas, con el resto de los datos relevantes
SELECT 
    vt.mes,
    vt.nombreLocal,
    vt.idVenta,
    vt.totalVenta AS ventaMasCara
FROM VentaTotal vt
JOIN MaxVenta m 
  ON vt.mes = m.mes 
  AND vt.idLocal = m.idLocal 
  AND vt.totalVenta = m.maxMonto
ORDER BY vt.mes, vt.nombreLocal;


# Consulta 8: Cliente que ha comprado más pinturas entre 2019 y 2021.
SELECT "Cliente que ha comprado más pinturas entre 2019 y 2021" AS "--------CONSULTA 8-------";

SELECT 
    c.idCliente,
    c.nombreCliente,
    c.apellidoCliente,
    COUNT(dv.idProducto) AS totalPinturasCompradas
# Unir tablas para obtener info de clientes con sus compras
FROM cliente c
JOIN venta v ON c.idCliente = v.idCliente
JOIN detalle_venta dv ON v.idVenta = dv.idVenta
JOIN producto p ON dv.idProducto = p.idProducto
# Filtrar que sean solo pinturas, y entre los años 2019 y 2021
WHERE LOWER(p.tipoProducto) = 'pintura'
  AND YEAR(v.fechaVenta) BETWEEN 2019 AND 2021
# Agrupar compras por cada cliente (juntar filas que sean el mismo cliente)
GROUP BY c.idCliente, c.nombreCliente, c.apellidoCliente
# Ordenar por numero de pinturas compradas
ORDER BY totalPinturasCompradas DESC
# Dejar solo al primero (el que compro mas pinturas)
LIMIT 1;


-- CONSULTA 9: Productos sin vender por región versus cantidad de ventas por region el 2026
SELECT "Productos sin vender por región versus cantidad de ventas por region el 2026" AS "--------CONSULTA 9-------";
SELECT 
    r.nombreRegion, 
    -- Contar los productos sin vender (catalogo acumulado)
    COUNT(DISTINCT CASE WHEN dv.idVenta IS NULL THEN p.idProducto END) AS productos_sin_vender_historico,
	-- Contar las ventas realizadas el 2026
    COUNT(DISTINCT CASE WHEN YEAR(v.fechaVenta) = 2026 THEN p.idProducto END) AS productos_vendidos_2026
FROM region r
JOIN comuna c ON r.idRegion = c.idRegion
JOIN galeria g ON c.idComuna = g.idComuna
JOIN producto p ON g.idLocal = p.idLocal
LEFT JOIN detalle_venta dv ON p.idProducto = dv.idProducto
LEFT JOIN venta v ON dv.idVenta = v.idVenta
GROUP BY r.idRegion, r.nombreRegion
ORDER BY productos_sin_vender_historico DESC;


-- CONSULTA 10: Suma total de dinero en ventas por año
SELECT "Suma total de dinero en ventas por año" AS "--------CONSULTA 10-------";
SELECT 
    YEAR(v.fechaVenta) AS Anio, 
    SUM(p.precio) AS Total_Ventas
FROM venta v
JOIN detalle_venta dv ON v.idVenta = dv.idVenta
JOIN producto p ON dv.idProducto = p.idProducto
GROUP BY YEAR(v.fechaVenta)
ORDER BY Anio ASC;