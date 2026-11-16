
-- =============================================
-- TALLER III - SISTEMA DE DROGUERIA
-- HITO 8: CONSULTAS BASICAS Y JOIN
-- RESPONSABLE: KEVINN CUERVO
-- POSTGRESQL 18
-- =============================================

-- =============================================
-- CONSULTA BASICA 1: PRODUCTOS POR PRECIO
-- =============================================

SELECT
    nombre,
    categoria,
    precio_unitario
FROM producto
WHERE precio_unitario >= 10000.00
ORDER BY precio_unitario DESC, nombre;

-- =============================================
-- CONSULTA BASICA 2: CLIENTES CON CEDULA
-- =============================================

SELECT
    nombre,
    tipo_identificacion,
    identificacion
FROM cliente
WHERE tipo_identificacion = 'CC'
ORDER BY nombre;

-- =============================================
-- CONSULTA BASICA 3: LOTES VENCIDOS
-- =============================================

SELECT
    codigo_lote,
    TO_CHAR(
        fecha_vencimiento,
        'DD/MM/YYYY'
    ) AS fecha_vencimiento,
    cantidad_stock
FROM lote
WHERE fecha_vencimiento < DATE '2026-11-15'
ORDER BY fecha_vencimiento, codigo_lote;

-- =============================================
-- CONSULTA JOIN 1: PRODUCTOS Y PROVEEDORES
-- =============================================

SELECT
    p.nombre AS producto,
    p.categoria,
    p.precio_unitario,
    pr.nombre AS proveedor
FROM producto p
INNER JOIN proveedor pr
    ON pr.id_proveedor = p.id_proveedor
ORDER BY pr.nombre, p.nombre;

-- =============================================
-- CONSULTA JOIN 2: VENTAS, CLIENTES Y FACTURAS
-- =============================================

SELECT
    c.nombre AS cliente,
    TO_CHAR(
        v.fecha,
        'DD/MM/YYYY'
    ) AS fecha_venta,
    f.tipo_factura,
    f.prefijo,
    f.numero_factura
FROM venta v
INNER JOIN cliente c
    ON c.id_cliente = v.id_cliente
INNER JOIN factura f
    ON f.id_venta = v.id_venta
ORDER BY c.nombre;
