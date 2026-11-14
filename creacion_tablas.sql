
-- =============================================
-- Taller III - Sistema de gestion de drogueria
-- Universidad de Manizales
-- Integrantes: Kevinn Cuervo y Stiven Hernandez
-- PostgreSQL 18
-- =============================================

-- Archivo: creacion_tablas.sql
-- Creacion inicial de las nueve tablas

-- Tabla 1: proveedor
CREATE TABLE proveedor (
    id_proveedor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo_electronico VARCHAR(120),
    direccion VARCHAR(200)
);

-- Tabla 2: cliente
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    tipo_identificacion VARCHAR(20) NOT NULL,
    identificacion VARCHAR(30) NOT NULL
);

-- Tabla 3: producto
CREATE TABLE producto (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    marca VARCHAR(80),
    categoria VARCHAR(80),
    precio_unitario NUMERIC(12,2) NOT NULL,
    id_proveedor INTEGER NOT NULL
);

-- Tabla 4: entrega
CREATE TABLE entrega (
    id_entrega SERIAL PRIMARY KEY,
    fecha_entrega DATE NOT NULL,
    id_proveedor INTEGER NOT NULL
);

-- Tabla 5: lote
CREATE TABLE lote (
    id_lote SERIAL PRIMARY KEY,
    codigo_lote VARCHAR(50) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    cantidad_recibida INTEGER NOT NULL,
    cantidad_stock INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    id_entrega INTEGER NOT NULL
);

-- Tabla 6: venta
CREATE TABLE venta (
    id_venta SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    id_cliente INTEGER NOT NULL
);

-- Tabla 7: detalle_venta
CREATE TABLE detalle_venta (
    id_detalle SERIAL PRIMARY KEY,
    id_venta INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad_comprada INTEGER NOT NULL,
    precio_unitario NUMERIC(12,2) NOT NULL
);

-- Tabla 8: detalle_lote_venta
CREATE TABLE detalle_lote_venta (
    id_distribucion SERIAL PRIMARY KEY,
    id_detalle INTEGER NOT NULL,
    id_lote INTEGER NOT NULL,
    cantidad_descontada INTEGER NOT NULL
);

-- Tabla 9: factura
CREATE TABLE factura (
    id_factura SERIAL PRIMARY KEY,
    id_venta INTEGER NOT NULL,
    tipo_factura VARCHAR(20) NOT NULL,
    prefijo VARCHAR(20) NOT NULL,
    numero_factura VARCHAR(30) NOT NULL
);
