-- Create tables

DROP TABLE IF EXISTS Users CASCADE;
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    user_password VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    registration_date TIMESTAMP NOT NULL
);

DROP TABLE IF EXISTS Categories CASCADE;
CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS Products CASCADE;
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    category_id INT NOT NULL,
    brand VARCHAR(50) NOT NULL,
    stock_quantity INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
	order_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
	FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

DROP TABLE IF EXISTS Orders CASCADE;
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

DROP TABLE IF EXISTS OrderDetails CASCADE;
CREATE TABLE OrderDetails (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

DROP TABLE IF EXISTS Reviews CASCADE;
CREATE TABLE Reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating SMALLINT NOT NULL,
    review_comments TEXT NOT NULL,
    review_date TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

DROP TABLE IF EXISTS Carts CASCADE;
CREATE TABLE Carts (
    cart_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

DROP TABLE IF EXISTS CartDetails CASCADE;
CREATE TABLE CartDetails (
    cart_detail_id SERIAL PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES Carts(cart_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

DROP TABLE IF EXISTS Payments CASCADE;
CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);