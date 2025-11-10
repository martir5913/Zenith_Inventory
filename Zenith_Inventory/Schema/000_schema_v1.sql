USE [master]
GO
CREATE DATABASE [DB_Zenith_Inventory]
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  User [developer]    Script Date: 7/11/2025 12:38:31 ******/
CREATE USER [developer] FOR LOGIN [developer] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [dba]    Script Date: 7/11/2025 12:38:31 ******/
CREATE USER [dba] FOR LOGIN [dba] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [developer]
GO
ALTER ROLE [db_owner] ADD MEMBER [dba]
GO
/****** Object:  Schema [ZI_GENERAL]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SCHEMA [ZI_GENERAL]
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Agentes]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Agentes] 
 AS [bigint]
 START WITH 4
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_BitacoraAuditoria]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_BitacoraAuditoria] 
 AS [bigint]
 START WITH 3
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Bodegas]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Bodegas] 
 AS [bigint]
 START WITH 3
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Categorias]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Categorias] 
 AS [bigint]
 START WITH 5
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Contratos]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Contratos] 
 AS [bigint]
 START WITH 3
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_DetalleDevolucion]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_DetalleDevolucion] 
 AS [bigint]
 START WITH 2
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_DetalleEgreso]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_DetalleEgreso] 
 AS [bigint]
 START WITH 3
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Devoluciones]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Devoluciones] 
 AS [bigint]
 START WITH 2
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Egresos]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Egresos] 
 AS [bigint]
 START WITH 3
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Equipos]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Equipos] 
 AS [bigint]
 START WITH 9
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Estados]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Estados] 
 AS [bigint]
 START WITH 6
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Ingresos]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Ingresos] 
 AS [bigint]
 START WITH 3
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_KardexEquipo]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_KardexEquipo] 
 AS [bigint]
 START WITH 5
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_KardexUsuarios]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_KardexUsuarios] 
 AS [bigint]
 START WITH 3
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Marcas]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Marcas] 
 AS [bigint]
 START WITH 5
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Modelos]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Modelos] 
 AS [bigint]
 START WITH 12
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Permisos]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Permisos] 
 AS [bigint]
 START WITH 17
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Roles]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Roles] 
 AS [bigint]
 START WITH 6
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Subcategorias]    Script Date: 7/11/2025 12:38:31 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Subcategorias] 
 AS [bigint]
 START WITH 12
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_TiposSalida]    Script Date: 7/11/2025 12:38:32 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_TiposSalida] 
 AS [bigint]
 START WITH 4
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_Usuarios]    Script Date: 7/11/2025 12:38:32 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_Usuarios] 
 AS [bigint]
 START WITH 13
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_ZI_Configuracion]    Script Date: 7/11/2025 12:38:32 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_ZI_Configuracion] 
 AS [bigint]
 START WITH 9
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  Sequence [ZI_GENERAL].[Seq_ZI_UsuariosRoles]    Script Date: 7/11/2025 12:38:32 ******/
CREATE SEQUENCE [ZI_GENERAL].[Seq_ZI_UsuariosRoles] 
 AS [bigint]
 START WITH 1
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 NO CACHE 
GO
/****** Object:  UserDefinedTableType [ZI_GENERAL].[T_DETALLE_EGRESO]    Script Date: 7/11/2025 12:38:32 ******/
CREATE TYPE [ZI_GENERAL].[T_DETALLE_EGRESO] AS TABLE(
	[DEG_EquipoId] [int] NOT NULL,
	[DEG_Serie] [varchar](252) NOT NULL,
	[DEG_TipoSalidaId] [int] NOT NULL,
	[DEG_Estado] [bit] NOT NULL
)
GO
/****** Object:  UserDefinedTableType [ZI_GENERAL].[T_DETALLE_EQUIPO]    Script Date: 7/11/2025 12:38:32 ******/
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
/****** Object:  Table [ZI_GENERAL].[ZI_AGENTES]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_AGENTES](
	[AGE_Id] [int] NOT NULL,
	[AGE_Nombre] [nvarchar](100) NOT NULL,
	[AGE_Correo] [nvarchar](100) NOT NULL,
	[AGE_RolId] [int] NOT NULL,
	[AGE_FechaCreacion] [datetime] NULL,
	[AGE_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[AGE_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_BITACORAAUDITORIA]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_BITACORAAUDITORIA](
	[BIT_Id] [int] NOT NULL,
	[BIT_AgenteId] [int] NULL,
	[BIT_Accion] [nvarchar](100) NOT NULL,
	[BIT_Entidad] [nvarchar](100) NOT NULL,
	[BIT_EntidadId] [int] NOT NULL,
	[BIT_Detalles] [nvarchar](500) NULL,
	[BIT_ValoresAntiguos] [nvarchar](max) NULL,
	[BIT_ValoresNuevos] [nvarchar](max) NULL,
	[BIT_FechaHora] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[BIT_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_BODEGAS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_BODEGAS](
	[BOD_Id] [int] NOT NULL,
	[BOD_Nombre] [nvarchar](100) NOT NULL,
	[BOD_Ubicacion] [nvarchar](255) NULL,
	[BOD_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[BOD_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_CATEGORIAS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_CATEGORIAS](
	[CAT_Id] [int] NOT NULL,
	[CAT_Nombre] [nvarchar](100) NOT NULL,
	[CAT_Descripcion] [nvarchar](255) NULL,
	[CAT_Estado] [bit] NULL,
	[CAT_FechaCreacion] [datetime] NULL,
	[CAT_UsuarioCreacion] [nvarchar](100) NOT NULL,
	[CAT_FechaModificacion] [datetime] NULL,
	[CAT_UsuarioModificacion] [nvarchar](100) NULL,
	[CAT_IpCreacion] [nvarchar](45) NULL,
	[CAT_IpModificacion] [nvarchar](45) NULL,
PRIMARY KEY CLUSTERED 
(
	[CAT_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_CONFIGURACION]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_CONFIGURACION](
	[ZIC_Id] [int] NOT NULL,
	[ZIC_Clave] [nvarchar](100) NOT NULL,
	[ZIC_Valor] [nvarchar](1000) NOT NULL,
	[ZIC_Descripcion] [nvarchar](500) NULL,
	[ZIC_Tipo] [nvarchar](50) NULL,
	[ZIC_Activo] [bit] NULL,
	[ZIC_FechaCreacion] [datetime] NULL,
	[ZIC_UsuarioCreacion] [nvarchar](100) NOT NULL,
	[ZIC_FechaModificacion] [datetime] NULL,
	[ZIC_UsuarioModificacion] [nvarchar](100) NULL,
	[ZIC_IpCreacion] [nvarchar](45) NULL,
	[ZIC_IpModificacion] [nvarchar](45) NULL,
PRIMARY KEY CLUSTERED 
(
	[ZIC_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_CONTRATOS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_CONTRATOS](
	[CON_Id] [int] NOT NULL,
	[CON_Nombre] [nvarchar](100) NOT NULL,
	[CON_Descripcion] [nvarchar](255) NULL,
	[CON_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[CON_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_DETALLEDEVOLUCION]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_DETALLEDEVOLUCION](
	[DDE_Id] [int] NOT NULL,
	[DDE_DevolucionId] [int] NOT NULL,
	[DDE_EquipoId] [int] NOT NULL,
	[DDE_EstadoEquipo] [int] NOT NULL,
	[DDE_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[DDE_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_DETALLEEGRESO]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_DETALLEEGRESO](
	[DEG_Id] [int] NOT NULL,
	[DEG_EgresoId] [int] NOT NULL,
	[DEG_EquipoId] [int] NOT NULL,
	[DEG_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[DEG_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_DEVOLUCIONES]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_DEVOLUCIONES](
	[DEV_Id] [int] NOT NULL,
	[DEV_EgresoId] [int] NOT NULL,
	[DEV_Fecha] [nvarchar](20) NULL,
	[DEV_Hora] [nvarchar](20) NULL,
	[DEV_Path] [nvarchar](512) NULL,
	[DEV_EstadoEquipo] [int] NULL,
	[DEV_Agente] [nvarchar](80) NULL,
	[DEV_Descripcion] [nvarchar](500) NULL,
	[DEV_Adjunto] [bit] NOT NULL,
	[DEV_Estado] [bit] NULL,
	[DEV_BodegaId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[DEV_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_EGRESOS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_EGRESOS](
	[EGR_Id] [int] NOT NULL,
	[EGR_UsuarioId] [int] NOT NULL,
	[EGR_ViceId] [int] NOT NULL,
	[EGR_BodegaId] [int] NOT NULL,
	[EGR_TipoSalidaId] [int] NOT NULL,
	[EGR_Usuario] [nvarchar](20) NULL,
	[EGR_Host] [nvarchar](20) NULL,
	[EGR_Fecha] [nvarchar](20) NULL,
	[EGR_Hora] [nvarchar](20) NULL,
	[EGR_Path] [nvarchar](512) NULL,
	[EGR_Adjunto] [bit] NOT NULL,
	[EGR_Descripcion] [nvarchar](500) NULL,
	[EGR_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[EGR_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_EQUIPOS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_EQUIPOS](
	[EQU_Id] [int] NOT NULL,
	[EQU_Serie] [nvarchar](252) NOT NULL,
	[EQU_ModeloId] [int] NOT NULL,
	[EQU_ContratoId] [int] NOT NULL,
	[EQU_BodegaId] [int] NOT NULL,
	[EQU_TipoSalidaId] [int] NULL,
	[EQU_EstadoEquipo] [int] NOT NULL,
	[EQU_Descripcion] [nvarchar](500) NULL,
	[EQU_Fecha] [datetime] NULL,
	[EQU_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[EQU_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_ESTADOS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_ESTADOS](
	[EST_Id] [int] NOT NULL,
	[EST_Nombre] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EST_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_INGRESOS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_INGRESOS](
	[ING_Id] [int] NOT NULL,
	[ING_Usuario] [nvarchar](25) NOT NULL,
	[ING_Host] [nvarchar](25) NOT NULL,
	[ING_Dominio] [nvarchar](25) NOT NULL,
	[ING_BodegaId] [int] NULL,
	[ING_Fecha] [nvarchar](25) NULL,
	[ING_Hora] [nvarchar](25) NULL,
	[ING_Descripcion] [nvarchar](500) NULL,
	[ING_Estado] [bit] NULL,
	[ING_TipoIngreso] [nvarchar](128) NULL,
PRIMARY KEY CLUSTERED 
(
	[ING_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_KARDEXEQUIPO]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_KARDEXEQUIPO](
	[KAR_Id] [int] NOT NULL,
	[KAR_MovId] [int] NOT NULL,
	[KAR_Serie] [nvarchar](256) NOT NULL,
	[KAR_TipoMov] [int] NOT NULL,
	[KAR_BodegaId] [int] NOT NULL,
	[KAR_Fecha] [datetime] NULL,
	[KAR_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[KAR_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_KARDEXUSUARIOS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_KARDEXUSUARIOS](
	[KUS_Id] [int] NOT NULL,
	[KUS_MovId] [int] NOT NULL,
	[KUS_UsuarioId] [nvarchar](256) NOT NULL,
	[KUS_TipoMov] [int] NOT NULL,
	[KUS_BodegaId] [int] NOT NULL,
	[KUS_Fecha] [datetime] NULL,
	[KUS_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[KUS_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_MARCAS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_MARCAS](
	[MAR_Id] [int] NOT NULL,
	[MAR_Nombre] [nvarchar](100) NOT NULL,
	[MAR_Estado] [bit] NULL,
	[MAR_FechaCreacion] [datetime] NOT NULL,
	[MAR_UsuarioCreacion] [nvarchar](100) NULL,
	[MAR_FechaModificacion] [datetime] NULL,
	[MAR_UsuarioModificacion] [nvarchar](100) NULL,
	[MAR_IpCreacion] [nvarchar](45) NULL,
	[MAR_IpModificacion] [nvarchar](45) NULL,
	[MAR_Descripcion] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[MAR_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_MODELOS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_MODELOS](
	[MOD_Id] [int] NOT NULL,
	[MOD_Nombre] [nvarchar](100) NOT NULL,
	[MOD_MarcaId] [int] NOT NULL,
	[MOD_Estado] [bit] NULL,
	[MOD_Descripcion] [nvarchar](500) NULL,
	[MOD_FechaCreacion] [datetime] NOT NULL,
	[MOD_UsuarioCreacion] [nvarchar](100) NULL,
	[MOD_FechaModificacion] [datetime] NULL,
	[MOD_UsuarioModificacion] [nvarchar](100) NULL,
	[MOD_IpCreacion] [nvarchar](45) NULL,
	[MOD_IpModificacion] [nvarchar](45) NULL,
	[MOD_SubcategoriaId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MOD_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_PERMISOS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_PERMISOS](
	[PER_Id] [int] NOT NULL,
	[PER_Nombre] [nvarchar](50) NOT NULL,
	[PER_Descripcion] [nvarchar](255) NULL,
	[PER_Modulo] [nvarchar](100) NULL,
	[PER_Accion] [nvarchar](100) NULL,
	[PER_Estado] [bit] NULL,
	[PER_Activo] [bit] NULL,
	[PER_FechaCreacion] [datetime] NULL,
	[PER_UsuarioCreacion] [nvarchar](100) NOT NULL,
	[PER_FechaModificacion] [datetime] NULL,
	[PER_UsuarioModificacion] [nvarchar](100) NULL,
	[PER_IpCreacion] [nvarchar](45) NULL,
	[PER_IpModificacion] [nvarchar](45) NULL,
PRIMARY KEY CLUSTERED 
(
	[PER_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_PERMISOSROLES]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_PERMISOSROLES](
	[PRO_RolId] [int] NOT NULL,
	[PRO_PermisoId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PRO_RolId] ASC,
	[PRO_PermisoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_ROLES]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_ROLES](
	[ROL_Id] [int] NOT NULL,
	[ROL_Nombre] [nvarchar](50) NOT NULL,
	[ROL_Descripcion] [nvarchar](255) NULL,
	[ROL_Activo] [bit] NULL,
	[ROL_FechaCreacion] [datetime] NULL,
	[ROL_UsuarioCreacion] [nvarchar](100) NOT NULL,
	[ROL_FechaModificacion] [datetime] NULL,
	[ROL_UsuarioModificacion] [nvarchar](100) NULL,
	[ROL_IpCreacion] [nvarchar](45) NULL,
	[ROL_IpModificacion] [nvarchar](45) NULL,
PRIMARY KEY CLUSTERED 
(
	[ROL_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_SUBCATEGORIAS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_SUBCATEGORIAS](
	[SUB_Id] [int] NOT NULL,
	[SUB_Nombre] [nvarchar](100) NOT NULL,
	[SUB_CategoriaId] [int] NOT NULL,
	[SUB_Descripcion] [nvarchar](255) NULL,
	[SUB_Estado] [bit] NULL,
	[SUB_FechaCreacion] [datetime] NOT NULL,
	[SUB_UsuarioCreacion] [nvarchar](100) NULL,
	[SUB_FechaModificacion] [datetime] NULL,
	[SUB_UsuarioModificacion] [nvarchar](100) NULL,
	[SUB_IpCreacion] [nvarchar](45) NULL,
	[SUB_IpModificacion] [nvarchar](45) NULL,
PRIMARY KEY CLUSTERED 
(
	[SUB_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_TIPOSSALIDA]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_TIPOSSALIDA](
	[TSA_Id] [int] NOT NULL,
	[TSA_Nombre] [nvarchar](100) NOT NULL,
	[TSA_Descripcion] [nvarchar](255) NULL,
	[TSA_Estado] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[TSA_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_USUARIOS]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_USUARIOS](
	[USU_Id] [int] NOT NULL,
	[USU_Codigo] [int] NOT NULL,
	[USU_Username] [nvarchar](100) NOT NULL,
	[USU_Nombre] [nvarchar](100) NOT NULL,
	[USU_Correo] [nvarchar](100) NOT NULL,
	[USU_Departamento] [nvarchar](100) NULL,
	[USU_Puesto] [nvarchar](100) NULL,
	[USU_FechaCreacion] [datetime] NULL,
	[USU_Activo] [bit] NULL,
	[USU_Bloqueado] [bit] NULL,
	[USU_IntentosFallidos] [int] NULL,
	[USU_FechaBloqueo] [datetime] NULL,
	[USU_UltimoLogin] [datetime] NULL,
	[USU_PasswordEncrypted] [nvarchar](500) NULL,
	[USU_PassTemp] [bit] NULL,
	[USU_Estado] [bit] NULL,
	[USU_Apellido] [nvarchar](150) NULL,
	[USU_Telefono] [nvarchar](20) NULL,
	[USU_UsuarioCreacion] [nvarchar](100) NOT NULL,
	[USU_FechaModificacion] [datetime] NULL,
	[USU_UsuarioModificacion] [nvarchar](100) NULL,
	[USU_IpCreacion] [nvarchar](45) NULL,
	[USU_IpModificacion] [nvarchar](45) NULL,
PRIMARY KEY CLUSTERED 
(
	[USU_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ZI_GENERAL].[ZI_USUARIOSROLES]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ZI_GENERAL].[ZI_USUARIOSROLES](
	[UR_Id] [int] NOT NULL,
	[UR_UsrId] [int] NOT NULL,
	[UR_RolId] [int] NOT NULL,
	[UR_FechaAsignacion] [datetime] NULL,
	[UR_Activo] [bit] NULL,
	[UR_UsuarioCreacion] [nvarchar](100) NOT NULL,
	[UR_IpCreacion] [nvarchar](45) NULL,
	[UR_FechaModificacion] [datetime] NULL,
	[UR_UsuarioModificacion] [nvarchar](100) NULL,
	[UR_IpModificacion] [nvarchar](45) NULL,
PRIMARY KEY CLUSTERED 
(
	[UR_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [ZI_GENERAL].[ZI_AGENTES] ([AGE_Id], [AGE_Nombre], [AGE_Correo], [AGE_RolId], [AGE_FechaCreacion], [AGE_Estado]) VALUES (1, N'JUAN PEREZ', N'juan.perez@empresa.com', 1, CAST(N'2025-11-02T18:44:02.300' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_AGENTES] ([AGE_Id], [AGE_Nombre], [AGE_Correo], [AGE_RolId], [AGE_FechaCreacion], [AGE_Estado]) VALUES (2, N'MARIA GARCIA', N'maria.garcia@empresa.com', 4, CAST(N'2025-11-02T18:47:18.557' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_AGENTES] ([AGE_Id], [AGE_Nombre], [AGE_Correo], [AGE_RolId], [AGE_FechaCreacion], [AGE_Estado]) VALUES (3, N'CARLOS LOPEZ', N'carlos.lopez@empresa.com', 5, CAST(N'2025-11-02T18:47:18.560' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (1, 1, N'CREAR EQUIPO', N'EQUIPOS', 1, N'EQUIPO CREADO', NULL, N'SERIE: DELL001', CAST(N'2025-11-02T18:44:02.503' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (2, 2, N'ASIGNAR EQUIPO', N'EQUIPOS', 3, N'EQUIPO ASIGNADO A USUARIO', N'ESTADO: NO ASIGNADO', N'ESTADO: ASIGNADO', CAST(N'2025-11-02T18:47:18.743' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (3, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T19:08:03.470' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (4, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-02T19:10:03.250' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (5, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-02T19:11:32.903' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (6, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-02T19:15:25.240' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (7, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T19:16:38.410' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (8, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T19:39:56.623' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (9, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T19:47:24.207' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (10, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T19:53:33.460' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (11, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:00:37.253' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (12, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:06:07.020' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (13, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:20:29.513' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (14, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:21:04.380' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (15, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:24:40.660' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (16, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:25:53.253' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (17, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:26:46.180' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (18, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:29:46.740' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (19, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:33:02.740' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (20, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-02T20:33:40.267' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (21, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:33:44.427' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (22, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:36:23.147' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (23, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:37:34.710' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (24, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-02T20:41:23.083' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (25, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-03T09:49:22.430' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (26, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T09:49:29.637' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (27, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T11:42:52.463' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (28, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T12:59:29.303' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (29, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T13:12:07.437' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (30, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T13:16:52.610' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (31, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T13:29:55.327' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (32, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T13:39:01.163' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (33, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T13:41:12.537' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (34, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T13:47:08.963' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (35, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T13:50:46.810' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (36, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T13:58:36.603' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (37, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T14:05:44.427' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (38, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T14:18:16.763' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (39, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T14:31:07.473' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (40, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T14:44:44.710' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (41, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T14:54:36.000' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (42, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T18:56:24.820' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (43, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T19:14:58.220' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (44, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T19:19:38.737' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (45, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T19:43:02.533' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (46, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T19:45:25.460' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (47, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T20:40:23.307' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (48, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T20:42:35.083' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (49, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T20:51:47.080' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (50, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T20:58:41.473' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (51, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-03T21:05:23.713' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (52, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:05:27.677' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (53, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:12:47.213' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (54, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:19:35.343' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (55, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:21:44.167' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (56, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:23:28.683' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (57, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:25:37.447' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (58, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:27:16.987' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (59, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:28:36.803' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (60, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:30:32.500' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (61, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:34:09.567' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (62, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-03T21:37:13.660' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (63, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:37:17.280' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (64, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:45:53.323' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (65, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T21:49:54.847' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (66, NULL, N'MIGRACION', N'TABLA', 0, N'Agregadas columnas de auditoría a ZI_CATEGORIAS', NULL, NULL, CAST(N'2025-11-03T21:58:36.113' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (67, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:00:50.230' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (68, NULL, N'ACTUALIZAR', N'CATEGORIAS', 1, N'Categoría actualizada: COMPUTADORA (ID: 1)', NULL, NULL, CAST(N'2025-11-03T22:02:05.763' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (69, NULL, N'ACTUALIZAR', N'CATEGORIAS', 1, N'Categoría actualizada: COMPUTADORAS (ID: 1)', NULL, NULL, CAST(N'2025-11-03T22:02:32.947' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (70, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:14:00.097' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (71, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:23:27.550' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (72, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:30:04.573' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (73, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:31:49.127' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (74, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:39:00.957' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (75, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:45:26.377' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (76, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:48:32.820' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (77, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-03T22:53:48.387' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (78, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:53:52.133' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (79, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:55:58.273' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (80, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:57:29.867' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (81, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T22:59:42.443' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (82, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:04:09.420' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (83, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:06:32.147' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (84, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:07:00.797' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (85, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:07:59.227' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (86, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-03T23:08:35.513' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (87, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:08:39.410' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (88, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:15:12.407' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (89, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-03T23:20:49.443' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (90, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:20:52.883' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (91, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:29:33.897' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (92, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:38:57.980' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (93, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:43:02.043' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (94, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:50:23.477' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (96, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:53:53.077' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (97, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:55:30.580' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (98, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-03T23:59:26.280' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (99, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T00:00:56.530' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (100, NULL, N'ACTUALIZAR', N'CATEGORIAS', 1, N'Categoría actualizada: COMPUTADORA (ID: 1)', NULL, NULL, CAST(N'2025-11-04T00:04:42.517' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (101, NULL, N'ACTUALIZAR', N'CATEGORIAS', 1, N'Categoría actualizada: COMPUTADORAs (ID: 1)', NULL, NULL, CAST(N'2025-11-04T00:05:44.653' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (102, NULL, N'ELIMINAR', N'CATEGORIAS', 5, N'Categoría eliminada: test (ID: 5)', NULL, NULL, CAST(N'2025-11-04T00:12:25.873' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (103, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T09:19:57.677' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (104, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T09:27:25.843' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (105, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T09:55:52.657' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (106, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T10:01:07.493' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (107, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T10:03:54.970' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (108, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T10:06:16.813' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (109, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T10:07:23.550' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (110, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T10:09:01.200' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (111, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T10:12:06.320' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (112, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T10:17:32.530' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (113, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-04T12:51:18.237' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (114, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T12:51:23.017' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (115, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T12:52:04.880' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (116, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T12:53:58.270' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (117, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T12:55:40.280' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (118, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T13:00:30.377' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (119, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T13:05:42.300' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (120, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T13:06:40.397' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (121, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T13:08:19.803' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (122, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T13:11:51.140' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (123, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T13:23:45.220' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (124, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-04T14:35:21.583' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (125, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T14:35:24.580' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (126, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T14:50:10.473' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (127, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T14:58:16.120' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (129, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T15:08:38.963' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (130, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T15:15:45.773' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (132, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T15:29:06.973' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (133, NULL, N'ACTUALIZAR', N'CATEGORIAS', 1, N'Categoría actualizada: COMPUTADORAS (ID: 1)', NULL, NULL, CAST(N'2025-11-04T15:29:27.313' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (134, NULL, N'CREAR', N'CATEGORIAS', 8, N'Categoría creada: IMPRESION Y ESCANEO', NULL, NULL, CAST(N'2025-11-04T15:31:50.627' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (135, NULL, N'CREAR', N'CATEGORIAS', 9, N'Categoría creada: TELEFONIA Y COMUNICACIONES', NULL, NULL, CAST(N'2025-11-04T15:34:24.817' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (136, NULL, N'ACTUALIZAR', N'CATEGORIAS', 1, N'Categoría actualizada: COMPUTO (ID: 1)', NULL, NULL, CAST(N'2025-11-04T15:36:02.733' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (137, NULL, N'ACTUALIZAR', N'CATEGORIAS', 7, N'Categoría actualizada: AUDIO Y VIDEO (ID: 7)', NULL, NULL, CAST(N'2025-11-04T15:36:30.380' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (138, NULL, N'ACTUALIZAR', N'CATEGORIAS', 3, N'Categoría actualizada: ACCESORIOS Y PERIFERICOS (ID: 3)', NULL, NULL, CAST(N'2025-11-04T15:37:35.693' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (139, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T15:43:50.937' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (140, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T15:44:34.483' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (141, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T15:55:25.283' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (142, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T15:57:46.427' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (143, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T16:10:50.150' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (144, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T16:15:43.533' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (145, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T16:25:36.367' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (146, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T16:47:57.613' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (147, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T17:27:50.920' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (148, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T17:29:41.487' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (149, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T17:37:56.207' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (150, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T17:41:20.657' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (151, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T17:48:59.690' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (152, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T17:54:31.640' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (153, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T18:01:37.253' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (154, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T18:06:41.900' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (155, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T21:23:30.770' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (156, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T21:26:16.927' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (157, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-04T21:58:43.543' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (158, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T10:44:55.427' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (159, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-05T11:31:55.313' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (160, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T11:31:58.123' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (161, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T12:22:54.583' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (162, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T14:55:59.843' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (163, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T14:57:18.367' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (164, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T15:03:34.690' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (165, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T17:05:37.563' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (166, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T17:44:44.450' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (167, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T17:54:05.787' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (168, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T18:43:14.033' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (169, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T19:40:40.583' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (170, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T20:24:37.963' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (171, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T20:26:52.140' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (172, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T20:30:26.173' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (173, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-05T20:35:05.187' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (174, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-06T11:28:52.123' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (175, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-06T11:46:51.950' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (176, NULL, N'ACTUALIZAR', N'CATEGORIAS', 1, N'Categoría actualizada: COMPUTO (ID: 1)', N'{"IdCategoria":1,"Nombre":"COMPUTO","Descripcion":"Tipos de computadoras","Activo":true}', N'{"IdCategoria":1,"Nombre":"COMPUTO","Descripcion":"COMPUTO","Activo":true}', CAST(N'2025-11-06T11:47:23.170' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (177, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-06T11:52:23.567' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (178, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-06T11:52:28.140' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (179, NULL, N'ACTUALIZAR', N'CATEGORIAS', 1, N'Categoría actualizada: COMPUTO (ID: 1)', N'{"IdCategoria":1,"Nombre":"COMPUTO","Descripcion":"COMPUTO","Activo":true}', N'{"IdCategoria":1,"Nombre":"COMPUTO","Descripcion":"COMPUTOS","Activo":true}', CAST(N'2025-11-06T11:52:52.637' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (180, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-06T12:36:15.443' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (181, NULL, N'ACTUALIZAR', N'SUBCATEGORIAS', 1, N'Subcategoría actualizada: LAPTOPS en categoría: COMPUTO (ID: 1)', N'{"IdSubcategoria":1,"Nombre":"LAPTOPS","IdCategoria":1,"NombreCategoria":"COMPUTO","Activo":true}', N'{"IdSubcategoria":1,"Nombre":"LAPTOPS","IdCategoria":1,"NombreCategoria":"COMPUTO","Descripcion":"Maquinas portátiles","Activo":true}', CAST(N'2025-11-06T12:37:08.630' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (182, NULL, N'ACTUALIZAR', N'SUBCATEGORIAS', 1, N'Subcategoría actualizada: LAPTOPS en categoría: COMPUTO (ID: 1)', N'{"IdSubcategoria":1,"Nombre":"LAPTOPS","IdCategoria":1,"NombreCategoria":"COMPUTO","Descripcion":"Maquinas portátiles","Activo":true}', N'{"IdSubcategoria":1,"Nombre":"LAPTOPS","IdCategoria":1,"NombreCategoria":"COMPUTO","Descripcion":"Maquinas portátile","Activo":true}', CAST(N'2025-11-06T12:37:56.110' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (183, NULL, N'ACTUALIZAR', N'SUBCATEGORIAS', 1, N'Subcategoría actualizada: LAPTOPS en categoría: COMPUTO (ID: 1)', N'{"IdSubcategoria":1,"Nombre":"LAPTOPS","IdCategoria":1,"NombreCategoria":"COMPUTO","Descripcion":"Maquinas portátile","Activo":true}', N'{"IdSubcategoria":1,"Nombre":"LAPTOPS","IdCategoria":1,"NombreCategoria":"COMPUTO","Descripcion":"Maquinas portátiles","Activo":true}', CAST(N'2025-11-06T12:38:51.183' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (184, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-06T12:41:47.970' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (185, NULL, N'ACTUALIZAR', N'SUBCATEGORIAS', 2, N'Subcategoría actualizada: ESCRITORIOS en categoría: COMPUTO (ID: 2)', N'{"IdSubcategoria":2,"Nombre":"ESCRITORIOS","IdCategoria":1,"NombreCategoria":"COMPUTO","Activo":true}', N'{"IdSubcategoria":2,"Nombre":"ESCRITORIOS","IdCategoria":1,"NombreCategoria":"COMPUTO","Descripcion":"Maquinas de escritorio","Activo":true}', CAST(N'2025-11-06T12:42:18.120' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (186, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-06T12:44:18.497' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (187, NULL, N'ACTUALIZAR', N'SUBCATEGORIAS', 8, N'Subcategoría actualizada: IMPRESORAS DE TINTA en categoría: ACCESORIOS Y PERIFERICOS (ID: 8)', N'{"IdSubcategoria":8,"Nombre":"IMPRESORAS DE TINTA","IdCategoria":3,"NombreCategoria":"ACCESORIOS Y PERIFERICOS","Activo":true}', N'{"IdSubcategoria":8,"Nombre":"IMPRESORAS DE TINTA","IdCategoria":3,"NombreCategoria":"ACCESORIOS Y PERIFERICOS","Descripcion":"Impresoras de inyección","Activo":true}', CAST(N'2025-11-06T12:45:23.430' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (188, NULL, N'ACTUALIZAR', N'SUBCATEGORIAS', 7, N'Subcategoría actualizada: IMPRESORAS LASER en categoría: ACCESORIOS Y PERIFERICOS (ID: 7)', N'{"IdSubcategoria":7,"Nombre":"IMPRESORAS LASER","IdCategoria":3,"NombreCategoria":"ACCESORIOS Y PERIFERICOS","Activo":true}', N'{"IdSubcategoria":7,"Nombre":"IMPRESORAS LASER","IdCategoria":3,"NombreCategoria":"ACCESORIOS Y PERIFERICOS","Descripcion":"Impresoras laser","Activo":true}', CAST(N'2025-11-06T12:46:04.730' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (189, NULL, N'CREAR', N'CATEGORIAS', 10, N'Categoría creada: MOBILIARIO TECNOLOGICO', NULL, N'{"IdCategoria":10,"Nombre":"MOBILIARIO TECNOLOGICO","Descripcion":"Equipos","Activo":true}', CAST(N'2025-11-06T12:48:20.773' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (190, NULL, N'CREAR', N'CATEGORIAS', 11, N'Categoría creada: SEGURIDAD Y CONTROL DE ACCESO', NULL, N'{"IdCategoria":11,"Nombre":"SEGURIDAD Y CONTROL DE ACCESO","Descripcion":"Equipos de Seguridad","Activo":true}', CAST(N'2025-11-06T12:49:00.317' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (191, NULL, N'CREAR', N'CATEGORIAS', 12, N'Categoría creada: OTROS/ MISCELANEOS', NULL, N'{"IdCategoria":12,"Nombre":"OTROS\/ MISCELANEOS","Descripcion":"Otros","Activo":true}', CAST(N'2025-11-06T12:49:35.280' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (192, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-06T12:55:16.077' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (193, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-06T14:33:02.220' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (194, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T10:20:15.760' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (195, NULL, N'CREAR', N'SUBCATEGORIAS', 12, N'Subcategoría creada: TECLADOS USB en categoría: PERIFERICOS', NULL, N'{"IdSubcategoria":12,"Nombre":"TECLADOS USB","IdCategoria":4,"NombreCategoria":"PERIFERICOS","Descripcion":"Teclados alambricos","Activo":true}', CAST(N'2025-11-07T10:21:21.040' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (196, NULL, N'ACTUALIZAR', N'SUBCATEGORIAS', 10, N'Subcategoría actualizada: TECLADOS INALAMBRICOS en categoría: PERIFERICOS (ID: 10)', N'{"IdSubcategoria":10,"Nombre":"TECLADOS","IdCategoria":4,"NombreCategoria":"PERIFERICOS","Activo":true}', N'{"IdSubcategoria":10,"Nombre":"TECLADOS INALAMBRICOS","IdCategoria":4,"NombreCategoria":"PERIFERICOS","Descripcion":"Teclado inalabrico","Activo":true}', CAST(N'2025-11-07T10:21:55.553' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (197, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T10:53:49.560' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (198, 1, N'LOGIN', N'AUTENTICACION', 1, N'Intento de login fallido', NULL, NULL, CAST(N'2025-11-07T11:16:51.093' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (199, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T11:16:55.120' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (200, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T11:28:51.227' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (201, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T11:42:33.290' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (202, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T11:46:48.517' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (203, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T11:55:58.833' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (204, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T12:08:16.107' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (205, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T12:19:50.120' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (206, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T12:22:54.320' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ([BIT_Id], [BIT_AgenteId], [BIT_Accion], [BIT_Entidad], [BIT_EntidadId], [BIT_Detalles], [BIT_ValoresAntiguos], [BIT_ValoresNuevos], [BIT_FechaHora]) VALUES (207, 1, N'LOGIN', N'AUTENTICACION', 1, N'Login exitoso', NULL, NULL, CAST(N'2025-11-07T12:27:10.487' AS DateTime))
GO
INSERT [ZI_GENERAL].[ZI_BODEGAS] ([BOD_Id], [BOD_Nombre], [BOD_Ubicacion], [BOD_Estado]) VALUES (1, N'BODEGA PRINCIPAL', N'DEPARTAMENTO DE IT', 1)
GO
INSERT [ZI_GENERAL].[ZI_BODEGAS] ([BOD_Id], [BOD_Nombre], [BOD_Ubicacion], [BOD_Estado]) VALUES (2, N'BODEGA SECUNDARIA', N'EDIFICIO B, PISO 2', 1)
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (1, N'COMPUTO', N'COMPUTOS', 1, NULL, N'SYSTEM', CAST(N'2025-11-06T11:52:52.637' AS DateTime), N'Administrador Sistema', NULL, N'::1')
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (2, N'REDES', N'EQUIPOS DE RED', 1, NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (3, N'ACCESORIOS Y PERIFERICOS', N'DISPOSITIVOS', 1, NULL, N'SYSTEM', CAST(N'2025-11-04T15:37:35.693' AS DateTime), N'Administrador Sistema', NULL, N'::1')
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (4, N'PERIFERICOS', N'ACCESORIOS', 1, NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (5, N'test', N'test', 0, CAST(N'2025-11-03T23:50:42.597' AS DateTime), N'Administrador Sistema', CAST(N'2025-11-04T00:12:25.870' AS DateTime), N'Administrador Sistema', N'::1', N'::1')
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (6, N'ALMACENAMIENTO', N'EQUIPOS DE ALMACENAMIENTO', 1, CAST(N'2025-11-04T14:59:06.713' AS DateTime), N'Administrador Sistema', NULL, NULL, N'::1', NULL)
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (7, N'AUDIO Y VIDEO', N'DISPOSITIVOS DE SALIDA DE VIDEO', 1, CAST(N'2025-11-04T15:17:08.917' AS DateTime), N'Administrador Sistema', CAST(N'2025-11-04T15:36:30.373' AS DateTime), N'Administrador Sistema', N'::1', N'::1')
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (8, N'IMPRESION Y ESCANEO', N'IMPRESION', 1, CAST(N'2025-11-04T15:31:50.623' AS DateTime), N'Administrador Sistema', NULL, NULL, N'::1', NULL)
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (9, N'TELEFONIA Y COMUNICACIONES', N'COMUNICACIONES', 1, CAST(N'2025-11-04T15:34:24.817' AS DateTime), N'Administrador Sistema', NULL, NULL, N'::1', NULL)
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (10, N'MOBILIARIO TECNOLOGICO', N'Equipos', 1, CAST(N'2025-11-06T12:48:20.770' AS DateTime), N'Administrador Sistema', NULL, NULL, N'::1', NULL)
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (11, N'SEGURIDAD Y CONTROL DE ACCESO', N'Equipos de Seguridad', 1, CAST(N'2025-11-06T12:49:00.317' AS DateTime), N'Administrador Sistema', NULL, NULL, N'::1', NULL)
GO
INSERT [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id], [CAT_Nombre], [CAT_Descripcion], [CAT_Estado], [CAT_FechaCreacion], [CAT_UsuarioCreacion], [CAT_FechaModificacion], [CAT_UsuarioModificacion], [CAT_IpCreacion], [CAT_IpModificacion]) VALUES (12, N'OTROS/ MISCELANEOS', N'Otros', 1, CAST(N'2025-11-06T12:49:35.277' AS DateTime), N'Administrador Sistema', NULL, NULL, N'::1', NULL)
GO
INSERT [ZI_GENERAL].[ZI_CONFIGURACION] ([ZIC_Id], [ZIC_Clave], [ZIC_Valor], [ZIC_Descripcion], [ZIC_Tipo], [ZIC_Activo], [ZIC_FechaCreacion], [ZIC_UsuarioCreacion], [ZIC_FechaModificacion], [ZIC_UsuarioModificacion], [ZIC_IpCreacion], [ZIC_IpModificacion]) VALUES (1, N'ENCRYPT_KEY', N'MilesimoDev2024PortalSecureKey123!', N'Clave principal para encriptación AES', N'STRING', 1, CAST(N'2025-11-02T18:37:07.953' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CONFIGURACION] ([ZIC_Id], [ZIC_Clave], [ZIC_Valor], [ZIC_Descripcion], [ZIC_Tipo], [ZIC_Activo], [ZIC_FechaCreacion], [ZIC_UsuarioCreacion], [ZIC_FechaModificacion], [ZIC_UsuarioModificacion], [ZIC_IpCreacion], [ZIC_IpModificacion]) VALUES (2, N'ENCRYPT_SALT', N'Portal_Milesimo_Salt_2024_Secure', N'Salt para encriptación de contraseñas', N'STRING', 1, CAST(N'2025-11-02T18:37:07.953' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CONFIGURACION] ([ZIC_Id], [ZIC_Clave], [ZIC_Valor], [ZIC_Descripcion], [ZIC_Tipo], [ZIC_Activo], [ZIC_FechaCreacion], [ZIC_UsuarioCreacion], [ZIC_FechaModificacion], [ZIC_UsuarioModificacion], [ZIC_IpCreacion], [ZIC_IpModificacion]) VALUES (3, N'ENCRYPT_IV', N'Milesimo_IV_2024', N'Vector inicial para encriptación AES', N'STRING', 1, CAST(N'2025-11-02T18:37:07.953' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CONFIGURACION] ([ZIC_Id], [ZIC_Clave], [ZIC_Valor], [ZIC_Descripcion], [ZIC_Tipo], [ZIC_Activo], [ZIC_FechaCreacion], [ZIC_UsuarioCreacion], [ZIC_FechaModificacion], [ZIC_UsuarioModificacion], [ZIC_IpCreacion], [ZIC_IpModificacion]) VALUES (4, N'SISTEMA_NOMBRE', N'Portal Milésimo', N'Nombre del sistema', N'STRING', 1, CAST(N'2025-11-02T18:37:07.953' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CONFIGURACION] ([ZIC_Id], [ZIC_Clave], [ZIC_Valor], [ZIC_Descripcion], [ZIC_Tipo], [ZIC_Activo], [ZIC_FechaCreacion], [ZIC_UsuarioCreacion], [ZIC_FechaModificacion], [ZIC_UsuarioModificacion], [ZIC_IpCreacion], [ZIC_IpModificacion]) VALUES (5, N'SISTEMA_VERSION', N'1.0.0', N'Versión actual del sistema', N'STRING', 1, CAST(N'2025-11-02T18:37:07.953' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CONFIGURACION] ([ZIC_Id], [ZIC_Clave], [ZIC_Valor], [ZIC_Descripcion], [ZIC_Tipo], [ZIC_Activo], [ZIC_FechaCreacion], [ZIC_UsuarioCreacion], [ZIC_FechaModificacion], [ZIC_UsuarioModificacion], [ZIC_IpCreacion], [ZIC_IpModificacion]) VALUES (6, N'HABILITAR_AUDITORIA', N'true', N'Indica si la auditoría está habilitada', N'BOOL', 1, CAST(N'2025-11-02T18:37:07.953' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CONFIGURACION] ([ZIC_Id], [ZIC_Clave], [ZIC_Valor], [ZIC_Descripcion], [ZIC_Tipo], [ZIC_Activo], [ZIC_FechaCreacion], [ZIC_UsuarioCreacion], [ZIC_FechaModificacion], [ZIC_UsuarioModificacion], [ZIC_IpCreacion], [ZIC_IpModificacion]) VALUES (7, N'MAX_INTENTOS_LOGIN', N'5', N'Máximo número de intentos de login fallidos', N'INT', 1, CAST(N'2025-11-02T18:37:07.953' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CONFIGURACION] ([ZIC_Id], [ZIC_Clave], [ZIC_Valor], [ZIC_Descripcion], [ZIC_Tipo], [ZIC_Activo], [ZIC_FechaCreacion], [ZIC_UsuarioCreacion], [ZIC_FechaModificacion], [ZIC_UsuarioModificacion], [ZIC_IpCreacion], [ZIC_IpModificacion]) VALUES (8, N'TIEMPO_BLOQUEO_MINUTOS', N'30', N'Tiempo en minutos de bloqueo por intentos fallidos', N'INT', 1, CAST(N'2025-11-02T18:37:07.953' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_CONTRATOS] ([CON_Id], [CON_Nombre], [CON_Descripcion], [CON_Estado]) VALUES (1, N'CONTRATO A', N'CONTRATO ESTANDAR PARA EQUIPOS', 1)
GO
INSERT [ZI_GENERAL].[ZI_CONTRATOS] ([CON_Id], [CON_Nombre], [CON_Descripcion], [CON_Estado]) VALUES (2, N'CONTRATO B', N'CONTRATO PREMIUM', 1)
GO
INSERT [ZI_GENERAL].[ZI_DETALLEDEVOLUCION] ([DDE_Id], [DDE_DevolucionId], [DDE_EquipoId], [DDE_EstadoEquipo], [DDE_Estado]) VALUES (1, 1, 3, 2, 1)
GO
INSERT [ZI_GENERAL].[ZI_DETALLEEGRESO] ([DEG_Id], [DEG_EgresoId], [DEG_EquipoId], [DEG_Estado]) VALUES (1, 1, 3, 1)
GO
INSERT [ZI_GENERAL].[ZI_DETALLEEGRESO] ([DEG_Id], [DEG_EgresoId], [DEG_EquipoId], [DEG_Estado]) VALUES (2, 2, 1, 1)
GO
INSERT [ZI_GENERAL].[ZI_DEVOLUCIONES] ([DEV_Id], [DEV_EgresoId], [DEV_Fecha], [DEV_Hora], [DEV_Path], [DEV_EstadoEquipo], [DEV_Agente], [DEV_Descripcion], [DEV_Adjunto], [DEV_Estado], [DEV_BodegaId]) VALUES (1, 1, N'2023-10-05', N'13:00', NULL, 2, N'JUAN PEREZ', N'DEVOLUCION POR CAMBIO DE PUESTO', 0, 1, 1)
GO
INSERT [ZI_GENERAL].[ZI_EGRESOS] ([EGR_Id], [EGR_UsuarioId], [EGR_ViceId], [EGR_BodegaId], [EGR_TipoSalidaId], [EGR_Usuario], [EGR_Host], [EGR_Fecha], [EGR_Hora], [EGR_Path], [EGR_Adjunto], [EGR_Descripcion], [EGR_Estado]) VALUES (1, 10, 1, 1, 1, N'ADMIN', N'PC001', N'2023-10-03', N'11:00', NULL, 0, N'ASIGNACION A USUARIO', 1)
GO
INSERT [ZI_GENERAL].[ZI_EGRESOS] ([EGR_Id], [EGR_UsuarioId], [EGR_ViceId], [EGR_BodegaId], [EGR_TipoSalidaId], [EGR_Usuario], [EGR_Host], [EGR_Fecha], [EGR_Hora], [EGR_Path], [EGR_Adjunto], [EGR_Descripcion], [EGR_Estado]) VALUES (2, 11, 1, 1, 1, N'ADMIN', N'PC001', N'2023-10-04', N'12:00', NULL, 0, N'ASIGNACION A DESARROLLADOR', 1)
GO
INSERT [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id], [EQU_Serie], [EQU_ModeloId], [EQU_ContratoId], [EQU_BodegaId], [EQU_TipoSalidaId], [EQU_EstadoEquipo], [EQU_Descripcion], [EQU_Fecha], [EQU_Estado]) VALUES (1, N'DELL001', 1, 1, 1, NULL, 2, N'LAPTOP DELL NUEVA', CAST(N'2025-11-02T18:44:02.343' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id], [EQU_Serie], [EQU_ModeloId], [EQU_ContratoId], [EQU_BodegaId], [EQU_TipoSalidaId], [EQU_EstadoEquipo], [EQU_Descripcion], [EQU_Fecha], [EQU_Estado]) VALUES (2, N'HP001', 2, 1, 1, NULL, 2, N'LAPTOP HP', CAST(N'2025-11-02T18:44:02.357' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id], [EQU_Serie], [EQU_ModeloId], [EQU_ContratoId], [EQU_BodegaId], [EQU_TipoSalidaId], [EQU_EstadoEquipo], [EQU_Descripcion], [EQU_Fecha], [EQU_Estado]) VALUES (3, N'LEN001', 3, 2, 1, NULL, 1, N'LAPTOP LENOVO ASIGNADA', CAST(N'2025-11-02T18:44:02.367' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id], [EQU_Serie], [EQU_ModeloId], [EQU_ContratoId], [EQU_BodegaId], [EQU_TipoSalidaId], [EQU_EstadoEquipo], [EQU_Descripcion], [EQU_Fecha], [EQU_Estado]) VALUES (4, N'DESK001', 4, 1, 2, NULL, 2, N'DESKTOP DELL', CAST(N'2025-11-02T18:44:02.373' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id], [EQU_Serie], [EQU_ModeloId], [EQU_ContratoId], [EQU_BodegaId], [EQU_TipoSalidaId], [EQU_EstadoEquipo], [EQU_Descripcion], [EQU_Fecha], [EQU_Estado]) VALUES (5, N'SERV001', 6, 2, 1, NULL, 2, N'SERVIDOR DELL', CAST(N'2025-11-02T18:44:02.383' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id], [EQU_Serie], [EQU_ModeloId], [EQU_ContratoId], [EQU_BodegaId], [EQU_TipoSalidaId], [EQU_EstadoEquipo], [EQU_Descripcion], [EQU_Fecha], [EQU_Estado]) VALUES (6, N'SWITCH001', 8, 1, 1, NULL, 2, N'SWITCH CISCO', CAST(N'2025-11-02T18:44:02.400' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id], [EQU_Serie], [EQU_ModeloId], [EQU_ContratoId], [EQU_BodegaId], [EQU_TipoSalidaId], [EQU_EstadoEquipo], [EQU_Descripcion], [EQU_Fecha], [EQU_Estado]) VALUES (7, N'PRINT001', 9, 1, 2, NULL, 2, N'IMPRESORA HP', CAST(N'2025-11-02T18:44:02.413' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id], [EQU_Serie], [EQU_ModeloId], [EQU_ContratoId], [EQU_BodegaId], [EQU_TipoSalidaId], [EQU_EstadoEquipo], [EQU_Descripcion], [EQU_Fecha], [EQU_Estado]) VALUES (8, N'MON001', 10, 1, 1, NULL, 2, N'MONITOR DELL', CAST(N'2025-11-02T18:44:02.430' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_ESTADOS] ([EST_Id], [EST_Nombre]) VALUES (1, N'ASIGNADO')
GO
INSERT [ZI_GENERAL].[ZI_ESTADOS] ([EST_Id], [EST_Nombre]) VALUES (5, N'EN REPARACION')
GO
INSERT [ZI_GENERAL].[ZI_ESTADOS] ([EST_Id], [EST_Nombre]) VALUES (4, N'LEASING')
GO
INSERT [ZI_GENERAL].[ZI_ESTADOS] ([EST_Id], [EST_Nombre]) VALUES (2, N'NO ASIGNADO')
GO
INSERT [ZI_GENERAL].[ZI_ESTADOS] ([EST_Id], [EST_Nombre]) VALUES (3, N'TRANSFERIDO')
GO
INSERT [ZI_GENERAL].[ZI_INGRESOS] ([ING_Id], [ING_Usuario], [ING_Host], [ING_Dominio], [ING_BodegaId], [ING_Fecha], [ING_Hora], [ING_Descripcion], [ING_Estado], [ING_TipoIngreso]) VALUES (1, N'ADMIN', N'PC001', N'EMPRESA.COM', 1, N'2023-10-01', N'09:00', N'INGRESO INICIAL DE EQUIPOS', 1, N'COMPRA')
GO
INSERT [ZI_GENERAL].[ZI_INGRESOS] ([ING_Id], [ING_Usuario], [ING_Host], [ING_Dominio], [ING_BodegaId], [ING_Fecha], [ING_Hora], [ING_Descripcion], [ING_Estado], [ING_TipoIngreso]) VALUES (2, N'ADMIN', N'PC002', N'EMPRESA.COM', 2, N'2023-10-02', N'10:00', N'INGRESO ADICIONAL', 1, N'DONACION')
GO
INSERT [ZI_GENERAL].[ZI_KARDEXEQUIPO] ([KAR_Id], [KAR_MovId], [KAR_Serie], [KAR_TipoMov], [KAR_BodegaId], [KAR_Fecha], [KAR_Estado]) VALUES (1, 1, N'DELL001', 1, 1, CAST(N'2025-11-02T18:44:02.460' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_KARDEXEQUIPO] ([KAR_Id], [KAR_MovId], [KAR_Serie], [KAR_TipoMov], [KAR_BodegaId], [KAR_Fecha], [KAR_Estado]) VALUES (2, 1, N'HP001', 1, 1, CAST(N'2025-11-02T18:44:02.477' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_KARDEXEQUIPO] ([KAR_Id], [KAR_MovId], [KAR_Serie], [KAR_TipoMov], [KAR_BodegaId], [KAR_Fecha], [KAR_Estado]) VALUES (3, 1, N'LEN001', 2, 1, CAST(N'2025-11-02T18:47:18.700' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_KARDEXEQUIPO] ([KAR_Id], [KAR_MovId], [KAR_Serie], [KAR_TipoMov], [KAR_BodegaId], [KAR_Fecha], [KAR_Estado]) VALUES (4, 2, N'DELL001', 2, 1, CAST(N'2025-11-02T18:47:18.707' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_KARDEXUSUARIOS] ([KUS_Id], [KUS_MovId], [KUS_UsuarioId], [KUS_TipoMov], [KUS_BodegaId], [KUS_Fecha], [KUS_Estado]) VALUES (1, 1, N'10', 2, 1, CAST(N'2025-11-02T18:47:18.723' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_KARDEXUSUARIOS] ([KUS_Id], [KUS_MovId], [KUS_UsuarioId], [KUS_TipoMov], [KUS_BodegaId], [KUS_Fecha], [KUS_Estado]) VALUES (2, 2, N'11', 2, 1, CAST(N'2025-11-02T18:47:18.743' AS DateTime), 1)
GO
INSERT [ZI_GENERAL].[ZI_MARCAS] ([MAR_Id], [MAR_Nombre], [MAR_Estado], [MAR_FechaCreacion], [MAR_UsuarioCreacion], [MAR_FechaModificacion], [MAR_UsuarioModificacion], [MAR_IpCreacion], [MAR_IpModificacion], [MAR_Descripcion]) VALUES (1, N'DELL', 1, CAST(N'2025-11-05T19:01:50.553' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_MARCAS] ([MAR_Id], [MAR_Nombre], [MAR_Estado], [MAR_FechaCreacion], [MAR_UsuarioCreacion], [MAR_FechaModificacion], [MAR_UsuarioModificacion], [MAR_IpCreacion], [MAR_IpModificacion], [MAR_Descripcion]) VALUES (2, N'HP', 1, CAST(N'2025-11-05T19:01:50.553' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_MARCAS] ([MAR_Id], [MAR_Nombre], [MAR_Estado], [MAR_FechaCreacion], [MAR_UsuarioCreacion], [MAR_FechaModificacion], [MAR_UsuarioModificacion], [MAR_IpCreacion], [MAR_IpModificacion], [MAR_Descripcion]) VALUES (3, N'LENOVO', 1, CAST(N'2025-11-05T19:01:50.553' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_MARCAS] ([MAR_Id], [MAR_Nombre], [MAR_Estado], [MAR_FechaCreacion], [MAR_UsuarioCreacion], [MAR_FechaModificacion], [MAR_UsuarioModificacion], [MAR_IpCreacion], [MAR_IpModificacion], [MAR_Descripcion]) VALUES (4, N'CISCO', 1, CAST(N'2025-11-05T19:01:50.553' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (1, N'LATITUDE 5420', 1, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 1)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (2, N'PROBOOK 450', 2, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 1)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (3, N'THINKPAD X1', 3, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 1)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (4, N'OPTIPLEX 7090', 1, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 2)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (5, N'PRODESK 400', 2, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 2)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (6, N'POWEREDGE R750', 1, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 3)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (7, N'PROLIANT DL380', 2, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 3)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (8, N'CATALYST 2960', 4, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 5)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (9, N'LASERJET PRO M182NW', 2, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 7)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (10, N'ULTRASHARP U2720Q', 1, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 9)
GO
INSERT [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id], [MOD_Nombre], [MOD_MarcaId], [MOD_Estado], [MOD_Descripcion], [MOD_FechaCreacion], [MOD_UsuarioCreacion], [MOD_FechaModificacion], [MOD_UsuarioModificacion], [MOD_IpCreacion], [MOD_IpModificacion], [MOD_SubcategoriaId]) VALUES (11, N'K380', 3, 1, NULL, CAST(N'2025-11-05T19:15:53.160' AS DateTime), NULL, NULL, NULL, NULL, NULL, 11)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (1, N'USUARIOS_CREAR', N'Crear usuarios', N'USUARIOS', N'CREAR', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (2, N'USUARIOS_LEER', N'Consultar usuarios', N'USUARIOS', N'LEER', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (3, N'USUARIOS_ACTUALIZAR', N'Actualizar usuarios', N'USUARIOS', N'ACTUALIZAR', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (4, N'USUARIOS_ELIMINAR', N'Eliminar usuarios', N'USUARIOS', N'ELIMINAR', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (5, N'ROLES_CREAR', N'Crear roles', N'ROLES', N'CREAR', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (6, N'ROLES_LEER', N'Consultar roles', N'ROLES', N'LEER', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (7, N'ROLES_ACTUALIZAR', N'Actualizar roles', N'ROLES', N'ACTUALIZAR', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (8, N'ROLES_ELIMINAR', N'Eliminar roles', N'ROLES', N'ELIMINAR', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (9, N'CONFIGURACION_LEER', N'Consultar configuraciones', N'CONFIGURACION', N'LEER', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (10, N'CONFIGURACION_ACTUALIZAR', N'Actualizar configuraciones', N'CONFIGURACION', N'ACTUALIZAR', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (11, N'AUDITORIA_LEER', N'Consultar bitácora de auditoría', N'AUDITORIA', N'LEER', 1, 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (12, N'CREAR EQUIPO', N'PERMISO PARA CREAR NUEVOS EQUIPOS', NULL, NULL, 1, 1, CAST(N'2025-11-02T18:47:18.550' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (13, N'EDITAR EQUIPO', N'PERMISO PARA EDITAR EQUIPOS EXISTENTES', NULL, NULL, 1, 1, CAST(N'2025-11-02T18:47:18.550' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (14, N'ELIMINAR EQUIPO', N'PERMISO PARA ELIMINAR EQUIPOS', NULL, NULL, 1, 1, CAST(N'2025-11-02T18:47:18.550' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (15, N'VER REPORTES', N'PERMISO PARA VER REPORTES', NULL, NULL, 1, 1, CAST(N'2025-11-02T18:47:18.550' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (16, N'GESTIONAR USUARIOS', N'PERMISO PARA GESTIONAR USUARIOS', NULL, NULL, 1, 1, CAST(N'2025-11-02T18:47:18.553' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (17, N'CATEGORIAS_LEER', N'Consultar categorías', N'CATEGORIAS', N'LEER', 1, 1, CAST(N'2025-11-03T13:03:47.840' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (18, N'CATEGORIAS_CREAR', N'Crear categorías', N'CATEGORIAS', N'CREAR', 1, 1, CAST(N'2025-11-03T13:03:47.840' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (19, N'CATEGORIAS_ACTUALIZAR', N'Actualizar categorías', N'CATEGORIAS', N'ACTUALIZAR', 1, 1, CAST(N'2025-11-03T13:03:47.843' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (20, N'CATEGORIAS_ELIMINAR', N'Eliminar categorías', N'CATEGORIAS', N'ELIMINAR', 1, 1, CAST(N'2025-11-03T13:03:47.843' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (22, N'SUB_CATEGORIAS_CREAR', N'Crear subcategorías', N'SUB_CATEGORIAS', N'CREAR', 1, 1, CAST(N'2025-11-04T17:26:18.643' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (23, N'SUB_CATEGORIAS_LEER', N'Consultar subcategorías', N'SUB_CATEGORIAS', N'LEER', 1, 1, CAST(N'2025-11-04T17:26:18.643' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (24, N'SUB_CATEGORIAS_ACTUALIZAR', N'Actualizar subcategorías', N'SUB_CATEGORIAS', N'ACTUALIZAR', 1, 1, CAST(N'2025-11-04T17:26:18.643' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id], [PER_Nombre], [PER_Descripcion], [PER_Modulo], [PER_Accion], [PER_Estado], [PER_Activo], [PER_FechaCreacion], [PER_UsuarioCreacion], [PER_FechaModificacion], [PER_UsuarioModificacion], [PER_IpCreacion], [PER_IpModificacion]) VALUES (25, N'SUB_CATEGORIAS_ELIMINAR', N'Eliminar subcategorías', N'SUB_CATEGORIAS', N'ELIMINAR', 1, 1, CAST(N'2025-11-04T17:26:18.643' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 1)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 2)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 3)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 4)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 5)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 6)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 7)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 8)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 9)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 10)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 11)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 12)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 13)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 14)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 15)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 16)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 17)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 18)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 19)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 20)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 22)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 23)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 24)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (1, 25)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (2, 2)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (2, 6)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (2, 9)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (2, 11)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (2, 17)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (2, 23)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (3, 2)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (3, 6)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (3, 17)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (3, 23)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (4, 12)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (4, 13)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (4, 15)
GO
INSERT [ZI_GENERAL].[ZI_PERMISOSROLES] ([PRO_RolId], [PRO_PermisoId]) VALUES (5, 15)
GO
INSERT [ZI_GENERAL].[ZI_ROLES] ([ROL_Id], [ROL_Nombre], [ROL_Descripcion], [ROL_Activo], [ROL_FechaCreacion], [ROL_UsuarioCreacion], [ROL_FechaModificacion], [ROL_UsuarioModificacion], [ROL_IpCreacion], [ROL_IpModificacion]) VALUES (1, N'Administrador', N'Rol con acceso completo al sistema', 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_ROLES] ([ROL_Id], [ROL_Nombre], [ROL_Descripcion], [ROL_Activo], [ROL_FechaCreacion], [ROL_UsuarioCreacion], [ROL_FechaModificacion], [ROL_UsuarioModificacion], [ROL_IpCreacion], [ROL_IpModificacion]) VALUES (2, N'Usuario', N'Rol básico de usuario del sistema', 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_ROLES] ([ROL_Id], [ROL_Nombre], [ROL_Descripcion], [ROL_Activo], [ROL_FechaCreacion], [ROL_UsuarioCreacion], [ROL_FechaModificacion], [ROL_UsuarioModificacion], [ROL_IpCreacion], [ROL_IpModificacion]) VALUES (3, N'Consulta', N'Rol solo de consulta, sin permisos de modificación', 1, CAST(N'2025-11-02T18:37:07.957' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_ROLES] ([ROL_Id], [ROL_Nombre], [ROL_Descripcion], [ROL_Activo], [ROL_FechaCreacion], [ROL_UsuarioCreacion], [ROL_FechaModificacion], [ROL_UsuarioModificacion], [ROL_IpCreacion], [ROL_IpModificacion]) VALUES (4, N'USUARIO IT', N'ACCESO LIMITADO A FUNCIONES DE IT', 1, CAST(N'2025-11-02T18:47:18.547' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_ROLES] ([ROL_Id], [ROL_Nombre], [ROL_Descripcion], [ROL_Activo], [ROL_FechaCreacion], [ROL_UsuarioCreacion], [ROL_FechaModificacion], [ROL_UsuarioModificacion], [ROL_IpCreacion], [ROL_IpModificacion]) VALUES (5, N'AUDITOR', N'SOLO LECTURA Y REPORTES', 1, CAST(N'2025-11-02T18:47:18.550' AS DateTime), N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (1, N'LAPTOPS', 1, N'Maquinas portátiles', 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, CAST(N'2025-11-06T12:38:51.183' AS DateTime), N'Administrador Sistema', NULL, N'::1')
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (2, N'ESCRITORIOS', 1, N'Maquinas de escritorio', 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, CAST(N'2025-11-06T12:42:18.120' AS DateTime), N'Administrador Sistema', NULL, N'::1')
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (3, N'SERVIDORES', 1, NULL, 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (4, N'ROUTERS', 2, NULL, 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (5, N'SWITCHES', 2, NULL, 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (6, N'PUNTOS DE ACCESO', 2, NULL, 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (7, N'IMPRESORAS LASER', 3, N'Impresoras laser', 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, CAST(N'2025-11-06T12:46:04.730' AS DateTime), N'Administrador Sistema', NULL, N'::1')
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (8, N'IMPRESORAS DE TINTA', 3, N'Impresoras de inyección', 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, CAST(N'2025-11-06T12:45:23.430' AS DateTime), N'Administrador Sistema', NULL, N'::1')
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (9, N'MONITORES', 4, NULL, 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (10, N'TECLADOS INALAMBRICOS', 4, N'Teclado inalabrico', 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, CAST(N'2025-11-07T10:21:55.540' AS DateTime), N'Administrador Sistema', NULL, N'::1')
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (11, N'MOUSES', 4, NULL, 1, CAST(N'2025-11-05T18:28:39.520' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id], [SUB_Nombre], [SUB_CategoriaId], [SUB_Descripcion], [SUB_Estado], [SUB_FechaCreacion], [SUB_UsuarioCreacion], [SUB_FechaModificacion], [SUB_UsuarioModificacion], [SUB_IpCreacion], [SUB_IpModificacion]) VALUES (12, N'TECLADOS USB', 4, N'Teclados alambricos', 1, CAST(N'2025-11-07T10:21:21.027' AS DateTime), N'Administrador Sistema', NULL, NULL, N'::1', NULL)
GO
INSERT [ZI_GENERAL].[ZI_TIPOSSALIDA] ([TSA_Id], [TSA_Nombre], [TSA_Descripcion], [TSA_Estado]) VALUES (1, N'ASIGNACION', N'SALIDA POR ASIGNACION A USUARIO', 1)
GO
INSERT [ZI_GENERAL].[ZI_TIPOSSALIDA] ([TSA_Id], [TSA_Nombre], [TSA_Descripcion], [TSA_Estado]) VALUES (2, N'TRANSFERENCIA', N'SALIDA POR TRANSFERENCIA ENTRE BODEGAS', 1)
GO
INSERT [ZI_GENERAL].[ZI_TIPOSSALIDA] ([TSA_Id], [TSA_Nombre], [TSA_Descripcion], [TSA_Estado]) VALUES (3, N'DEVOLUCION', N'SALIDA POR DEVOLUCION', 1)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (1, 1, N'admin', N'Administrador', N'admin@milesimo.com', NULL, NULL, CAST(N'2025-11-02T18:37:07.960' AS DateTime), 1, 0, 0, NULL, CAST(N'2025-11-07T12:27:10.487' AS DateTime), N'53yMAk6c+DKRx4yxVWdn2A==', 0, 1, N'Sistema', NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (2, 3, N'mchopen', N'MARIA', N'mchopen@milesimo.com.gt', NULL, NULL, CAST(N'2025-11-02T18:37:07.960' AS DateTime), 1, 0, 0, NULL, NULL, N'/4t3dPzCsHQ7dnX2UQBgsg==', 1, 1, N'CHOPEN', NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (3, 4, N'acaseros', N'ANDREA', N'acaseros@milesimo.com.gt', NULL, NULL, CAST(N'2025-11-02T18:37:07.960' AS DateTime), 1, 0, 0, NULL, NULL, N'D31DO6Gqa2GgmxFpsStGkQ==', 0, 1, N'CASEROS', NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (4, 5, N'lbarreda', N'MAYTE', N'lbarreda@milesimo.com.gt', NULL, NULL, CAST(N'2025-11-02T18:37:07.960' AS DateTime), 1, 0, 0, NULL, NULL, N'aQgDVftdftzo0ywRsKKMhw==', 1, 1, N'BARREDA', NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (5, 6, N'khigueros', N'KENIA', N'khigueros@milesimo.com.gt', NULL, NULL, CAST(N'2025-11-02T18:37:07.960' AS DateTime), 1, 0, 0, NULL, NULL, N'KGxllLwDhwXvGrSV5jkabA==', 1, 1, N'HIGUEROS', NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (6, 7, N'asoliz', N'ALEJANDRA', N'temp@milesimo.com.gt', NULL, NULL, CAST(N'2025-11-02T18:37:07.960' AS DateTime), 1, 0, 0, NULL, NULL, N'rA4W81DxszGaqaytBWOPiw==', 1, 1, N'SOLIZ', NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (7, 8, N'rlemus', N'RENE', N'rlemus@milesimo.com.gt', NULL, NULL, CAST(N'2025-11-02T18:37:07.960' AS DateTime), 1, 0, 0, NULL, NULL, N'd2JcLUyrfOzWD9MXHsAZog==', 1, 1, N'LEMUS', NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (8, 9, N'lblopez', N'BELINDA', N'lblopez@milesimo.com.gt', NULL, NULL, CAST(N'2025-11-02T18:37:07.960' AS DateTime), 1, 0, 0, NULL, NULL, N'TmzF7+Zmoq5k+/EDbRHORA==', 1, 1, N'LOPEZ', NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (9, 10, N'wsalguero', N'Wesley', N'wsalguero@milesimo.com.gt', NULL, NULL, CAST(N'2025-11-02T18:37:07.960' AS DateTime), 1, 0, 0, NULL, NULL, N'xXFkg8+2ZBl6uJsxGFx0lg==', 0, 1, N'Salguero', NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (10, 1001, N'ana.rodriguez', N'ANA RODRIGUEZ', N'ana.rodriguez@empresa.com', N'VENTAS', N'GERENTE', CAST(N'2025-11-02T18:47:18.560' AS DateTime), 1, 0, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (11, 1002, N'pedro.martinez', N'PEDRO MARTINEZ', N'pedro.martinez@empresa.com', N'IT', N'DESARROLLADOR', CAST(N'2025-11-02T18:47:18.560' AS DateTime), 1, 0, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id], [USU_Codigo], [USU_Username], [USU_Nombre], [USU_Correo], [USU_Departamento], [USU_Puesto], [USU_FechaCreacion], [USU_Activo], [USU_Bloqueado], [USU_IntentosFallidos], [USU_FechaBloqueo], [USU_UltimoLogin], [USU_PasswordEncrypted], [USU_PassTemp], [USU_Estado], [USU_Apellido], [USU_Telefono], [USU_UsuarioCreacion], [USU_FechaModificacion], [USU_UsuarioModificacion], [USU_IpCreacion], [USU_IpModificacion]) VALUES (12, 1003, N'laura.sanchez', N'LAURA SANCHEZ', N'laura.sanchez@empresa.com', N'RRHH', N'ANALISTA', CAST(N'2025-11-02T18:47:18.560' AS DateTime), 1, 0, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
INSERT [ZI_GENERAL].[ZI_USUARIOSROLES] ([UR_Id], [UR_UsrId], [UR_RolId], [UR_FechaAsignacion], [UR_Activo], [UR_UsuarioCreacion], [UR_IpCreacion], [UR_FechaModificacion], [UR_UsuarioModificacion], [UR_IpModificacion]) VALUES (1, 1, 1, CAST(N'2025-11-03T13:06:22.050' AS DateTime), 1, N'SYSTEM', NULL, NULL, NULL, NULL)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_AGENT__22210DD4FDBEDAA3]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_AGENTES] ADD UNIQUE NONCLUSTERED 
(
	[AGE_Correo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_BODEG__A15916B2D83484ED]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_BODEGAS] ADD UNIQUE NONCLUSTERED 
(
	[BOD_Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_CATEG__E09ED8F06858A786]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_CATEGORIAS] ADD UNIQUE NONCLUSTERED 
(
	[CAT_Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_CONFI__9A4407269E9676E1]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_CONFIGURACION] ADD UNIQUE NONCLUSTERED 
(
	[ZIC_Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_CONTR__2467C71DB9C2E670]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_CONTRATOS] ADD UNIQUE NONCLUSTERED 
(
	[CON_Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_EQUIP__59C544661F5D1465]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_EQUIPOS] ADD UNIQUE NONCLUSTERED 
(
	[EQU_Serie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_ESTAD__E52EE5AEC33AD13E]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_ESTADOS] ADD UNIQUE NONCLUSTERED 
(
	[EST_Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_MARCA__401506142B268463]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_MARCAS] ADD UNIQUE NONCLUSTERED 
(
	[MAR_Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_MARCAS_NOMBRE]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_MARCAS] ADD  CONSTRAINT [UQ_MARCAS_NOMBRE] UNIQUE NONCLUSTERED 
(
	[MAR_Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_MODELOS_NOMBRE_MARCA_SUBCATEGORIA]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_MODELOS] ADD  CONSTRAINT [UQ_MODELOS_NOMBRE_MARCA_SUBCATEGORIA] UNIQUE NONCLUSTERED 
(
	[MOD_Nombre] ASC,
	[MOD_MarcaId] ASC,
	[MOD_SubcategoriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_PERMI__E2819782269E694E]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_PERMISOS] ADD UNIQUE NONCLUSTERED 
(
	[PER_Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_ROLES__4430D9B483080F33]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_ROLES] ADD UNIQUE NONCLUSTERED 
(
	[ROL_Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_SUBCA__558303714F648E23]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_SUBCATEGORIAS] ADD UNIQUE NONCLUSTERED 
(
	[SUB_Nombre] ASC,
	[SUB_CategoriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_TIPOS__51E044F7461FEBE3]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_TIPOSSALIDA] ADD UNIQUE NONCLUSTERED 
(
	[TSA_Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__ZI_USUAR__496107D8B8718A6C]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD UNIQUE NONCLUSTERED 
(
	[USU_Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_USUAR__D846911F8ED55118]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD UNIQUE NONCLUSTERED 
(
	[USU_Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ZI_USUAR__EB9FAC8F3D6D729B]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD UNIQUE NONCLUSTERED 
(
	[USU_Correo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__ZI_USUAR__07EEDD28A19FE82E]    Script Date: 7/11/2025 12:38:32 ******/
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOSROLES] ADD UNIQUE NONCLUSTERED 
(
	[UR_UsrId] ASC,
	[UR_RolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [ZI_GENERAL].[ZI_AGENTES] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Agentes]) FOR [AGE_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_AGENTES] ADD  DEFAULT (getdate()) FOR [AGE_FechaCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_AGENTES] ADD  DEFAULT ((1)) FOR [AGE_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_BitacoraAuditoria]) FOR [BIT_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_BITACORAAUDITORIA] ADD  DEFAULT (getdate()) FOR [BIT_FechaHora]
