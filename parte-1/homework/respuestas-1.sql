-- ## Semana 1 - Parte A


-- 1. Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
select * from stg.product_master where category = 'Electro'

-- 2. Cuales son los producto producidos en China?
select name, origin from stg.product_master where origin= 'China'

-- 3. Mostrar todos los productos de Electro ordenados por nombre.
select name, category from stg.product_master where category = 'Electro' order by 1 asc

-- 4. Cuales son las TV que se encuentran activas para la venta?
select * from stg.product_master where subcategory = 'TV' and is_active = 'true'

-- 5. Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
select * from stg.store_master where country = 'Argentina' order by start_date asc

-- 6. Cuales fueron las ultimas 5 ordenes de ventas?
select * from stg.order_line_sale order by date desc limit 5

-- 7. Mostrar los primeros 10 registros de el conteo de trafico por Super store ordenados por fecha.
select * from stg.super_store_count order by date desc limit 10

-- 8. Cuales son los producto de electro que no son Soporte de TV ni control remoto.
select * from stg.product_master where category ='Electro' and subsubcategory not in ('TV','Control remoto')

-- 9. Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
select * from stg.order_line_sale where sale > 100000 and currency ='ARS'

-- 10. Mostrar todas las lineas de ventas de Octubre 2022.
select * from stg.order_line_sale where cast(date as varchar) like '2022-10-%'
--between '2022-10-01' and '2022-10-31'

-- 11. Mostrar todos los productos que tengan EAN.
select * from stg.product_master where ean is not null

-- 12. Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
select * from stg.order_line_sale where date between '2022-10-01' and '2022-11-10'

-- ## Semana 1 - Parte B

-- 1. Cuales son los paises donde la empresa tiene tiendas?
select distinct country from stg.store_master

-- 2. Cuantos productos por subcategoria tiene disponible para la venta?
select subcategory, count(subcategory) from stg.product_master 
where is_active = 'true' group by subcategory

-- 3. Cuales son las ordenes de venta de Argentina de mayor a $100.000?
select * 
from stg.order_line_sale a
left join stg.store_master b
on a.store=b.store_id
where sale > 100000
-- 4. Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
select currency, sum(promotion) as total_promotion
from stg.order_line_sale 
where cast(date as varchar) like '2022-11-%'
group by currency

-- 5. Obtener los impuestos pagados en Europa durante el 2022.
select currency, sum(tax) as total_tax
from stg.order_line_sale 
where cast(date as varchar) like '2022-%' and currency = 'EUR'
group by currency

-- 6. En cuantas ordenes se utilizaron creditos?
select count(*) from stg.order_line_sale where credit is not null

-- 7. Cual es el % de descuentos otorgados (sobre las ventas) por tienda?	
select distinct store, round(((sum(promotion) / sum(sale)) * 100),2) as Promotion
from stg.order_line_sale
group by store

-- 8. Cual es el inventario promedio por dia que tiene cada tienda?
SELECT store_id, date, round(avg(initial+final),2) as avg_inventory
from stg.inventory
group by store_id, date

-- 9. Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
select distinct
	product
	, round(coalesce((sale-promotion-tax),sale),2) as ventas_netas
	, coalesce(round(((promotion/sale)*100),2),0) as descuento_venta
from stg.order_line_sale
where currency ='ARS'

-- 10. Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa para contar la cantidad de gente que ingresa a tienda,
--uno para las tiendas de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
select store_id, to_char(to_date(date::text, 'YYYYMMDD'),'YYYY-MM-DD') as date, traffic
from stg.market_count
union all
select * from stg.super_store_count


-- 11. Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
select name from stg.product_master where is_active = 'true' and name like '%PHILIPS%'

-- 12. Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal de las ventas (sin importar la moneda).
select store, currency, sum(sale)
from stg.order_line_sale
group by store, currency
order by sum(sale) desc

-- 13. Cual es el precio promedio de venta de cada producto en las distintas monedas? Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
select product, currency, round(avg(sale),2) as precio_promedio
from stg.order_line_sale
group by product, currency
order by 1

-- 14. Cual es la tasa de impuestos que se pago por cada orden de venta?
select order_number, coalesce(round(((tax/sale) * 100),2),0) as tasa_impuestos
from stg.order_line_sale
group by order_number, tax, sale

-- ## Semana 2 - Parte A

-- 1. Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, mostrando la leyenda "Unknown" cuando no hay un color disponible
select 
	name
	, product_code
	, category
	, coalesce(color, 'Unknown') as color
from stg.product_master
where name like '%PHILIPS%' or name like '%SAMSUNG%'

-- 2. Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
select distinct
	b.country
	, b.province
	, a.currency
	, round(sum(a.sale),2) as ventas_brutas
	, round(sum(a.tax),2) as total_impuestos
