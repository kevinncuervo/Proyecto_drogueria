
-- =============================================
-- TALLER III - SISTEMA DE DROGUERIA
-- HITO 7: VERIFICACION DE VENTAS
-- RESPONSABLE: STIVEN HERNANDEZ
-- POSTGRESQL 18
-- =============================================

-- CONSULTA 1: CANTIDAD DE REGISTROS

SELECT 'proveedor' AS tabla, COUNT(*) AS cantidad
FROM proveedor
UNION ALL
SELECT 'cliente', COUNT(*) FROM cliente
UNION ALL
SELECT 'producto', COUNT(*) FROM producto
UNION ALL
SELECT 'entrega', COUNT(*) FROM entrega
UNION ALL
SELECT 'lote', COUNT(*) FROM lote
UNION ALL
SELECT 'venta', COUNT(*) FROM venta
UNION ALL
SELECT 'detalle_venta', COUNT(*) FROM detalle_venta
UNION ALL
SELECT 'detalle_lote_venta', COUNT(*) FROM detalle_lote_venta
UNION ALL
SELECT 'factura', COUNT(*) FROM factura
ORDER BY tabla;


-- CONSULTA 2: RESUMEN DE VENTAS

SELECT
    c.nombre AS cliente,
    TO_CHAR(v.fecha, 'DD/MM/YYYY') AS fecha_venta,
    COUNT(dv.id_detalle) AS cantidad_detalles,
    SUM(dv.cantidad_comprada) AS unidades_vendidas,
    SUM(
        dv.cantidad_comprada * dv.precio_unitario
    ) AS total_venta
FROM venta v
INNER JOIN cliente c
    ON c.id_cliente = v.id_cliente
INNER JOIN detalle_venta dv
    ON dv.id_venta = v.id_venta
GROUP BY v.id_venta, c.nombre, v.fecha
ORDER BY c.nombre;


-- CONSULTA 3: DISTRIBUCION AUTOMATICA FEFO

SELECT
    c.nombre AS cliente,
    p.nombre AS producto,
    l.codigo_lote,
    TO_CHAR(l.fecha_vencimiento, 'DD/MM/YYYY')
        AS fecha_vencimiento,
    dlv.cantidad_descontada,
    l.cantidad_stock AS stock_restante
FROM detalle_lote_venta dlv
INNER JOIN detalle_venta dv
    ON dv.id_detalle = dlv.id_detalle
INNER JOIN venta v
    ON v.id_venta = dv.id_venta
INNER JOIN cliente c
    ON c.id_cliente = v.id_cliente
INNER JOIN producto p
    ON p.id_producto = dv.id_producto
INNER JOIN lote l
    ON l.id_lote = dlv.id_lote
ORDER BY
    c.nombre,
    p.nombre,
    l.fecha_vencimiento,
    l.id_lote;


-- CONSULTA 4: FACTURAS GENERADAS

SELECT
    c.nombre AS cliente,
    f.tipo_factura,
    f.prefijo,
    f.numero_factura,
    TO_CHAR(v.fecha, 'DD/MM/YYYY') AS fecha_venta,
    SUM(
        dv.cantidad_comprada * dv.precio_unitario
    ) AS total_facturado
FROM factura f
INNER JOIN venta v
    ON v.id_venta = f.id_venta
INNER JOIN cliente c
    ON c.id_cliente = v.id_cliente
INNER JOIN detalle_venta dv
    ON dv.id_venta = v.id_venta
GROUP BY
    f.id_factura,
    c.nombre,
    f.tipo_factura,
    f.prefijo,
    f.numero_factura,
    v.fecha
ORDER BY c.nombre;


-- CONSULTA 5: CONCILIACION DE INVENTARIO

SELECT
    l.codigo_lote,
    p.nombre AS producto,
    l.cantidad_recibida,
    COALESCE(
        SUM(dlv.cantidad_descontada), 0
    ) AS unidades_vendidas,
    l.cantidad_stock AS stock_actual,
    (
        l.cantidad_recibida
        - COALESCE(
            SUM(dlv.cantidad_descontada), 0
        )
    ) AS stock_calculado,
    (
        l.cantidad_stock =
        l.cantidad_recibida
        - COALESCE(
            SUM(dlv.cantidad_descontada), 0
        )
    ) AS coincide
FROM lote l
INNER JOIN producto p
    ON p.id_producto = l.id_producto
LEFT JOIN detalle_lote_venta dlv
    ON dlv.id_lote = l.id_lote
GROUP BY
    l.id_lote,
    l.codigo_lote,
    p.nombre,
    l.cantidad_recibida,
    l.cantidad_stock
ORDER BY l.codigo_lote;


-- CONSULTA 6: RESUMEN DE VALIDACION FINAL

WITH conciliacion AS (
    SELECT
        l.id_lote,
        l.cantidad_recibida,
        l.cantidad_stock,
        COALESCE(
            SUM(dlv.cantidad_descontada), 0
        ) AS unidades_descontadas
    FROM lote l
    LEFT JOIN detalle_lote_venta dlv
        ON dlv.id_lote = l.id_lote
    GROUP BY
        l.id_lote,
        l.cantidad_recibida,
        l.cantidad_stock
),
distribuciones AS (
    SELECT
        dv.id_detalle,
        dv.cantidad_comprada,
        COALESCE(
            SUM(dlv.cantidad_descontada), 0
        ) AS cantidad_distribuida
    FROM detalle_venta dv
    LEFT JOIN detalle_lote_venta dlv
        ON dlv.id_detalle = dv.id_detalle
    GROUP BY
        dv.id_detalle,
        dv.cantidad_comprada
)
SELECT
    (SELECT COUNT(*) FROM conciliacion)
        AS lotes_verificados,
    (SELECT COUNT(*)
     FROM conciliacion
     WHERE cantidad_recibida
           - unidades_descontadas <> cantidad_stock)
        AS lotes_inconsistentes,
    (SELECT COUNT(*)
     FROM distribuciones
     WHERE cantidad_comprada <> cantidad_distribuida)
        AS detalles_incompletos,
    (SELECT COUNT(*)
     FROM venta v
     LEFT JOIN factura f
         ON f.id_venta = v.id_venta
     WHERE f.id_factura IS NULL)
        AS ventas_sin_factura,
    (SELECT SUM(cantidad_comprada * precio_unitario)
     FROM detalle_venta)
        AS total_vendido,
    (SELECT SUM(total_facturado)
     FROM (
         SELECT
             f.id_factura,
             SUM(
                 dv.cantidad_comprada
                 * dv.precio_unitario
             ) AS total_facturado
         FROM factura f
         INNER JOIN detalle_venta dv
             ON dv.id_venta = f.id_venta
         GROUP BY f.id_factura
     ) AS resumen_facturas)
        AS total_facturado;
