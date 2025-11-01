-- Esquema Mejorado de Base de Datos para Sistema de Inventario Zenith
-- Versión mejorada basada en 000_Schema_Base.sql, normalizada y con cumplimiento de ACID mediante transacciones en procedimientos almacenados.

USE [master]
GO
/****** Object:  Database [DB_Zenith_Inventory]    Script Date: 31/10/2025 22:26:05 ******/
CREATE DATABASE [DB_Zenith_Inventory] 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  User [dba]    Script Date: 31/10/2025 22:26:05 ******/
CREATE USER [dba] FOR LOGIN [dba] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [dba]
GO
/****** Object:  Schema [SCH_GENERAL]    Script Date: 31/10/2025 22:26:06 ******/
CREATE SCHEMA [SCH_GENERAL]
GO

-- Secuencias para controlar IDs y evitar saltos en inserciones
CREATE SEQUENCE SCH_GENERAL.Seq_Roles START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Permisos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Agentes START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Usuarios START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Marcas START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Categorias START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Subcategorias START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Modelos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Contratos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Bodegas START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Estados START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_TiposSalida START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Equipos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Ingresos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Egresos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_DetalleEgreso START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_Devoluciones START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_DetalleDevolucion START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_KardexEquipo START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_KardexUsuarios START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE SCH_GENERAL.Seq_BitacoraAuditoria START WITH 1 INCREMENT BY 1 NO CACHE;

GO

-- Tipos de tabla para procedimientos almacenados (mejora para normalización y eficiencia)
CREATE TYPE [SCH_GENERAL].[T_DETALLE_EQUIPO] AS TABLE(
	[ModeloId] [int] NOT NULL,
	[ContratoId] [int] NOT NULL,
	[BodegaId] [int] NOT NULL,
	[Serie] [varchar](252) NOT NULL,
	[EstadoEquipo] [int] NOT NULL,
	[Descripcion] [text] NULL,
	[Estado] [bit] NULL
)
GO

CREATE TYPE [SCH_GENERAL].[T_DETALLE_EGRESO] AS TABLE(
	[EquipoId] [int] NOT NULL,
	[Serie] [varchar](252) NOT NULL,
	[TipoSalidaId] [int] NOT NULL,
	[Estado] [bit] NOT NULL
)
GO

-- Tabla Roles
CREATE TABLE SCH_GENERAL.Roles (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Roles,
    Nombre NVARCHAR(50) NOT NULL UNIQUE,
    Descripcion NVARCHAR(255)
);

-- Tabla Permisos
CREATE TABLE SCH_GENERAL.Permisos (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Permisos,
    Nombre NVARCHAR(50) NOT NULL UNIQUE,
    Descripcion NVARCHAR(255)
);

-- Tabla PermisosRoles (muchos-a-muchos)
CREATE TABLE SCH_GENERAL.PermisosRoles (
    RolId INT NOT NULL,
    PermisoId INT NOT NULL,
    PRIMARY KEY (RolId, PermisoId),
    FOREIGN KEY (RolId) REFERENCES SCH_GENERAL.Roles(Id) ON DELETE CASCADE,
    FOREIGN KEY (PermisoId) REFERENCES SCH_GENERAL.Permisos(Id) ON DELETE CASCADE
);

-- Tabla Agentes (personal de IT)
CREATE TABLE SCH_GENERAL.Agentes (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Agentes,
    Nombre NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(100) NOT NULL UNIQUE,
    RolId INT NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    Estado BIT DEFAULT 1,
    FOREIGN KEY (RolId) REFERENCES SCH_GENERAL.Roles(Id)
);

-- Tabla Usuarios (empleados a quienes se asigna equipo)
CREATE TABLE SCH_GENERAL.Usuarios (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Usuarios,
    Codigo INT NOT NULL UNIQUE,
    Nombre NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(100) NOT NULL UNIQUE,
    Departamento NVARCHAR(100),
    Puesto NVARCHAR(100),
    FechaCreacion DATETIME DEFAULT GETDATE(),
    Estado BIT DEFAULT 1
);

