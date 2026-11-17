
-- =============================================
-- TALLER III - SISTEMA DE DROGUERIA
-- HITO 12: NL2SQL Y VALIDACION FINAL
-- RESPONSABLE: KEVINN CUERVO
-- POSTGRESQL 18
-- =============================================

-- =============================================
-- PRUEBA NL2SQL 1:
-- PRODUCTOS CON STOCK VIGENTE
-- =============================================

-- PREGUNTA EN LENGUAJE NATURAL:
-- ¿Cuales son los productos que tienen
-- existencias vigentes al 15/11/2026
-- y cuantas unidades tiene cada uno?

-- CONSULTA SQL:

SELECT
    producto,
    categoria,
    stock_fisico,
    stock_vigente
FROM vw_existencias_producto
WHERE stock_vigente > 0
ORDER BY stock_vigente DESC, producto;

-- =============================================
-- PRUEBA NL2SQL 2:
-- CLIENTES CON COMPRAS REGISTRADAS
-- =============================================

-- PREGUNTA EN LENGUAJE NATURAL:
-- ¿Cuales son los clientes que han realizado
-- compras en la drogueria, cuantas ventas
-- tiene cada uno y cual es el valor total
-- comprado?

-- CONSULTA SQL:

SELECT
    cliente,
    cantidad_ventas,
    total_comprado
FROM vw_compras_cliente
WHERE cantidad_ventas > 0
ORDER BY total_comprado DESC, cliente;

-- =============================================
-- PRUEBA NL2SQL 3:
-- FACTURACION POR TIPO DE FACTURA
-- =============================================

-- PREGUNTA EN LENGUAJE NATURAL:
-- ¿Cuanto dinero se ha facturado por cada
-- tipo de factura y cuantas facturas
-- se han emitido?

-- CONSULTA SQL:

SELECT
    f.tipo_factura,
    COUNT(DISTINCT f.id_factura) AS cantidad_facturas,
    SUM(
        dv.cantidad_comprada * dv.precio_unitario
    ) AS total_facturado
FROM factura f
INNER JOIN venta v
    ON v.id_venta = f.id_venta
INNER JOIN detalle_venta dv
    ON dv.id_venta = v.id_venta
GROUP BY f.tipo_factura
ORDER BY total_facturado DESC;

-- =============================================
-- VALIDACION FINAL DEL SISTEMA
-- HITO 12
-- =============================================

SELECT
    (SELECT COUNT(*) FROM proveedor)
        AS proveedores,

    (SELECT COUNT(*) FROM cliente)
        AS clientes,

    (SELECT COUNT(*) FROM producto)
        AS productos,

    (SELECT COUNT(*) FROM entrega)
        AS entregas,

    (SELECT COUNT(*) FROM lote)
        AS lotes,

    (SELECT COUNT(*) FROM venta)
        AS ventas,

    (SELECT COUNT(*) FROM detalle_venta)
        AS detalles_venta,

    (SELECT COUNT(*) FROM detalle_lote_venta)
        AS distribuciones_fefo,

    (SELECT COUNT(*) FROM factura)
        AS facturas,

    (SELECT COUNT(*) FROM vw_existencias_producto)
        AS registros_inventario,

    (SELECT COUNT(*) FROM vw_detalle_ventas)
        AS registros_detalle_ventas,

    (SELECT COUNT(*) FROM vw_compras_cliente)
        AS registros_compras_cliente;

-- =============================================
-- PARTE 6: NL2SQL GENERADO POR IA
-- PRUEBA 1: INVENTARIO VIGENTE BAJO
-- HERRAMIENTA: CHATGPT
-- =============================================

-- PREGUNTA:
-- ¿Que productos tienen menos de 10 unidades
-- vigentes al 15/11/2026 y cual es su proveedor?

-- SQL ORIGINAL GENERADO POR IA:

SELECT
    p.nombre AS producto,
    pr.nombre AS proveedor,
    v.stock_fisico,
    v.stock_vigente
FROM vw_existencias_producto v
INNER JOIN producto p
    ON p.id_producto = v.id_producto
INNER JOIN proveedor pr
    ON pr.id_proveedor = p.id_proveedor
WHERE v.stock_vigente < 10
ORDER BY v.stock_vigente ASC, p.nombre;

-- =============================================
-- PARTE 6: NL2SQL GENERADO POR IA
-- PRUEBA 2: LOTES PROXIMOS A VENCER
-- HERRAMIENTA: CHATGPT
-- =============================================

-- PREGUNTA:
-- ¿Que lotes venceran entre el 15/11/2026
-- y el 15/12/2026 y cuantas unidades fisicas
-- quedan en cada uno?

-- SQL ORIGINAL GENERADO POR IA:

SELECT
    l.codigo_lote,
    p.nombre AS producto,
    TO_CHAR(
        l.fecha_vencimiento,
        'DD/MM/YYYY'
    ) AS fecha_vencimiento,
    l.cantidad_stock
FROM lote l
INNER JOIN producto p
    ON p.id_producto = l.id_producto
WHERE l.fecha_vencimiento
      BETWEEN DATE '2026-11-15'
          AND DATE '2026-12-15'
ORDER BY
    l.fecha_vencimiento,
    l.codigo_lote;

-- =============================================
-- PARTE 6: NL2SQL GENERADO POR IA
-- PRUEBA 3: PRODUCTOS SIN VENTAS
-- HERRAMIENTA: CHATGPT
-- =============================================

-- PREGUNTA:
-- ¿Que proveedores suministran productos
-- que todavia no registran ventas y cuales
-- son esos productos?

-- SQL ORIGINAL GENERADO POR IA:

SELECT
    pr.nombre AS proveedor,
    p.nombre AS producto,
    p.categoria
FROM producto p
INNER JOIN proveedor pr
    ON pr.id_proveedor = p.id_proveedor
WHERE NOT EXISTS (
    SELECT 1
    FROM detalle_venta dv
    WHERE dv.id_producto = p.id_producto
)
ORDER BY
    pr.nombre,
    p.nombre;
