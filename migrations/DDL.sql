DROP TABLE IF EXISTS public.shipping_transfer;
DROP TABLE IF EXISTS public.shipping_agreement;
DROP TABLE IF EXISTS public.shipping_country_rates;
DROP TABLE IF EXISTS public.shipping_status;
DROP TABLE IF EXISTS public.shipping_info;
DROP TABLE IF EXISTS public.shipping_datamart;

CREATE TABLE public.shipping_transfer(
	transfer_type_id serial not NULL,
	transfer_type varchar(20) NULL,
	transfer_model text NULL,
	shipping_transfer_rate numeric(14, 3) NULL,
	PRIMARY KEY (transfer_type_id)
);

CREATE TABLE public.shipping_agreement (
	agreement_id bigint not NULL,
	agreement_number varchar(20) NULL,
	agreement_rate numeric(14, 3) NULL,
	agreement_commission numeric(14, 3) NULL,
	PRIMARY KEY (agreement_id)
);

CREATE TABLE public.shipping_country_rates (
	id serial not NULL,
	shipping_country text NULL,
	shipping_country_base_rate numeric(14, 3) NULL,
	PRIMARY KEY (id)
);

CREATE TABLE public.shipping_status(
	shipping_id serial not NULL,
	shipping_status text NULL,
	shipping_state text NULL,
	shipping_start_fact_datetime timestamp NULL,
	shipping_end_fact_datetime timestamp NULL,
	PRIMARY KEY (shipping_id) 
 );
 
CREATE TABLE public.shipping_info(
	id serial not NULL,
	shipping_id serial not NULL,
	vendor_id int8 NULL,
	payment_amount numeric(14,3) NULL,
	shipping_plan_datetime timestamp NULL,
	shipping_transfer_id int8 NULL,
	shipping_agreement_id int8 NULL,
	shipping_country_rate_id int8 NULL,
	PRIMARY KEY (id), 
 	FOREIGN KEY (shipping_transfer_id) REFERENCES public.shipping_transfer(transfer_type_id) ON UPDATE CASCADE,
 	FOREIGN KEY (shipping_country_rate_id) REFERENCES public.shipping_country_rates(id) ON UPDATE CASCADE,
	FOREIGN KEY (shipping_agreement_id ) REFERENCES public.shipping_agreement(agreement_id) ON UPDATE CASCADE
);

CREATE TABLE public.shipping_datamart(
	id serial not NULL,
	shipping_id serial not NULL,
	vendor_id int8 NULL,
	transfer_type text NULL,
	full_day_at_shipping numeric NULL,
	is_delay numeric null,
	is_shipping_finish numeric  NULL,
	delay_day_at_shipping numeric NULL,
	payment_amount numeric(14,3) NULL,
	vat  numeric(14,3) NULL,
	profit  numeric(14,3) null,
	PRIMARY KEY (id) 
);


 
 

