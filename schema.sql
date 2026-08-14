create database e_commerce;
use e_commerce;




CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Active','Inactive') DEFAULT 'Active'
);


 CREATE TABLE Addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    house_no VARCHAR(20),
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50) DEFAULT 'India',
    pincode VARCHAR(10),
    address_type ENUM('Home','Office') DEFAULT 'Home',

    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id)
        ON DELETE CASCADE
);



 CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);



 CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,

    product_name VARCHAR(150) NOT NULL,
    description TEXT,

    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,

    sku VARCHAR(50) UNIQUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    status ENUM('Available','Out of Stock','Discontinued')
    DEFAULT 'Available',

    CHECK (price >= 0),

    FOREIGN KEY (category_id)
        REFERENCES Categories(category_id)
);



 CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,

    customer_id INT NOT NULL,
    address_id INT NOT NULL,

    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    total_amount DECIMAL(12,2) DEFAULT 0,

    order_status ENUM(
        'Pending',
        'Confirmed',
        'Packed',
        'Shipped',
        'Delivered',
        'Cancelled',
        'Returned'
    ) DEFAULT 'Pending',

    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    FOREIGN KEY (address_id)
        REFERENCES Addresses(address_id)
);
 CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id INT NOT NULL,
    product_id INT NOT NULL,

    quantity INT NOT NULL,

    unit_price DECIMAL(10,2) NOT NULL,

    subtotal DECIMAL(12,2),

    CHECK (quantity > 0),

    FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
        ON DELETE CASCADE,

    FOREIGN KEY (product_id)
        REFERENCES Products(product_id)
);



 CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id INT NOT NULL UNIQUE,

    payment_method ENUM(
        'UPI',
        'Card',
        'Net Banking',
        'Cash On Delivery',
        'Wallet'
    ),

    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    amount DECIMAL(12,2),

    payment_status ENUM(
        'Pending',
        'Completed',
        'Failed',
        'Refunded'
    ) DEFAULT 'Pending',

    transaction_reference VARCHAR(100),

    FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
);



CREATE TABLE Shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id INT NOT NULL UNIQUE,

    tracking_number VARCHAR(100) UNIQUE,

    courier_name VARCHAR(100),

    shipment_date DATETIME,

    delivery_date DATETIME,

    shipment_status ENUM(
        'Ready',
        'In Transit',
        'Delivered',
        'Lost',
        'Returned'
    ) DEFAULT 'Ready',

    FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
);



 CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,

    customer_id INT NOT NULL,
    product_id INT NOT NULL,

    rating INT,

    review_text TEXT,

    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    CHECK (rating BETWEEN 1 AND 5),

    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    FOREIGN KEY (product_id)
        REFERENCES Products(product_id)
);



 CREATE TABLE Cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,

    customer_id INT NOT NULL UNIQUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id)
        ON DELETE CASCADE
);
 CREATE TABLE Cart_Items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,

    cart_id INT NOT NULL,

    product_id INT NOT NULL,

    quantity INT DEFAULT 1,

    CHECK (quantity > 0),

    FOREIGN KEY (cart_id)
        REFERENCES Cart(cart_id)
        ON DELETE CASCADE,

    FOREIGN KEY (product_id)
        REFERENCES Products(product_id),

    UNIQUE(cart_id, product_id)
);



 CREATE TABLE Wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,

    customer_id INT NOT NULL,

    product_id INT NOT NULL,

    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id)
        ON DELETE CASCADE,

    FOREIGN KEY (product_id)
        REFERENCES Products(product_id),

    UNIQUE(customer_id, product_id)
);



 CREATE TABLE Inventory_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,

    product_id INT NOT NULL,

    old_stock INT,

    new_stock INT,

    action_type VARCHAR(50),

    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES Products(product_id)
);

show tables;
