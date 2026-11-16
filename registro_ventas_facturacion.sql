
-- =============================================
-- TALLER III - SISTEMA DE DROGUERIA
-- HITO 7: REGISTRO DE VENTAS Y FACTURACION
-- RESPONSABLE: STIVEN HERNANDEZ
-- POSTGRESQL 18
-- =============================================

BEGIN;

DO $$
DECLARE
    v_cliente INTEGER;
    v_producto INTEGER;
    v_venta INTEGER;
    v_precio NUMERIC(12,2);
BEGIN

    -- 1. IMPEDIR CARGAS COMERCIALES DUPLICADAS
    IF EXISTS (SELECT 1 FROM venta)
       OR EXISTS (SELECT 1 FROM detalle_venta)
       OR EXISTS (SELECT 1 FROM detalle_lote_venta)
       OR EXISTS (SELECT 1 FROM factura) THEN
        RAISE EXCEPTION
            'Ya existen registros comerciales. Revisar antes de cargar.';
    END IF;

    -- 2. COMPROBAR QUE FEFO ESTE ACTIVO
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger t
        INNER JOIN pg_class c
            ON c.oid = t.tgrelid
        INNER JOIN pg_proc p
            ON p.oid = t.tgfoid
        WHERE c.oid = 'public.detalle_venta'::regclass
          AND t.tgname = 'trg_asignar_lotes_fefo'
          AND p.proname = 'fn_asignar_lotes_fefo'
          AND t.tgenabled = 'O'
          AND NOT t.tgisinternal
    ) THEN
        RAISE EXCEPTION
            'El disparador FEFO no esta instalado o habilitado.';
    END IF;

    -- 3. VERIFICAR INVENTARIO INICIAL
    IF (
        SELECT COUNT(*)
        FROM lote
        WHERE
            (codigo_lote = 'L001' AND cantidad_stock = 60)
            OR (codigo_lote = 'L002' AND cantidad_stock = 50)
            OR (codigo_lote = 'L020' AND cantidad_stock = 3)
            OR (codigo_lote = 'L021' AND cantidad_stock = 30)
            OR (codigo_lote = 'L023' AND cantidad_stock = 35)
    ) <> 5 THEN
        RAISE EXCEPTION
            'El inventario inicial no coincide con los datos del Hito 5.';
    END IF;

    -- =========================================
    -- VENTA 1: ANA MARIA LOPEZ
    -- =========================================

    SELECT c.id_cliente
    INTO STRICT v_cliente
    FROM cliente c
    WHERE c.tipo_identificacion = 'CC'
      AND c.identificacion = '10010001';

    INSERT INTO venta (
        fecha,
        id_cliente
    )
    VALUES (
        DATE '2026-11-15',
        v_cliente
    )
    RETURNING id_venta INTO v_venta;

    -- Detalle 1: 35 unidades de acetaminofen.
    SELECT p.id_producto, p.precio_unitario
    INTO STRICT v_producto, v_precio
    FROM producto p
    WHERE p.nombre = 'Acetaminofen 500 mg';

    INSERT INTO detalle_venta (
        id_venta,
        id_producto,
        cantidad_comprada,
        precio_unitario
    )
    VALUES (
        v_venta,
        v_producto,
        35,
        v_precio
    );

    -- Detalle 2: 4 unidades de loratadina.
    SELECT p.id_producto, p.precio_unitario
    INTO STRICT v_producto, v_precio
    FROM producto p
    WHERE p.nombre = 'Loratadina 10 mg';

    INSERT INTO detalle_venta (
        id_venta,
        id_producto,
        cantidad_comprada,
        precio_unitario
    )
    VALUES (
        v_venta,
        v_producto,
        4,
        v_precio
    );

    -- Factura electronica.
    INSERT INTO factura (
        id_venta,
        tipo_factura,
        prefijo,
        numero_factura
    )
    VALUES (
        v_venta,
        'Electronica',
        'FE',
        '000001'
    );

    -- =========================================
    -- VENTA 2: CARLOS ANDRES RUIZ
    -- =========================================

    SELECT c.id_cliente
    INTO STRICT v_cliente
    FROM cliente c
    WHERE c.tipo_identificacion = 'CC'
      AND c.identificacion = '10010002';

    INSERT INTO venta (
        fecha,
        id_cliente
    )
    VALUES (
        DATE '2026-11-15',
        v_cliente
    )
    RETURNING id_venta INTO v_venta;

    -- Detalle 3: 2 paquetes de gasa esteril.
    SELECT p.id_producto, p.precio_unitario
    INTO STRICT v_producto, v_precio
    FROM producto p
    WHERE p.nombre = 'Gasa esteril paquete';

    INSERT INTO detalle_venta (
        id_venta,
        id_producto,
        cantidad_comprada,
        precio_unitario
    )
    VALUES (
        v_venta,
        v_producto,
        2,
        v_precio
    );

    -- Factura POS.
    INSERT INTO factura (
        id_venta,
        tipo_factura,
        prefijo,
        numero_factura
    )
    VALUES (
        v_venta,
        'POS',
        'POS',
        '000001'
    );

    -- =========================================
    -- VENTA 3: LAURA SOFIA PEREZ
    -- =========================================

    SELECT c.id_cliente
    INTO STRICT v_cliente
    FROM cliente c
    WHERE c.tipo_identificacion = 'CC'
      AND c.identificacion = '10010003';

    INSERT INTO venta (
        fecha,
        id_cliente
    )
    VALUES (
        DATE '2026-11-15',
        v_cliente
    )
    RETURNING id_venta INTO v_venta;

    -- Detalle 4: 5 unidades de ibuprofeno.
    SELECT p.id_producto, p.precio_unitario
    INTO STRICT v_producto, v_precio
    FROM producto p
    WHERE p.nombre = 'Ibuprofeno 400 mg';

    INSERT INTO detalle_venta (
        id_venta,
        id_producto,
        cantidad_comprada,
        precio_unitario
    )
    VALUES (
        v_venta,
        v_producto,
        5,
        v_precio
    );

    -- Segunda factura POS.
    INSERT INTO factura (
        id_venta,
        tipo_factura,
        prefijo,
        numero_factura
    )
    VALUES (
        v_venta,
        'POS',
        'POS',
        '000002'
    );

    -- =========================================
    -- 4. VALIDACION DE REGISTROS
    -- =========================================

    IF (SELECT COUNT(*) FROM venta) <> 3
       OR (SELECT COUNT(*) FROM detalle_venta) <> 4
       OR (SELECT COUNT(*) FROM detalle_lote_venta) <> 5
       OR (SELECT COUNT(*) FROM factura) <> 3 THEN
        RAISE EXCEPTION
            'Cantidad incorrecta de registros comerciales.';
    END IF;

    -- 5. VALIDAR DISTRIBUCIONES FEFO
    IF EXISTS (
        SELECT 1
        FROM detalle_venta dv
        LEFT JOIN detalle_lote_venta dlv
            ON dlv.id_detalle = dv.id_detalle
        GROUP BY
            dv.id_detalle,
            dv.cantidad_comprada
        HAVING COALESCE(
            SUM(dlv.cantidad_descontada), 0
        ) <> dv.cantidad_comprada
    ) THEN
        RAISE EXCEPTION
            'Los detalles no estan completamente distribuidos.';
    END IF;

    -- 6. VALIDAR UNA FACTURA POR VENTA
    IF EXISTS (
        SELECT 1
        FROM venta v
        LEFT JOIN factura f
            ON f.id_venta = v.id_venta
        WHERE f.id_factura IS NULL
    ) THEN
        RAISE EXCEPTION
            'Existe una venta sin factura.';
    END IF;

    -- 7. VALIDAR TOTAL DE VENTAS
    IF (
        SELECT SUM(
            cantidad_comprada * precio_unitario
        )
        FROM detalle_venta
    ) <> 218700.00 THEN
        RAISE EXCEPTION
            'Total de ventas incorrecto.';
    END IF;

    -- 8. VALIDAR STOCK RESULTANTE
    IF (
        SELECT COUNT(*)
        FROM lote
        WHERE
            (codigo_lote = 'L001' AND cantidad_stock = 55)
            OR (codigo_lote = 'L002' AND cantidad_stock = 45)
            OR (codigo_lote = 'L020' AND cantidad_stock = 1)
            OR (codigo_lote = 'L021' AND cantidad_stock = 0)
            OR (codigo_lote = 'L023' AND cantidad_stock = 31)
    ) <> 5 THEN
        RAISE EXCEPTION
            'Las existencias finales no coinciden con FEFO.';
    END IF;

    RAISE NOTICE
        'Hito 7 validado: 3 ventas, 4 detalles, 5 distribuciones y 3 facturas. Total: 218700.00';

END;
$$;

COMMIT;
