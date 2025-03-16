DROP FUNCTION IF EXISTS load_data_from_csv CASCADE;

-- Function to load data from CSV files
CREATE OR REPLACE FUNCTION load_data_from_csv(
    users_file_path TEXT,
    products_file_path TEXT,
    categories_file_path TEXT,
    orders_file_path TEXT
)
RETURNS VOID AS $$
BEGIN

    -- Create temporary tables
    CREATE TEMP TABLE TempUsers (
        user_id INT,
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        email VARCHAR(100),
        user_password VARCHAR(255),
        address VARCHAR(255),
        phone VARCHAR(15),
        registration_date TIMESTAMP
    );

    CREATE TEMP TABLE TempProducts (
        product_id INT,
        name VARCHAR(100),
        description TEXT,
        price NUMERIC(10, 2),
        category_id INT,
        brand VARCHAR(50),
        stock_quantity INT,
        image_url VARCHAR(255),
        order_id INT
    );

    CREATE TEMP TABLE TempCategories (
        category_id INT,
        category_name VARCHAR(50)
    );

    CREATE TEMP TABLE TempOrders (
        order_id INT,
        user_id INT,
        order_date TIMESTAMP,
        status VARCHAR(20),
        total_amount NUMERIC(10, 2)
    );

    -- Load data into temporary tables
    EXECUTE format('COPY TempUsers (user_id, first_name, last_name, email, user_password, address, phone, registration_date) FROM %L DELIMITER '','' CSV HEADER', users_file_path);
    EXECUTE format('COPY TempProducts (product_id, name, description, price, category_id, brand, stock_quantity, image_url, order_id) FROM %L DELIMITER '','' CSV HEADER', products_file_path);
    EXECUTE format('COPY TempCategories (category_id, category_name) FROM %L DELIMITER '','' CSV HEADER', categories_file_path);
    EXECUTE format('COPY TempOrders (order_id, user_id, order_date, status, total_amount) FROM %L DELIMITER '','' CSV HEADER', orders_file_path);

    -- Insert data into Users table
    INSERT INTO Users (user_id, first_name, last_name, email, user_password, address, phone, registration_date)
    SELECT user_id, first_name, last_name, email, user_password, address, phone, registration_date
    FROM TempUsers
    ON CONFLICT (user_id) DO NOTHING;

    -- Insert data into Categories table
    INSERT INTO Categories (category_id, category_name)
    SELECT category_id, category_name
    FROM TempCategories
    ON CONFLICT (category_id) DO NOTHING;

    -- Insert data into Products table
    INSERT INTO Products (product_id, product_name, description, price, category_id, brand, stock_quantity, image_url, order_id)
    SELECT product_id, name, description, price, category_id, brand, stock_quantity, image_url, order_id
    FROM TempProducts
    ON CONFLICT (product_id) DO NOTHING;

    -- Insert data into Orders table
    INSERT INTO Orders (order_id, user_id, order_date, status, total_amount)
    SELECT order_id, user_id, order_date, status, total_amount
    FROM TempOrders
    ON CONFLICT (order_id) DO NOTHING;

    -- Drop temporary tables
    DROP TABLE TempUsers;
    DROP TABLE TempProducts;
    DROP TABLE TempCategories;
    DROP TABLE TempOrders;

END;
$$ LANGUAGE plpgsql;

-- Call the function with appropriate file paths
SELECT load_data_from_csv('D:\databases\Course_Work\users.csv', 'D:\databases\Course_Work\products.csv', 'D:\databases\Course_Work\categories.csv', 'D:\databases\Course_Work\orders.csv');


SELECT * FROM Users ORDER BY user_id;
SELECT * FROM Categories ORDER BY category_id;
SELECT * FROM Products ORDER BY product_id;
SELECT * FROM Orders ORDER BY order_id;