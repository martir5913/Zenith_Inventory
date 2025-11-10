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
/****** Object:  Schema [ZI_GENERAL]    Script Date: 31/10/2025 22:26:06 ******/
CREATE SCHEMA [ZI_GENERAL]
GO

-- Secuencias para controlar IDs y evitar saltos en inserciones
CREATE SEQUENCE ZI_GENERAL.Seq_Roles START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Permisos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Agentes START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Usuarios START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Marcas START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Categorias START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Subcategorias START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Modelos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Contratos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Bodegas START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Estados START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_TiposSalida START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Equipos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Ingresos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Egresos START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_DetalleEgreso START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_Devoluciones START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_DetalleDevolucion START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_KardexEquipo START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_KardexUsuarios START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_BitacoraAuditoria START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_ZI_Configuracion START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE ZI_GENERAL.Seq_ZI_UsuariosRoles START WITH 1 INCREMENT BY 1 NO CACHE;

GO

-- Tipos de tabla para procedimientos almacenados (mejora para normalización y eficiencia)
CREATE TYPE [ZI_GENERAL].[T_DETALLE_EQUIPO] AS TABLE(
	[DET_ModeloId] [int] NOT NULL,
	[DET_ContratoId] [int] NOT NULL,
	[DET_BodegaId] [int] NOT NULL,
	[DET_Serie] [varchar](252) NOT NULL,
	[DET_EstadoEquipo] [int] NOT NULL,
	[DET_Descripcion] [text] NULL,
	[DET_Estado] [bit] NULL
)
GO

CREATE TYPE [ZI_GENERAL].[T_DETALLE_EGRESO] AS TABLE(
	[DEG_EquipoId] [int] NOT NULL,
	[DEG_Serie] [varchar](252) NOT NULL,
	[DEG_TipoSalidaId] [int] NOT NULL,
	[DEG_Estado] [bit] NOT NULL
)
GO

-- Tabla ZI_ROLES
CREATE TABLE ZI_GENERAL.ZI_ROLES (
    ROL_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Roles,
    ROL_Nombre NVARCHAR(50) NOT NULL UNIQUE,
    ROL_Descripcion NVARCHAR(255),
    ROL_Activo BIT DEFAULT 1,
    ROL_FechaCreacion DATETIME DEFAULT GETDATE(),
    ROL_UsuarioCreacion NVARCHAR(100) NOT NULL,
    ROL_FechaModificacion DATETIME NULL,
    ROL_UsuarioModificacion NVARCHAR(100) NULL,
    ROL_IpCreacion NVARCHAR(45) NULL,
    ROL_IpModificacion NVARCHAR(45) NULL
);

-- Tabla ZI_PERMISOS
CREATE TABLE ZI_GENERAL.ZI_PERMISOS (
    PER_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Permisos,
    PER_Nombre NVARCHAR(50) NOT NULL UNIQUE,
    PER_Descripcion NVARCHAR(255),
    PER_Modulo NVARCHAR(100),
    PER_Accion NVARCHAR(100),
    PER_Estado BIT DEFAULT 1,
    PER_Activo BIT DEFAULT 1,
    PER_FechaCreacion DATETIME DEFAULT GETDATE(),
    PER_UsuarioCreacion NVARCHAR(100) NOT NULL,
    PER_FechaModificacion DATETIME NULL,
    PER_UsuarioModificacion NVARCHAR(100) NULL,
    PER_IpCreacion NVARCHAR(45) NULL,
    PER_IpModificacion NVARCHAR(45) NULL
);

-- Tabla ZI_PERMISOSROLES (muchos-a-muchos)
CREATE TABLE ZI_GENERAL.ZI_PERMISOSROLES (
    PRO_RolId INT NOT NULL,
    PRO_PermisoId INT NOT NULL,
    PRIMARY KEY (PRO_RolId, PRO_PermisoId),
    FOREIGN KEY (PRO_RolId) REFERENCES ZI_GENERAL.ZI_ROLES(ROL_Id) ON DELETE CASCADE,
    FOREIGN KEY (PRO_PermisoId) REFERENCES ZI_GENERAL.ZI_PERMISOS(PER_Id) ON DELETE CASCADE
);

-- Tabla ZI_AGENTES (personal de IT)
CREATE TABLE ZI_GENERAL.ZI_AGENTES (
    AGE_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Agentes,
    AGE_Nombre NVARCHAR(100) NOT NULL,
    AGE_Correo NVARCHAR(100) NOT NULL UNIQUE,
    AGE_RolId INT NOT NULL,
    AGE_FechaCreacion DATETIME DEFAULT GETDATE(),
    AGE_Estado BIT DEFAULT 1,
    FOREIGN KEY (AGE_RolId) REFERENCES ZI_GENERAL.ZI_ROLES(ROL_Id)
);

