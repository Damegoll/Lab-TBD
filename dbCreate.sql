CREATE DATABASE IF NOT EXISTS TBDGrupo2;
USE TBDGrupo2;

CREATE TABLE IF NOT EXISTS region(
idRegion INT AUTO_INCREMENT PRIMARY KEY,
nombreRegion VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS comuna (
idComuna INT AUTO_INCREMENT PRIMARY KEY,
idRegion INT,
nombreComuna VARCHAR(50),
FOREIGN KEY (idRegion) REFERENCES region(idRegion)
);

CREATE TABLE IF NOT EXISTS galeria (
idLocal INT AUTO_INCREMENT PRIMARY KEY,
idComuna INT,
nombreLocal VARCHAR(50),
FOREIGN KEY (idComuna) REFERENCES comuna(idComuna)
);  

CREATE TABLE IF NOT EXISTS producto (
idProducto INT AUTO_INCREMENT PRIMARY KEY,
idLocal INT,
tipoProducto VARCHAR (9),
precio INT,
peso FLOAT,
Estado VARCHAR(10),
FOREIGN KEY (idLocal) REFERENCES galeria(idLocal)
);

CREATE TABLE IF NOT EXISTS empleado (
idEmpleado INT AUTO_INCREMENT PRIMARY KEY,
idLocal INT,
nombreEmpleado VARCHAR (20),
apellidoEmpleado VARCHAR (20),
telefonoEmpleado VARCHAR(20),
generoEmpleado VARCHAR(10),
calleEmpleado VARCHAR(50),
numeroCalleEmpleado INT,
fechaNacimientoEmpleado DATE,
FOREIGN KEY (idLocal) REFERENCES galeria(idLocal)
);

CREATE TABLE IF NOT EXISTS sueldo (
idSueldo INT AUTO_INCREMENT PRIMARY KEY,
idEmpleado INT,
monto INT,
fechaSueldo DATE,
FOREIGN KEY (idEmpleado) REFERENCES empleado(idEmpleado)
);

CREATE TABLE IF NOT EXISTS cliente (
idCliente INT AUTO_INCREMENT PRIMARY KEY,
nombreCliente VARCHAR(20),
apellidoCliente VARCHAR(20),
telefonoCliente VARCHAR(20),
calleCliente VARCHAR(50),
numeroCalleCliente INT,
fechaNacimientoCliente DATE
);

CREATE TABLE IF NOT EXISTS venta (
idVenta INT AUTO_INCREMENT PRIMARY KEY,
idCliente INT,
idEmpleado INT,
fechaVenta DATE,
FOREIGN KEY (idCliente) REFERENCES cliente(idCliente),
FOREIGN KEY (idEmpleado) REFERENCES empleado(idEmpleado)
);

CREATE TABLE IF NOT EXISTS detalle_venta (
idVenta INT,
idProducto INT,
PRIMARY KEY (idVenta, idProducto),
FOREIGN KEY (idVenta) REFERENCES venta (idVenta),
FOREIGN KEY (idProducto) REFERENCES producto (idProducto)
);