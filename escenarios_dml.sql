
BEGIN;

INSERT INTO cliente (
    nombre,
    tipo_identificacion,
    identificacion
)
VALUES (
    'Cliente Prueba Hito 8',
    'CC',
    'H8-900001'
)
RETURNING
    id_cliente,
    nombre,
    tipo_identificacion,
    identificacion;


-- Verificar el cliente insertado
SELECT
    id_cliente,
    nombre,
    tipo_identificacion,
    identificacion
FROM cliente
WHERE identificacion = 'H8-900001';

-- Revertir la insercion de prueba
ROLLBACK;

-- =============================================
-- ESCENARIO 2: ACTUALIZAR PRECIO DE PRODUCTO
-- =============================================

BEGIN;

-- Consultar el precio original
SELECT
    nombre,
    precio_unitario AS precio_anterior
FROM producto
WHERE nombre = 'Vitamina C 500 mg';

-- Actualizar temporalmente el precio
UPDATE producto
SET precio_unitario = 5600.00
WHERE nombre = 'Vitamina C 500 mg'
  AND precio_unitario = 5400.00
RETURNING
    id_producto,
    nombre,
    precio_unitario AS precio_actualizado;

-- Verificar el precio modificado
SELECT
    nombre,
    precio_unitario
FROM producto
WHERE nombre = 'Vitamina C 500 mg';

-- Revertir la modificacion
ROLLBACK;

-- =============================================
-- ESCENARIO 3: ELIMINAR CLIENTE SIN VENTAS
-- =============================================

BEGIN;

-- Verificar que el cliente no tenga ventas
SELECT
    c.id_cliente,
    c.nombre,
    c.tipo_identificacion,
    c.identificacion
FROM cliente c
LEFT JOIN venta v
    ON v.id_cliente = c.id_cliente
WHERE c.tipo_identificacion = 'CE'
  AND c.identificacion = '30030001'
  AND v.id_venta IS NULL;

-- Eliminar temporalmente el cliente
DELETE FROM cliente
WHERE tipo_identificacion = 'CE'
  AND identificacion = '30030001'
RETURNING
    id_cliente,
    nombre,
    identificacion;

-- Comprobar la eliminacion
SELECT
    COUNT(*) AS clientes_encontrados
FROM cliente
WHERE tipo_identificacion = 'CE'
  AND identificacion = '30030001';

-- Revertir la eliminacion
ROLLBACK;
