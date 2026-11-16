-- ============================================================
-- TALLER III - SISTEMA DE GESTION DE INVENTARIO Y VENTA
-- HITO 9: DIEZ CONSULTAS DE AGREGACION Y AGRUPACION
-- RESPONSABLE: STIVEN HERNANDEZ PEREZ
-- MOTOR: POSTGRESQL 18
-- Archivo: scripts/consultas_agregacion.sql
-- Consultas de solo lectura; no requieren BEGIN ni COMMIT.
-- ============================================================

-- CONSULTA 1 / FIGURA 39: CANTIDAD DE PRODUCTOS POR CATEGORIA
SELECT
    categoria,
    COUNT(*) AS cantidad_productos
FROM producto
GROUP BY categoria
ORDER BY cantidad_productos DESC, categoria;

-- CONSULTA 2 / FIGURA 40: PRECIO PROMEDIO POR CATEGORIA
SELECT
    categoria,
    COUNT(*) AS cantidad_productos,
    ROUND(AVG(precio_unitario), 2) AS precio_promedio
FROM producto
GROUP BY categoria
ORDER BY precio_promedio DESC, categoria;

-- CONSULTA 3 / FIGURA 41: PRECIOS MINIMO Y MAXIMO POR CATEGORIA
SELECT
    categoria,
    MIN(precio_unitario) AS precio_minimo,
    MAX(precio_unitario) AS precio_maximo
FROM producto
GROUP BY categoria
ORDER BY categoria;

-- CONSULTA 4 / FIGURA 42: CANTIDAD DE PRODUCTOS POR PROVEEDOR
SELECT
    pr.nombre AS proveedor,
    COUNT(p.id_producto) AS cantidad_productos
FROM proveedor pr
LEFT JOIN producto p
    ON p.id_proveedor = pr.id_proveedor
GROUP BY pr.id_proveedor, pr.nombre
ORDER BY cantidad_productos DESC, pr.nombre;

-- CONSULTA 5 / FIGURA 43: STOCK TOTAL POR PRODUCTO (TODOS LOS LOTES)
-- Nota: incluye stock fisico de lotes vencidos; NO equivale a stock vendible.
SELECT
    p.nombre AS producto,
    COALESCE(SUM(l.cantidad_stock), 0) AS stock_fisico_total
FROM producto p
LEFT JOIN lote l
    ON l.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY stock_fisico_total DESC, p.nombre;

-- CONSULTA 6 / FIGURA 44: NUMERO DE LOTES POR PRODUCTO
SELECT
    p.nombre AS producto,
    COUNT(l.id_lote) AS cantidad_lotes
FROM producto p
LEFT JOIN lote l
    ON l.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY cantidad_lotes DESC, p.nombre;

-- CONSULTA 7 / FIGURA 45: UNIDADES E INGRESOS POR PRODUCTO VENDIDO
-- El importe proviene del precio historico en detalle_venta.
SELECT
    p.nombre AS producto,
    SUM(dv.cantidad_comprada) AS unidades_vendidas,
    SUM(dv.cantidad_comprada * dv.precio_unitario) AS importe_vendido
FROM detalle_venta dv
INNER JOIN producto p
    ON p.id_producto = dv.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY importe_vendido DESC, p.nombre;

-- CONSULTA 8 / FIGURA 46: TOTAL FACTURADO POR MES
-- Se agrupa la fecha de la venta y se incluyen solo ventas con factura.
-- Supone una factura por venta (situacion confirmada para datos del Hito 7).
SELECT
    TO_CHAR(DATE_TRUNC('month', v.fecha), 'MM/YYYY') AS mes,
    COUNT(DISTINCT v.id_venta) AS ventas_facturadas,
    COUNT(DISTINCT f.id_factura) AS facturas,
    SUM(dv.cantidad_comprada * dv.precio_unitario) AS total_facturado
FROM venta v
INNER JOIN factura f
    ON f.id_venta = v.id_venta
INNER JOIN detalle_venta dv
    ON dv.id_venta = v.id_venta
GROUP BY DATE_TRUNC('month', v.fecha)
ORDER BY DATE_TRUNC('month', v.fecha);

-- CONSULTA 9 / FIGURA 47: NUMERO DE VENTAS E IMPORTE POR CLIENTE
-- Se incluyen solo los clientes con ventas; un cliente no se cuenta
-- repetidamente por tener varios renglones de detalle.
SELECT
    c.nombre AS cliente,
    COUNT(DISTINCT v.id_venta) AS cantidad_ventas,
    SUM(dv.cantidad_comprada * dv.precio_unitario) AS total_comprado
FROM cliente c
INNER JOIN venta v
    ON v.id_cliente = c.id_cliente
INNER JOIN detalle_venta dv
    ON dv.id_venta = v.id_venta
GROUP BY c.id_cliente, c.nombre
ORDER BY total_comprado DESC, c.nombre;

-- CONSULTA 10 / FIGURA 48: CATEGORIAS CON MAS DE DOS PRODUCTOS
SELECT
    categoria,
    COUNT(*) AS cantidad_productos
FROM producto
GROUP BY categoria
HAVING COUNT(*) > 2
ORDER BY cantidad_productos DESC, categoria;
