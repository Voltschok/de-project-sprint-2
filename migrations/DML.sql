INSERT INTO public.shipping_transfer(transfer_type, transfer_model, shipping_transfer_rate)
SELECT DISTINCT std.shipping_transfer_char[1]::varchar(20) AS transfer_type,
	   std.shipping_transfer_char[2]::text AS transfer_model,
	    
	   s.shipping_transfer_rate  
FROM (
SELECT  *, regexp_split_to_array(shipping_transfer_description, ':+') AS shipping_transfer_char
FROM public.shipping s) AS std
JOIN public.shipping s ON std.id =s.id;



INSERT INTO public.shipping_agreement (agreement_id, agreement_number, agreement_rate, agreement_commission   )
SELECT agreement_char[1]::bigint  AS agreement_id,
	   agreement_char[2]::varchar(20) AS agreement_number,
	   agreement_char [3]::numeric(14, 3) AS agreement_rate,
	   agreement_char [4]::numeric(14, 3) AS agreement_commission
FROM (
SELECT  DISTINCT regexp_split_to_array(vendor_agreement_description, ':+') AS agreement_char
FROM public.shipping s) AS rsta;

INSERT INTO public.shipping_country_rates (shipping_country, shipping_country_base_rate)
SELECT DISTINCT shipping_country, shipping_country_base_rate
FROM public.shipping s;
 
INSERT INTO public.shipping_status
(shipping_id, shipping_status, shipping_state, shipping_start_fact_datetime, shipping_end_fact_datetime)
WITH vl1 AS  (
select distinct shippingid, 
FIRST_VALUE (status) OVER (PARTITION BY shippingid ORDER BY state_datetime DESC) as shipping_status,
FIRST_VALUE (state) OVER (PARTITION BY shippingid ORDER BY state_datetime DESC) as shipping_state
FROM shipping), 
vl2 as (select distinct shippingid,  
min(CASE WHEN state = 'booked' THEN state_datetime END) AS shipping_start_fact_datetime,
max(CASE WHEN state = 'recieved' THEN state_datetime END) AS shipping_end_fact_datetime 
from shipping group by shippingid)
SELECT  vl1.shippingid, vl1.shipping_status, vl1.shipping_state, 
vl2.shipping_start_fact_datetime, vl2.shipping_end_fact_datetime
FROM vl1
LEFT JOIN vl2 ON vl1.shippingid=vl2.shippingid;
 

INSERT INTO public.shipping_info(
					shipping_id , 
					vendor_id, 
					payment_amount,
					shipping_plan_datetime,
 					shipping_transfer_id,
 					shipping_agreement_id,
 					shipping_country_rate_id) 
SELECT  distinct v1.shippingid , 
		v1.vendorid, 
		v1.payment_amount,
		v1.shipping_plan_datetime,
		str.transfer_type_id AS shipping_transfer_id,
		shipping_agreement_id::int,
 		scr.id AS shipping_country_rate_id
FROM (
SELECT  shippingid , vendorid, payment_amount, shipping_plan_datetime,shipping_country, shipping_transfer_description,
	(regexp_split_to_array(shipping_transfer_description, ':+'))[1]  AS transfer_char,
	(regexp_split_to_array(vendor_agreement_description, ':+'))[1]  AS shipping_agreement_id
FROM public.shipping)     AS v1
LEFT JOIN public.shipping_transfer str ON v1.shipping_transfer_description=str.transfer_type||':'||str.transfer_model
LEFT JOIN public.shipping_country_rates scr ON v1.shipping_country=scr.shipping_country;

 
create or replace view public.shipping_datamart  as
SELECT distinct psi1.shipping_id,
	vendor_id, 
	str1.transfer_type, 
 	EXTRACT (DAY FROM (pss.shipping_end_fact_datetime - pss.shipping_start_fact_datetime))  AS  full_day_at_shipping,
	CASE WHEN  pss.shipping_end_fact_datetime>psi1.shipping_plan_datetime
	THEN 1  ELSE 0 	END AS is_delay,
	CASE WHEN pss.shipping_status='finished'
	THEN 1  ELSE 0 	END AS is_shipping_finish,
	CASE WHEN pss.shipping_end_fact_datetime>psi1.shipping_plan_datetime
	then EXTRACT (DAY FROM (pss.shipping_end_fact_datetime - psi1.shipping_plan_datetime)) 
	ELSE 0  END AS delay_day_at_shipping,
	psi1.payment_amount,
	psi1.payment_amount*(scr.shipping_country_base_rate+sag.agreement_rate+str1.shipping_transfer_rate) AS vat,
	psi1.payment_amount*sag.agreement_commission AS profit
FROM public.shipping_info psi1
LEFT JOIN public.shipping_transfer AS str1 ON str1.transfer_type_id=psi1.shipping_transfer_id
LEFT JOIN public.shipping_status AS pss ON pss.shipping_id=psi1.shipping_id 
LEFT JOIN public.shipping_country_rates AS scr ON scr.id=psi1.shipping_country_rate_id
LEFT JOIN public.shipping_agreement  AS sag ON sag.agreement_id=psi1.shipping_agreement_id;

 