-- Tabla ZI_USUARIOS (empleados a quienes se asigna equipo)
CREATE TABLE ZI_GENERAL.ZI_USUARIOS (
    USU_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Usuarios,
    USU_Codigo INT NOT NULL UNIQUE,
    USU_Username NVARCHAR(100) NOT NULL UNIQUE,
    USU_Nombre NVARCHAR(100) NOT NULL,
    USU_Correo NVARCHAR(100) NOT NULL UNIQUE,
    USU_Departamento NVARCHAR(100),
    USU_Puesto NVARCHAR(100),
    USU_FechaCreacion DATETIME DEFAULT GETDATE(),
    USU_Activo BIT DEFAULT 1,
    USU_Bloqueado BIT DEFAULT 0,
    USU_IntentosFallidos INT DEFAULT 0,
    USU_FechaBloqueo DATETIME NULL,
    USU_UltimoLogin DATETIME NULL,
    USU_PasswordEncrypted NVARCHAR(500) NULL,
    USU_PassTemp BIT DEFAULT 0,
    USU_Estado BIT DEFAULT 1,
    USU_Apellido NVARCHAR(150) NULL,
    USU_Telefono NVARCHAR(20) NULL,
    USU_UsuarioCreacion NVARCHAR(100) NOT NULL,
    USU_FechaModificacion DATETIME NULL,
    USU_UsuarioModificacion NVARCHAR(100) NULL,
    USU_IpCreacion NVARCHAR(45) NULL,
    USU_IpModificacion NVARCHAR(45) NULL
);

-- Tabla ZI_MARCAS
CREATE TABLE ZI_GENERAL.ZI_MARCAS (
    MAR_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Marcas,
    MAR_Nombre NVARCHAR(100) NOT NULL UNIQUE,
    MAR_Estado BIT DEFAULT 1
);

-- Tabla ZI_CATEGORIAS
CREATE TABLE ZI_GENERAL.ZI_CATEGORIAS (
    CAT_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Categorias,
    CAT_Nombre NVARCHAR(100) NOT NULL UNIQUE,
    CAT_Descripcion NVARCHAR(255),
    CAT_Estado BIT DEFAULT 1
);

-- Tabla ZI_SUBCATEGORIAS
CREATE TABLE ZI_GENERAL.ZI_SUBCATEGORIAS (
    SUB_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Subcategorias,
    SUB_Nombre NVARCHAR(100) NOT NULL,
    SUB_CategoriaId INT NOT NULL,
    SUB_Descripcion NVARCHAR(255),
    SUB_Estado BIT DEFAULT 1,
    UNIQUE (SUB_Nombre, SUB_CategoriaId),
    FOREIGN KEY (SUB_CategoriaId) REFERENCES ZI_GENERAL.ZI_CATEGORIAS(CAT_Id) ON DELETE CASCADE
);

-- Tabla ZI_MODELOS
CREATE TABLE ZI_GENERAL.ZI_MODELOS (
    MOD_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Modelos,
    MOD_Nombre NVARCHAR(100) NOT NULL,
    MOD_MarcaId INT NOT NULL,
    MOD_SubcategoriaId INT NOT NULL,
    MOD_Estado BIT DEFAULT 1,
    UNIQUE (MOD_Nombre, MOD_MarcaId, MOD_SubcategoriaId),
    FOREIGN KEY (MOD_MarcaId) REFERENCES ZI_GENERAL.ZI_MARCAS(MAR_Id) ON DELETE CASCADE,
    FOREIGN KEY (MOD_SubcategoriaId) REFERENCES ZI_GENERAL.ZI_SUBCATEGORIAS(SUB_Id) ON DELETE CASCADE
);

-- Tabla ZI_CONTRATOS
CREATE TABLE ZI_GENERAL.ZI_CONTRATOS (
    CON_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Contratos,
    CON_Nombre NVARCHAR(100) NOT NULL UNIQUE,
    CON_Descripcion NVARCHAR(255),
    CON_Estado BIT DEFAULT 1
);

-- Tabla ZI_BODEGAS
CREATE TABLE ZI_GENERAL.ZI_BODEGAS (
    BOD_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Bodegas,
    BOD_Nombre NVARCHAR(100) NOT NULL UNIQUE,
    BOD_Ubicacion NVARCHAR(255),
    BOD_Estado BIT DEFAULT 1
);

-- Tabla ZI_ESTADOS
CREATE TABLE ZI_GENERAL.ZI_ESTADOS (
    EST_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Estados,
    EST_Nombre NVARCHAR(50) NOT NULL UNIQUE
);

-- Tabla ZI_TIPOSSALIDA
CREATE TABLE ZI_GENERAL.ZI_TIPOSSALIDA (
    TSA_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_TiposSalida,
    TSA_Nombre NVARCHAR(100) NOT NULL UNIQUE,
    TSA_Descripcion NVARCHAR(255),
    TSA_Estado BIT DEFAULT 1
);

-- Tabla ZI_EQUIPOS
CREATE TABLE ZI_GENERAL.ZI_EQUIPOS (
    EQU_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Equipos,
    EQU_Serie NVARCHAR(252) NOT NULL UNIQUE,
    EQU_ModeloId INT NOT NULL,
    EQU_ContratoId INT NOT NULL,
    EQU_BodegaId INT NOT NULL,
    EQU_TipoSalidaId INT NULL,
    EQU_EstadoEquipo INT NOT NULL DEFAULT 1,
    EQU_Descripcion NVARCHAR(500),
    EQU_Fecha DATETIME DEFAULT GETDATE(),
    EQU_Estado BIT DEFAULT 1,
    FOREIGN KEY (EQU_ModeloId) REFERENCES ZI_GENERAL.ZI_MODELOS(MOD_Id),
    FOREIGN KEY (EQU_ContratoId) REFERENCES ZI_GENERAL.ZI_CONTRATOS(CON_Id),
    FOREIGN KEY (EQU_BodegaId) REFERENCES ZI_GENERAL.ZI_BODEGAS(BOD_Id),
    FOREIGN KEY (EQU_TipoSalidaId) REFERENCES ZI_GENERAL.ZI_TIPOSSALIDA(TSA_Id)
);

