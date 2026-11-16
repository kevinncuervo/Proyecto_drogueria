
-- =============================================
-- Taller III - Sistema de gestion de drogueria
-- Hito 5: Carga de datos sinteticos
-- Responsable: Stiven Hernandez
-- PostgreSQL 18
-- =============================================

BEGIN;

-- 1. COMPROBAR QUE NO EXISTAN DATOS PREVIOS
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM proveedor
        UNION ALL SELECT 1 FROM cliente
        UNION ALL SELECT 1 FROM producto
        UNION ALL SELECT 1 FROM entrega
        UNION ALL SELECT 1 FROM lote
        UNION ALL SELECT 1 FROM venta
        UNION ALL SELECT 1 FROM detalle_venta
        UNION ALL SELECT 1 FROM detalle_lote_venta
        UNION ALL SELECT 1 FROM factura
    ) THEN
        RAISE EXCEPTION
            'Las tablas contienen datos. Revisar antes de cargar.';
    END IF;
END;
$$;

-- =============================================
-- 2. PROVEEDORES: 6 REGISTROS
-- =============================================

INSERT INTO proveedor (
    nombre, telefono, correo_electronico, direccion
)
VALUES
('Distribuidora Andina', '3001001001',
 'andina@ejemplo.com', 'Calle 10 # 15-20'),
('Farma Central', '3001001002',
 'central@ejemplo.com', 'Carrera 12 # 20-30'),
('Laboratorios del Cafe', '3001001003',
 'cafe@ejemplo.com', 'Calle 25 # 18-40'),
('Salud Integral', '3001001004',
 'salud@ejemplo.com', 'Carrera 8 # 30-15'),
('Drogueria Mayorista', '3001001005',
 'mayorista@ejemplo.com', 'Calle 40 # 12-50'),
('Insumos Clinicos', '3001001006',
 'insumos@ejemplo.com', 'Carrera 20 # 16-25');

-- =============================================
-- 3. CLIENTES: 20 REGISTROS
-- =============================================

INSERT INTO cliente (
    nombre, tipo_identificacion, identificacion
)
VALUES
('Ana Maria Lopez', 'CC', '10010001'),
('Carlos Andres Ruiz', 'CC', '10010002'),
('Laura Sofia Perez', 'CC', '10010003'),
('Miguel Angel Torres', 'CC', '10010004'),
('Daniela Garcia', 'CC', '10010005'),
('Juan David Morales', 'CC', '10010006'),
('Valentina Ramirez', 'CC', '10010007'),
('Andres Felipe Gomez', 'CC', '10010008'),
('Camila Restrepo', 'CC', '10010009'),
('Santiago Herrera', 'CC', '10010010'),
('Paula Andrea Castro', 'CC', '10010011'),
('Sebastian Marin', 'CC', '10010012'),
('Natalia Cardona', 'CC', '10010013'),
('David Alejandro Rios', 'CC', '10010014'),
('Isabella Vargas', 'CC', '10010015'),
('Mateo Jimenez', 'CC', '10010016'),
('Sara Martinez', 'TI', '20020001'),
('Samuel Ortiz', 'TI', '20020002'),
('Luciana Franco', 'TI', '20020003'),
('Daniel Quintero', 'CE', '30030001');

-- =============================================
-- 4. PRODUCTOS: 20 REGISTROS
-- =============================================

INSERT INTO producto (
    nombre, marca, categoria, precio_unitario,
    id_proveedor
)
SELECT
    d.nombre,
    d.marca,
    d.categoria,
    d.precio,
    p.id_proveedor
