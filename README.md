# Sistema de Gestión de Inventario y Venta de una Droguería

Proyecto académico de **Bases de Datos I — Taller III: Implementación física y SQL**, desarrollado en **PostgreSQL 18** para la **Universidad de Manizales**, programa de Ingeniería de Sistemas y Telecomunicaciones.

**Integrantes:** Kevinn Andrés Cuervo Ríos y Stiven Hernández Pérez.

## Descripción y alcance

El proyecto implementa una base de datos relacional para gestionar proveedores, productos, entregas de mercancía, inventario por lotes y fechas de vencimiento, clientes, ventas y facturación.

Una funcionalidad central es la asignación automática de lotes mediante **FEFO (First Expired, First Out)**. Al registrar un detalle de venta, una función y un trigger de PostgreSQL seleccionan los lotes elegibles próximos a vencer, registran la distribución de unidades vendidas entre lotes y actualizan las existencias.

El alcance es **académico y de base de datos**: no incluye una aplicación web, un sistema de caja ni integración real con servicios de facturación electrónica.

## Tecnologías y herramientas

- **PostgreSQL 18:** modelo físico, restricciones, consultas, vistas, transacciones y PL/pgSQL.
- **pgAdmin 4:** ejecución de scripts y verificación de resultados.
- **Visual Studio Code:** edición de scripts `.sql` y documentación.
- **Git y GitHub:** versionamiento y colaboración del equipo.
- **ChatGPT:** apoyo en la generación de datos sintéticos y en las pruebas NL2SQL, con revisión humana.

## Modelo de datos

El sistema está compuesto por **nueve tablas**:

| Tabla | Propósito |
|---|---|
| `proveedor` | Información de los proveedores. |
| `cliente` | Identificación de los clientes. |
| `producto` | Catálogo, categorías, precios y proveedor asociado. |
| `entrega` | Entregas de mercancía realizadas por proveedores. |
| `lote` | Códigos de lote, vencimientos, cantidades recibidas y existencias. |
| `venta` | Encabezados de las operaciones de venta. |
| `detalle_venta` | Productos, cantidades y precios históricos de cada venta. |
| `detalle_lote_venta` | Distribución de las cantidades vendidas entre lotes. |
| `factura` | Documentos de facturación asociados a ventas. |

Un proveedor puede suministrar varios productos y registrar varias entregas; un producto puede estar asociado con varios lotes; cada venta puede contener varios detalles, y cada detalle puede descontar unidades de uno o más lotes.

El modelo aplica claves primarias y foráneas, restricciones `NOT NULL`, `UNIQUE` y `CHECK`, y acciones referenciales. El atributo `lote.codigo_lote` tiene unicidad global en el sistema.

## Organización académica

El proyecto se estructura en seis partes:

1. **Diseño físico y DDL:** creación de tablas, tipos de datos y sentencias `ALTER TABLE`; explicación de `DROP TABLE` y `TRUNCATE TABLE`.
2. **Restricciones e integridad:** PK, FK, UNIQUE, NOT NULL y CHECK, acciones referenciales y pruebas positivas y negativas.
3. **Datos sintéticos y automatización FEFO:** carga y validación de datos, función, trigger y pruebas del descuento por lotes.
4. **Manipulación de datos y consultas SQL:** escenarios DML, filtros, JOIN, agregaciones, subconsultas y análisis de rendimiento.
5. **Vistas y transacciones:** vistas operativas y escenarios para evaluar las propiedades ACID.
6. **NL2SQL con controles de seguridad:** tres preguntas de negocio, consultas generadas con IA, verificación de solo lectura y contraste semántico.

### Distribución de los doce hitos

