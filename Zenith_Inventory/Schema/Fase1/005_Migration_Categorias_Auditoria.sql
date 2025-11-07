-- =============================================
-- MIGRACIÓN: Agregar columnas de auditoría a ZI_CATEGORIAS
-- Fecha: 2025-01-27
-- Descripción: Agregar campos de auditoría faltantes a la tabla de categorías
-- =============================================

USE [DB_Zenith_Inventory]
GO

-- Agregar columnas de auditoría a la tabla ZI_CATEGORIAS
ALTER TABLE ZI_GENERAL.ZI_CATEGORIAS
ADD CAT_FechaCreacion DATETIME DEFAULT GETDATE(),
    CAT_UsuarioCreacion NVARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    CAT_FechaModificacion DATETIME NULL,
    CAT_UsuarioModificacion NVARCHAR(100) NULL,
    CAT_IpCreacion NVARCHAR(45) NULL,
    CAT_IpModificacion NVARCHAR(45) NULL;

GO

-- Actualizar registros existentes con valores por defecto
UPDATE ZI_GENERAL.ZI_CATEGORIAS
SET CAT_UsuarioCreacion = 'SYSTEM',
    CAT_FechaCreacion = GETDATE()
WHERE CAT_UsuarioCreacion IS NULL;

GO

-- Registrar la migración en bitácora
INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (
    BIT_AgenteId,
    BIT_Accion,
    BIT_Entidad,
    BIT_EntidadId,
    BIT_Detalles,
    BIT_FechaHora
) VALUES (
    NULL,
    'MIGRACION',
    'TABLA',
    0,
    'Agregadas columnas de auditoría a ZI_CATEGORIAS',
    GETDATE()
);

GO