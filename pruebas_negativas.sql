
-- =============================================
-- Taller III - Sistema de gestion de drogueria
-- Hito 4: Pruebas negativas de integridad
-- Responsable: Kevinn Cuervo
-- PostgreSQL 18
-- =============================================

BEGIN;

-- N1: Clave foranea inexistente
DO $$
DECLARE
    v_mensaje TEXT;
    v_codigo TEXT;
    v_rechazada BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO venta (fecha, id_cliente)
        VALUES (DATE '2026-11-15', -1);

    EXCEPTION WHEN foreign_key_violation THEN
        GET STACKED DIAGNOSTICS
            v_mensaje = MESSAGE_TEXT,
            v_codigo = RETURNED_SQLSTATE;

        v_rechazada := TRUE;

        RAISE NOTICE
            'N1 | SQLSTATE: % | ERROR: %',
            v_codigo, v_mensaje;
    END;

    IF NOT v_rechazada THEN
        RAISE EXCEPTION
            'N1 fallo: la insercion invalida fue aceptada';
    END IF;
END;
$$;

-- N2: Identificacion de cliente duplicada
DO $$
DECLARE
    v_mensaje TEXT;
    v_codigo TEXT;
    v_rechazada BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO cliente (
            nombre,
            tipo_identificacion,
            identificacion
        )
        VALUES (
            'Cliente prueba H4 A',
            'CC',
            'H4-900001'
        );

        INSERT INTO cliente (
            nombre,
            tipo_identificacion,
            identificacion
        )
        VALUES (
            'Cliente prueba H4 B',
            'CC',
            'H4-900001'
        );

    EXCEPTION WHEN unique_violation THEN
        GET STACKED DIAGNOSTICS
            v_mensaje = MESSAGE_TEXT,
            v_codigo = RETURNED_SQLSTATE;

        v_rechazada := TRUE;

        RAISE NOTICE
            'N2 | SQLSTATE: % | ERROR: %',
            v_codigo, v_mensaje;
    END;

    IF NOT v_rechazada THEN
        RAISE EXCEPTION
            'N2 fallo: la identificacion duplicada fue aceptada';
    END IF;
END;
$$;

-- Preparar proveedor existente para N3
INSERT INTO proveedor (
    nombre,
    telefono,
    correo_electronico,
    direccion
)
VALUES (
    'Proveedor negativo H4',
    '3009876543',
    'negativo.h4@ejemplo.com',
    'Direccion de prueba'
);

-- N3: Precio del producto igual a cero
DO $$
DECLARE
    v_mensaje TEXT;
    v_codigo TEXT;
    v_rechazada BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO producto (
            nombre,
            marca,
            categoria,
            precio_unitario,
            id_proveedor
        )
        VALUES (
            'Producto precio invalido H4',
            'Marca Prueba',
            'Medicamentos',
            0.00,
            currval(pg_get_serial_sequence(
                'proveedor', 'id_proveedor'
            ))
        );

    EXCEPTION WHEN check_violation THEN
        GET STACKED DIAGNOSTICS
            v_mensaje = MESSAGE_TEXT,
            v_codigo = RETURNED_SQLSTATE;

        v_rechazada := TRUE;

        RAISE NOTICE
            'N3 | SQLSTATE: % | ERROR: %',
            v_codigo, v_mensaje;
    END;

    IF NOT v_rechazada THEN
        RAISE EXCEPTION
            'N3 fallo: el precio igual a cero fue aceptado';
    END IF;
END;
$$;

-- Revertir los datos de preparacion
ROLLBACK;
