USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Script para corregir la jerarquía de catálogos
-- Estructura correcta: Categoría ? Subcategoría ? Marca ? Modelo
-- =============================================

-- =============================================
-- PASO 1: Agregar columnas de auditoría a ZI_MARCAS
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') AND name = 'MAR_FechaCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS ADD MAR_FechaCreacion DATETIME DEFAULT GETDATE() NOT NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') AND name = 'MAR_UsuarioCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS ADD MAR_UsuarioCreacion NVARCHAR(100) NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') AND name = 'MAR_FechaModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS ADD MAR_FechaModificacion DATETIME NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') AND name = 'MAR_UsuarioModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS ADD MAR_UsuarioModificacion NVARCHAR(100) NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') AND name = 'MAR_IpCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS ADD MAR_IpCreacion NVARCHAR(45) NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') AND name = 'MAR_IpModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS ADD MAR_IpModificacion NVARCHAR(45) NULL;
END

-- Agregar descripción a Marcas
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') AND name = 'MAR_Descripcion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS ADD MAR_Descripcion NVARCHAR(500) NULL;
END
GO

-- =============================================
-- PASO 2: Agregar SubcategoriaId a ZI_MARCAS
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') AND name = 'MAR_SubcategoriaId')
BEGIN
    -- Agregar la columna
    ALTER TABLE ZI_GENERAL.ZI_MARCAS ADD MAR_SubcategoriaId INT NULL;
    
    -- Agregar la foreign key
    ALTER TABLE ZI_GENERAL.ZI_MARCAS 
    ADD CONSTRAINT FK_MARCAS_SUBCATEGORIAS 
    FOREIGN KEY (MAR_SubcategoriaId) REFERENCES ZI_GENERAL.ZI_SUBCATEGORIAS(SUB_Id);
    
    PRINT 'Columna MAR_SubcategoriaId agregada exitosamente';
END
ELSE
BEGIN
    PRINT 'La columna MAR_SubcategoriaId ya existe';
END
GO

-- =============================================
-- PASO 3: Modificar constraint de nombre único en Marcas
-- =============================================
-- Primero eliminar el constraint de nombre único si existe
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ__ZI_MARCA__' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS'))
BEGIN
    DECLARE @ConstraintName NVARCHAR(200);
    SELECT @ConstraintName = name 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') 
    AND is_unique_constraint = 1 
    AND name LIKE 'UQ__ZI_MARCA%';
    
    IF @ConstraintName IS NOT NULL
    BEGIN
        DECLARE @SQL NVARCHAR(500) = 'ALTER TABLE ZI_GENERAL.ZI_MARCAS DROP CONSTRAINT ' + @ConstraintName;
        EXEC sp_executesql @SQL;
        PRINT 'Constraint único de MAR_Nombre eliminado';
    END
END

-- Crear nuevo constraint: nombre único por subcategoría
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_MARCAS_NOMBRE_SUBCATEGORIA' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS'))
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS 
    ADD CONSTRAINT UQ_MARCAS_NOMBRE_SUBCATEGORIA 
    UNIQUE (MAR_Nombre, MAR_SubcategoriaId);
    
    PRINT 'Constraint único MAR_Nombre + MAR_SubcategoriaId creado';
END
GO

-- =============================================
-- PASO 4: Eliminar MAR_MarcaId de ZI_MODELOS (si es necesario más adelante)
-- =============================================
-- NOTA: Por ahora mantenemos MOD_MarcaId porque ya hay datos
-- Este paso se ejecutará después de migrar los datos existentes

PRINT 'Estructura de tablas actualizada correctamente';
PRINT 'Nueva jerarquía: Categoría ? Subcategoría ? Marca ? Modelo';
GO