-- Tabla ZI_INGRESOS
CREATE TABLE ZI_GENERAL.ZI_INGRESOS (
    ING_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Ingresos,
    ING_Usuario NVARCHAR(25) NOT NULL,
    ING_Host NVARCHAR(25) NOT NULL,
    ING_Dominio NVARCHAR(25) NOT NULL,
    ING_BodegaId INT NULL,
    ING_Fecha NVARCHAR(25) NULL,
    ING_Hora NVARCHAR(25) NULL,
    ING_Descripcion NVARCHAR(500),
    ING_Estado BIT DEFAULT 1,
    ING_TipoIngreso NVARCHAR(128) NULL,
    FOREIGN KEY (ING_BodegaId) REFERENCES ZI_GENERAL.ZI_BODEGAS(BOD_Id)
);

-- Tabla ZI_EGRESOS
CREATE TABLE ZI_GENERAL.ZI_EGRESOS (
    EGR_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Egresos,
    EGR_UsuarioId INT NOT NULL,
    EGR_ViceId INT NOT NULL,
    EGR_BodegaId INT NOT NULL,
    EGR_TipoSalidaId INT NOT NULL,
    EGR_Usuario NVARCHAR(20) NULL,
    EGR_Host NVARCHAR(20) NULL,
    EGR_Fecha NVARCHAR(20) NULL,
    EGR_Hora NVARCHAR(20) NULL,
    EGR_Path NVARCHAR(512) NULL,
    EGR_Adjunto BIT NOT NULL DEFAULT 0,
    EGR_Descripcion NVARCHAR(500),
    EGR_Estado BIT DEFAULT 1,
    FOREIGN KEY (EGR_UsuarioId) REFERENCES ZI_GENERAL.ZI_USUARIOS(USU_Id),
    FOREIGN KEY (EGR_BodegaId) REFERENCES ZI_GENERAL.ZI_BODEGAS(BOD_Id),
    FOREIGN KEY (EGR_TipoSalidaId) REFERENCES ZI_GENERAL.ZI_TIPOSSALIDA(TSA_Id)
);

-- Tabla ZI_DETALLEEGRESO
CREATE TABLE ZI_GENERAL.ZI_DETALLEEGRESO (
    DEG_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_DetalleEgreso,
    DEG_EgresoId INT NOT NULL,
    DEG_EquipoId INT NOT NULL,
    DEG_Estado BIT DEFAULT 1,
    FOREIGN KEY (DEG_EgresoId) REFERENCES ZI_GENERAL.ZI_EGRESOS(EGR_Id),
    FOREIGN KEY (DEG_EquipoId) REFERENCES ZI_GENERAL.ZI_EQUIPOS(EQU_Id)
);

-- Tabla ZI_DEVOLUCIONES
CREATE TABLE ZI_GENERAL.ZI_DEVOLUCIONES (
    DEV_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_Devoluciones,
    DEV_EgresoId INT NOT NULL,
    DEV_Fecha NVARCHAR(20) NULL,
    DEV_Hora NVARCHAR(20) NULL,
    DEV_Path NVARCHAR(512) NULL,
    DEV_EstadoEquipo INT NULL,
    DEV_Agente NVARCHAR(80) NULL,
    DEV_Descripcion NVARCHAR(500),
    DEV_Adjunto BIT NOT NULL DEFAULT 0,
    DEV_Estado BIT DEFAULT 1,
    DEV_BodegaId INT NULL,
    FOREIGN KEY (DEV_EgresoId) REFERENCES ZI_GENERAL.ZI_EGRESOS(EGR_Id),
    FOREIGN KEY (DEV_BodegaId) REFERENCES ZI_GENERAL.ZI_BODEGAS(BOD_Id)
);

-- Tabla ZI_DETALLEDEVOLUCION
CREATE TABLE ZI_GENERAL.ZI_DETALLEDEVOLUCION (
    DDE_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_DetalleDevolucion,
    DDE_DevolucionId INT NOT NULL,
    DDE_EquipoId INT NOT NULL,
    DDE_EstadoEquipo INT NOT NULL,
    DDE_Estado BIT NULL,
    FOREIGN KEY (DDE_DevolucionId) REFERENCES ZI_GENERAL.ZI_DEVOLUCIONES(DEV_Id),
    FOREIGN KEY (DDE_EquipoId) REFERENCES ZI_GENERAL.ZI_EQUIPOS(EQU_Id)
);

-- Tabla ZI_KARDEXEQUIPO (para historial)
CREATE TABLE ZI_GENERAL.ZI_KARDEXEQUIPO (
    KAR_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_KardexEquipo,
    KAR_MovId INT NOT NULL,
    KAR_Serie NVARCHAR(256) NOT NULL,
    KAR_TipoMov INT NOT NULL,
    KAR_BodegaId INT NOT NULL,
    KAR_Fecha DATETIME DEFAULT GETDATE(),
    KAR_Estado BIT DEFAULT 1,
    FOREIGN KEY (KAR_BodegaId) REFERENCES ZI_GENERAL.ZI_BODEGAS(BOD_Id)
);

