
-- =====================================================
-- TALLER III - SISTEMA DE GESTION DE DROGUERIA
-- HITO 11: VISTAS Y TRANSACCIONES ACID
-- RESPONSABLE: STIVEN HERNANDEZ
-- POSTGRESQL 18
-- =====================================================

-- IMPORTANTE:
-- Ejecutar cada seccion de manera independiente.
-- No ejecutar el archivo completo con F5.
-- Las pruebas ACID se realizan por pasos.


-- =====================================================
-- PARTE 1: CREACION DE VISTAS
-- =====================================================

-- VISTA 1: EXISTENCIAS FISICAS Y STOCK VIGENTE

CREATE OR REPLACE VIEW vw_existencias_producto AS
SELECT
    p.id_producto,
    p.nombre AS producto,
    p.categoria,
    COALESCE(
        SUM(l.cantidad_stock), 0
    ) AS stock_fisico,
    COALESCE(
        SUM(l.cantidad_stock) FILTER (
            WHERE l.fecha_vencimiento >= DATE '2026-11-15'
        ), 0
    ) AS stock_vigente
FROM producto p
LEFT JOIN lote l
    ON l.id_producto = p.id_producto
GROUP BY
    p.id_producto,
    p.nombre,
    p.categoria;


-- VISTA 2: DETALLE DE VENTAS REGISTRADAS

CREATE OR REPLACE VIEW vw_detalle_ventas AS
SELECT
    v.id_venta,
    TO_CHAR(v.fecha, 'DD/MM/YYYY') AS fecha_venta,
    c.nombre AS cliente,
    p.nombre AS producto,
    dv.cantidad_comprada,
    dv.precio_unitario,
    (
        dv.cantidad_comprada * dv.precio_unitario
    ) AS subtotal
FROM venta v
INNER JOIN cliente c
    ON c.id_cliente = v.id_cliente
INNER JOIN detalle_venta dv
    ON dv.id_venta = v.id_venta
INNER JOIN producto p
    ON p.id_producto = dv.id_producto;


-- VISTA 3: RESUMEN DE COMPRAS POR CLIENTE

CREATE OR REPLACE VIEW vw_compras_cliente AS
SELECT
    c.id_cliente,
    c.nombre AS cliente,
    COUNT(DISTINCT v.id_venta) AS cantidad_ventas,
    COALESCE(
        SUM(
            dv.cantidad_comprada * dv.precio_unitario
        ), 0
    ) AS total_comprado
FROM cliente c
LEFT JOIN venta v
    ON v.id_cliente = c.id_cliente
LEFT JOIN detalle_venta dv
    ON dv.id_venta = v.id_venta
GROUP BY
    c.id_cliente,
    c.nombre;


-- =====================================================
-- PARTE 2: CONSULTAS DE VALIDACION DE LAS VISTAS
-- =====================================================

-- FIGURA 59: EXISTENCIAS POR PRODUCTO

SELECT
    id_producto,
    producto,
    categoria,
    stock_fisico,
    stock_vigente
FROM vw_existencias_producto
ORDER BY producto;


-- FIGURA 60: DETALLE DE VENTAS

SELECT
    id_venta,
    fecha_venta,
    cliente,
    producto,
    cantidad_comprada,
    precio_unitario,
    subtotal
FROM vw_detalle_ventas
ORDER BY id_venta, producto;


-- FIGURA 61: COMPRAS POR CLIENTE

SELECT
    id_cliente,
    cliente,
    cantidad_ventas,
    total_comprado
FROM vw_compras_cliente
ORDER BY total_comprado DESC, cliente;


-- =====================================================
-- PARTE 3: TRANSACCIONES ACID
-- =====================================================

-- FIGURA 62: ATOMICIDAD
-- Ejecutar el bloque BEGIN / INSERT / SELECT.
-- Capturar el registro temporal.
-- Ejecutar ROLLBACK por separado.

BEGIN;

INSERT INTO cliente (
    nombre,
    tipo_identificacion,
    identificacion
)
VALUES (
    'Cliente Prueba Atomicidad',
    'CC',
    'H11-AT-01'
)
RETURNING
    id_cliente,
    nombre,
    identificacion;

SELECT
    COUNT(*) AS registros_temporales
FROM cliente
WHERE identificacion = 'H11-AT-01';

ROLLBACK;

-- Comprobacion despues del ROLLBACK

