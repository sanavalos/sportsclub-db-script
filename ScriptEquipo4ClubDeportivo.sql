drop database if exists Equipo4;
create database Equipo4;
use Equipo4;

create table Roles(
  id_rol int,
  nombre_rol varchar(20),
  constraint primary key(id_rol)
);

insert into Roles values
(1,'Administrador'),
(2,'Socio'),
(3,'No Socio');

create table Tipos_Documentos(
  id_tipo_documento int,
  nombre_tipo_documento varchar(20),
  constraint primary key(id_tipo_documento)
);

insert into Tipos_Documentos values
(1,'DNI'),
(2,'Pasaporte'),
(3,'LC');

create table Estados(
  id_estado int,
  nombre_estado varchar(20),
  constraint primary key(id_estado)
);

insert into Estados values
(1,'Rechazado'),
(2,'Pendiente'),
(3,'Aprobado');

create table Formas_De_Pago(
  id_forma_pago int,
  nombre_forma_pago varchar(20),
  constraint primary key(id_forma_pago)
);

insert into Formas_De_Pago values
(1,'Tarjeta de Crédito'),
(2,'Efectivo');

create table Actividades(
  id_actividad int,
  nombre_actividad varchar(20),
  cupo int,
  horario time,
  precio decimal(8,2),
  constraint primary key(id_actividad)
);

insert into Actividades values
(1, 'Fútbol', 11, '14:30:00', 10000),
(2, 'Natación', 10, '15:00:00', 15000),
(3, 'Handball', 10, '16:30:00', 12500),
(4, 'Basketball', 10, '18:00:00', 12500),
(5, 'Tenis', 4, '09:00:00', 8000),
(6, 'Gimnasia', 20, '10:30:00', 5000),
(7, 'Yoga', 15, '08:00:00', 6000),
(8, 'Zumba', 25, '11:00:00', 5500),
(9, 'Voleibol', 12, '13:00:00', 9000),
(10, 'Kickboxing', 15, '17:00:00', 7500),
(11, 'Pilates', 15, '19:00:00', 7000),
(12, 'Crossfit', 20, '06:00:00', 12000),
(13, 'Boxeo', 10, '20:00:00', 8500),
(14, 'Escalada', 8, '08:30:00', 11000);

CREATE TABLE Usuarios (
    id_usuario int auto_increment,
    id_tipo_documento int not null,
    id_rol int not null,
    nombre varchar(20),
    apellido varchar(20),
    documento varchar(20),
    telefono varchar(20),
    email varchar(50),
    pass varchar(50),
    direccion varchar(50),
    constraint pk_usuario primary key(id_usuario),
    constraint fk_usuarios_tipo_documento foreign key(id_tipo_documento) references Tipos_Documentos(id_tipo_documento),
    constraint fk_usuarios_roles foreign key(id_rol) references Roles(id_rol)
);

insert into Usuarios values
(null,1, 1,'Admin', 'Sistema', '34123856', '54785487', 'admin@sistema.com', '123456', 'Av. Libertador 123'),
(null,1, 1,'Manager', 'Sistema', '40100200', '4741234', 'manager@sistema.com', '123456', 'Calle 1');

create table Pagos(
  id_pago int auto_increment,
  id_forma_pago int not null,
  id_usuario int not null,
  fecha_pago date,
  monto decimal(8,2),
  cant_cuotas int,
  constraint pk_pago primary key(id_pago),
  constraint fk_forma_pago foreign key(id_forma_pago) references Formas_De_Pago(id_forma_pago),
  constraint fk_pagos_usuario foreign key(id_usuario) references Usuarios(id_usuario)
);

create table Actividades_Pagadas(
  id_actividad_pagada int auto_increment,
  id_pago int not null,
  id_actividad int not null,
  constraint pk_actividad primary key(id_actividad_pagada),
  constraint fk_pago foreign key(id_pago) references Pagos(id_pago),
  constraint fk_actividad foreign key(id_actividad) references Actividades(id_actividad)
);

create table Planes(
  id_plan int,
  descripcion varchar(50),
  monto_mensual decimal(8,2),
  constraint primary key(id_plan)
);

insert into Planes values
(1,"2 veces por semana", 34000),
(2,"3 veces por semana", 43000),
(3,"Libre", 56000);

create table Socios(
  id_usuario int,
  id_estado int not null,
  id_plan int not null,
  nro_carnet varchar(20),
  tiene_deuda boolean,
  fecha_vencimiento date,
  imagen_carnet mediumblob,
  imagen_apto_fisico mediumblob,
  constraint pk_socio primary key(id_usuario),
  constraint fk_socio_estado foreign key(id_estado) references Estados(id_estado),
  constraint fk_socio_plan foreign key(id_plan) references Planes(id_plan),
  foreign key (id_usuario) REFERENCES Usuarios(id_usuario)
);

create table No_Socios(
  id_usuario int,
  id_estado int not null,
  imagen_apto_fisico mediumblob,
  constraint pk_no_socio primary key(id_usuario),
  constraint fk_no_socio_estado foreign key(id_estado) references Estados(id_estado),
  foreign key (id_usuario) REFERENCES Usuarios(id_usuario)
);

delimiter //  

