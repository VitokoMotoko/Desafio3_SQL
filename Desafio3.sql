--Creacion de la BD:

CREATE DATABASE desafio3_Victor_Gomez_007;

--creacion tabla Usuarios:

CREATE TABLE Usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol VARCHAR(50) NOT NULL
);

-- Insertar 5 usuarios:
INSERT INTO Usuarios (email, nombre, apellido, rol) VALUES
('admin@example.com', 'Admin', 'Gomez', 'administrador'),
('user1@example.com', 'Juan', 'Pérez', 'usuario'),
('user2@example.com', 'Ana', 'Lopez', 'usuario'),
('user3@example.com', 'Luis', 'Martinez', 'usuario'),
('user4@example.com', 'Maria', 'Fernandez', 'usuario');

--Crear tabla Post:
CREATE TABLE Post (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    destacado BOOLEAN NOT NULL,
    usuario_id BIGINT REFERENCES Usuarios(id)
);

-- Insertar 5 posts
INSERT INTO Post (titulo, contenido, destacado, usuario_id) VALUES
('Post 1', 'Contenido del post 1', TRUE, 1),  -- Admin
('Post 2', 'Contenido del post 2', FALSE, 1), -- Admin
('Post 3', 'Contenido del post 3', TRUE, 2),  -- Usuario 1
('Post 4', 'Contenido del post 4', FALSE, 3), -- Usuario 2
('Post 5', 'Contenido del post 5', TRUE, NULL); -- Sin usuario

--Crear tabla Comentarios:
CREATE TABLE Comentarios (
    id SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT REFERENCES Usuarios(id),
    post_id BIGINT REFERENCES Post(id)
);

-- Insertar 5 comentarios
INSERT INTO Comentarios (contenido, usuario_id, post_id) VALUES
('Comentario 1', 1, 1),  -- Usuario 1 en Post 1
('Comentario 2', 2, 1),  -- Usuario 2 en Post 1
('Comentario 3', 3, 1),  -- Usuario 3 en Post 1
('Comentario 4', 1, 2),  -- Usuario 1 en Post 2
('Comentario 5', 2, 2);  -- Usuario 2 en Post 2

----Requerimientos del PDF

--1 Completar el setup
----Entiendo que ya lo tendria listo con lo desarrollado arriba

--2 Cruzar los datos de la tabla Usuarios y Post:
SELECT 
    U.nombre, 
    U.email, 
    P.titulo, 
    P.contenido 
FROM 
    Usuarios U
JOIN 
    Post P ON U.id = P.usuario_id;

--3 Mostrar el id, titulo y contenido de los Post de los administradores:
SELECT 
    P.id, 
    P.titulo, 
    P.contenido 
FROM 
    Post P
JOIN 
    Usuarios U ON P.usuario_id = U.id
WHERE 
    U.rol = 'administrador';

--4 contar la cantidad de posts de cada usuario:
SELECT 
    U.id, 
    U.email, 
    COUNT(P.id) AS cantidad_posts 
FROM 
    Usuarios U
LEFT JOIN 
    Post P ON U.id = P.usuario_id
GROUP BY 
    U.id, U.email;

--5 Mostrar el mail del usuario que ah creado mas posts:
SELECT 
    U.email 
FROM 
    Usuarios U
JOIN 
    Post P ON U.id = P.usuario_id
GROUP BY 
    U.email
ORDER BY 
    COUNT(P.id) DESC
LIMIT 1;


--6 Mostrar la fecha del ultimo post de cada usuario:
SELECT 
    U.id, 
    MAX(P.fecha_creacion) AS ultima_fecha_post 
FROM 
    Usuarios U
LEFT JOIN 
    Post P ON U.id = P.usuario_id
GROUP BY 
    U.id;
--En el resultado me sale 2 usuarios sin post y por ellos aparecen con valor null esto es por el Left Join
--ya que se incluyen todos los usuarios tengan o no posts.
--Ahora.. si lo cambio a un Inner Join puedo cambiar el resultado al incluir solo usuarios con al menos 1 post.
SELECT 
    U.id, 
    MAX(P.fecha_creacion) AS ultima_fecha_post 
FROM 
    Usuarios U
INNER JOIN 
    Post P ON U.id = P.usuario_id
GROUP BY 
    U.id;


--7 Mostrar el titulo y contenido del post con mas comentarios:
SELECT 
    P.titulo, 
    P.contenido 
FROM 
    Post P
JOIN 
    Comentarios C ON P.id = C.post_id
GROUP BY 
    P.id
ORDER BY 
    COUNT(C.id) DESC
LIMIT 1;


--8 Mostrar titulo de cada post, contenido de cada post y contenido de cada comentario asociado con el
--mail de usuario que lo escribió:
SELECT 
    P.titulo, 
    P.contenido AS contenido_post, 
    C.contenido AS contenido_comentario, 
    U.email 
FROM 
    Post P
LEFT JOIN 
    Comentarios C ON P.id = C.post_id
LEFT JOIN 
    Usuarios U ON C.usuario_id = U.id;

--9 Mostrar el contenido del ultimo comentario de cada usuario:
SELECT 
    U.nombre, 
    C.contenido 
FROM 
    Comentarios C
JOIN 
    Usuarios U ON C.usuario_id = U.id
WHERE 
    C.fecha_creacion = (
        SELECT MAX(fecha_creacion) 
        FROM Comentarios 
        WHERE usuario_id = U.id
    );

--10 Mostrar los emails de los usuarios que no han escrito ningun comentario:
SELECT 
    U.email 
FROM 
    Usuarios U
LEFT JOIN 
    Comentarios C ON U.id = C.usuario_id
GROUP BY 
    U.id
HAVING 
    COUNT(C.id) = 0;

