USE TBDGrupo2;

# Consulta 7: Venta más cara por mes, por galería en el 2019.

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
JOIN detalleVenta dv ON v.idVenta = dv.idVenta
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


SELECT 
    c.idCliente,
    c.nombreCliente,
    c.apellidoCliente,
    COUNT(dv.idProducto) AS totalPinturasCompradas
# Unir tablas para obtener info de clientes con sus compras
FROM cliente c
JOIN venta v ON c.idCliente = v.idCliente
JOIN detalleVenta dv ON v.idVenta = dv.idVenta
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