-- Tabla Marcas
CREATE TABLE SCH_GENERAL.Marcas (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Marcas,
    Nombre NVARCHAR(100) NOT NULL UNIQUE,
    Estado BIT DEFAULT 1
);

-- Tabla Categorias
CREATE TABLE SCH_GENERAL.Categorias (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Categorias,
    Nombre NVARCHAR(100) NOT NULL UNIQUE,
    Descripcion NVARCHAR(255),
    Estado BIT DEFAULT 1
);

-- Tabla Subcategorias
CREATE TABLE SCH_GENERAL.Subcategorias (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Subcategorias,
    Nombre NVARCHAR(100) NOT NULL,
    CategoriaId INT NOT NULL,
    Descripcion NVARCHAR(255),
    Estado BIT DEFAULT 1,
    UNIQUE (Nombre, CategoriaId),
    FOREIGN KEY (CategoriaId) REFERENCES SCH_GENERAL.Categorias(Id) ON DELETE CASCADE
);

-- Tabla Modelos
CREATE TABLE SCH_GENERAL.Modelos (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Modelos,
    Nombre NVARCHAR(100) NOT NULL,
    MarcaId INT NOT NULL,
    SubcategoriaId INT NOT NULL,
    Estado BIT DEFAULT 1,
    UNIQUE (Nombre, MarcaId, SubcategoriaId),
    FOREIGN KEY (MarcaId) REFERENCES SCH_GENERAL.Marcas(Id) ON DELETE CASCADE,
    FOREIGN KEY (SubcategoriaId) REFERENCES SCH_GENERAL.Subcategorias(Id) ON DELETE CASCADE
);

-- Tabla Contratos
CREATE TABLE SCH_GENERAL.Contratos (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Contratos,
    Nombre NVARCHAR(100) NOT NULL UNIQUE,
    Descripcion NVARCHAR(255),
    Estado BIT DEFAULT 1
);

-- Tabla Bodegas
CREATE TABLE SCH_GENERAL.Bodegas (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Bodegas,
    Nombre NVARCHAR(100) NOT NULL UNIQUE,
    Ubicacion NVARCHAR(255),
    Estado BIT DEFAULT 1
);

-- Tabla Estados
CREATE TABLE SCH_GENERAL.Estados (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Estados,
    Nombre NVARCHAR(50) NOT NULL UNIQUE
);

-- Tabla TiposSalida
CREATE TABLE SCH_GENERAL.TiposSalida (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_TiposSalida,
    Nombre NVARCHAR(100) NOT NULL UNIQUE,
    Descripcion NVARCHAR(255),
    Estado BIT DEFAULT 1
);

-- Tabla Equipos
CREATE TABLE SCH_GENERAL.Equipos (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Equipos,
    Serie NVARCHAR(252) NOT NULL UNIQUE,
    ModeloId INT NOT NULL,
    ContratoId INT NOT NULL,
    BodegaId INT NOT NULL,
    TipoSalidaId INT NULL,
    EstadoEquipo INT NOT NULL DEFAULT 1,
    Descripcion NVARCHAR(500),
    Fecha DATETIME DEFAULT GETDATE(),
    Estado BIT DEFAULT 1,
    FOREIGN KEY (ModeloId) REFERENCES SCH_GENERAL.Modelos(Id),
    FOREIGN KEY (ContratoId) REFERENCES SCH_GENERAL.Contratos(Id),
    FOREIGN KEY (BodegaId) REFERENCES SCH_GENERAL.Bodegas(Id),
    FOREIGN KEY (TipoSalidaId) REFERENCES SCH_GENERAL.TiposSalida(Id)
);

-- Tabla Ingresos
CREATE TABLE SCH_GENERAL.Ingresos (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Ingresos,
    Usuario NVARCHAR(25) NOT NULL,
    Host NVARCHAR(25) NOT NULL,
    Dominio NVARCHAR(25) NOT NULL,
    BodegaId INT NULL,
    Fecha NVARCHAR(25) NULL,
    Hora NVARCHAR(25) NULL,
    Descripcion NVARCHAR(500),
    Estado BIT DEFAULT 1,
    TipoIngreso NVARCHAR(128) NULL,
    FOREIGN KEY (BodegaId) REFERENCES SCH_GENERAL.Bodegas(Id)
);

