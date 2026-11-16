
-- ============================================
-- HITO 6 - PRUEBA POSITIVA FEFO
-- Venta de 35 unidades de Acetaminofen
-- ============================================

BEGIN;

-- Crear una venta temporal.
INSERT INTO venta (
    fecha,
    id_cliente
)
SELECT
    DATE '2026-11-15',
    c.id_cliente
FROM cliente c
ORDER BY c.id_cliente
LIMIT 1;

-- El trigger FEFO se ejecutara
-- al insertar este detalle de venta.
INSERT INTO detalle_venta (
    id_venta,
    id_producto,
    cantidad_comprada,
    precio_unitario
)
SELECT
    currval(pg_get_serial_sequence(
        'venta', 'id_venta'
    )),
    p.id_producto,
    35,
    p.precio_unitario
FROM producto p
WHERE p.nombre = 'Acetaminofen 500 mg';

-- Consultar de que lotes se descontaron
-- las 35 unidades.
SELECT
    l.codigo_lote,
    l.fecha_vencimiento,
    dlv.cantidad_descontada,
    l.cantidad_stock AS stock_restante
FROM detalle_lote_venta dlv
INNER JOIN lote l
    ON l.id_lote = dlv.id_lote
INNER JOIN detalle_venta dv
    ON dv.id_detalle = dlv.id_detalle
INNER JOIN producto p
    ON p.id_producto = dv.id_producto
WHERE dv.id_venta = currval(
    pg_get_serial_sequence(
        'venta', 'id_venta'
    )
)
  AND p.nombre = 'Acetaminofen 500 mg'
ORDER BY l.fecha_vencimiento, l.id_lote;

-- Ejecutar ROLLBACK despues de la captura.
ROLLBACK;

-- ============================================
-- HITO 6 - PRUEBAS NEGATIVAS FEFO
-- N1: Inventario insuficiente
-- N2: Producto con lote vencido
-- ============================================

BEGIN;

-- Venta temporal para las pruebas.
INSERT INTO venta (
    fecha,
    id_cliente
)
SELECT
    DATE '2026-11-15',
    c.id_cliente
FROM cliente c
ORDER BY c.id_cliente
LIMIT 1;

-- N1: Intentar descontar mas unidades
-- de las que realmente existen.
DO $$
DECLARE
    v_error TEXT;
    v_codigo TEXT;
    v_rechazada BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO detalle_venta (
            id_venta,
            id_producto,
            cantidad_comprada,
            precio_unitario
        )
        SELECT
            currval(pg_get_serial_sequence(
                'venta', 'id_venta'
            )),
            p.id_producto,
            100000,
            p.precio_unitario
        FROM producto p
        WHERE p.nombre = 'Acetaminofen 500 mg';

    EXCEPTION WHEN SQLSTATE 'P0001' THEN
        GET STACKED DIAGNOSTICS
            v_error = MESSAGE_TEXT,
            v_codigo = RETURNED_SQLSTATE;

        v_rechazada := TRUE;
        RAISE NOTICE
            'N1 | SQLSTATE: % | %',
            v_codigo, v_error;
    END;

    IF NOT v_rechazada THEN
        RAISE EXCEPTION
            'N1 fallo: la venta invalida fue aceptada';
    END IF;
END;
$$;

-- N2: Intentar vender un producto
-- cuyo unico lote esta vencido.
DO $$
DECLARE
    v_error TEXT;
    v_codigo TEXT;
    v_rechazada BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO detalle_venta (
            id_venta,
            id_producto,
            cantidad_comprada,
            precio_unitario
        )
        SELECT
            currval(pg_get_serial_sequence(
                'venta', 'id_venta'
            )),
            p.id_producto,
            1,
            p.precio_unitario
        FROM producto p
        WHERE p.nombre = 'Tapabocas caja 50';

    EXCEPTION WHEN SQLSTATE 'P0001' THEN
        GET STACKED DIAGNOSTICS
            v_error = MESSAGE_TEXT,
            v_codigo = RETURNED_SQLSTATE;

        v_rechazada := TRUE;
        RAISE NOTICE
            'N2 | SQLSTATE: % | %',
            v_codigo, v_error;
    END;

    IF NOT v_rechazada THEN
        RAISE EXCEPTION
            'N2 fallo: la venta invalida fue aceptada';
    END IF;
END;
$$;

-- Verificar que las existencias
-- no fueron modificadas.
SELECT
    l.codigo_lote,
    l.cantidad_stock
FROM lote l
WHERE l.codigo_lote IN (
    'L001', 'L021', 'L017'
)
ORDER BY l.codigo_lote;

ROLLBACK;
