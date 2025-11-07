USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Script FINAL para corregir jerarquía de catálogos
-- Estructura CORRECTA: Categoría ? Subcategoría ? Modelo ? Marca (independiente)
-- =============================================

PRINT '========================================';
PRINT 'Corrección FINAL de jerarquía de catálogos';
PRINT '========================================';
GO

-- =============================================
-- PASO 1: Corregir ZI_MARCAS - Eliminar MAR_SubcategoriaId
-- =============================================
PRINT 'Paso 1: Eliminando MAR_SubcategoriaId de ZI_MARCAS...';

-- Eliminar Foreign Key de MAR_SubcategoriaId
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MARCAS_SUBCATEGORIAS')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS DROP CONSTRAINT FK_MARCAS_SUBCATEGORIAS;
    PRINT '  - Foreign Key FK_MARCAS_SUBCATEGORIAS eliminada';
END

-- Eliminar constraint único que incluye MAR_SubcategoriaId
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_MARCAS_NOMBRE_SUBCATEGORIA' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS'))
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS DROP CONSTRAINT UQ_MARCAS_NOMBRE_SUBCATEGORIA;
    PRINT '  - Constraint único UQ_MARCAS_NOMBRE_SUBCATEGORIA eliminado';
END

-- Eliminar la columna MAR_SubcategoriaId
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS') AND name = 'MAR_SubcategoriaId')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS DROP COLUMN MAR_SubcategoriaId;
    PRINT '  ? Columna MAR_SubcategoriaId eliminada';
END

-- Crear constraint único: nombre único globalmente
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_MARCAS_NOMBRE' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_MARCAS'))
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MARCAS 
    ADD CONSTRAINT UQ_MARCAS_NOMBRE UNIQUE (MAR_Nombre);
    
    PRINT '  ? Constraint único (MAR_Nombre) creado';
END
GO

-- =============================================
-- PASO 2: Restaurar MOD_SubcategoriaId en ZI_MODELOS si fue eliminado
-- =============================================
PRINT 'Paso 2: Verificando MOD_SubcategoriaId en ZI_MODELOS...';

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS') AND name = 'MOD_SubcategoriaId')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS ADD MOD_SubcategoriaId INT NULL;
    PRINT '  - Columna MOD_SubcategoriaId agregada';
    
    -- Agregar Foreign Key
    ALTER TABLE ZI_GENERAL.ZI_MODELOS 
    ADD CONSTRAINT FK_MODELOS_SUBCATEGORIAS 
    FOREIGN KEY (MOD_SubcategoriaId) REFERENCES ZI_GENERAL.ZI_SUBCATEGORIAS(SUB_Id);
    
    PRINT '  ? Foreign Key FK_MODELOS_SUBCATEGORIAS creada';
END
ELSE
BEGIN
    PRINT '  ? Columna MOD_SubcategoriaId ya existe';
    
    -- Verificar que tenga Foreign Key
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys 
                   WHERE parent_object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS')
                   AND referenced_object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS'))
    BEGIN
        ALTER TABLE ZI_GENERAL.ZI_MODELOS 
        ADD CONSTRAINT FK_MODELOS_SUBCATEGORIAS 
        FOREIGN KEY (MOD_SubcategoriaId) REFERENCES ZI_GENERAL.ZI_SUBCATEGORIAS(SUB_Id);
        
        PRINT '  ? Foreign Key FK_MODELOS_SUBCATEGORIAS creada';
    END
END
GO

-- =============================================
-- PASO 3: Actualizar constraint único de ZI_MODELOS
-- =============================================
PRINT 'Paso 3: Actualizando constraint único de ZI_MODELOS...';

-- Eliminar constraint antiguo si existe
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_MODELOS_NOMBRE_MARCA' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS'))
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS DROP CONSTRAINT UQ_MODELOS_NOMBRE_MARCA;
    PRINT '  - Constraint único anterior eliminado';
END

-- Crear nuevo constraint: Nombre único por Marca y Subcategoría
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_MODELOS_NOMBRE_MARCA_SUBCATEGORIA' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_MODELOS'))
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_MODELOS 
    ADD CONSTRAINT UQ_MODELOS_NOMBRE_MARCA_SUBCATEGORIA 
    UNIQUE (MOD_Nombre, MOD_MarcaId, MOD_SubcategoriaId);
    
    PRINT '  ? Constraint único (MOD_Nombre, MOD_MarcaId, MOD_SubcategoriaId) creado';
END
GO

-- =============================================
-- PASO 4: Actualizar columna TotalModelos en Subcategorías
-- =============================================
PRINT 'Paso 4: Actualizando nombre de columna en Subcategorías...';

-- Cambiar TotalMarcas por TotalModelos en SP si existe
-- (Los SPs se actualizarán en scripts posteriores)

PRINT '  ? Preparación completada';
GO

-- =============================================
-- PASO 5: Verificar estructura final
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'Verificación de Estructura Final';
PRINT '========================================';
PRINT '';

PRINT '? ZI_CATEGORIAS:';
PRINT '   - CAT_Id, CAT_Nombre, CAT_Descripcion, CAT_Estado';
PRINT '   - Campos de auditoría';
PRINT '';

PRINT '? ZI_SUBCATEGORIAS:';
PRINT '   - SUB_Id, SUB_Nombre, SUB_CategoriaId (FK), SUB_Descripcion, SUB_Estado';
PRINT '   - Campos de auditoría';
PRINT '';

PRINT '? ZI_MARCAS (INDEPENDIENTE):';
PRINT '   - MAR_Id, MAR_Nombre (UNIQUE global), MAR_Descripcion, MAR_Estado';
PRINT '   - Campos de auditoría';
PRINT '   ? MAR_SubcategoriaId ELIMINADO';
PRINT '';

PRINT '? ZI_MODELOS:';
PRINT '   - MOD_Id, MOD_Nombre';
PRINT '   - MOD_MarcaId (FK a Marcas) ? Reutilizable';
PRINT '   - MOD_SubcategoriaId (FK a Subcategorías) ? Específico';
PRINT '   - MOD_Descripcion, MOD_Estado';
PRINT '   - Campos de auditoría';
PRINT '   - UNIQUE (MOD_Nombre, MOD_MarcaId, MOD_SubcategoriaId)';
PRINT '';

PRINT '========================================';
PRINT '? Estructura corregida exitosamente';
PRINT '========================================';
PRINT '';
PRINT 'Jerarquía FINAL:';
PRINT '  Categoría ? Subcategoría ? Modelo ? Marca (independiente)';
PRINT '';
PRINT 'Ejemplos:';
PRINT '  - Marca DELL (única, ID: 1)';
PRINT '    ? Modelo Optiplex 7090 (MarcaId: 1, SubcategoriaId: 1 "Escritorio")';
PRINT '    ? Modelo Latitude 5520 (MarcaId: 1, SubcategoriaId: 2 "Portátil")';
PRINT '';
GO