SELECT
    COUNT(*) AS registros_restantes
FROM cliente
WHERE identificacion = 'H11-AT-01';


-- =====================================================
-- FIGURA 63: CONSISTENCIA
-- PRUEBA CONTROLADA DE INTEGRIDAD REFERENCIAL
--
-- Ejecutar BEGIN y SAVEPOINT juntos.
-- Ejecutar el INSERT invalido por separado.
-- Debe producir el SQLSTATE 23503.
-- Luego ejecutar ROLLBACK TO SAVEPOINT y ROLLBACK.
-- =====================================================

BEGIN;

SAVEPOINT antes_de_error;

-- Ejecutar esta instruccion por separado:

INSERT INTO venta (
    fecha,
    id_cliente
)
VALUES (
    DATE '2026-11-16',
    99999999
);

-- Tras el error, ejecutar estas instrucciones
-- para recuperar el estado de la transaccion:

ROLLBACK TO SAVEPOINT antes_de_error;

ROLLBACK;

-- Verificar que no se genero ninguna venta:

SELECT
    COUNT(*) AS ventas_cliente_inexistente
FROM venta
WHERE id_cliente = 99999999;


-- =====================================================
-- FIGURA 64: AISLAMIENTO
-- REQUIERE DOS SESIONES INDEPENDIENTES
-- =====================================================

-- SESION A
-- Ejecutar BEGIN e INSERT, sin ROLLBACK todavia.

BEGIN;

INSERT INTO cliente (
    nombre,
    tipo_identificacion,
    identificacion
)
VALUES (
    'Cliente Prueba Aislamiento',
    'CC',
    'H11-ISO-01'
)
RETURNING
    id_cliente,
    nombre,
    identificacion;

-- SESION B (otra conexion)
-- Ejecutar mientras A sigue sin confirmar:

SELECT
    COUNT(*) AS registros_visibles
FROM cliente
WHERE identificacion = 'H11-ISO-01';

-- SESION A
-- Revertir el registro no confirmado:

ROLLBACK;

-- SESION B
-- Comprobar nuevamente:

SELECT
    COUNT(*) AS registros_finales
FROM cliente
WHERE identificacion = 'H11-ISO-01';


-- =====================================================
-- FIGURA 65: DURABILIDAD
-- REGISTRO CONFIRMADO CON COMMIT
-- =====================================================

-- SESION A
-- Ejecutar desde BEGIN hasta COMMIT.

BEGIN;

INSERT INTO cliente (
    nombre,
    tipo_identificacion,
    identificacion
)
VALUES (
    'Cliente Prueba Durabilidad',
    'CC',
    'H11-DUR-01'
)
RETURNING
    id_cliente,
    nombre,
    identificacion;

COMMIT;

-- SESION B
-- Comprobar la persistencia del registro:

SELECT
    nombre,
    tipo_identificacion,
    identificacion
FROM cliente
WHERE identificacion = 'H11-DUR-01';

-- LIMPIEZA OBLIGATORIA
-- Ejecutar una vez capturada la evidencia:

BEGIN;

DELETE FROM cliente
WHERE identificacion = 'H11-DUR-01'
RETURNING
    id_cliente,
    nombre;

COMMIT;

-- Comprobar que el dato de prueba fue retirado:

SELECT
    COUNT(*) AS registros_restantes
FROM cliente
WHERE identificacion = 'H11-DUR-01';


-- =====================================================
-- FIGURA 66: COMPROBACION FINAL
-- =====================================================

SELECT
    (SELECT COUNT(*) FROM cliente) AS total_clientes,
    (SELECT COUNT(*) FROM producto) AS total_productos,
    (SELECT COUNT(*) FROM lote) AS total_lotes,
    (SELECT COUNT(*) FROM venta) AS total_ventas,
    (SELECT COUNT(*) FROM factura) AS total_facturas,
    (SELECT COUNT(*) FROM vw_existencias_producto)
        AS productos_en_vista,
    (SELECT COUNT(*) FROM vw_detalle_ventas)
        AS detalles_en_vista,
    (SELECT COUNT(*) FROM cliente
     WHERE identificacion IN (
         'H11-AT-01',
         'H11-ISO-01',
         'H11-DUR-01'
     )) AS clientes_prueba_restantes,
    (SELECT COUNT(*) FROM venta
     WHERE id_cliente = 99999999)
        AS ventas_invalidas;
