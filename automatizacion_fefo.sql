
-- ============================================
-- TALLER III - SISTEMA DE DROGUERIA
-- HITO 6: AUTOMATIZACION FEFO
-- RESPONSABLE: KEVINN CUERVO
-- POSTGRESQL 18
-- ============================================

BEGIN;

-- Funcion que distribuye una venta entre lotes
-- y descuenta las existencias automaticamente.

CREATE OR REPLACE FUNCTION fn_asignar_lotes_fefo()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_fecha_venta DATE;
    v_pendiente INTEGER;
    v_descontar INTEGER;
    v_lote RECORD;
BEGIN

    -- Obtener la fecha de la venta.
    SELECT v.fecha
    INTO STRICT v_fecha_venta
    FROM venta v
    WHERE v.id_venta = NEW.id_venta;

    -- Cantidad pendiente por distribuir.
    v_pendiente := NEW.cantidad_comprada;

    -- Bloquear lotes elegibles y recorrerlos
    -- desde el vencimiento mas cercano.
    FOR v_lote IN
        SELECT
            l.id_lote,
            l.cantidad_stock,
            l.fecha_vencimiento
        FROM lote l
        INNER JOIN entrega e
            ON e.id_entrega = l.id_entrega
        INNER JOIN producto p
            ON p.id_producto = l.id_producto
        WHERE l.id_producto = NEW.id_producto
          AND l.fecha_vencimiento >= v_fecha_venta
          AND e.fecha_entrega <= v_fecha_venta
          AND e.id_proveedor = p.id_proveedor
          AND l.cantidad_stock > 0
        ORDER BY
            l.fecha_vencimiento ASC,
            l.id_lote ASC
        FOR UPDATE OF l
    LOOP

        -- Cantidad que se toma de este lote.
        v_descontar := LEAST(
            v_pendiente,
            v_lote.cantidad_stock
        );

        -- Actualizar las existencias.
        UPDATE lote
        SET cantidad_stock =
            cantidad_stock - v_descontar
        WHERE id_lote = v_lote.id_lote;

        -- Registrar de cual lote salieron
        -- las unidades del detalle de venta.
        INSERT INTO detalle_lote_venta (
            id_detalle,
            id_lote,
            cantidad_descontada
        )
        VALUES (
            NEW.id_detalle,
            v_lote.id_lote,
            v_descontar
        );

        -- Actualizar cantidad pendiente.
        v_pendiente :=
            v_pendiente - v_descontar;

        EXIT WHEN v_pendiente = 0;

    END LOOP;

    -- Si faltan unidades, rechazar la operacion.
    -- PostgreSQL revierte los cambios de la
    -- instruccion que disparo el error.
    IF v_pendiente > 0 THEN
        RAISE EXCEPTION
            'Inventario insuficiente para producto %. Faltan % unidades.',
            NEW.id_producto,
            v_pendiente
        USING ERRCODE = 'P0001';
    END IF;

    RETURN NEW;

END;
$$;

-- Crear el disparador.
-- Una insercion en detalle_venta ejecuta FEFO.

DROP TRIGGER IF EXISTS
    trg_asignar_lotes_fefo
ON detalle_venta;

CREATE TRIGGER trg_asignar_lotes_fefo
AFTER INSERT ON detalle_venta
FOR EACH ROW
EXECUTE FUNCTION fn_asignar_lotes_fefo();

COMMIT;
