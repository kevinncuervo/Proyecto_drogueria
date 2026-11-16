
-- =============================================
-- Taller III - Sistema de gestion de drogueria
-- Hito 5: Verificacion de datos sinteticos
-- Responsable: Stiven Hernandez
-- PostgreSQL 18
-- Fecha de referencia: 15/11/2026
-- =============================================

-- CONSULTA 1: CANTIDAD DE REGISTROS POR TABLA

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
SELECT 'detalle_lote_venta', COUNT(*)
FROM detalle_lote_venta
UNION ALL
SELECT 'factura', COUNT(*) FROM factura
ORDER BY tabla;


-- CONSULTA 2: COHERENCIA DE LOS LOTES

SELECT
    COUNT(*) AS total_lotes,
    COUNT(*) FILTER (
        WHERE p.id_proveedor <> e.id_proveedor
    ) AS proveedores_incorrectos,
    COUNT(*) FILTER (
        WHERE l.fecha_vencimiento < e.fecha_entrega
    ) AS fechas_incorrectas,
    COUNT(*) FILTER (
        WHERE l.cantidad_stock <> l.cantidad_recibida
    ) AS existencias_iniciales_incorrectas
FROM lote l
INNER JOIN producto p
    ON p.id_producto = l.id_producto
INNER JOIN entrega e
    ON e.id_entrega = l.id_entrega;


-- CONSULTA 3: CLASIFICACION DE LOTES POR VENCIMIENTO

SELECT
    CASE
        WHEN fecha_vencimiento < DATE '2026-11-15'
            THEN 'Vencido'
        WHEN fecha_vencimiento = DATE '2026-11-15'
            THEN 'Vence en fecha de referencia'
        ELSE 'Vigente posterior'
    END AS estado_lote,
    COUNT(*) AS cantidad_lotes,
    SUM(cantidad_stock) AS unidades_fisicas
FROM lote
GROUP BY
    CASE
        WHEN fecha_vencimiento < DATE '2026-11-15'
            THEN 'Vencido'
        WHEN fecha_vencimiento = DATE '2026-11-15'
            THEN 'Vence en fecha de referencia'
        ELSE 'Vigente posterior'
    END
ORDER BY estado_lote;


-- CONSULTA 4: PRODUCTOS CON BAJO STOCK DISPONIBLE

SELECT
    p.nombre AS producto,
    COALESCE(
        SUM(
            CASE
                WHEN l.fecha_vencimiento >= DATE '2026-11-15'
                    THEN l.cantidad_stock
                ELSE 0
            END
        ), 0
    ) AS stock_disponible
FROM producto p
LEFT JOIN lote l
    ON l.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
HAVING COALESCE(
    SUM(
        CASE
            WHEN l.fecha_vencimiento >= DATE '2026-11-15'
                THEN l.cantidad_stock
            ELSE 0
        END
    ), 0
) < 5
ORDER BY stock_disponible, p.nombre;