-- Tabla ZI_KARDEXUSUARIOS
CREATE TABLE ZI_GENERAL.ZI_KARDEXUSUARIOS (
    KUS_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_KardexUsuarios,
    KUS_MovId INT NOT NULL,
    KUS_UsuarioId NVARCHAR(256) NOT NULL,
    KUS_TipoMov INT NOT NULL,
    KUS_BodegaId INT NOT NULL,
    KUS_Fecha DATETIME DEFAULT GETDATE(),
    KUS_Estado BIT DEFAULT 1,
    FOREIGN KEY (KUS_BodegaId) REFERENCES ZI_GENERAL.ZI_BODEGAS(BOD_Id)
);

-- Tabla ZI_BITACORAAUDITORIA (Bitácora de gestiones)
CREATE TABLE ZI_GENERAL.ZI_BITACORAAUDITORIA (
    BIT_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_BitacoraAuditoria,
    BIT_AgenteId INT NULL,
    BIT_Accion NVARCHAR(100) NOT NULL,
    BIT_Entidad NVARCHAR(100) NOT NULL,
    BIT_EntidadId INT NOT NULL,
    BIT_Detalles NVARCHAR(500),
    BIT_ValoresAntiguos NVARCHAR(MAX),
    BIT_ValoresNuevos NVARCHAR(MAX),
    BIT_FechaHora DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BIT_AgenteId) REFERENCES ZI_GENERAL.ZI_AGENTES(AGE_Id)
);

-- Tabla ZI_CONFIGURACION (Configuraciones del sistema)
CREATE TABLE ZI_GENERAL.ZI_CONFIGURACION (
    ZIC_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_ZI_Configuracion,
    ZIC_Clave NVARCHAR(100) NOT NULL UNIQUE,
    ZIC_Valor NVARCHAR(1000) NOT NULL,
    ZIC_Descripcion NVARCHAR(500),
    ZIC_Tipo NVARCHAR(50) DEFAULT 'STRING',
    ZIC_Activo BIT DEFAULT 1,
    ZIC_FechaCreacion DATETIME DEFAULT GETDATE(),
    ZIC_UsuarioCreacion NVARCHAR(100) NOT NULL,
    ZIC_FechaModificacion DATETIME NULL,
    ZIC_UsuarioModificacion NVARCHAR(100) NULL,
    ZIC_IpCreacion NVARCHAR(45) NULL,
    ZIC_IpModificacion NVARCHAR(45) NULL
);

GO

-- Tabla ZI_USUARIOSROLES (muchos-a-muchos usuarios-roles)
CREATE TABLE ZI_GENERAL.ZI_USUARIOSROLES (
    UR_Id INT PRIMARY KEY DEFAULT NEXT VALUE FOR ZI_GENERAL.Seq_ZI_UsuariosRoles,
    UR_UsrId INT NOT NULL,
    UR_RolId INT NOT NULL,
    UR_FechaAsignacion DATETIME DEFAULT GETDATE(),
    UR_Activo BIT DEFAULT 1,
    UR_UsuarioCreacion NVARCHAR(100) NOT NULL,
    UR_IpCreacion NVARCHAR(45) NULL,
    UR_FechaModificacion DATETIME NULL,
    UR_UsuarioModificacion NVARCHAR(100) NULL,
    UR_IpModificacion NVARCHAR(45) NULL,
    UNIQUE (UR_UsrId, UR_RolId),
    FOREIGN KEY (UR_UsrId) REFERENCES ZI_GENERAL.ZI_USUARIOS(USU_Id) ON DELETE CASCADE,
    FOREIGN KEY (UR_RolId) REFERENCES ZI_GENERAL.ZI_ROLES(ROL_Id) ON DELETE CASCADE
);

GO

-- Insertar datos iniciales
INSERT INTO ZI_GENERAL.ZI_ESTADOS (EST_Nombre) VALUES ('ASIGNADO'), ('NO ASIGNADO'), ('TRANSFERIDO'), ('LEASING');
INSERT INTO ZI_GENERAL.ZI_BODEGAS (BOD_Nombre, BOD_Ubicacion) VALUES ('BODEGA PRINCIPAL', 'DEPARTAMENTO DE IT');
INSERT INTO ZI_GENERAL.ZI_CATEGORIAS (CAT_Nombre, CAT_Descripcion) VALUES ('COMPUTADORAS', 'EQUIPOS DE COMPUTO'), ('REDES', 'EQUIPOS DE RED'), ('IMPRESORAS', 'DISPOSITIVOS DE IMPRESION'), ('PERIFERICOS', 'ACCESORIOS');
INSERT INTO ZI_GENERAL.ZI_SUBCATEGORIAS (SUB_Nombre, SUB_CategoriaId) VALUES 
('LAPTOPS', 1), ('ESCRITORIOS', 1), ('SERVIDORES', 1),
('ROUTERS', 2), ('SWITCHES', 2), ('PUNTOS DE ACCESO', 2),
('IMPRESORAS LASER', 3), ('IMPRESORAS DE TINTA', 3),
('MONITORES', 4), ('TECLADOS', 4), ('MOUSES', 4);

GO

