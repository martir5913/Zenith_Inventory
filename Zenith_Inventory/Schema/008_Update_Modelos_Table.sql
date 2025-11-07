USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Script para actualizar tabla ZI_MODELOS
-- Eliminar MOD_SubcategoriaId (redundante con nueva jerarquía)
-- Agregar columnas de auditoría
-- =============================================

PRINT '========================================';
PRINT 'Iniciando actualización de ZI_MODELOS';
PRINT '========================================';
GO

-- =============================================
-- PASO 1: Agregar columnas de auditoría a ZI_MODELOS
-- =============================================
PRINT 'Paso 1: Agregando columnas de auditoría...';

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS') AND name = 'MOD_Descripcion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS ADD MOD_Descripcion NVARCHAR(500) NULL;
    PRINT '  - MOD_Descripcion agregada';
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS') AND name = 'MOD_FechaCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS ADD MOD_FechaCreacion DATETIME DEFAULT GETDATE() NOT NULL;
    PRINT '  - MOD_FechaCreacion agregada';
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS') AND name = 'MOD_UsuarioCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS ADD MOD_UsuarioCreacion NVARCHAR(100) NULL;
    PRINT '  - MOD_UsuarioCreacion agregada';
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS') AND name = 'MOD_FechaModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS ADD MOD_FechaModificacion DATETIME NULL;
    PRINT '  - MOD_FechaModificacion agregada';
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS') AND name = 'MOD_UsuarioModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS ADD MOD_UsuarioModificacion NVARCHAR(100) NULL;
    PRINT '  - MOD_UsuarioModificacion agregada';
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS') AND name = 'MOD_IpCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS ADD MOD_IpCreacion NVARCHAR(45) NULL;
    PRINT '  - MOD_IpCreacion agregada';
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS') AND name = 'MOD_IpModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS ADD MOD_IpModificacion NVARCHAR(45) NULL;
    PRINT '  - MOD_IpModificacion agregada';
END
GO

-- =============================================
-- PASO 2: Verificar y corregir datos antes de eliminar MOD_SubcategoriaId
-- =============================================
PRINT 'Paso 2: Verificando consistencia de datos...';

-- Contar inconsistencias
DECLARE @Inconsistencias INT;
SELECT @Inconsistencias = COUNT(*)
FROM ZI_GENERAL.ZI_MODELOS MOD
INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
WHERE MOD.MOD_SubcategoriaId <> MAR.MAR_SubcategoriaId
OR MOD.MOD_SubcategoriaId IS NULL;

IF @Inconsistencias > 0
BEGIN
    PRINT '  ?? Se encontraron ' + CAST(@Inconsistencias AS NVARCHAR(10)) + ' registros inconsistentes';
    PRINT '  - Corrigiendo automáticamente...';
    
    -- Corregir inconsistencias
    UPDATE MOD
    SET MOD.MOD_SubcategoriaId = MAR.MAR_SubcategoriaId
    FROM ZI_GENERAL.ZI_MODELOS MOD
    INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
    WHERE MOD.MOD_SubcategoriaId <> MAR.MAR_SubcategoriaId
    OR MOD.MOD_SubcategoriaId IS NULL;
    
    PRINT '  ? Inconsistencias corregidas';
END
ELSE
BEGIN
    PRINT '  ? No se encontraron inconsistencias';
END
GO

-- =============================================
-- PASO 3: Eliminar constraint único antiguo si existe
-- =============================================
PRINT 'Paso 3: Eliminando constraints antiguos...';

-- Buscar y eliminar el constraint único que incluye MOD_SubcategoriaId
DECLARE @ConstraintName NVARCHAR(200);
DECLARE @SQL NVARCHAR(500);

SELECT @ConstraintName = kc.name
FROM sys.key_constraints kc
INNER JOIN sys.indexes i ON kc.parent_object_id = i.object_id AND kc.unique_index_id = i.index_id
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE kc.parent_object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS')
AND kc.type = 'UQ'
AND c.name = 'MOD_SubcategoriaId';