| Hito | Responsable | Desarrollo |
|---:|---|---|
| 1 | Kevinn | Inicialización del repositorio. |
| 2 | Kevinn | Creación de las nueve tablas con DDL. |
| 3 | Stiven | Restricciones y acciones referenciales. |
| 4 | Kevinn | Pruebas positivas y negativas de integridad. |
| 5 | Stiven | Datos sintéticos y su validación. |
| 6 | Kevinn | Función y trigger de asignación FEFO. |
| 7 | Stiven | Registro de ventas, distribución por lotes y facturación. |
| 8 | Kevinn | Escenarios DML, consultas básicas y JOIN. |
| 9 | Stiven | Consultas de agregación y agrupamiento. |
| 10 | Kevinn | Subconsultas y análisis `EXPLAIN (ANALYZE, BUFFERS)`. |
| 11 | Stiven | Tres vistas y escenarios de transacciones ACID. |
| 12 | Kevinn | Pruebas NL2SQL y validación general de datos. |

## Archivos del repositorio

Los **17 archivos SQL** están publicados directamente en la **raíz de la rama `main`**. No existe una carpeta `scripts/` para estos archivos.

| Archivo | Contenido |
|---|---|
| [`creacion_tablas.sql`](creacion_tablas.sql) | Creación inicial de las nueve tablas. |
| [`restricciones.sql`](restricciones.sql) | Claves foráneas, restricciones adicionales y acciones referenciales. |
| [`pruebas_positivas.sql`](pruebas_positivas.sql) | Inserciones válidas para probar integridad. |
| [`pruebas_negativas.sql`](pruebas_negativas.sql) | Intentos controlados de violar restricciones. |
| [`datos_sinteticos.sql`](datos_sinteticos.sql) | Carga inicial de registros sintéticos. |
| [`verificacion_datos.sql`](verificacion_datos.sql) | Revisión de datos cargados y su consistencia. |
| [`automatizacion_fefo.sql`](automatizacion_fefo.sql) | Función y trigger para asignación automática de lotes. |
| [`pruebas_fefo.sql`](pruebas_fefo.sql) | Escenarios de validación del método FEFO. |
| [`registro_ventas_facturacion.sql`](registro_ventas_facturacion.sql) | Registro de ventas, detalles y facturas. |
| [`verificacion_ventas_facturacion.sql`](verificacion_ventas_facturacion.sql) | Verificaciones de ventas, lotes y facturación. |
| [`escenarios_dml.sql`](escenarios_dml.sql) | Tres escenarios de manipulación de datos. |
| [`consultas_basicas_joins.sql`](consultas_basicas_joins.sql) | Tres consultas básicas y dos consultas con JOIN. |
| [`consultas_agregacion.sql`](consultas_agregacion.sql) | Diez consultas de agregación y agrupamiento. |
| [`consultas_subconsultas.sql`](consultas_subconsultas.sql) | Cinco subconsultas de negocio. |
| [`analisis_rendimiento.sql`](analisis_rendimiento.sql) | Cinco análisis de planes de ejecución. |
| [`vistas_acid.sql`](vistas_acid.sql) | Tres vistas y escenarios de propiedades ACID. |
| [`nl2sql_validacion.sql`](nl2sql_validacion.sql) | Tres consultas NL2SQL con controles de seguridad. |

Los archivos `.sql` constituyen la implementación reproducible. Las capturas de pgAdmin, las explicaciones académicas, los resultados obtenidos y las salvedades de cada prueba se documentan en el informe que acompaña la entrega.

