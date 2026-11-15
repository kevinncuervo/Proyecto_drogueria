-- Taller III - Sistema de gestion de drogueria
-- Universidad de Manizales
-- Integrantes: Kevinn Cuervo y Stiven Hernandez
-- PostgreSQL 18
-- Hito 3: Restricciones de integridad
-- Responsable: Stiven Hernandez
-- =============================================

BEGIN;

-- =============================================
-- 1. CLAVES FORANEAS
-- =============================================



-- 1.2. Entrega - Proveedor
ALTER TABLE entrega
ADD CONSTRAINT fk_entrega_proveedor
FOREIGN KEY (id_proveedor)
REFERENCES proveedor(id_proveedor)
ON UPDATE RESTRICT
ON DELETE RESTRICT;

-- 1.3. Lote - Producto
ALTER TABLE lote
ADD CONSTRAINT fk_lote_producto
FOREIGN KEY (id_producto)
REFERENCES producto(id_producto)
ON UPDATE RESTRICT
ON DELETE RESTRICT;

-- 1.4. Lote - Entrega
ALTER TABLE lote
ADD CONSTRAINT fk_lote_entrega
FOREIGN KEY (id_entrega)
REFERENCES entrega(id_entrega)
ON UPDATE RESTRICT
ON DELETE RESTRICT;

-- 1.5. Venta - Cliente
ALTER TABLE venta
ADD CONSTRAINT fk_venta_cliente
FOREIGN KEY (id_cliente)
REFERENCES cliente(id_cliente)
ON UPDATE RESTRICT
ON DELETE RESTRICT;

-- 1.6. Detalle de venta - Venta
ALTER TABLE detalle_venta
ADD CONSTRAINT fk_detalle_venta_venta
FOREIGN KEY (id_venta)
REFERENCES venta(id_venta)
ON UPDATE RESTRICT
ON DELETE RESTRICT;

-- 1.7. Detalle de venta - Producto
ALTER TABLE detalle_venta
ADD CONSTRAINT fk_detalle_venta_producto
FOREIGN KEY (id_producto)
REFERENCES producto(id_producto)
ON UPDATE RESTRICT
ON DELETE RESTRICT;

-- 1.8. Distribucion - Detalle de venta
ALTER TABLE detalle_lote_venta
ADD CONSTRAINT fk_distribucion_detalle
FOREIGN KEY (id_detalle)
REFERENCES detalle_venta(id_detalle)
ON UPDATE RESTRICT
ON DELETE RESTRICT;

-- 1.9. Distribucion - Lote
ALTER TABLE detalle_lote_venta
ADD CONSTRAINT fk_distribucion_lote
FOREIGN KEY (id_lote)
REFERENCES lote(id_lote)
ON UPDATE RESTRICT
ON DELETE RESTRICT;

-- 1.10. Factura - Venta
ALTER TABLE factura
ADD CONSTRAINT fk_factura_venta
FOREIGN KEY (id_venta)
REFERENCES venta(id_venta)
ON UPDATE RESTRICT
ON DELETE RESTRICT;

-- =============================================
-- 2. RESTRICCIONES UNIQUE
-- =============================================

-- 2.1. Documento unico por tipo
ALTER TABLE cliente
ADD CONSTRAINT uq_cliente_identificacion
UNIQUE (tipo_identificacion, identificacion);

-- 2.2. Codigo globalmente unico por lote
ALTER TABLE lote
ADD CONSTRAINT uq_lote_codigo
UNIQUE (codigo_lote);

-- 2.3. Un producto por linea de venta
ALTER TABLE detalle_venta
ADD CONSTRAINT uq_detalle_venta_producto
UNIQUE (id_venta, id_producto);

-- 2.4. Un lote por distribucion de detalle
ALTER TABLE detalle_lote_venta
ADD CONSTRAINT uq_distribucion_detalle_lote
UNIQUE (id_detalle, id_lote);

-- 2.5. Una factura por venta
ALTER TABLE factura
ADD CONSTRAINT uq_factura_venta
UNIQUE (id_venta);

-- 2.6. Numeracion unica por serie
ALTER TABLE factura
ADD CONSTRAINT uq_factura_numeracion
UNIQUE (tipo_factura, prefijo, numero_factura);

-- =============================================
-- 3. RESTRICCIONES CHECK
-- =============================================

-- 3.1. Precio del producto positivo
ALTER TABLE producto
ADD CONSTRAINT ck_producto_precio_positivo
CHECK (precio_unitario > 0);

-- 3.2. Cantidad recibida positiva
ALTER TABLE lote
ADD CONSTRAINT ck_lote_cantidad_recibida
CHECK (cantidad_recibida > 0);

-- 3.3. Stock no negativo
ALTER TABLE lote
ADD CONSTRAINT ck_lote_stock_no_negativo
CHECK (cantidad_stock >= 0);

-- 3.4. Stock no superior a lo recibido
ALTER TABLE lote
ADD CONSTRAINT ck_lote_stock_maximo
CHECK (cantidad_stock <= cantidad_recibida);

-- 3.5. Cantidad comprada positiva
ALTER TABLE detalle_venta
ADD CONSTRAINT ck_detalle_cantidad_positiva
CHECK (cantidad_comprada > 0);

-- 3.6. Precio historico positivo
ALTER TABLE detalle_venta
ADD CONSTRAINT ck_detalle_precio_positivo
CHECK (precio_unitario > 0);

-- 3.7. Cantidad descontada positiva
ALTER TABLE detalle_lote_venta
ADD CONSTRAINT ck_distribucion_cantidad_positiva
CHECK (cantidad_descontada > 0);

-- 3.8. Tipos de factura permitidos
ALTER TABLE factura
ADD CONSTRAINT ck_factura_tipo
CHECK (tipo_factura IN ('POS', 'Electronica'));

COMMIT;