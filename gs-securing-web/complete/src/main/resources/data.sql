INSERT INTO users (username, password, enabled) VALUES
('user', '{bcrypt}$2a$10$8.UnVuG9HHgfeM6zQ7/SLOxQxcwT3l3voAV.PM7Kp3.6k0Vi3j4PK', true),
('admin', '{bcrypt}$2a$10$5lC3Q3g3b0y3s2f1h/6fL.9fM5f3l3voAV.PM7Kp3.6k0Vi3j4PK', true);

INSERT INTO authorities (username, authority) VALUES
('user', 'ROLE_USER'),
('admin', 'ROLE_ADMIN');