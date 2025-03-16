CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Create a foreign server that connects to 'datawarehouse'
CREATE SERVER oltp
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'localhost', dbname 'oltp', port '5432');
    
-- Create a user mapping for the current user
CREATE USER MAPPING FOR CURRENT_USER
    SERVER oltp
    OPTIONS (user 'postgres', password '9901113822');

-- Import foreign schema
IMPORT FOREIGN SCHEMA public
FROM SERVER oltp
INTO public;

DROP USER MAPPING FOR CURRENT_USER SERVER oltp;
DROP SERVER oltp CASCADE;


DROP FUNCTION IF EXISTS transferring_data CASCADE;

-- Create a function to transfer data from OLTP to OLAP
CREATE OR REPLACE FUNCTION transferring_data()
RETURNS void AS $$
BEGIN
    -- Transferring data to DimUsers
    INSERT INTO DimUsers (user_id, first_name, last_name, email, user_password, address, phone, registration_date, start_date, end_date, current_flag)
    SELECT user_id, first_name, last_name, email, user_password, address, phone, registration_date, CURRENT_TIMESTAMP, NULL, TRUE
    FROM public.Users
    ON CONFLICT (user_id) DO NOTHING;

    -- Transferring data to DimCategories
    INSERT INTO DimCategories (category_id, category_name)
    SELECT category_id, category_name
    FROM public.Categories
    ON CONFLICT (category_id) DO NOTHING;

    -- Transferring data to DimOrders
    INSERT INTO DimOrders (order_id, user_id, order_date, status, total_amount)
    SELECT o.order_id, u.user_id, o.order_date, o.status, o.total_amount
    FROM public.Orders o
    JOIN DimUsers u ON o.user_id = u.user_id AND u.current_flag = TRUE
    ON CONFLICT (order_id) DO NOTHING;

    -- Transferring data to DimProducts
    INSERT INTO DimProducts (product_id, product_name, description, price, category_id, brand, stock_quantity, image_url, order_id)
    SELECT p.product_id, p.product_name, p.description, p.price, p.category_id, p.brand, p.stock_quantity, p.image_url, p.order_id
    FROM public.Products p
    JOIN public.Orders o ON p.order_id = o.order_id
    ON CONFLICT (product_id) DO NOTHING;

    -- Transferring data to DimOrderDetails
    INSERT INTO DimOrderDetails (order_detail_id, order_id, product_id, quantity, price)
    SELECT order_detail_id, order_id, product_id, quantity, price
    FROM public.OrderDetails
    ON CONFLICT (order_detail_id) DO NOTHING;

    -- Transferring data to DimReviews
    INSERT INTO DimReviews (review_id, user_id, product_id, rating, review_comments, review_date)
    SELECT r.review_id, u.user_id, r.product_id, r.rating, r.review_comments, r.review_date
    FROM public.Reviews r
    JOIN DimUsers u ON r.user_id = u.user_id AND u.current_flag = TRUE
    ON CONFLICT (review_id) DO NOTHING;

    -- Transferring data to DimCarts
    INSERT INTO DimCarts (cart_id, user_id)
    SELECT c.cart_id, u.user_id
    FROM public.Carts c
    JOIN DimUsers u ON c.user_id = u.user_id AND u.current_flag = TRUE
    ON CONFLICT (cart_id) DO NOTHING;

    -- Transferring data to DimCartDetails
    INSERT INTO DimCartDetails (cart_detail_id, cart_id, product_id, quantity)
    SELECT cart_detail_id, cart_id, product_id, quantity
    FROM public.CartDetails
    ON CONFLICT (cart_detail_id) DO NOTHING;

    -- Transferring data to DimPayments
    INSERT INTO DimPayments (payment_id, order_id, payment_date, amount, payment_method, status)
    SELECT payment_id, order_id, payment_date, amount, payment_method, status
    FROM public.Payments
    ON CONFLICT (payment_id) DO NOTHING;

    -- Transferring data to FactSales
    INSERT INTO FactSales (order_id, product_id, user_id, quantity, total_amount)
    SELECT od.order_id, od.product_id, ud.user_id, od.quantity, od.price
    FROM public.OrderDetails od
    JOIN public.Orders o ON od.order_id = o.order_id
    JOIN DimUsers ud ON o.user_id = ud.user_id AND ud.current_flag = TRUE
    ON CONFLICT (fact_sales_id) DO NOTHING;

    -- Transferring data to FactPayments
    INSERT INTO FactPayments (order_id, payment_date, amount, payment_method, status)
    SELECT p.order_id, p.payment_date, p.amount, p.payment_method, p.status
    FROM public.Payments p
    JOIN DimOrders dorder ON p.order_id = dorder.order_id
    ON CONFLICT (fact_payment_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- Call the function to transfer data
SELECT transferring_data();

-- Validating data in OLAP tables
SELECT * FROM DimUsers ORDER BY user_id;
SELECT * FROM DimCategories ORDER BY category_id;
SELECT * FROM DimProducts ORDER BY product_id;
SELECT * FROM DimOrders ORDER BY order_id;
SELECT * FROM DimOrderDetails ORDER BY order_detail_id;
SELECT * FROM DimReviews ORDER BY review_id;
SELECT * FROM DimCarts ORDER BY cart_id;
SELECT * FROM DimCartDetails ORDER BY cart_detail_id;
SELECT * FROM DimPayments ORDER BY payment_id;
SELECT * FROM FactSales ORDER BY fact_sales_id;
SELECT * FROM FactPayments ORDER BY fact_payment_id;