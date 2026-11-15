
-- =============================================
-- Taller III - Sistema de gestion de drogueria
-- Hito 4: Pruebas positivas de integridad
-- Responsable: Kevinn Cuervo
-- PostgreSQL 18
-- =============================================

BEGIN;

-- P1: Registrar un proveedor valido
INSERT INTO proveedor (
    nombre,
    telefono,
    correo_electronico,
    direccion
)
VALUES (
    'Proveedor prueba H4',
    '3001234567',
    'proveedor.h4@ejemplo.com',
    'Direccion de prueba'
);

-- P2: Registrar un producto con proveedor existente
INSERT INTO producto (
    nombre,
    marca,
    categoria,
    precio_unitario,
    id_proveedor
)
VALUES (
    'Producto prueba H4',
    'Marca Prueba',
    'Medicamentos',
    15000.00,
    currval(pg_get_serial_sequence(
        'proveedor', 'id_proveedor'
    ))
);

-- Preparacion para P3: entrega valida
INSERT INTO entrega (
    fecha_entrega,
    id_proveedor
)
VALUES (
    DATE '2026-11-15',
    currval(pg_get_serial_sequence(
        'proveedor', 'id_proveedor'
    ))
);

-- P3: Registrar un lote valido
INSERT INTO lote (
    codigo_lote,
    fecha_vencimiento,
    cantidad_recibida,
    cantidad_stock,
    id_producto,
    id_entrega
)
VALUES (
    'H4-LOTE-PRUEBA',
    DATE '2027-12-31',
    50,
    50,
    currval(pg_get_serial_sequence(
        'producto', 'id_producto'
    )),
    currval(pg_get_serial_sequence(
        'entrega', 'id_entrega'
    ))
);

-- Verificar las tres pruebas positivas
SELECT
    'P1 - Proveedor valido' AS prueba,
    EXISTS (
        SELECT 1
        FROM proveedor
        WHERE id_proveedor = currval(
            pg_get_serial_sequence(
                'proveedor', 'id_proveedor'
            )
        )
    ) AS resultado

UNION ALL

SELECT
    'P2 - Producto con proveedor valido',
    EXISTS (
        SELECT 1
        FROM producto
        WHERE id_producto = currval(
            pg_get_serial_sequence(
                'producto', 'id_producto'
            )
        )
    )

UNION ALL

SELECT
    'P3 - Lote con datos validos',
    EXISTS (
        SELECT 1
        FROM lote
        WHERE id_lote = currval(
            pg_get_serial_sequence(
                'lote', 'id_lote'
            )
        )
    );

-- Revertir los datos de prueba
ROLLBACK;
