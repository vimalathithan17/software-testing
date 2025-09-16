-- schema.sql for fullstack_sqlite
DROP TABLE IF EXISTS tasks;

CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  text TEXT NOT NULL,
  completed BOOLEAN NOT NULL CHECK (completed IN (0, 1))
);