from stg.order_line_sale a
left join stg.store_master b
on a.store=b.store_id
group by 1, 2, 3

-- 3. Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
select distinct
	b.subcategory
	, a.currency
	, round(sum(a.sale),2) as ventas_totales
from stg.order_line_sale a
left join stg.product_master b
on a.product=b.product_code
group by 1,2
order by 1,2

-- 4. Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; 
--usar guion como separador y usarla para ordernar el resultado.
select
	b.subcategory
	,sum(a.quantity) as unidades_vendidas
	, concat(c.country,'-',c.province) as pais_provincia
from stg.order_line_sale a
left join stg.product_master b on a.product=b.product_code
left join stg.store_master c on a.store=c.store_id
group by 1, 3
order by 3
  
-- 5. Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de apertura para el sistema "super_store".
select 
	b.name
	, sum(traffic) as cantidad_entradas
from stg.super_store_count a
left join stg.store_master b on a.store_id=b.store_id
where cast(a.date as date) >= b.start_date
group by a.store_id, b.name
 
-- 6. Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
  
-- 7. Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.
select 
	case 
		when material is null then 'Unkown'
		else initcap(material)
	end
	, sum(quantity) as unidades_vendidas
from stg.product_master a
left join stg.order_line_sale b
on a.product_code=b.product
group by 
	case 
		when material is null then 'Unkown'
		else initcap(material)
	end
	
-- 8. Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta en cada linea convertido a dolares usando la tabla de tipo de cambio.
select 
	a.*
	, case 
		when currency = 'EUR' then ((a.quantity * a.sale)* fx_rate_usd_eur) 
		when currency = 'ARS' then ((a.quantity * a.sale)* fx_rate_usd_peso) 
		else ((a.quantity * a.sale)* fx_rate_usd_uru)
	 end as ventas_brutas_USD
from stg.order_line_sale a
left join stg.monthly_average_fx_rate b
on a.date=b.month

-- 9. Calcular cantidad de ventas totales de la empresa en dolares.
select 
	sum(
	case 
		when currency = 'EUR' then ((a.quantity * a.sale)* fx_rate_usd_eur) 
		when currency = 'ARS' then ((a.quantity * a.sale)* fx_rate_usd_peso) 
		else ((a.quantity * a.sale)* fx_rate_usd_uru)
	 end )as ventas_brutas_USD
from stg.order_line_sale a
left join stg.monthly_average_fx_rate b
on a.date=b.month
-- 10. Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - descuento) - costo expresado en dolares.
select 
	a.*
	, case 
		when currency = 'EUR' then ( ((a.sale - coalesce(a.promotion, 0))- costo) * fx_rate_usd_eur ) 
		when currency = 'ARS' then ((a.quantity * a.sale)* fx_rate_usd_peso) 
		else ((a.quantity * a.sale)* fx_rate_usd_uru)
	 end as ventas_brutas_USD
from stg.order_line_sale a
left join stg.monthly_average_fx_rate b
on a.date=b.month
-- 11. Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
select distinct
	a. order_number
	, b.subcategory
	, count(a.product) as cantidad_items
from stg.order_line_sale a
left join stg.product_master b on a.product = b.product_code
group by 1,2
order by 1

-- ## Semana 2 - Parte B


-- 1. Crear un backup de la tabla product_master. Utilizar un esquema llamada "bkp" y agregar un prefijo al nombre de la tabla con la fecha del backup en forma de numero entero.
-- creamos la tabla bakcup
CREATE SCHEMA IF NOT EXISTS bkp;

do $$

declare
	schema_name TEXT := 'bkp';
	table_name TEXT := to_char(now(), 'YYYYMMDD') || '_' || 'product_master';
	full_table_name TEXT := schema_name || '.' || table_name;
BEGIN
EXECUTE 'CREATE SCHEMA IF NOT EXISTS ' || quote_ident(schema_name);	
--CREATE TABLE IF NOT EXISTS bkp.table_name
EXECUTE 'CREATE TABLE ' || quote_ident(full_table_name) || 
' (
    product_code character varying(255) COLLATE pg_catalog."default",
    name character varying(255) COLLATE pg_catalog."default",
    category character varying(255) COLLATE pg_catalog."default",
    subcategory character varying(255) COLLATE pg_catalog."default",
    subsubcategory character varying(255) COLLATE pg_catalog."default",
    material character varying(255) COLLATE pg_catalog."default",
    color character varying(255) COLLATE pg_catalog."default",
    origin character varying(255) COLLATE pg_catalog."default",
    ean bigint,
    is_active boolean,
    has_bluetooth boolean,
    size character varying(255) COLLATE pg_catalog."default"
)
 ';
end $$;
-- introducimos los datos
insert into  bkp."20231205_product_master" 
(select * from stg.product_master)

select * FROM bkp."20231205_product_master"
	