GO
ALTER TABLE [ZI_GENERAL].[ZI_BODEGAS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Bodegas]) FOR [BOD_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_BODEGAS] ADD  DEFAULT ((1)) FOR [BOD_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CATEGORIAS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Categorias]) FOR [CAT_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CATEGORIAS] ADD  DEFAULT ((1)) FOR [CAT_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CATEGORIAS] ADD  DEFAULT (getdate()) FOR [CAT_FechaCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CATEGORIAS] ADD  DEFAULT ('SYSTEM') FOR [CAT_UsuarioCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CONFIGURACION] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_ZI_Configuracion]) FOR [ZIC_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CONFIGURACION] ADD  DEFAULT ('STRING') FOR [ZIC_Tipo]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CONFIGURACION] ADD  DEFAULT ((1)) FOR [ZIC_Activo]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CONFIGURACION] ADD  DEFAULT (getdate()) FOR [ZIC_FechaCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CONTRATOS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Contratos]) FOR [CON_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_CONTRATOS] ADD  DEFAULT ((1)) FOR [CON_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_DETALLEDEVOLUCION] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_DetalleDevolucion]) FOR [DDE_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_DETALLEEGRESO] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_DetalleEgreso]) FOR [DEG_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_DETALLEEGRESO] ADD  DEFAULT ((1)) FOR [DEG_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_DEVOLUCIONES] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Devoluciones]) FOR [DEV_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_DEVOLUCIONES] ADD  DEFAULT ((0)) FOR [DEV_Adjunto]
GO
ALTER TABLE [ZI_GENERAL].[ZI_DEVOLUCIONES] ADD  DEFAULT ((1)) FOR [DEV_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_EGRESOS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Egresos]) FOR [EGR_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_EGRESOS] ADD  DEFAULT ((0)) FOR [EGR_Adjunto]
GO
ALTER TABLE [ZI_GENERAL].[ZI_EGRESOS] ADD  DEFAULT ((1)) FOR [EGR_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_EQUIPOS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Equipos]) FOR [EQU_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_EQUIPOS] ADD  DEFAULT ((1)) FOR [EQU_EstadoEquipo]
GO
ALTER TABLE [ZI_GENERAL].[ZI_EQUIPOS] ADD  DEFAULT (getdate()) FOR [EQU_Fecha]
GO
ALTER TABLE [ZI_GENERAL].[ZI_EQUIPOS] ADD  DEFAULT ((1)) FOR [EQU_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_ESTADOS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Estados]) FOR [EST_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_INGRESOS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Ingresos]) FOR [ING_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_INGRESOS] ADD  DEFAULT ((1)) FOR [ING_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_KARDEXEQUIPO] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_KardexEquipo]) FOR [KAR_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_KARDEXEQUIPO] ADD  DEFAULT (getdate()) FOR [KAR_Fecha]
GO
ALTER TABLE [ZI_GENERAL].[ZI_KARDEXEQUIPO] ADD  DEFAULT ((1)) FOR [KAR_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_KARDEXUSUARIOS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_KardexUsuarios]) FOR [KUS_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_KARDEXUSUARIOS] ADD  DEFAULT (getdate()) FOR [KUS_Fecha]
GO
ALTER TABLE [ZI_GENERAL].[ZI_KARDEXUSUARIOS] ADD  DEFAULT ((1)) FOR [KUS_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_MARCAS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Marcas]) FOR [MAR_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_MARCAS] ADD  DEFAULT ((1)) FOR [MAR_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_MARCAS] ADD  DEFAULT (getdate()) FOR [MAR_FechaCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_MODELOS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Modelos]) FOR [MOD_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_MODELOS] ADD  DEFAULT ((1)) FOR [MOD_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_MODELOS] ADD  DEFAULT (getdate()) FOR [MOD_FechaCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_PERMISOS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Permisos]) FOR [PER_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_PERMISOS] ADD  DEFAULT ((1)) FOR [PER_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_PERMISOS] ADD  DEFAULT ((1)) FOR [PER_Activo]
GO
ALTER TABLE [ZI_GENERAL].[ZI_PERMISOS] ADD  DEFAULT (getdate()) FOR [PER_FechaCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_ROLES] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Roles]) FOR [ROL_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_ROLES] ADD  DEFAULT ((1)) FOR [ROL_Activo]
GO
ALTER TABLE [ZI_GENERAL].[ZI_ROLES] ADD  DEFAULT (getdate()) FOR [ROL_FechaCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_SUBCATEGORIAS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Subcategorias]) FOR [SUB_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_SUBCATEGORIAS] ADD  DEFAULT ((1)) FOR [SUB_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_SUBCATEGORIAS] ADD  DEFAULT (getdate()) FOR [SUB_FechaCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_TIPOSSALIDA] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_TiposSalida]) FOR [TSA_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_TIPOSSALIDA] ADD  DEFAULT ((1)) FOR [TSA_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_Usuarios]) FOR [USU_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD  DEFAULT (getdate()) FOR [USU_FechaCreacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD  DEFAULT ((1)) FOR [USU_Activo]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD  DEFAULT ((0)) FOR [USU_Bloqueado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD  DEFAULT ((0)) FOR [USU_IntentosFallidos]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD  DEFAULT ((0)) FOR [USU_PassTemp]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOS] ADD  DEFAULT ((1)) FOR [USU_Estado]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOSROLES] ADD  DEFAULT (NEXT VALUE FOR [ZI_GENERAL].[Seq_ZI_UsuariosRoles]) FOR [UR_Id]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOSROLES] ADD  DEFAULT (getdate()) FOR [UR_FechaAsignacion]
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOSROLES] ADD  DEFAULT ((1)) FOR [UR_Activo]
GO
ALTER TABLE [ZI_GENERAL].[ZI_AGENTES]  WITH CHECK ADD FOREIGN KEY([AGE_RolId])
REFERENCES [ZI_GENERAL].[ZI_ROLES] ([ROL_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_BITACORAAUDITORIA]  WITH CHECK ADD FOREIGN KEY([BIT_AgenteId])
REFERENCES [ZI_GENERAL].[ZI_AGENTES] ([AGE_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_DETALLEDEVOLUCION]  WITH CHECK ADD FOREIGN KEY([DDE_DevolucionId])
REFERENCES [ZI_GENERAL].[ZI_DEVOLUCIONES] ([DEV_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_DETALLEDEVOLUCION]  WITH CHECK ADD FOREIGN KEY([DDE_EquipoId])
REFERENCES [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_DETALLEEGRESO]  WITH CHECK ADD FOREIGN KEY([DEG_EgresoId])
REFERENCES [ZI_GENERAL].[ZI_EGRESOS] ([EGR_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_DETALLEEGRESO]  WITH CHECK ADD FOREIGN KEY([DEG_EquipoId])
REFERENCES [ZI_GENERAL].[ZI_EQUIPOS] ([EQU_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_DEVOLUCIONES]  WITH CHECK ADD FOREIGN KEY([DEV_BodegaId])
REFERENCES [ZI_GENERAL].[ZI_BODEGAS] ([BOD_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_DEVOLUCIONES]  WITH CHECK ADD FOREIGN KEY([DEV_EgresoId])
REFERENCES [ZI_GENERAL].[ZI_EGRESOS] ([EGR_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_EGRESOS]  WITH CHECK ADD FOREIGN KEY([EGR_BodegaId])
REFERENCES [ZI_GENERAL].[ZI_BODEGAS] ([BOD_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_EGRESOS]  WITH CHECK ADD FOREIGN KEY([EGR_TipoSalidaId])
REFERENCES [ZI_GENERAL].[ZI_TIPOSSALIDA] ([TSA_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_EGRESOS]  WITH CHECK ADD FOREIGN KEY([EGR_UsuarioId])
REFERENCES [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_EQUIPOS]  WITH CHECK ADD FOREIGN KEY([EQU_BodegaId])
REFERENCES [ZI_GENERAL].[ZI_BODEGAS] ([BOD_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_EQUIPOS]  WITH CHECK ADD FOREIGN KEY([EQU_ContratoId])
REFERENCES [ZI_GENERAL].[ZI_CONTRATOS] ([CON_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_EQUIPOS]  WITH CHECK ADD FOREIGN KEY([EQU_ModeloId])
REFERENCES [ZI_GENERAL].[ZI_MODELOS] ([MOD_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_EQUIPOS]  WITH CHECK ADD FOREIGN KEY([EQU_TipoSalidaId])
REFERENCES [ZI_GENERAL].[ZI_TIPOSSALIDA] ([TSA_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_INGRESOS]  WITH CHECK ADD FOREIGN KEY([ING_BodegaId])
REFERENCES [ZI_GENERAL].[ZI_BODEGAS] ([BOD_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_KARDEXEQUIPO]  WITH CHECK ADD FOREIGN KEY([KAR_BodegaId])
REFERENCES [ZI_GENERAL].[ZI_BODEGAS] ([BOD_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_KARDEXUSUARIOS]  WITH CHECK ADD FOREIGN KEY([KUS_BodegaId])
REFERENCES [ZI_GENERAL].[ZI_BODEGAS] ([BOD_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_MODELOS]  WITH CHECK ADD FOREIGN KEY([MOD_MarcaId])
REFERENCES [ZI_GENERAL].[ZI_MARCAS] ([MAR_Id])
ON DELETE CASCADE
GO
ALTER TABLE [ZI_GENERAL].[ZI_MODELOS]  WITH CHECK ADD  CONSTRAINT [FK_MODELOS_SUBCATEGORIAS] FOREIGN KEY([MOD_SubcategoriaId])
REFERENCES [ZI_GENERAL].[ZI_SUBCATEGORIAS] ([SUB_Id])
GO
ALTER TABLE [ZI_GENERAL].[ZI_MODELOS] CHECK CONSTRAINT [FK_MODELOS_SUBCATEGORIAS]
GO
ALTER TABLE [ZI_GENERAL].[ZI_PERMISOSROLES]  WITH CHECK ADD FOREIGN KEY([PRO_PermisoId])
REFERENCES [ZI_GENERAL].[ZI_PERMISOS] ([PER_Id])
ON DELETE CASCADE
GO
ALTER TABLE [ZI_GENERAL].[ZI_PERMISOSROLES]  WITH CHECK ADD FOREIGN KEY([PRO_RolId])
REFERENCES [ZI_GENERAL].[ZI_ROLES] ([ROL_Id])
ON DELETE CASCADE
GO
ALTER TABLE [ZI_GENERAL].[ZI_SUBCATEGORIAS]  WITH CHECK ADD FOREIGN KEY([SUB_CategoriaId])
REFERENCES [ZI_GENERAL].[ZI_CATEGORIAS] ([CAT_Id])
ON DELETE CASCADE
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOSROLES]  WITH CHECK ADD FOREIGN KEY([UR_RolId])
REFERENCES [ZI_GENERAL].[ZI_ROLES] ([ROL_Id])
ON DELETE CASCADE
GO
ALTER TABLE [ZI_GENERAL].[ZI_USUARIOSROLES]  WITH CHECK ADD FOREIGN KEY([UR_UsrId])
REFERENCES [ZI_GENERAL].[ZI_USUARIOS] ([USU_Id])
ON DELETE CASCADE
GO

USE [master]
GO
ALTER DATABASE [DB_Zenith_Inventory] SET  READ_WRITE 
GO
