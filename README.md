Sistema de Gestión de Inventario y Venta de una Droguería
Proyecto académico de Bases de Datos I — Taller III: Implementación física y SQL, desarrollado en PostgreSQL 18 para la Universidad de Manizales, programa de Ingeniería de Sistemas y Telecomunicaciones.
Integrantes
- Kevinn Andrés Cuervo Ríos
- Stiven Hernández Pérez
Descripción del proyecto
El proyecto implementa una base de datos relacional para administrar el catálogo de productos de una droguería, sus proveedores, las entregas de mercancía, los lotes y fechas de vencimiento, los clientes, las ventas y la facturación.

Una de sus funcionalidades centrales es la asignación automática de lotes mediante FEFO (First Expired, First Out): al registrar un detalle de venta, una función y un disparador de PostgreSQL seleccionan primero los lotes vigentes cuya fecha de vencimiento es más próxima, registran la distribución y actualizan las existencias correspondientes.

El trabajo incluye implementación física, restricciones y pruebas de integridad, datos sintéticos, automatización, consultas SQL, análisis de rendimiento, vistas, transacciones y validación de SQL generado por inteligencia artificial (NL2SQL).
Alcance: es un proyecto académico de base de datos. No incorpora una aplicación web, un sistema de caja ni integraciones con servicios reales de facturación electrónica.

Tecnologías y herramientas
- PostgreSQL 18: tablas, restricciones, consultas y funciones PL/pgSQL.
- pgAdmin 4: ejecución y validación de scripts, inspección de resultados y planes de ejecución.
- Visual Studio Code: edición y organización de archivos .sql y Markdown.
- Git y GitHub: control de versiones y colaboración.
- ChatGPT: apoyo en la generación de datos sintéticos y en las pruebas de lenguaje natural a SQL, con revisión humana de los resultados.
Modelo de datos
La solución utiliza nueve tablas:
Tabla	Propósito
proveedor	Información de los proveedores de productos.
producto	Catálogo de productos, categorías, precios y proveedor asociado.
entrega	Registro de entregas realizadas por los proveedores.
lote	Lotes recibidos, fechas de vencimiento y cantidades físicas disponibles.
cliente	Identificación de clientes.
venta	Encabezados de las operaciones de venta.
detalle_venta	Productos, cantidades y precios históricos de cada venta.
detalle_lote_venta	Distribución de unidades vendidas entre lotes, utilizada por FEFO.
factura	Documentos de facturación asociados con las ventas.


Relaciones principales
- Un proveedor puede suministrar varios productos y registrar varias entregas.
- Un producto puede estar distribuido en varios lotes; cada lote se relaciona con una entrega.
- Un cliente puede realizar varias ventas.
- Una venta contiene uno o varios detalles de venta.
- Un detalle de venta puede descontar unidades de uno o más lotes, mediante detalle_lote_venta.
- La factura se asocia con la venta correspondiente.
El diseño emplea claves primarias y foráneas, restricciones de unicidad, verificaciones de dominio y acciones referenciales para preservar la integridad de la información.
Organización académica: seis partes y doce hitos
El Taller III se desarrolla en seis partes académicas, distribuidas en doce hitos de trabajo:
Hito	Responsable	Desarrollo
1	Kevinn	Inicialización del repositorio y configuración del proyecto.
2	Kevinn	Creación física de las nueve tablas mediante DDL.
3	Stiven	Restricciones de integridad y acciones referenciales.
4	Kevinn	Pruebas positivas y negativas de integridad.
5	Stiven	Generación, carga y revisión de datos sintéticos.
6	Kevinn	Función y trigger para asignación automática FEFO.
7	Stiven	Registro de ventas, distribución entre lotes y facturación.
8	Kevinn	Tres escenarios DML, consultas básicas y consultas con JOIN.
9	Stiven	Diez consultas de agregación y agrupamiento.
10	Kevinn	Cinco subconsultas y cinco análisis EXPLAIN (ANALYZE, BUFFERS).
11	Stiven	Tres vistas SQL y demostraciones de propiedades ACID.
12	Kevinn	Tres pruebas NL2SQL con IA y validación general de la base de datos.


