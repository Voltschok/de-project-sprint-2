DROP TABLE IF EXISTS public.shipping_transfer cascade;
DROP TABLE IF EXISTS public.shipping_agreement cascade;
DROP TABLE IF EXISTS public.shipping_country_rates cascade;
DROP TABLE IF EXISTS public.shipping_status cascade;
DROP TABLE IF EXISTS public.shipping_info cascade;
 
 

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
	shipping_id int8 PRIMARY KEY,
	shipping_status text NULL,
	shipping_state text NULL,
	shipping_start_fact_datetime timestamp NULL,
	shipping_end_fact_datetime timestamp NULL 
 );
 
CREATE TABLE public.shipping_info(
	 
	shipping_id int8 not null PRIMARY KEY,
	vendor_id int8 NULL,
	payment_amount numeric(14,3) NULL,
	shipping_plan_datetime timestamp NULL,
	shipping_transfer_id int8 NULL,
	shipping_agreement_id int8 NULL,
	shipping_country_rate_id int8 NULL,
 
 	FOREIGN KEY (shipping_transfer_id) REFERENCES public.shipping_transfer(transfer_type_id) ON UPDATE CASCADE,
 	FOREIGN KEY (shipping_country_rate_id) REFERENCES public.shipping_country_rates(id) ON UPDATE CASCADE,
	FOREIGN KEY (shipping_agreement_id ) REFERENCES public.shipping_agreement(agreement_id) ON UPDATE CASCADE
);
