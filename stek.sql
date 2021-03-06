--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.1

-- Started on 2022-03-27 15:53:19

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 227 (class 1255 OID 16611)
-- Name: calculate_total_price_for_orders_group(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_total_price_for_orders_group(group_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	is_group text;
	answer integer;
BEGIN
	SELECT group_name INTO is_group FROM orders WHERE row_id = group_id;
	
	IF is_group ISNULL THEN 
		RETURN sum(order_items.price)
		FROM order_items
		WHERE order_items.order_id = group_id;
	ELSE
		WITH RECURSIVE a AS (
			SELECT row_id, parent_id, group_name
			FROM orders
			WHERE parent_id = group_id
			UNION ALL
			SELECT d.row_id, d.parent_id, d.group_name
			FROM orders d
			JOIN a ON a.row_id = d.parent_id )
			
			SELECT sum(price) INTO answer FROM a 
			JOIN order_items ON order_items.order_id = a.row_id
			WHERE group_name ISNULL;
			RETURN answer;
	END IF;
END;
$$;


ALTER FUNCTION public.calculate_total_price_for_orders_group(group_id integer) OWNER TO postgres;

--
-- TOC entry 215 (class 1255 OID 16597)
-- Name: select_orders_by_item_name(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.select_orders_by_item_name(item text) RETURNS TABLE(row_id integer, name_item text, count_item integer)
    LANGUAGE sql
    AS $$
   SELECT orders.row_id, customers.name_customer, COUNT(orders.row_id) AS count_item FROM orders 
	JOIN order_items ON order_items.order_id = orders.row_id 
	JOIN customers ON orders.customer_id = customers.row_id
	WHERE order_items.name_item = item
	GROUP BY orders.row_id, customers.name_customer;
$$;


ALTER FUNCTION public.select_orders_by_item_name(item text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 16499)
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    row_id integer NOT NULL,
    name_customer text NOT NULL
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 16498)
-- Name: customers_row_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_row_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customers_row_id_seq OWNER TO postgres;

--
-- TOC entry 3337 (class 0 OID 0)
-- Dependencies: 209
-- Name: customers_row_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_row_id_seq OWNED BY public.customers.row_id;


--
-- TOC entry 211 (class 1259 OID 16525)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    row_id integer NOT NULL,
    order_id integer NOT NULL,
    name_item text NOT NULL,
    price integer NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16587)
-- Name: order_items_row_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.order_items ALTER COLUMN row_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.order_items_row_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 213 (class 1259 OID 16564)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    row_id integer NOT NULL,
    parent_id integer,
    group_name text,
    customer_id integer,
    registered_at date
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16563)
-- Name: orders_row_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_row_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_row_id_seq OWNER TO postgres;

--
-- TOC entry 3338 (class 0 OID 0)
-- Dependencies: 212
-- Name: orders_row_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_row_id_seq OWNED BY public.orders.row_id;


--
-- TOC entry 3176 (class 2604 OID 16502)
-- Name: customers row_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN row_id SET DEFAULT nextval('public.customers_row_id_seq'::regclass);


--
-- TOC entry 3177 (class 2604 OID 16567)
-- Name: orders row_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN row_id SET DEFAULT nextval('public.orders_row_id_seq'::regclass);


--
-- TOC entry 3327 (class 0 OID 16499)
-- Dependencies: 210
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.customers (row_id, name_customer) VALUES (1, '????????????');
INSERT INTO public.customers (row_id, name_customer) VALUES (2, '????????????');
INSERT INTO public.customers (row_id, name_customer) VALUES (3, '??????????????');
INSERT INTO public.customers (row_id, name_customer) VALUES (4, '???? ??????????????');


--
-- TOC entry 3328 (class 0 OID 16525)
-- Dependencies: 211
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (1, 4, '??????????????', 30);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (2, 4, '????????', 20);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (3, 5, '??????????????', 50);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (4, 5, '???????????????? ??????????????', 40);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (5, 5, '????????', 30);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (6, 6, '???????????????? ??????????????', 30);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (7, 6, '???????????????? ??????????????', 40);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (8, 7, '?????????????????????????? ??????????????', 50);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (9, 7, '??????????????????????', 10);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (10, 7, '???????????????? ??????????????', 60);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (11, 8, '??????????????', 50);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (12, 8, '??????????????????????', 10);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (13, 9, '???????????????????? ??????????????', 50);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (14, 9, '???????????????? ??????????????', 40);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (15, 11, '????????????', 2);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (16, 11, '??????????', 1);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (17, 13, '??????????', 100);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (18, 13, '????????????', 70);
INSERT INTO public.order_items (row_id, order_id, name_item, price) VALUES (19, 13, '????????', 20);


--
-- TOC entry 3330 (class 0 OID 16564)
-- Dependencies: 213
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (1, NULL, '?????? ????????????', NULL, NULL);
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (2, 1, '?????????????? ????????', NULL, NULL);
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (3, 2, '????????????????????', NULL, NULL);
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (4, 3, NULL, 1, '2019-10-02');
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (5, 3, NULL, 1, '2020-05-17');
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (6, 3, NULL, 1, '2020-04-28');
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (7, 3, NULL, 2, '2019-08-05');
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (8, 3, NULL, 2, '2020-05-17');
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (9, 3, NULL, 2, '2020-02-11');
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (10, 2, '????????????????????', NULL, NULL);
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (11, 10, NULL, 3, '2020-04-09');
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (12, 1, '?????????????????????? ????????', NULL, NULL);
INSERT INTO public.orders (row_id, parent_id, group_name, customer_id, registered_at) VALUES (13, 12, NULL, 4, '2020-06-25');


--
-- TOC entry 3339 (class 0 OID 0)
-- Dependencies: 209
-- Name: customers_row_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_row_id_seq', 4, true);


--
-- TOC entry 3340 (class 0 OID 0)
-- Dependencies: 214
-- Name: order_items_row_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_row_id_seq', 19, true);


--
-- TOC entry 3341 (class 0 OID 0)
-- Dependencies: 212
-- Name: orders_row_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_row_id_seq', 13, true);


--
-- TOC entry 3179 (class 2606 OID 16506)
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (row_id);


--
-- TOC entry 3181 (class 2606 OID 16531)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (row_id);


--
-- TOC entry 3183 (class 2606 OID 16571)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (row_id);


--
-- TOC entry 3184 (class 2606 OID 16582)
-- Name: order_items order_items_order_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fk FOREIGN KEY (order_id) REFERENCES public.orders(row_id) NOT VALID;


--
-- TOC entry 3186 (class 2606 OID 16577)
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(row_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3185 (class 2606 OID 16572)
-- Name: orders orders_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.orders(row_id);


-- Completed on 2022-03-27 15:53:20

--
-- PostgreSQL database dump complete
--

