USE TBDGrupo2;

-- CONSULTA 9: Productos sin vender por región versus cantidad de ventas por region el 2026

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

SELECT 
    YEAR(v.fechaVenta) AS Anio, 
    SUM(p.precio) AS Total_Ventas
FROM venta v
JOIN detalle_venta dv ON v.idVenta = dv.idVenta
JOIN producto p ON dv.idProducto = p.idProducto
GROUP BY YEAR(v.fechaVenta)
ORDER BY Anio ASC;