-- Insertar datos de configuración
INSERT INTO ZI_GENERAL.ZI_CONFIGURACION (ZIC_Clave, ZIC_Valor, ZIC_Descripcion, ZIC_Tipo, ZIC_UsuarioCreacion) VALUES 
('ENCRYPT_KEY', 'MilesimoDev2024PortalSecureKey123!', 'Clave principal para encriptación AES', 'STRING', 'SYSTEM'),
('ENCRYPT_SALT', 'Portal_Milesimo_Salt_2024_Secure', 'Salt para encriptación de contraseñas', 'STRING', 'SYSTEM'),
('ENCRYPT_IV', 'Milesimo_IV_2024', 'Vector inicial para encriptación AES', 'STRING', 'SYSTEM'),
('SISTEMA_NOMBRE', 'Portal Milésimo', 'Nombre del sistema', 'STRING', 'SYSTEM'),
('SISTEMA_VERSION', '1.0.0', 'Versión actual del sistema', 'STRING', 'SYSTEM'),
('HABILITAR_AUDITORIA', 'true', 'Indica si la auditoría está habilitada', 'BOOL', 'SYSTEM'),
('MAX_INTENTOS_LOGIN', '5', 'Máximo número de intentos de login fallidos', 'INT', 'SYSTEM'),
('TIEMPO_BLOQUEO_MINUTOS', '30', 'Tiempo en minutos de bloqueo por intentos fallidos', 'INT', 'SYSTEM');

-- Insertar roles
INSERT INTO ZI_GENERAL.ZI_ROLES (ROL_Nombre, ROL_Descripcion, ROL_UsuarioCreacion) VALUES 
('Administrador', 'Rol con acceso completo al sistema', 'SYSTEM'),
('Usuario', 'Rol básico de usuario del sistema', 'SYSTEM'),
('Consulta', 'Rol solo de consulta, sin permisos de modificación', 'SYSTEM');

-- Insertar permisos
INSERT INTO ZI_GENERAL.ZI_PERMISOS (PER_Nombre, PER_Descripcion, PER_Modulo, PER_Accion, PER_UsuarioCreacion) VALUES 
('USUARIOS_CREAR', 'Crear usuarios', 'USUARIOS', 'CREAR', 'SYSTEM'),
('USUARIOS_LEER', 'Consultar usuarios', 'USUARIOS', 'LEER', 'SYSTEM'),
('USUARIOS_ACTUALIZAR', 'Actualizar usuarios', 'USUARIOS', 'ACTUALIZAR', 'SYSTEM'),
('USUARIOS_ELIMINAR', 'Eliminar usuarios', 'USUARIOS', 'ELIMINAR', 'SYSTEM'),
('ROLES_CREAR', 'Crear roles', 'ROLES', 'CREAR', 'SYSTEM'),
('ROLES_LEER', 'Consultar roles', 'ROLES', 'LEER', 'SYSTEM'),
('ROLES_ACTUALIZAR', 'Actualizar roles', 'ROLES', 'ACTUALIZAR', 'SYSTEM'),
('ROLES_ELIMINAR', 'Eliminar roles', 'ROLES', 'ELIMINAR', 'SYSTEM'),
('CONFIGURACION_LEER', 'Consultar configuraciones', 'CONFIGURACION', 'LEER', 'SYSTEM'),
('CONFIGURACION_ACTUALIZAR', 'Actualizar configuraciones', 'CONFIGURACION', 'ACTUALIZAR', 'SYSTEM'),
('AUDITORIA_LEER', 'Consultar bitácora de auditoría', 'AUDITORIA', 'LEER', 'SYSTEM');

-- Insertar permisos-roles
INSERT INTO ZI_GENERAL.ZI_PERMISOSROLES (PRO_RolId, PRO_PermisoId) VALUES 
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),
(2,2),(2,6),(2,9),(2,11),
(3,2),(3,6);

-- Insertar usuarios
INSERT INTO ZI_GENERAL.ZI_USUARIOS (USU_Codigo, USU_Username, USU_PasswordEncrypted, USU_Nombre, USU_Apellido, USU_Correo, USU_UsuarioCreacion, USU_PassTemp) VALUES 
(1, 'admin', 'rtMYxD8D6iLwvDHbTkpxRQ==', 'Administrador', 'Sistema', 'admin@milesimo.com', 'SYSTEM', 0),
(3, 'mchopen', '/4t3dPzCsHQ7dnX2UQBgsg==', 'MARIA', 'CHOPEN', 'mchopen@milesimo.com.gt', 'SYSTEM', 1),
(4, 'acaseros', 'D31DO6Gqa2GgmxFpsStGkQ==', 'ANDREA', 'CASEROS', 'acaseros@milesimo.com.gt', 'SYSTEM', 0),
(5, 'lbarreda', 'aQgDVftdftzo0ywRsKKMhw==', 'MAYTE', 'BARREDA', 'lbarreda@milesimo.com.gt', 'SYSTEM', 1),
(6, 'khigueros', 'KGxllLwDhwXvGrSV5jkabA==', 'KENIA', 'HIGUEROS', 'khigueros@milesimo.com.gt', 'SYSTEM', 1),
(7, 'asoliz', 'rA4W81DxszGaqaytBWOPiw==', 'ALEJANDRA', 'SOLIZ', 'temp@milesimo.com.gt', 'SYSTEM', 1),
(8, 'rlemus', 'd2JcLUyrfOzWD9MXHsAZog==', 'RENE', 'LEMUS', 'rlemus@milesimo.com.gt', 'SYSTEM', 1),
(9, 'lblopez', 'TmzF7+Zmoq5k+/EDbRHORA==', 'BELINDA', 'LOPEZ', 'lblopez@milesimo.com.gt', 'SYSTEM', 1),
(10, 'wsalguero', 'xXFkg8+2ZBl6uJsxGFx0lg==', 'Wesley', 'Salguero', 'wsalguero@milesimo.com.gt', 'SYSTEM', 0);

