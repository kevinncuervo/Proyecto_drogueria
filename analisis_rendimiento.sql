
-- =============================================
-- TALLER III - SISTEMA DE DROGUERIA
-- HITO 10: ANALISIS DE RENDIMIENTO
-- RESPONSABLE: KEVINN CUERVO
-- POSTGRESQL 18
-- =============================================

-- =============================================
-- ANALISIS 1:
-- PRODUCTOS CON PRECIO SUPERIOR AL PROMEDIO
-- =============================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    id_producto,
    nombre,
    categoria,
    precio_unitario
FROM producto
WHERE precio_unitario > (
    SELECT AVG(precio_unitario)
    FROM producto
)
ORDER BY precio_unitario DESC, nombre;

-- =============================================
-- ANALISIS 2:
-- PRODUCTOS CON LOTES VENCIDOS
-- =============================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    id_producto,
    nombre,
    categoria
FROM producto
WHERE id_producto IN (
    SELECT id_producto
    FROM lote
    WHERE fecha_vencimiento < DATE '2026-11-15'
)
ORDER BY nombre;

-- =============================================
-- ANALISIS 3:
-- CLIENTES QUE HAN REALIZADO VENTAS
-- =============================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    c.id_cliente,
    c.nombre,
    c.tipo_identificacion,
    c.identificacion
FROM cliente c
WHERE EXISTS (
    SELECT 1
    FROM venta v
    WHERE v.id_cliente = c.id_cliente
)
ORDER BY c.nombre;

-- =============================================
-- ANALISIS 4:
-- PROVEEDORES CON TRES O MAS PRODUCTOS
-- =============================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    pr.id_proveedor,
    pr.nombre,
    (
        SELECT COUNT(*)
        FROM producto p
        WHERE p.id_proveedor = pr.id_proveedor
    ) AS cantidad_productos
FROM proveedor pr
WHERE (
    SELECT COUNT(*)
    FROM producto p
    WHERE p.id_proveedor = pr.id_proveedor
) >= 3
ORDER BY cantidad_productos DESC, pr.nombre;

-- =============================================
-- ANALISIS 5:
-- VENTAS SUPERIORES AL PROMEDIO GENERAL
-- =============================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    v.id_venta,
    c.nombre AS cliente,
    SUM(
        dv.cantidad_comprada * dv.precio_unitario
    ) AS total_venta
FROM venta v
INNER JOIN cliente c
    ON c.id_cliente = v.id_cliente
INNER JOIN detalle_venta dv
    ON dv.id_venta = v.id_venta
GROUP BY
    v.id_venta,
    c.nombre
HAVING SUM(
    dv.cantidad_comprada * dv.precio_unitario
) > (
    SELECT AVG(t.total_venta)
    FROM (
        SELECT
            SUM(
                dv2.cantidad_comprada
                * dv2.precio_unitario
            ) AS total_venta
        FROM detalle_venta dv2
        GROUP BY dv2.id_venta
    ) t
)
ORDER BY total_venta DESC;
