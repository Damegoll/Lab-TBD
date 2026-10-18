USE TBDGrupo2;

-- Tipo de arte más vendido por año.
 
 -- creacion de una tabla virtual temporal para guardar los datos
 WITH arteVendido AS (
	SELECT p.tipoProducto as TipoArte,
    YEAR(v.fechaVenta) as Anio,
	COUNT(*) AS TotalVentas,
    /* 
    la funcio row_number le asigna un numero de posicion a cada fila
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


-- Lista de regiones y sus galerías por comuna.

	SELECT r.nombreRegion AS Region,
    c.nombreComuna AS Comuna,
    g.nombreLocal AS Galeria
FROM Region r
INNER JOIN comuna c ON r.idRegion = c.idRegion
INNER JOIN galeria g ON c.idComuna = g.idComuna
ORDER BY Region, Comuna, Galeria