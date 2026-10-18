CREATE DATABASE IF NOT EXISTS TBDGrupo2;
USE TBDGrupo2;

CREATE TABLE IF NOT EXISTS region(
idRegion INT AUTO_INCREMENT PRIMARY KEY,
nombreRegion VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS comuna (
idComuna INT AUTO_INCREMENT PRIMARY KEY,
idRegion INT NOT NULL,
nombreComuna VARCHAR(50) NOT NULL,
FOREIGN KEY (idRegion) REFERENCES region(idRegion)
);

CREATE TABLE IF NOT EXISTS galeria (
idLocal INT AUTO_INCREMENT PRIMARY KEY,
idComuna INT NOT NULL,
nombreLocal VARCHAR(50) NOT NULL,
FOREIGN KEY (idComuna) REFERENCES comuna(idComuna)
);

CREATE TABLE IF NOT EXISTS producto (
idProducto INT AUTO_INCREMENT PRIMARY KEY,
idLocal INT NOT NULL,
tipoProducto VARCHAR (9) NOT NULL,
precio INT NOT NULL,
peso DECIMAL(6,2),
Estado VARCHAR(10) NOT NULL,
FOREIGN KEY (idLocal) REFERENCES galeria(idLocal)
);

CREATE TABLE IF NOT EXISTS empleado (
idEmpleado INT AUTO_INCREMENT PRIMARY KEY,
idLocal INT NOT NULL,
nombreEmpleado VARCHAR (20) NOT NULL,
apellidoEmpleado VARCHAR (20) NOT NULL,
telefonoEmpleado VARCHAR(20) NOT NULL,
generoEmpleado VARCHAR(10) NOT NULL,
calleEmpleado VARCHAR(50),
numeroCalleEmpleado INT,
fechaNacimientoEmpleado DATE NOT NULL,
FOREIGN KEY (idLocal) REFERENCES galeria(idLocal)
);

CREATE TABLE IF NOT EXISTS sueldo (
idSueldo INT AUTO_INCREMENT PRIMARY KEY,
idEmpleado INT NOT NULL,
monto INT NOT NULL,
fechaSueldo DATE NOT NULL,
FOREIGN KEY (idEmpleado) REFERENCES empleado(idEmpleado)
);

CREATE TABLE IF NOT EXISTS cliente (
idCliente INT AUTO_INCREMENT PRIMARY KEY,
nombreCliente VARCHAR(20) NOT NULL,
apellidoCliente VARCHAR(20) NOT NULL,
telefonoCliente VARCHAR(20),
calleCliente VARCHAR(50),
numeroCalleCliente INT,
fechaNacimientoCliente DATE
);

CREATE TABLE IF NOT EXISTS venta (
idVenta INT AUTO_INCREMENT PRIMARY KEY,
idCliente INT NOT NULL,
idEmpleado INT NOT NULL,
fechaVenta DATE NOT NULL,
FOREIGN KEY (idCliente) REFERENCES cliente(idCliente),
FOREIGN KEY (idEmpleado) REFERENCES empleado(idEmpleado)
);

CREATE TABLE IF NOT EXISTS detalle_venta (
idVenta INT NOT NULL,
idProducto INT NOT NULL,
PRIMARY KEY (idVenta, idProducto),
FOREIGN KEY (idVenta) REFERENCES venta (idVenta),
FOREIGN KEY (idProducto) REFERENCES producto (idProducto)
);