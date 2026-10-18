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