-- Tabla Egresos
CREATE TABLE SCH_GENERAL.Egresos (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Egresos,
    UsuarioId INT NOT NULL,
    ViceId INT NOT NULL,
    BodegaId INT NOT NULL,
    TipoSalidaId INT NOT NULL,
    Usuario NVARCHAR(20) NULL,
    Host NVARCHAR(20) NULL,
    Fecha NVARCHAR(20) NULL,
    Hora NVARCHAR(20) NULL,
    Path NVARCHAR(512) NULL,
    Adjunto BIT NOT NULL DEFAULT 0,
    Descripcion NVARCHAR(500),
    Estado BIT DEFAULT 1,
    FOREIGN KEY (UsuarioId) REFERENCES SCH_GENERAL.Usuarios(Id),
    FOREIGN KEY (BodegaId) REFERENCES SCH_GENERAL.Bodegas(Id),
    FOREIGN KEY (TipoSalidaId) REFERENCES SCH_GENERAL.TiposSalida(Id)
);

-- Tabla DetalleEgreso
CREATE TABLE SCH_GENERAL.DetalleEgreso (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_DetalleEgreso,
    EgresoId INT NOT NULL,
    EquipoId INT NOT NULL,
    Estado BIT DEFAULT 1,
    FOREIGN KEY (EgresoId) REFERENCES SCH_GENERAL.Egresos(Id),
    FOREIGN KEY (EquipoId) REFERENCES SCH_GENERAL.Equipos(Id)
);

-- Tabla Devoluciones
CREATE TABLE SCH_GENERAL.Devoluciones (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_Devoluciones,
    EgresoId INT NOT NULL,
    Fecha NVARCHAR(20) NULL,
    Hora NVARCHAR(20) NULL,
    Path NVARCHAR(512) NULL,
    EstadoEquipo INT NULL,
    Agente NVARCHAR(80) NULL,
    Descripcion NVARCHAR(500),
    Adjunto BIT NOT NULL DEFAULT 0,
    Estado BIT DEFAULT 1,
    BodegaId INT NULL,
    FOREIGN KEY (EgresoId) REFERENCES SCH_GENERAL.Egresos(Id),
    FOREIGN KEY (BodegaId) REFERENCES SCH_GENERAL.Bodegas(Id)
);

-- Tabla DetalleDevolucion
CREATE TABLE SCH_GENERAL.DetalleDevolucion (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_DetalleDevolucion,
    DevolucionId INT NOT NULL,
    EquipoId INT NOT NULL,
    EstadoEquipo INT NOT NULL,
    Estado BIT NULL,
    FOREIGN KEY (DevolucionId) REFERENCES SCH_GENERAL.Devoluciones(Id),
    FOREIGN KEY (EquipoId) REFERENCES SCH_GENERAL.Equipos(Id)
);

-- Tabla KardexEquipo (para historial)
CREATE TABLE SCH_GENERAL.KardexEquipo (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_KardexEquipo,
    MovId INT NOT NULL,
    Serie NVARCHAR(256) NOT NULL,
    TipoMov INT NOT NULL,
    BodegaId INT NOT NULL,
    Fecha DATETIME DEFAULT GETDATE(),
    Estado BIT DEFAULT 1,
    FOREIGN KEY (BodegaId) REFERENCES SCH_GENERAL.Bodegas(Id)
);

-- Tabla KardexUsuarios
CREATE TABLE SCH_GENERAL.KardexUsuarios (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_KardexUsuarios,
    MovId INT NOT NULL,
    UsuarioId NVARCHAR(256) NOT NULL,
    TipoMov INT NOT NULL,
    BodegaId INT NOT NULL,
    Fecha DATETIME DEFAULT GETDATE(),
    Estado BIT DEFAULT 1,
    FOREIGN KEY (BodegaId) REFERENCES SCH_GENERAL.Bodegas(Id)
);