Parte 1. Diseño físico y DDL
Se implementó el esquema relacional con tipos de datos adecuados de PostgreSQL y convenciones de nombres en minúsculas y snake_case. Se documentaron la creación de tablas y las modificaciones del esquema.
Parte 2. Restricciones e integridad
Se implementaron restricciones PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL y CHECK, junto con las acciones referenciales elegidas para el dominio. Se ejecutaron pruebas de integridad positivas y negativas, registrando los resultados y los errores esperados.
Parte 3. Datos sintéticos y automatización FEFO
Se cargaron datos de prueba para el catálogo, proveedores, clientes, entregas y lotes. La asignación FEFO se implementó mediante:
- Función fn_asignar_lotes_fefo().
- Trigger trg_asignar_lotes_fefo asociado con detalle_venta.
- Registro de cantidades descontadas en detalle_lote_venta.
El objetivo es utilizar primero los lotes no vencidos con vencimiento más próximo, evitando elegir lotes caducados para las ventas.
Parte 4. Manipulación de datos y consultas SQL
Se desarrollaron:
- Tres escenarios DML para operaciones del negocio.
- Tres consultas básicas con filtros u ordenamiento.
- Dos consultas con JOIN.
- Diez consultas de agregación y agrupamiento.
- Cinco subconsultas para resolver preguntas del negocio.
- Cinco pruebas de rendimiento mediante EXPLAIN (ANALYZE, BUFFERS).
Parte 5. Vistas y transacciones
Se diseñaron tres vistas:
Vista	Información que proporciona
vw_existencias_producto	Stock físico y vigente agrupado por producto.
vw_detalle_ventas	Ventas, clientes, productos, cantidades, precios y subtotales.
vw_compras_cliente	Número de ventas y valor total comprado por cliente.


También se prepararon escenarios para ilustrar las propiedades ACID: atomicidad, consistencia, aislamiento y durabilidad, con uso de BEGIN, COMMIT, ROLLBACK y SAVEPOINT, según el escenario. La evidencia de ejecución de cada prueba debe consultarse en la documentación académica.
Parte 6. NL2SQL con controles de seguridad
Se formularon tres preguntas de negocio, se solicitó a ChatGPT traducirlas a SQL y se comprobaron sus resultados mediante consultas de solo lectura en pgAdmin:
Pregunta de negocio	Resultado obtenido	Validación
¿Qué productos tienen menos de 10 unidades vigentes al 15/11/2026 y cuál es su proveedor?	2 productos: Tapabocas caja 50 (0 vigentes) y Gasa esteril paquete (1 vigente).	Correcta; sin cambios.
¿Qué lotes vencen entre el 15/11/2026 y el 15/12/2026 y cuántas unidades físicas tienen?	1 lote: L009, Losartan 50 mg, vencimiento 15/11/2026, 25 unidades físicas.	Correcta; sin cambios.
¿Qué proveedores suministran productos sin ventas registradas y cuáles son esos productos?	16 productos distribuidos entre 6 proveedores.	Correcta; sin cambios.


El análisis incluyó la revisión de la validez sintáctica y semántica, así como la ausencia de instrucciones que modificaran datos. Los prompts, el SQL original producido por la IA, la tabla de auditoría y las capturas de ejecución se documentan en el informe del taller.
Nota sobre fechas: las consultas de inventario usan una fecha de referencia explícita (15/11/2026). Por tanto, sus resultados históricos no equivalen necesariamente al inventario vigente en la fecha actual.

Datos de comprobación
Los siguientes conteos fueron verificados en PostgreSQL durante el Hito 12:
Tabla	Registros	Tabla o vista	Registros
proveedor	6	cliente	20
producto	20	entrega	12
lote	35	venta	3
detalle_venta	4	detalle_lote_venta	5
factura	3	vw_existencias_producto	20
vw_detalle_ventas	4	vw_compras_cliente	20


Como comprobación adicional, las 3 ventas registradas sumaron $218.700 COP y se documentaron 3 facturas: una Electronica por $180.700 y dos POS por un total de $38.000. Son datos sintéticos de prueba.
Archivos SQL y estructura del repositorio
Importante: la estructura exacta debe comprobarse en la rama de Git que se vaya a publicar. En la versión pública consultada durante la revisión, los scripts visibles se encuentran en la raíz, no en una carpeta scripts/. Los archivos de hitos posteriores pueden encontrarse todavía en una copia local o una rama sin publicar.
Scripts visibles en la versión pública revisada
Proyecto_drogueria/
├── README.md
├── creacion_tablas.sql
├── restricciones.sql
├── pruebas_positivas.sql
├── pruebas_negativas.sql
├── datos_sinteticos.sql
├── verificacion_datos.sql
├── automatizacion_fefo.sql
├── pruebas_fefo.sql
├── registro_ventas_facturacion.sql
├── verificacion_ventas_facturacion.sql
├── escenarios_dml.sql
├── consultas_basicas_joins.sql
└── consultas_agregacion.sql
Scripts adicionales desarrollados en los hitos posteriores
Antes de publicar, comprobar sus rutas y nombres reales en la copia local. En el trabajo se utilizaron estos nombres:
- consultas_subconsultas.sql — cinco subconsultas del Hito 10.
- analisis_rendimiento.sql — cinco planes de análisis de rendimiento del Hito 10.
- hito_11_vistas_acid.sql — definición de vistas y pruebas ACID del Hito 11.
- nl2sql_validacion.sql — consultas NL2SQL de IA y validación del Hito 12.
No se presupone que esos cuatro archivos estén publicados en la rama remota consultada. El informe Word/PDF y las capturas pueden conservarse aparte mientras no se incorporen explícitamente al repositorio.
Requisitos para ejecutar el proyecto
1. Tener instalado PostgreSQL 18 y una herramienta de administración como pgAdmin 4.
2. Clonar el repositorio:
   git clone https://github.com/kevinncuervo/Proyecto_drogueria.git
   cd Proyecto_drogueria