## Ejecución orientativa en PostgreSQL 18

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/kevinncuervo/Proyecto_drogueria.git
   cd Proyecto_drogueria
   ```

2. Crear una **base de datos de pruebas vacía** y conectarse desde pgAdmin 4.

3. Ejecutar la estructura inicial: `creacion_tablas.sql` y luego `restricciones.sql`.

4. Cargar los datos: `datos_sinteticos.sql`; comprobarlos con `verificacion_datos.sql`.

5. Instalar la automatización mediante `automatizacion_fefo.sql`.

6. Ejecutar las pruebas FEFO y las operaciones de ventas/facturación en el orden adecuado para el entorno de pruebas; consultar `pruebas_fefo.sql`, `registro_ventas_facturacion.sql` y `verificacion_ventas_facturacion.sql`.

7. Revisar por separado `escenarios_dml.sql`, los archivos de consultas, los planes de rendimiento, `vistas_acid.sql` y `nl2sql_validacion.sql`. Las vistas deben crearse antes de las consultas que dependan de ellas.

**Precauciones:** algunas pruebas provocan errores intencionales, generan datos temporales o modifican registros. Se recomienda utilizar una base aislada y revisar cada script antes de ejecutarlo.

No todos los scripts son idempotentes: ejecutarlos repetidamente sobre los mismos datos puede generar conflictos o alterar los conteos.

Las pruebas ACID deben evaluarse según la evidencia y las indicaciones del documento académico; la presencia del script no implica que todos los escenarios se hayan vuelto a ejecutar en otra instalación.

## Consultas, vistas y verificación

La Parte 4 incluye **20 consultas de negocio**: 3 básicas, 2 con `JOIN`, 10 de agregación y 5 subconsultas. Adicionalmente, incluye 5 análisis de rendimiento con `EXPLAIN (ANALYZE, BUFFERS)`.

Las tres vistas son:

| Vista | Información |
|---|---|
| `vw_existencias_producto` | Existencias físicas y vigentes por producto. |
| `vw_detalle_ventas` | Detalle de las ventas, productos y subtotales. |
| `vw_compras_cliente` | Compras y valores acumulados por cliente. |

Según las comprobaciones documentadas para el proyecto, el conjunto de prueba contiene estos registros:

| Tabla | Registros |
|---|---:|
| `proveedor` | 6 |
| `cliente` | 20 |
| `producto` | 20 |
| `entrega` | 12 |
| `lote` | 35 |
| `venta` | 3 |
| `detalle_venta` | 4 |
| `detalle_lote_venta` | 5 |
| `factura` | 3 |

También se documentaron **tres facturas** correspondientes a **$218.700 COP** en ventas sintéticas: una electrónica por $180.700 y dos POS por $38.000 en conjunto.

Estos son resultados del conjunto de prueba documentado, no cifras de producción.

Para comprobar la existencia de las vistas:

```sql
SELECT viewname
FROM pg_views
WHERE schemaname = 'public'
  AND viewname IN (
    'vw_existencias_producto',
    'vw_detalle_ventas',
    'vw_compras_cliente'
  )
ORDER BY viewname;
```

## Validación NL2SQL

Se formularon tres preguntas de negocio diferentes de las consultas de la Parte 4:

1. ¿Qué productos tienen menos de diez unidades vigentes al 15/11/2026 y cuál es su proveedor?
2. ¿Qué lotes de productos vencerán entre el 15/11/2026 y el 15/12/2026, y cuántas unidades físicas quedan en cada uno?
3. ¿Qué proveedores suministran productos que todavía no registran ventas y cuáles son esos productos?

Para cada pregunta se contrastaron el SQL propuesto por la IA, la seguridad de solo lectura y el significado del resultado.

Los prompts, la tabla de auditoría y las capturas de pgAdmin forman parte de la documentación académica.

**Referencia temporal:** las consultas sobre vencimientos e inventario utilizan la fecha explícita **15/11/2026**. Los resultados documentados para esa fecha no representan necesariamente las existencias vigentes de hoy.

## Control de versiones y entrega

Los integrantes versionaron sus contribuciones con Git. El historial de modificaciones, sus autores y los commits están disponibles directamente en GitHub:

- [Historial de commits de la rama main](https://github.com/kevinncuervo/Proyecto_drogueria/commits/main/)
- [Repositorio del proyecto](https://github.com/kevinncuervo/Proyecto_drogueria)

El repositorio contiene los scripts SQL; el **documento académico** con explicaciones y evidencias de ejecución se entrega por separado al docente.

La revisión de las pruebas ACID y de la presentación final de NL2SQL se realiza en ese documento, sin alterar el código que ya se encuentra versionado.