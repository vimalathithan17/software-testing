-- schema.sql (for MySQL)

-- Use this line if you want to start fresh each time
DROP TABLE IF EXISTS tasks;

CREATE TABLE tasks (
  id INT PRIMARY KEY AUTO_INCREMENT,
  text VARCHAR(255) NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT 0
);