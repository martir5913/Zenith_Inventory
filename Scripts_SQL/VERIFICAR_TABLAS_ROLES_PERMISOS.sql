-- ============================================
-- VERIFICAR NOMBRE DE TABLAS DE ROLES Y PERMISOS
-- ============================================

USE PortalMilesimo;
GO

PRINT '=== VERIFICANDO TABLAS EXISTENTES ===';
PRINT '';

-- Verificar tablas que contengan "ROL" en el esquema ZI_GENERAL
PRINT 'Tablas que contienen ROL:';
SELECT 
    SCHEMA_NAME(schema_id) + '.' + name AS NombreCompleto,
    name AS NombreTabla
FROM sys.tables
WHERE name LIKE '%ROL%'
  AND schema_id = SCHEMA_ID('ZI_GENERAL')
ORDER BY name;

PRINT '';

-- Verificar tablas que contengan "PERM" en el esquema ZI_GENERAL
PRINT 'Tablas que contienen PERM:';
SELECT 
    SCHEMA_NAME(schema_id) + '.' + name AS NombreCompleto,
    name AS NombreTabla
FROM sys.tables
WHERE name LIKE '%PERM%'
  AND schema_id = SCHEMA_ID('ZI_GENERAL')
ORDER BY name;

PRINT '';

-- Buscar todas las tablas en ZI_GENERAL
PRINT 'Todas las tablas en ZI_GENERAL:';
SELECT 
    SCHEMA_NAME(schema_id) + '.' + name AS NombreCompleto,
    name AS NombreTabla
FROM sys.tables
WHERE schema_id = SCHEMA_ID('ZI_GENERAL')
ORDER BY name;

PRINT '';

-- Verificar si existe alguna tabla de relación
PRINT 'Tablas que podrían ser relaciones (contienen dos nombres):';
SELECT 
    SCHEMA_NAME(schema_id) + '.' + name AS NombreCompleto,
    name AS NombreTabla
FROM sys.tables
WHERE schema_id = SCHEMA_ID('ZI_GENERAL')
  AND (name LIKE '%_%_%' OR name LIKE '%ROL%PERM%' OR name LIKE '%PERM%ROL%')
ORDER BY name;
