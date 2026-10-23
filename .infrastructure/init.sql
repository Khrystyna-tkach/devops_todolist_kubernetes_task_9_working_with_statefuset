
CREATE DATABASE IF NOT EXISTS todoapp;

USE todoapp;

CREATE TABLE IF NOT EXISTS lab_init_marker (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255) NOT NULL
);

INSERT INTO lab_init_marker (message)
VALUES ('MySQL initialized successfully');