-- Tabla BitacoraAuditoria (Bitácora de gestiones)
CREATE TABLE SCH_GENERAL.BitacoraAuditoria (
    Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR SCH_GENERAL.Seq_BitacoraAuditoria,
    AgenteId INT NULL,
    Accion NVARCHAR(100) NOT NULL,
    Entidad NVARCHAR(100) NOT NULL,
    EntidadId INT NOT NULL,
    Detalles NVARCHAR(500),
    ValoresAntiguos NVARCHAR(MAX),
    ValoresNuevos NVARCHAR(MAX),
    FechaHora DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (AgenteId) REFERENCES SCH_GENERAL.Agentes(Id)
);

GO

-- Insertar datos iniciales
INSERT INTO SCH_GENERAL.Estados (Nombre) VALUES ('Asignado'), ('No Asignado'), ('Transferido'), ('Leasing');
INSERT INTO SCH_GENERAL.Bodegas (Nombre, Ubicacion) VALUES ('Bodega Principal', 'Departamento de IT');
INSERT INTO SCH_GENERAL.Categorias (Nombre, Descripcion) VALUES ('Computadoras', 'Equipos de cómputo'), ('Redes', 'Equipos de red'), ('Impresoras', 'Dispositivos de impresión'), ('Perifericos', 'Accesorios');
INSERT INTO SCH_GENERAL.Subcategorias (Nombre, CategoriaId) VALUES 
('Laptops', 1), ('Escritorios', 1), ('Servidores', 1),
('Routers', 2), ('Switches', 2), ('Puntos de Acceso', 2),
('Impresoras Laser', 3), ('Impresoras de Tinta', 3),
('Monitores', 4), ('Teclados', 4), ('Mouses', 4);

GO

-- Procedimientos almacenados con transacciones para cumplimiento de ACID
CREATE PROCEDURE SCH_GENERAL.SP_Ingresos_Create
(
    @Usuario NVARCHAR(25),
    @Host NVARCHAR(25),
    @Dominio NVARCHAR(25),
    @BodegaId INT,
    @Fecha NVARCHAR(25),
    @Hora NVARCHAR(25),
    @Descripcion NVARCHAR(500),
    @Estado BIT,
    @TipoIngreso NVARCHAR(128),
    @TipoMovimiento INT,
    @DetalleEquipo SCH_GENERAL.T_DETALLE_EQUIPO READONLY,
    @Resultado BIT OUTPUT,
    @Mensaje NVARCHAR(500) OUTPUT
)
AS 
BEGIN
    BEGIN TRY
        DECLARE @IdMovimiento INT
        DECLARE @InsertedIds TABLE (Id INT)
        SET @Resultado = 1
        SET @Mensaje = ''

        BEGIN TRANSACTION REGISTRO

        INSERT INTO SCH_GENERAL.Ingresos (Usuario, Host, Dominio, BodegaId, Fecha, Hora, Descripcion, Estado, TipoIngreso)
        OUTPUT INSERTED.Id INTO @InsertedIds
        VALUES (@Usuario, @Host, @Dominio, @BodegaId, @Fecha, @Hora, @Descripcion, @Estado, @TipoIngreso)

        SELECT @IdMovimiento = Id FROM @InsertedIds

        INSERT INTO SCH_GENERAL.Equipos (Serie, ModeloId, ContratoId, BodegaId, EstadoEquipo, Descripcion, Estado)
        SELECT Serie, ModeloId, ContratoId, BodegaId, EstadoEquipo, Descripcion, Estado FROM @DetalleEquipo

        INSERT INTO SCH_GENERAL.KardexEquipo (MovId, Serie, TipoMov, BodegaId, Estado)
        SELECT @IdMovimiento, Serie, @TipoMovimiento, BodegaId, @Estado FROM @DetalleEquipo

        COMMIT TRANSACTION REGISTRO
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
        SET @Mensaje = ERROR_MESSAGE()
        ROLLBACK TRANSACTION REGISTRO
    END CATCH
END
GO

-- Más procedimientos pueden agregarse aquí basados en 000_Schema_Base.sql, como SP_Egresos_Create, etc.

USE [master]
GO
ALTER DATABASE [DB_Zenith_Inventory] SET READ_WRITE 
GO