FROM (
    VALUES
    ('Acetaminofen 500 mg', 'SaludMed',
     'Analgesicos', 4500.00, 'Distribuidora Andina'),
    ('Ibuprofeno 400 mg', 'SaludMed',
     'Analgesicos', 6200.00, 'Distribuidora Andina'),
    ('Loratadina 10 mg', 'Alergimed',
     'Antialergicos', 5800.00, 'Distribuidora Andina'),
    ('Omeprazol 20 mg', 'GastroMed',
     'Digestivos', 7600.00, 'Distribuidora Andina'),
    ('Amoxicilina 500 mg', 'FarmaVida',
     'Antibioticos', 12500.00, 'Farma Central'),
    ('Azitromicina 500 mg', 'FarmaVida',
     'Antibioticos', 18500.00, 'Farma Central'),
    ('Naproxeno 250 mg', 'DolorFlex',
     'Analgesicos', 7200.00, 'Farma Central'),
    ('Metformina 850 mg', 'ControlMed',
     'Antidiabeticos', 8900.00, 'Laboratorios del Cafe'),
    ('Losartan 50 mg', 'ControlMed',
     'Antihipertensivos', 9300.00, 'Laboratorios del Cafe'),
    ('Enalapril 10 mg', 'ControlMed',
     'Antihipertensivos', 6900.00, 'Laboratorios del Cafe'),
    ('Vitamina C 500 mg', 'VitaPlus',
     'Vitaminas', 5400.00, 'Salud Integral'),
    ('Suero oral 500 ml', 'HidraSalud',
     'Hidratacion', 4800.00, 'Salud Integral'),
    ('Antiacido 200 ml', 'GastroPlus',
     'Digestivos', 11900.00, 'Salud Integral'),
    ('Alcohol antiseptico 70', 'BioClean',
     'Antisepticos', 8500.00, 'Drogueria Mayorista'),
    ('Agua oxigenada 120 ml', 'BioClean',
     'Antisepticos', 4200.00, 'Drogueria Mayorista'),
    ('Gel antibacterial 250 ml', 'BioClean',
     'Higiene', 9900.00, 'Drogueria Mayorista'),
    ('Tapabocas caja 50', 'ProtecSalud',
     'Proteccion', 18000.00, 'Insumos Clinicos'),
    ('Guantes nitrilo caja 100', 'ProtecSalud',
     'Proteccion', 32500.00, 'Insumos Clinicos'),
    ('Termometro digital', 'MediTech',
     'Dispositivos', 24500.00, 'Insumos Clinicos'),
    ('Gasa esteril paquete', 'ProtecSalud',
     'Curaciones', 3500.00, 'Insumos Clinicos')
) AS d(nombre, marca, categoria, precio, proveedor)
INNER JOIN proveedor p
    ON p.nombre = d.proveedor;

-- =============================================
-- 5. ENTREGAS: 12 REGISTROS
-- =============================================

INSERT INTO entrega (
    fecha_entrega, id_proveedor
)
SELECT
    d.fecha,
    p.id_proveedor
FROM (
    VALUES
    ('Distribuidora Andina', DATE '2026-09-15'),
    ('Distribuidora Andina', DATE '2026-10-28'),
    ('Farma Central', DATE '2026-09-15'),
    ('Farma Central', DATE '2026-10-28'),
    ('Laboratorios del Cafe', DATE '2026-09-15'),
    ('Laboratorios del Cafe', DATE '2026-10-28'),
    ('Salud Integral', DATE '2026-09-15'),
    ('Salud Integral', DATE '2026-10-28'),
    ('Drogueria Mayorista', DATE '2026-09-15'),
    ('Drogueria Mayorista', DATE '2026-10-28'),
    ('Insumos Clinicos', DATE '2026-09-15'),
    ('Insumos Clinicos', DATE '2026-10-28')
) AS d(proveedor, fecha)
INNER JOIN proveedor p
    ON p.nombre = d.proveedor;

-- =============================================
-- 6. LOTES: 35 REGISTROS
-- =============================================

-- Inicialmente el stock coincide con
-- la cantidad recibida de cada lote.

INSERT INTO lote (
    codigo_lote,
    fecha_vencimiento,
    cantidad_recibida,
    cantidad_stock,
    id_producto,
    id_entrega
)
SELECT
    d.codigo,
    d.vencimiento,
    d.cantidad,
    d.cantidad,
    p.id_producto,
    e.id_entrega