-- Insertar usuarios-roles
INSERT INTO ZI_GENERAL.ZI_USUARIOSROLES (UR_UsrId, UR_RolId, UR_UsuarioCreacion) VALUES 
(1,1, 'SYSTEM'),
(9,2, 'SYSTEM'),
(8,2, 'SYSTEM'),
(7,2, 'SYSTEM'),
(6,2, 'SYSTEM'),
(5,2, 'SYSTEM'),
(3,2, 'SYSTEM'),
(4,2, 'SYSTEM'),
(10,2, 'SYSTEM');

GO

-- Procedimientos almacenados con transacciones para cumplimiento de ACID
CREATE PROCEDURE ZI_GENERAL.SP_Ingresos_Create
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
    @DetalleEquipo ZI_GENERAL.T_DETALLE_EQUIPO READONLY,
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

        INSERT INTO ZI_GENERAL.ZI_INGRESOS (ING_Usuario, ING_Host, ING_Dominio, ING_BodegaId, ING_Fecha, ING_Hora, ING_Descripcion, ING_Estado, ING_TipoIngreso)
        OUTPUT INSERTED.ING_Id INTO @InsertedIds
        VALUES (@Usuario, @Host, @Dominio, @BodegaId, @Fecha, @Hora, @Descripcion, @Estado, @TipoIngreso)

        SELECT @IdMovimiento = Id FROM @InsertedIds

        INSERT INTO ZI_GENERAL.ZI_EQUIPOS (EQU_Serie, EQU_ModeloId, EQU_ContratoId, EQU_BodegaId, EQU_EstadoEquipo, EQU_Descripcion, EQU_Estado)
        SELECT DET_Serie, DET_ModeloId, DET_ContratoId, DET_BodegaId, DET_EstadoEquipo, DET_Descripcion, DET_Estado FROM @DetalleEquipo

        INSERT INTO ZI_GENERAL.ZI_KARDEXEQUIPO (KAR_MovId, KAR_Serie, KAR_TipoMov, KAR_BodegaId, KAR_Estado)
        SELECT @IdMovimiento, DET_Serie, @TipoMovimiento, DET_BodegaId, @Estado FROM @DetalleEquipo

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


-- Cambiar la contraseña del login existente
USE [master];
GO

ALTER LOGIN [developer] WITH PASSWORD = 'DevM1l32025';
GO

-- Crear el usuario en la base de datos si no existe y asignar permisos
USE [DB_Zenith_Inventory];
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'developer')
BEGIN
    CREATE USER [developer] FOR LOGIN [developer];
END
GO

ALTER ROLE [db_owner] ADD MEMBER [developer];
GO

GO

