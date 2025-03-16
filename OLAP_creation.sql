DROP TABLE IF EXISTS DimUsers CASCADE;
CREATE TABLE DimUsers (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
	user_password VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    registration_date TIMESTAMP NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    current_flag BOOLEAN NOT NULL
);


DROP TABLE IF EXISTS DimCategories CASCADE;
CREATE TABLE DimCategories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);


DROP TABLE IF EXISTS DimProducts CASCADE;
CREATE TABLE DimProducts (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    category_id INT NOT NULL,
    brand VARCHAR(50) NOT NULL,
    stock_quantity INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
	order_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES DimCategories(category_id),
	FOREIGN KEY (order_id) REFERENCES DimOrders(order_id)
);


DROP TABLE IF EXISTS DimOrders CASCADE;
CREATE TABLE DimOrders (
    order_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES DimUsers(user_id)
);


DROP TABLE IF EXISTS DimOrderDetails CASCADE;
CREATE TABLE DimOrderDetails (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES DimOrders(order_id),
    FOREIGN KEY (product_id) REFERENCES DimProducts(product_id)
);


DROP TABLE IF EXISTS DimReviews CASCADE;
CREATE TABLE DimReviews (
    review_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating SMALLINT NOT NULL,
    review_comments TEXT NOT NULL,
    review_date TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES DimUsers(user_id),
    FOREIGN KEY (product_id) REFERENCES DimProducts(product_id)
);


DROP TABLE IF EXISTS DimCarts CASCADE;
CREATE TABLE DimCarts (
    cart_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES DimUsers(user_id)
);


DROP TABLE IF EXISTS DimCartDetails CASCADE;
CREATE TABLE DimCartDetails (
    cart_detail_id SERIAL PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES DimCarts(cart_id),
    FOREIGN KEY (product_id) REFERENCES DimProducts(product_id)
);


DROP TABLE IF EXISTS DimPayments CASCADE;
CREATE TABLE DimPayments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES DimOrders(order_id)
);


DROP TABLE IF EXISTS FactSales CASCADE;
CREATE TABLE FactSales (
    fact_sales_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    quantity INT NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES DimOrders(order_id),
    FOREIGN KEY (product_id) REFERENCES DimProducts(product_id),
    FOREIGN KEY (user_id) REFERENCES DimUsers(user_id)
);


DROP TABLE IF EXISTS FactPayments CASCADE;
CREATE TABLE FactPayments (
    fact_payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES DimOrders(order_id)
);

-- Example of filling DimUsers - SCD Type 2
INSERT INTO DimUsers (user_id, first_name, last_name, email, user_password, address, phone, registration_date, start_date, end_date, current_flag)
SELECT user_id, first_name, last_name, email, user_password, address, phone, registration_date, CURRENT_TIMESTAMP, NULL, TRUE FROM Users;

-- Example of filling DimCategories
INSERT INTO DimCategories (category_id, category_name)
SELECT category_id, category_name FROM Categories;

-- Example of filling DimProducts
INSERT INTO DimProducts (product_id, product_name, description, price, category_id, brand, stock_quantity, image_url, order_id)
SELECT p.product_id, p.product_name, p.description, p.price, p.category_id, p.brand, p.stock_quantity, p.image_url, p.order_id
FROM Products p
JOIN DimOrders o ON p.order_id = o.order_id;

-- Example of filling DimOrders
INSERT INTO DimOrders (order_id, user_id, order_date, status, total_amount)
SELECT o.order_id, u.user_id, o.order_date, o.status, o.total_amount
FROM Orders o
JOIN DimUsers u ON o.user_id = u.user_id AND u.current_flag = TRUE;

-- Example of filling DimOrderDetails
INSERT INTO DimOrderDetails (order_detail_id, order_id, product_id, quantity, price)
SELECT order_detail_id, order_id, product_id, quantity, price
FROM OrderDetails;

-- Example of filling DimReviews
INSERT INTO DimReviews (review_id, user_id, product_id, rating, review_comments, review_date)
SELECT r.review_id, u.user_id, r.product_id, r.rating, r.review_comments, r.review_date
FROM Reviews r
JOIN DimUsers u ON r.user_id = u.user_id AND u.current_flag = TRUE;

-- Example of filling DimCarts
INSERT INTO DimCarts (cart_id, user_id)
SELECT c.cart_id, u.user_id
FROM Carts c
JOIN DimUsers u ON c.user_id = u.user_id AND u.current_flag = TRUE;

-- Example of filling DimCartDetails
INSERT INTO DimCartDetails (cart_detail_id, cart_id, product_id, quantity)
SELECT cart_detail_id, cart_id, product_id, quantity
FROM CartDetails;

-- Example of filling DimPayments
INSERT INTO DimPayments (payment_id, order_id, payment_date, amount, payment_method, status)
SELECT payment_id, order_id, payment_date, amount, payment_method, status
FROM Payments;

-- Example of filling FactSales
INSERT INTO FactSales (order_id, product_id, user_id, quantity, total_amount)
SELECT od.order_id, od.product_id, ud.user_id, od.quantity, od.price
FROM OrderDetails od
JOIN Orders o ON od.order_id = o.order_id
JOIN DimUsers ud ON o.user_id = ud.user_id AND ud.current_flag = TRUE;

-- Example of filling FactPayments
INSERT INTO FactPayments (order_id, payment_date, amount, payment_method, status)
SELECT p.order_id, p.payment_date, p.amount, p.payment_method, p.status
FROM Payments p
JOIN DimOrders dorder ON p.order_id = dorder.order_id;

-- Example of trigger for SCD Type 2 processing for user
CREATE OR REPLACE FUNCTION scd_user_dimension_trigger() RETURNS TRIGGER AS $$
 BEGIN
     IF (TG_OP = 'UPDATE') THEN
         -- Marking an old post as outdated
         UPDATE DimUsers
         SET end_date = CURRENT_TIMESTAMP, current_flag = FALSE
         WHERE user_id = NEW.user_id AND current_flag = TRUE;

         -- Adding a new entry
         INSERT INTO DimUsers (user_id, first_name, last_name, email, user_password, address, phone, registration_date, start_date, end_date, current_flag)
         VALUES (NEW.user_id, NEW.first_name, NEW.last_name, NEW.email, NEW.user_password, NEW.address, NEW.phone, NEW.registration_date, CURRENT_TIMESTAMP, NULL, TRUE);

         RETURN NEW;
     ELSIF (TG_OP = 'INSERT') THEN
         -- Adding a new entry
         INSERT INTO DimUsers (user_id, first_name, last_name, email, user_password, address, phone, registration_date, start_date, end_date, current_flag)
         VALUES (NEW.user_id, NEW.first_name, NEW.last_name, NEW.email, NEW.user_password, NEW.address, NEW.phone, NEW.registration_date, CURRENT_TIMESTAMP, NULL, TRUE);

         RETURN NEW;
     END IF;
   RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

-- Create a trigger to update SCD Type 2 for a user
CREATE TRIGGER scd_user_dimension_trigger
AFTER INSERT OR UPDATE ON Users
FOR EACH ROW
EXECUTE FUNCTION scd_user_dimension_trigger();