IF @ConstraintName IS NOT NULL
BEGIN
    SET @SQL = 'ALTER TABLE ZI_GENERAL.ZI_MODELOS DROP CONSTRAINT ' + @ConstraintName;
    EXEC sp_executesql @SQL;
    PRINT '  - Constraint único ' + @ConstraintName + ' eliminado';
END
ELSE
BEGIN
    PRINT '  - No se encontró constraint único con MOD_SubcategoriaId';
END
GO

-- =============================================
-- PASO 4: Eliminar Foreign Key de MOD_SubcategoriaId
-- =============================================
PRINT 'Paso 4: Eliminando Foreign Key...';

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MODELOS_SUBCATEGORIAS' OR name LIKE 'FK__ZI_MODELO__MOD_S%')
BEGIN
    DECLARE @FKName NVARCHAR(200);
    SELECT @FKName = name 
    FROM sys.foreign_keys 
    WHERE parent_object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS')
    AND (name = 'FK_MODELOS_SUBCATEGORIAS' OR name LIKE 'FK__ZI_MODELO__MOD_S%');
    
    IF @FKName IS NOT NULL
    BEGIN
        DECLARE @DropFK NVARCHAR(500) = 'ALTER TABLE ZI_GENERAL.ZI_MODELOS DROP CONSTRAINT ' + @FKName;
        EXEC sp_executesql @DropFK;
        PRINT '  - Foreign Key ' + @FKName + ' eliminada';
    END
END
ELSE
BEGIN
    PRINT '  - No se encontró Foreign Key para eliminar';
END
GO

-- =============================================
-- PASO 5: Eliminar la columna MOD_SubcategoriaId
-- =============================================
PRINT 'Paso 5: Eliminando columna MOD_SubcategoriaId...';

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS') AND name = 'MOD_SubcategoriaId')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS DROP COLUMN MOD_SubcategoriaId;
    PRINT '  ? Columna MOD_SubcategoriaId eliminada exitosamente';
END
ELSE
BEGIN
    PRINT '  - Columna MOD_SubcategoriaId ya no existe';
END
GO

-- =============================================
-- PASO 6: Crear nuevo constraint único correcto
-- =============================================
PRINT 'Paso 6: Creando constraint único correcto...';

-- Eliminar constraint antiguo si existe (sin SubcategoriaId)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_MODELOS_NOMBRE_MARCA' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS'))
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS DROP CONSTRAINT UQ_MODELOS_NOMBRE_MARCA;
    PRINT '  - Constraint único anterior eliminado';
END

-- Crear nuevo constraint: Nombre único por Marca
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_MODELOS_NOMBRE_MARCA' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS'))
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS 
    ADD CONSTRAINT UQ_MODELOS_NOMBRE_MARCA 
    UNIQUE (MOD_Nombre, MOD_MarcaId);
    
    PRINT '  ? Constraint único (MOD_Nombre, MOD_MarcaId) creado';
END
GO

-- =============================================
-- PASO 7: Verificar estructura final
-- =============================================
PRINT 'Paso 7: Verificando estructura final...';
PRINT '';

SELECT 
    'ZI_MODELOS' AS Tabla,
    COLUMN_NAME AS Columna,
    DATA_TYPE AS Tipo,
    IS_NULLABLE AS Nullable,
    COLUMN_DEFAULT AS ValorPorDefecto
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ZI_GENERAL'
AND TABLE_NAME = 'ZI_MODELOS'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '========================================';
PRINT '? Actualización completada exitosamente';
PRINT '========================================';
PRINT '';
PRINT 'Nueva estructura de ZI_MODELOS:';
PRINT '  - MOD_Id (PK)';
PRINT '  - MOD_Nombre';
PRINT '  - MOD_MarcaId (FK a ZI_MARCAS)';
PRINT '  - MOD_Descripcion';
PRINT '  - MOD_Estado';
PRINT '  - Campos de auditoría completos';
PRINT '';
PRINT 'Jerarquía correcta implementada:';
PRINT '  Categoría ? Subcategoría ? Marca ? Modelo';
PRINT '';
PRINT 'Constraint único: (MOD_Nombre, MOD_MarcaId)';
GO