-- Procedimiento para validar login de usuario
CREATE PROCEDURE ZI_GENERAL.SP_VALIDATE_USER_LOGIN
    @Username NVARCHAR(100),
    @EncryptedPassword NVARCHAR(500),
    @IpAddress NVARCHAR(45) = NULL,
    @UserAgent NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserId INT;
    DECLARE @IsBlocked BIT = 0;
    DECLARE @FailedAttempts INT = 0;
    DECLARE @MaxAttempts INT;
    DECLARE @BlockTimeMinutes INT;
    DECLARE @LastBlockTime DATETIME2;
    DECLARE @CurrentTime DATETIME2 = GETDATE();
    DECLARE @Result NVARCHAR(50) = 'ERROR';
    DECLARE @Message NVARCHAR(500) = '';
    
    BEGIN TRY
        -- Obtener configuraciones de seguridad
        SELECT @MaxAttempts = CAST(ZIC_VALOR AS INT) 
        FROM ZI_GENERAL.ZI_CONFIGURACION 
        WHERE ZIC_CLAVE = 'MAX_INTENTOS_LOGIN' AND ZIC_ACTIVO = 1;
        
        SELECT @BlockTimeMinutes = CAST(ZIC_VALOR AS INT) 
        FROM ZI_GENERAL.ZI_CONFIGURACION 
        WHERE ZIC_CLAVE = 'TIEMPO_BLOQUEO_MINUTOS' AND ZIC_ACTIVO = 1;
        
        SET @MaxAttempts = ISNULL(@MaxAttempts, 5);
        SET @BlockTimeMinutes = ISNULL(@BlockTimeMinutes, 30);
        
        -- Buscar usuario
        SELECT 
            @UserId = USU_Id,
            @IsBlocked = USU_Bloqueado,
            @FailedAttempts = USU_IntentosFallidos,
            @LastBlockTime = USU_FechaBloqueo
        FROM ZI_GENERAL.ZI_USUARIOS 
        WHERE USU_Username = @Username AND USU_Activo = 1;
        
        -- Verificar si el usuario existe
        IF @UserId IS NULL
        BEGIN
            SET @Result = 'ERROR';
            SET @Message = 'Usuario no encontrado o inactivo';
            
            -- Registrar intento fallido en bitácora
            INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
            VALUES (NULL, 'LOGIN', 'AUTENTICACION', 0, 'Intento de login con usuario inexistente: ' + @Username, @CurrentTime);
            
            SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
            RETURN;
        END
        
        -- Verificar si está bloqueado y si ya pasó el tiempo de bloqueo
        IF @IsBlocked = 1 AND @LastBlockTime IS NOT NULL
        BEGIN
            IF DATEDIFF(MINUTE, @LastBlockTime, @CurrentTime) >= @BlockTimeMinutes
            BEGIN
                -- Desbloquear usuario
                UPDATE ZI_GENERAL.ZI_USUARIOS 
                SET USU_Bloqueado = 0, 
                    USU_IntentosFallidos = 0,
                    USU_FechaBloqueo = NULL
                WHERE USU_Id = @UserId;
                
                SET @IsBlocked = 0;
                SET @FailedAttempts = 0;
            END
            ELSE
            BEGIN
                SET @Result = 'ERROR';
                SET @Message = 'Usuario bloqueado. Intente nuevamente en ' + CAST(@BlockTimeMinutes - DATEDIFF(MINUTE, @LastBlockTime, @CurrentTime) AS NVARCHAR(10)) + ' minutos.';
                
                -- Registrar intento en usuario bloqueado
                INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
                VALUES (@UserId, 'LOGIN', 'AUTENTICACION', @UserId, 'Intento de login en usuario bloqueado', @CurrentTime);
                
                SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
                RETURN;
            END
        END
        
        -- Verificar contraseña
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Id = @UserId AND USU_PasswordEncrypted = @EncryptedPassword)
        BEGIN
            -- Login exitoso
            UPDATE ZI_GENERAL.ZI_USUARIOS 
            SET USU_UltimoLogin = @CurrentTime,
                USU_IntentosFallidos = 0,
                USU_Bloqueado = 0,
                USU_FechaBloqueo = NULL
            WHERE USU_Id = @UserId;
            
            SET @Result = 'EXITO';
            SET @Message = 'Login exitoso';
            
            -- Registrar login exitoso
            INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
            VALUES (@UserId, 'LOGIN', 'AUTENTICACION', @UserId, 'Login exitoso', @CurrentTime);
            
            SELECT @Result as Resultado, @Message as Mensaje, @UserId as UserId;
        END
        ELSE
        BEGIN
            -- Contraseña incorrecta
            SET @FailedAttempts = @FailedAttempts + 1;
            
            IF @FailedAttempts >= @MaxAttempts
            BEGIN
                -- Bloquear usuario
                UPDATE ZI_GENERAL.ZI_USUARIOS 
                SET USU_IntentosFallidos = @FailedAttempts,
                    USU_Bloqueado = 1,
                    USU_FechaBloqueo = @CurrentTime
                WHERE USU_Id = @UserId;
                
                SET @Result = 'ERROR';
                SET @Message = 'Usuario bloqueado por exceder intentos máximos de login. Intente en ' + CAST(@BlockTimeMinutes AS NVARCHAR(10)) + ' minutos.';
            END
            ELSE
            BEGIN
                -- Incrementar intentos fallidos
                UPDATE ZI_GENERAL.ZI_USUARIOS 
                SET USU_IntentosFallidos = @FailedAttempts
                WHERE USU_Id = @UserId;
                
                SET @Result = 'ERROR';
                SET @Message = 'Contraseña incorrecta. Intentos restantes: ' + CAST(@MaxAttempts - @FailedAttempts AS NVARCHAR(10));
            END
            
            -- Registrar intento fallido
            INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
            VALUES (@UserId, 'LOGIN', 'AUTENTICACION', @UserId, 'Intento de login fallido', @CurrentTime);
            
            SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
        END
        
    END TRY
    BEGIN CATCH
        SET @Result = 'ERROR';
        SET @Message = 'Error interno del sistema: ' + ERROR_MESSAGE();
        
        -- Registrar error en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (@UserId, 'LOGIN', 'AUTENTICACION', ISNULL(@UserId, 0), 'Error en proceso de login', @CurrentTime);
        
        SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
    END CATCH
END

GO

-- Procedimiento para obtener configuración de encriptación
CREATE PROCEDURE ZI_GENERAL.SP_GET_ENCRYPTION_CONFIG
AS
BEGIN
    SELECT ZIC_Clave, ZIC_Valor
    FROM ZI_GENERAL.ZI_CONFIGURACION
    WHERE ZIC_Clave IN ('ENCRYPT_KEY', 'ENCRYPT_SALT', 'ENCRYPT_IV')
    AND ZIC_Activo = 1
END

GO