FROM (
    VALUES
    ('L001', 'Acetaminofen 500 mg',
     DATE '2026-09-15', DATE '2027-03-31', 60),
    ('L002', 'Ibuprofeno 400 mg',
     DATE '2026-10-28', DATE '2027-04-30', 50),
    ('L003', 'Loratadina 10 mg',
     DATE '2026-09-15', DATE '2027-05-31', 40),
    ('L004', 'Omeprazol 20 mg',
     DATE '2026-10-28', DATE '2027-06-30', 50),
    ('L005', 'Amoxicilina 500 mg',
     DATE '2026-09-15', DATE '2027-07-31', 40),
    ('L006', 'Azitromicina 500 mg',
     DATE '2026-10-28', DATE '2027-02-28', 30),
    ('L007', 'Naproxeno 250 mg',
     DATE '2026-09-15', DATE '2026-10-31', 40),
    ('L008', 'Metformina 850 mg',
     DATE '2026-10-28', DATE '2027-09-30', 80),
    ('L009', 'Losartan 50 mg',
     DATE '2026-09-15', DATE '2026-11-15', 25),
    ('L010', 'Enalapril 10 mg',
     DATE '2026-10-28', DATE '2027-08-31', 50),
    ('L011', 'Vitamina C 500 mg',
     DATE '2026-09-15', DATE '2027-11-30', 60),
    ('L012', 'Suero oral 500 ml',
     DATE '2026-10-28', DATE '2027-02-28', 40),
    ('L013', 'Antiacido 200 ml',
     DATE '2026-09-15', DATE '2027-05-31', 35),
    ('L014', 'Alcohol antiseptico 70',
     DATE '2026-10-28', DATE '2027-04-30', 60),
    ('L015', 'Agua oxigenada 120 ml',
     DATE '2026-09-15', DATE '2027-04-30', 40),
    ('L016', 'Gel antibacterial 250 ml',
     DATE '2026-10-28', DATE '2027-01-31', 35),
    ('L017', 'Tapabocas caja 50',
     DATE '2026-09-15', DATE '2026-10-31', 30),
    ('L018', 'Guantes nitrilo caja 100',
     DATE '2026-10-28', DATE '2027-12-31', 35),
    ('L019', 'Termometro digital',
     DATE '2026-09-15', DATE '2027-10-31', 20),
    ('L020', 'Gasa esteril paquete',
     DATE '2026-10-28', DATE '2027-12-31', 3),
    ('L021', 'Acetaminofen 500 mg',
     DATE '2026-10-28', DATE '2026-12-31', 30),
    ('L022', 'Ibuprofeno 400 mg',
     DATE '2026-09-15', DATE '2026-10-31', 40),
    ('L023', 'Loratadina 10 mg',
     DATE '2026-10-28', DATE '2027-01-31', 35),
    ('L024', 'Omeprazol 20 mg',
     DATE '2026-09-15', DATE '2027-03-31', 20),
    ('L025', 'Amoxicilina 500 mg',
     DATE '2026-10-28', DATE '2027-02-28', 40),
    ('L026', 'Azitromicina 500 mg',
     DATE '2026-09-15', DATE '2026-10-31', 20),
    ('L027', 'Naproxeno 250 mg',
     DATE '2026-10-28', DATE '2027-08-31', 40),
    ('L028', 'Metformina 850 mg',
     DATE '2026-09-15', DATE '2026-10-31', 45),
    ('L029', 'Losartan 50 mg',
     DATE '2026-10-28', DATE '2027-06-30', 30),
    ('L030', 'Enalapril 10 mg',
     DATE '2026-09-15', DATE '2027-10-31', 30),
    ('L031', 'Vitamina C 500 mg',
     DATE '2026-10-28', DATE '2027-01-31', 20),
    ('L032', 'Suero oral 500 ml',
     DATE '2026-09-15', DATE '2026-10-31', 50),
    ('L033', 'Antiacido 200 ml',
     DATE '2026-10-28', DATE '2027-09-30', 20),
    ('L034', 'Alcohol antiseptico 70',
     DATE '2026-09-15', DATE '2026-10-31', 30),
    ('L035', 'Agua oxigenada 120 ml',
     DATE '2026-10-28', DATE '2027-08-31', 30)
) AS d(
    codigo, producto, fecha_entrega,
    vencimiento, cantidad
)
INNER JOIN producto p
    ON p.nombre = d.producto
INNER JOIN entrega e
    ON e.id_proveedor = p.id_proveedor
   AND e.fecha_entrega = d.fecha_entrega;

-- =============================================
-- 7. VALIDACIONES ANTES DEL COMMIT
-- =============================================

DO $$
DECLARE
    v_proveedores INTEGER;
    v_clientes INTEGER;
    v_productos INTEGER;
    v_entregas INTEGER;
    v_lotes INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_proveedores
    FROM proveedor;

    SELECT COUNT(*) INTO v_clientes
    FROM cliente;

    SELECT COUNT(*) INTO v_productos
    FROM producto;

    SELECT COUNT(*) INTO v_entregas
    FROM entrega;

    SELECT COUNT(*) INTO v_lotes
    FROM lote;

    IF v_proveedores <> 6
       OR v_clientes <> 20
       OR v_productos <> 20
       OR v_entregas <> 12
       OR v_lotes <> 35 THEN
        RAISE EXCEPTION
            'Conteos incorrectos: %, %, %, %, %',
            v_proveedores,
            v_clientes,
            v_productos,
            v_entregas,
            v_lotes;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM lote l
        INNER JOIN producto p
            ON p.id_producto = l.id_producto
        INNER JOIN entrega e
            ON e.id_entrega = l.id_entrega
        WHERE p.id_proveedor <> e.id_proveedor
           OR l.fecha_vencimiento < e.fecha_entrega
           OR l.cantidad_stock <> l.cantidad_recibida
    ) THEN
        RAISE EXCEPTION
            'Se encontraron lotes inconsistentes';
    END IF;

    RAISE NOTICE
        'Carga validada: 6 proveedores, 20 clientes, 20 productos, 12 entregas y 35 lotes';
END;
$$;

COMMIT;