3. Crear una base de datos de pruebas en PostgreSQL y abrir su Query Tool.
4. Ejecutar los scripts disponibles siguiendo la dependencia lógica: creación de tablas → restricciones → datos sintéticos → automatización FEFO → pruebas controladas y consultas → vistas. Verificar los nombres y el contenido de cada archivo en la rama utilizada.
5. Ejecutar pruebas DML/FEFO/ACID únicamente en una base de pruebas, porque pueden insertar, modificar, eliminar o revertir datos; algunos escenarios están diseñados para generar errores de integridad de forma intencional.
6. Ejecutar las consultas de informes, rendimiento y NL2SQL para contrastar sus resultados con la documentación. Si algún script define vistas que aún no existen en la base local, crearlas antes de consultar esas vistas.
Advertencia de reproducibilidad: los conteos publicados corresponden al estado validado durante el taller. La ejecución repetida de scripts con inserciones, pruebas DML o modificaciones puede alterar los resultados o provocar conflictos de claves. No se garantiza que todos los scripts puedan ejecutarse consecutivamente varias veces sobre una misma base sin reinicializarla.

Verificaciones SQL rápidas
Comprobar cantidades en tablas principales:
SELECT 'proveedor' AS tabla, COUNT(*) AS registros FROM proveedor
UNION ALL SELECT 'cliente', COUNT(*) FROM cliente
UNION ALL SELECT 'producto', COUNT(*) FROM producto
UNION ALL SELECT 'entrega', COUNT(*) FROM entrega
UNION ALL SELECT 'lote', COUNT(*) FROM lote
UNION ALL SELECT 'venta', COUNT(*) FROM venta
UNION ALL SELECT 'detalle_venta', COUNT(*) FROM detalle_venta
UNION ALL SELECT 'detalle_lote_venta', COUNT(*) FROM detalle_lote_venta
UNION ALL SELECT 'factura', COUNT(*) FROM factura;
Comprobar que están creadas las tres vistas:
SELECT viewname
FROM pg_views
WHERE schemaname = 'public'
  AND viewname IN (
      'vw_existencias_producto',
      'vw_detalle_ventas',
      'vw_compras_cliente'
  )
ORDER BY viewname;
Documentación y evidencias
El informe académico reúne la estructura de la base de datos, las decisiones de integridad, los scripts, los resultados esperados y obtenidos, las pruebas FEFO, las consultas, los planes de ejecución, las vistas, los escenarios ACID y la auditoría NL2SQL.

La evidencia NL2SQL incluye:
- Preguntas originales y prompts enviados a ChatGPT.
- SQL devuelto por la herramienta.
- Capturas de la ejecución en pgAdmin.
- Tabla de auditoría: pregunta | SQL generado por IA | ¿válido? | corrección aplicada.
La validación de conteos y resultados específicos no sustituye la comprobación de todas las reglas de integridad ni la ejecución de todas las demostraciones ACID en cada instalación.
Estado del proyecto
- Hitos 1 a 10: desarrollados y documentados durante el taller.
- Hito 11: scripts de vistas y escenarios ACID desarrollados; las tres vistas fueron verificadas en la base local. La comprobación individual de las cuatro demostraciones ACID debe consultarse en las evidencias del informe.
- Hito 12: tres consultas generadas con IA ejecutadas y contrastadas; validación final de conteos de tablas y vistas completada.
- Publicación en GitHub: pendiente de confirmar la sincronización de todos los archivos locales, el README actualizado y el commit/push de cierre.
Repositorio
github.com/kevinncuervo/Proyecto_drogueria