create procedure Login(IN p_email VARCHAR(50), IN p_pass VARCHAR(50))
BEGIN
    DECLARE rol_user INT DEFAULT 0;
    
    SET rol_user = (SELECT u.id_rol FROM usuarios u WHERE u.email = p_email AND u.pass = p_pass);
    
    IF rol_user = 1 THEN
        SELECT u.id_usuario, u.nombre, u.apellido, t.nombre_tipo_documento, u.documento, 
               u.telefono, u.email, u.direccion, r.nombre_rol
        FROM usuarios u
        INNER JOIN roles r ON u.id_rol = r.id_rol
        INNER JOIN tipos_documentos t ON u.id_tipo_documento = t.id_tipo_documento
        WHERE u.email = p_email AND u.pass = p_pass;
        
    ELSEIF rol_user = 2 THEN
        SELECT u.id_usuario, u.nombre, u.apellido, t.nombre_tipo_documento, u.documento, 
               u.telefono, u.email, u.direccion, r.nombre_rol, s.nro_carnet, s.tiene_deuda, 
               s.fecha_vencimiento, s.imagen_carnet, e.nombre_estado, t.nombre_tipo_documento, 
               s.imagen_apto_fisico, p.monto_mensual
        FROM usuarios u
        INNER JOIN roles r ON u.id_rol = r.id_rol
        INNER JOIN tipos_documentos t ON u.id_tipo_documento = t.id_tipo_documento
        INNER JOIN socios s ON u.id_usuario = s.id_usuario
        INNER JOIN estados e ON s.id_estado = e.id_estado
        INNER JOIN planes p ON s.id_plan = p.id_plan
        WHERE u.email = p_email AND u.pass = p_pass;
        
    ELSEIF rol_user = 3 THEN
        SELECT u.id_usuario, u.nombre, u.apellido, t.nombre_tipo_documento, u.documento, 
               u.telefono, u.email, u.direccion, r.nombre_rol, e.nombre_estado, 
               t.nombre_tipo_documento, n.imagen_apto_fisico
        FROM usuarios u
        INNER JOIN roles r ON u.id_rol = r.id_rol
        INNER JOIN tipos_documentos t ON u.id_tipo_documento = t.id_tipo_documento
        INNER JOIN no_socios n ON n.id_usuario = u.id_usuario
        INNER JOIN estados e ON n.id_estado = e.id_estado
        WHERE u.email = p_email AND u.pass = p_pass;
    END IF;
END//

create procedure VerificarExistencia(in p_email varchar(50), in p_documento varchar(20), in p_tipo_documento int)
begin
    select count(*) from usuarios where email = p_email OR 
						(documento = p_documento AND id_tipo_documento = p_tipo_documento);
END //

create procedure ObtenerTiposDeDocumento()
begin
    select * from tipos_documentos;
END //

create procedure ObtenerFormasDePago()
begin
    select * from formas_de_pago;
END //

create procedure ObtenerActividades()
begin
    select * from actividades;
END //

create procedure ObtenerPlanes()
begin
    select * from planes;
END //

create procedure RegistrarSocio(
    in p_nombre varchar(20),
    in p_apellido varchar(20),
    in p_id_tipo_documento int,
    in p_documento varchar(20),
    in p_telefono varchar(20),
    in p_email varchar(50),
    in p_pass varchar(50),
    in p_direccion varchar(50),
    in p_id_rol int,
    in p_nro_carnet varchar(20),
    in p_tiene_deuda boolean,
    in p_fecha_vencimiento date,
    in p_imagen_carnet mediumblob,
    in p_imagen_apto_fisico mediumblob,
    in p_id_estado int,
    in p_id_plan int,
	out p_id_usuario int
)
begin

    insert into Usuarios (nombre, apellido, id_tipo_documento, documento, telefono, email, pass, direccion, id_rol)
    values (p_nombre, p_apellido, p_id_tipo_documento, p_documento, p_telefono, p_email, p_pass, p_direccion, p_id_rol);

    set p_id_usuario = LAST_INSERT_ID();

    insert into Socios (id_usuario, id_estado, id_plan, nro_carnet, tiene_deuda, fecha_vencimiento, imagen_carnet, imagen_apto_fisico)
    values (p_id_usuario, p_id_estado, p_id_plan, p_nro_carnet, p_tiene_deuda, p_fecha_vencimiento, p_imagen_carnet, p_imagen_apto_fisico);
END //

create PROCEDURE RegistrarNoSocio(
    in p_nombre varchar(20),
    in p_apellido varchar(20),
    in p_id_tipo_documento int,
    in p_documento varchar(20),
    in p_telefono varchar(20),
    in p_email varchar(50),
    in p_pass varchar(50),
    in p_direccion varchar(50),
    in p_id_rol int,
    in p_imagen_apto_físico mediumblob,
    in p_id_estado int,
	out p_id_usuario int
)
begin

    insert into Usuarios (nombre, apellido, id_tipo_documento, documento, telefono, email, pass, direccion, id_rol)
    values (p_nombre, p_apellido, p_id_tipo_documento, p_documento, p_telefono, p_email, p_pass, p_direccion, p_id_rol);

    set p_id_usuario = LAST_INSERT_ID();

    insert into No_Socios (id_usuario, id_estado, imagen_apto_fisico)
    values (p_id_usuario, p_id_estado, p_imagen_apto_fisico);
END//

create procedure RealizarPago(
    in p_id_usuario int,
    in p_id_forma_pago int,
    in p_fecha_pago date,
    in p_monto int,
    in p_cant_cuotas int,
	out p_id_pago int
)
begin

    insert into Pagos (id_usuario, id_forma_pago, fecha_pago, monto, cant_cuotas)
    values (p_id_usuario, p_id_forma_pago, p_fecha_pago, p_monto, p_cant_cuotas);

    set p_id_pago = LAST_INSERT_ID();

END //

create procedure EmitirCarnet(in p_id_usuario int)
BEGIN
	SELECT u.id_usuario, u.nombre, u.apellido, u.documento, s.nro_carnet, s.imagen_carnet
        FROM usuarios u
        INNER JOIN socios s ON u.id_usuario = s.id_usuario
        WHERE u.id_usuario = p_id_usuario;
END //

delimiter ; 

select * from socios;