-- 2. Hacer un update a la nueva tabla (creada en el punto anterior) de product_master agregando la leyendo "N/A" para los valores null de material y color. Pueden utilizarse dos sentencias.
update bkp."20231205_product_master"
set material = 'N/A' where material is NULL

update bkp."20231205_product_master"
set color = 'N/A' where color is NULL
  
-- 3. Hacer un update a la tabla del punto anterior, actualizando la columa "is_active", desactivando todos los productos en la subsubcategoria "Control Remoto".
update bkp."20231205_product_master"
set is_active = 'false' where subsubcategory = 'Control remoto'

-- 4. Agregar una nueva columna a la tabla anterior llamada "is_local" indicando los productos producidos en Argentina y fuera de Argentina.
alter table bkp."20231205_product_master"
add is_local varchar(10)

update bkp."20231205_product_master"
set is_local = 'yes' where origin='Argentina'

update bkp."20231205_product_master"
set is_local = 'no' where origin != 'Argentina'
-- 5. Agregar una nueva columna a la tabla de ventas llamada "line_key" que resulte ser la concatenacion de el numero de orden y el codigo de producto.
alter table bkp."20231205_product_master"
add line_key varchar(100)

update bkp."20231205_product_master" a 
set line_key = b.order_number || '_' || b.product 
				from stg.order_line_sale b
			   	where b.product = a.product_code


-- 6. Crear una tabla llamada "employees" (por el momento vacia) que tenga un id (creado de forma incremental), name, surname, start_date, end_name, phone, country, province, store_id, position. Decidir cual es el tipo de dato mas acorde.
CREATE TABLE IF NOT EXISTS stg.employees
(
	id serial ,
	name character varying(255) COLLATE pg_catalog."default",
	surname character varying(255) COLLATE pg_catalog."default",
	start_date date,
	end_name date,
	phone bigint,
	country character varying(255) COLLATE pg_catalog."default",
	province character varying(255) COLLATE pg_catalog."default",
	store_id bigint,
	position character varying(255) COLLATE pg_catalog."default"
)

select * from stg.employees
-- 7. Insertar nuevos valores a la tabla "employees" para los siguientes 4 empleados:
    -- Juan Perez, 2022-01-01, telefono +541113869867, Argentina, Santa Fe, tienda 2, Vendedor.
    -- Catalina Garcia, 2022-03-01, Argentina, Buenos Aires, tienda 2, Representante Comercial
    -- Ana Valdez, desde 2020-02-21 hasta 2022-03-01, España, Madrid, tienda 8, Jefe Logistica
    -- Fernando Moralez, 2022-04-04, España, Valencia, tienda 9, Vendedor.

insert into stg.employees
values  (1,'Juan','Perez','2022-01-01',NULL,541113869867,'Argentina','Santa Fe',2, 'Vendedor'),
		(2,'Catalina','Garcia','2022-03-01',NULL,NULL,'Argentina','Buenos Aires',2, 'Representante Comercial'),
		(3,'Ana','Valdez','2020-02-21','2022-03-01',NULL,'España','Madrid',8, 'Jefe Logistica'),
		(4,'Fernando','Moralez','2022-04-04',NULL,NULL,'España','Valencia',9, 'Vendedor')
)
  
-- 8. Crear un backup de la tabla "cost" agregandole una columna que se llame "last_updated_ts" que sea el momento exacto en el cual estemos realizando el backup en formato datetime.
do $$

declare
	schema_name TEXT := 'bkp';
	table_name TEXT := 'bkp_cost';
	full_table_name TEXT := schema_name || '.' || table_name;
BEGIN
EXECUTE 'CREATE SCHEMA IF NOT EXISTS ' || quote_ident(schema_name);	
--CREATE TABLE IF NOT EXISTS bkp.table_name
EXECUTE 'CREATE TABLE ' || quote_ident(full_table_name) || 
' (
    product_code character varying(10) COLLATE pg_catalog."default",
    product_cost_usd numeric,
	last_updated_ts date
)
 ';
end $$;
-- introducimos los datos
insert into  public."bkp.bkp_cost" 
(select 
 	*,
 	now() as last_updated_ts
 from stg.cost)

select * FROM public."bkp.bkp_cost"  
-- 9. En caso de hacer un cambio que deba revertirse en la tabla order_line_sale y debemos volver la tabla a su estado original, como lo harias? Responder con palabras que sentencia utilizarias. (no hace falta usar codigo)
/*Antes de hacer ningún cambio se debe indicar el comienzo de una transacción con el ocmando BEGIN, después, se aplicará el código necesario para
aplicar cualquier cambio que queramos en la tabla order_line_sale. Si queremos revertir esos cambios, deberemos aplicar el comando ROLLBACK:
Indicando cual es el código o cambios que queremos revertir.*/