-- Procedimiento para cambiar contraseña
CREATE PROCEDURE ZI_GENERAL.SP_CHANGE_PASSWORD
    @UserId INT,
    @NewEncryptedPassword NVARCHAR(500),
    @ModifiedBy NVARCHAR(100),
    @IpAddress NVARCHAR(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Result NVARCHAR(50) = 'ERROR';
    DECLARE @Message NVARCHAR(500) = '';
    DECLARE @Username NVARCHAR(100);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verificar si el usuario existe
        SELECT @Username = USU_Username 
        FROM ZI_GENERAL.ZI_USUARIOS 
        WHERE USU_Id = @UserId AND USU_Activo = 1;
        
        IF @Username IS NULL
        BEGIN
            SET @Message = 'Usuario no encontrado o inactivo';
            ROLLBACK TRANSACTION;
            SELECT @Result as Resultado, @Message as Mensaje;
            RETURN;
        END
        
        -- Actualizar contraseña
        UPDATE ZI_GENERAL.ZI_USUARIOS 
        SET USU_PasswordEncrypted = @NewEncryptedPassword,
            USU_FechaModificacion = GETDATE(),
            USU_UsuarioModificacion = @ModifiedBy,
            USU_IpModificacion = @IpAddress,
            USU_IntentosFallidos = 0,
            USU_Bloqueado = 0,
            USU_FechaBloqueo = NULL,
            USU_PassTemp = 0
        WHERE USU_Id = @UserId;
        
        -- Registrar en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (@UserId, 'CAMBIAR_PASSWORD', 'USUARIOS', @UserId, 'Contraseña cambiada para usuario: ' + @Username, GETDATE());
        
        SET @Result = 'EXITO';
        SET @Message = 'Contraseña actualizada exitosamente';
        
        COMMIT TRANSACTION;
        SELECT @Result as Resultado, @Message as Mensaje;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Message = 'Error al cambiar contraseña: ' + ERROR_MESSAGE();
        
        -- Registrar error en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (@UserId, 'CAMBIAR_PASSWORD', 'USUARIOS', ISNULL(@UserId, 0), 'Error al cambiar contraseña: ' + ISNULL(@Username, 'ID:' + CAST(@UserId AS NVARCHAR(10))), GETDATE());
        
        SELECT @Result as Resultado, @Message as Mensaje;
    END CATCH
END

GO

-- Procedimiento para crear usuario
CREATE PROCEDURE ZI_GENERAL.SP_CREATE_USER
    @Username NVARCHAR(100),
    @EncryptedPassword NVARCHAR(500),
    @Nombre NVARCHAR(150),
    @Apellido NVARCHAR(150),
    @Email NVARCHAR(255),
    @Telefono NVARCHAR(20) = NULL,
    @CreatedBy NVARCHAR(100),
    @IpAddress NVARCHAR(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserId INT;
    DECLARE @Result NVARCHAR(50) = 'ERROR';
    DECLARE @Message NVARCHAR(500) = '';
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verificar si el username ya existe
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Username = @Username)
        BEGIN
            SET @Message = 'El nombre de usuario ya existe';
            ROLLBACK TRANSACTION;
            SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
            RETURN;
        END
        
        -- Verificar si el email ya existe
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Correo = @Email)
        BEGIN
            SET @Message = 'El email ya está registrado';
            ROLLBACK TRANSACTION;
            SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
            RETURN;
        END
        
        -- Insertar usuario
        INSERT INTO ZI_GENERAL.ZI_USUARIOS (
            USU_Username, USU_PasswordEncrypted, USU_Nombre, USU_Apellido, 
            USU_Correo, USU_Telefono, USU_UsuarioCreacion, USU_IpCreacion,
            USU_PassTemp
        ) VALUES (
            @Username, @EncryptedPassword, @Nombre, @Apellido, 
            @Email, @Telefono, @CreatedBy, @IpAddress,
            1
        );
        
        SET @UserId = SCOPE_IDENTITY();
        
        -- Registrar en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (@UserId, 'CREAR', 'USUARIOS', @UserId, 'Usuario creado: ' + @Username, GETDATE());
        
        SET @Result = 'EXITO';
        SET @Message = 'Usuario creado exitosamente';
        
        COMMIT TRANSACTION;
        SELECT @Result as Resultado, @Message as Mensaje, @UserId as UserId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Message = 'Error al crear usuario: ' + ERROR_MESSAGE();
        
        -- Registrar error en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (NULL, 'CREAR', 'USUARIOS', 0, 'Error al crear usuario: ' + @Username, GETDATE());
        
        SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
    END CATCH
END

GO

-- Procedimiento para obtener información de un usuario
CREATE PROCEDURE ZI_GENERAL.SP_GET_USER_INFO
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Información del usuario
         SELECT 
            USU_Id,
            USU_Username,
            USU_PasswordEncrypted,
            USU_Nombre,
            USU_Apellido,
            USU_Correo,
            USU_Telefono,
            USU_Activo,
            USU_UltimoLogin,
            USU_IntentosFallidos,
            USU_Bloqueado,
            USU_FechaBloqueo,
            USU_PassTemp,
            USU_FechaCreacion,
            USU_UsuarioCreacion,
            USU_FechaModificacion,
            USU_UsuarioModificacion,
            USU_IpCreacion,
            USU_IpModificacion
        FROM ZI_GENERAL.ZI_USUARIOS 
        WHERE USU_Id = @UserId AND USU_Activo = 1;
        
        -- Roles del usuario
        SELECT 
            r.ROL_Id,
            r.ROL_Nombre,
            r.ROL_Descripcion,
            r.ROL_Activo
        FROM ZI_GENERAL.ZI_ROLES r
        INNER JOIN ZI_GENERAL.ZI_USUARIOSROLES ur ON r.ROL_Id = ur.UR_RolId
        WHERE ur.UR_UsrId = @UserId 
        AND r.ROL_Activo = 1 
        AND ur.UR_Activo = 1;
        
        -- Permisos del usuario
        SELECT DISTINCT
            p.PER_Id,
            p.PER_Nombre,
            p.PER_Descripcion,
            p.PER_Modulo,
            p.PER_Accion,
            p.PER_Activo
        FROM ZI_GENERAL.ZI_PERMISOS p
        INNER JOIN ZI_GENERAL.ZI_PERMISOSROLES pr ON p.PER_Id = pr.PRO_PermisoId
        INNER JOIN ZI_GENERAL.ZI_USUARIOSROLES ur ON pr.PRO_RolId = ur.UR_RolId
        WHERE ur.UR_UsrId = @UserId 
        AND p.PER_Activo = 1 
        AND pr.RP_Activo = 1 
        AND ur.UR_Activo = 1;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END