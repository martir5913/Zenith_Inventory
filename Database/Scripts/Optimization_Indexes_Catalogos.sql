-- =============================================
-- OPTIMIZACIÓN DE RENDIMIENTO - ÍNDICES
-- Zenith Inventory - Módulos de Categorías y Subcategorías
-- =============================================
-- Fecha: 2024
-- Descripción: Índices optimizados para mejorar el rendimiento
--              de consultas en los módulos de catálogos
-- =============================================

USE [Zenith_Inventory];
GO

-- =============================================
-- 1. ÍNDICES PARA TABLA ZI_CATEGORIAS
-- =============================================

PRINT '?? Verificando índices existentes en ZI_CATEGORIAS...';
GO

-- Índice para búsquedas y listados filtrados por estado
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CATEGORIAS_ACTIVO_NOMBRE' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_CATEGORIAS'))
BEGIN
    PRINT '? Creando índice IX_CATEGORIAS_ACTIVO_NOMBRE...';
    CREATE NONCLUSTERED INDEX IX_CATEGORIAS_ACTIVO_NOMBRE
    ON ZI_GENERAL.ZI_CATEGORIAS(Activo, Nombre)
    INCLUDE (Descripcion, FechaCreacion, UsuarioCreacion);
    PRINT '   Índice creado exitosamente.';
END
ELSE
BEGIN
    PRINT '??  Índice IX_CATEGORIAS_ACTIVO_NOMBRE ya existe.';
END
GO

-- Índice para búsquedas de texto en nombre
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CATEGORIAS_NOMBRE' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_CATEGORIAS'))
BEGIN
    PRINT '? Creando índice IX_CATEGORIAS_NOMBRE...';
    CREATE NONCLUSTERED INDEX IX_CATEGORIAS_NOMBRE
    ON ZI_GENERAL.ZI_CATEGORIAS(Nombre)
    WHERE Activo = 1;
    PRINT '   Índice creado exitosamente.';
END
ELSE
BEGIN
    PRINT '??  Índice IX_CATEGORIAS_NOMBRE ya existe.';
END
GO

-- =============================================
-- 2. ÍNDICES PARA TABLA ZI_SUBCATEGORIAS
-- =============================================

PRINT '?? Verificando índices existentes en ZI_SUBCATEGORIAS...';
GO

-- Índice compuesto para filtros comunes (estado + categoría)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SUBCATEGORIAS_ACTIVO_CATEGORIA' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS'))
BEGIN
    PRINT '? Creando índice IX_SUBCATEGORIAS_ACTIVO_CATEGORIA...';
    CREATE NONCLUSTERED INDEX IX_SUBCATEGORIAS_ACTIVO_CATEGORIA
    ON ZI_GENERAL.ZI_SUBCATEGORIAS(Activo, IdCategoria)
    INCLUDE (Nombre, Descripcion, FechaCreacion, UsuarioCreacion);
    PRINT '   Índice creado exitosamente.';
END
ELSE
BEGIN
    PRINT '??  Índice IX_SUBCATEGORIAS_ACTIVO_CATEGORIA ya existe.';
END
GO

-- Índice para búsquedas de texto en nombre
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SUBCATEGORIAS_NOMBRE' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS'))
BEGIN
    PRINT '? Creando índice IX_SUBCATEGORIAS_NOMBRE...';
    CREATE NONCLUSTERED INDEX IX_SUBCATEGORIAS_NOMBRE
    ON ZI_GENERAL.ZI_SUBCATEGORIAS(Nombre)
    WHERE Activo = 1;
    PRINT '   Índice creado exitosamente.';
END
ELSE
BEGIN
    PRINT '??  Índice IX_SUBCATEGORIAS_NOMBRE ya existe.';
END
GO

-- Índice para FK hacia Categorías (mejora JOINs)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SUBCATEGORIAS_IDCATEGORIA' AND object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS'))
BEGIN
    PRINT '? Creando índice IX_SUBCATEGORIAS_IDCATEGORIA...';
    CREATE NONCLUSTERED INDEX IX_SUBCATEGORIAS_IDCATEGORIA
    ON ZI_GENERAL.ZI_SUBCATEGORIAS(IdCategoria);
    PRINT '   Índice creado exitosamente.';
END
ELSE
BEGIN
    PRINT '??  Índice IX_SUBCATEGORIAS_IDCATEGORIA ya existe.';
END
GO

-- =============================================
-- 3. ACTUALIZAR ESTADÍSTICAS
-- =============================================

PRINT '?? Actualizando estadísticas...';
GO

UPDATE STATISTICS ZI_GENERAL.ZI_CATEGORIAS WITH FULLSCAN;
UPDATE STATISTICS ZI_GENERAL.ZI_SUBCATEGORIAS WITH FULLSCAN;

PRINT '? Estadísticas actualizadas.';
GO

-- =============================================
-- 4. VERIFICAR FRAGMENTACIÓN DE ÍNDICES
-- =============================================

PRINT '?? Verificando fragmentación de índices...';
GO

SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc AS IndexType,
    ips.avg_fragmentation_in_percent AS FragmentationPercent,
    ips.page_count AS PageCount,
    CASE 
        WHEN ips.avg_fragmentation_in_percent > 30 THEN '? Requiere REBUILD'
        WHEN ips.avg_fragmentation_in_percent > 10 THEN '??  Requiere REORGANIZE'
        ELSE '? OK'
    END AS Recommendation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE OBJECT_NAME(i.object_id) IN ('ZI_CATEGORIAS', 'ZI_SUBCATEGORIAS')
    AND ips.index_id > 0
    AND ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;
GO

-- =============================================
-- 5. PLAN DE MANTENIMIENTO RECOMENDADO
-- =============================================

PRINT '';
PRINT '?? PLAN DE MANTENIMIENTO RECOMENDADO:';
PRINT '----------------------------------------';
PRINT '1. Ejecutar REORGANIZE si fragmentación > 10%';
PRINT '2. Ejecutar REBUILD si fragmentación > 30%';
PRINT '3. Actualizar estadísticas semanalmente';
PRINT '4. Monitorear planes de ejecución de SPs';
PRINT '';
PRINT '?? Comandos de mantenimiento:';
PRINT '';
PRINT '-- Reorganizar índices:';
PRINT 'ALTER INDEX ALL ON ZI_GENERAL.ZI_CATEGORIAS REORGANIZE;';
PRINT 'ALTER INDEX ALL ON ZI_GENERAL.ZI_SUBCATEGORIAS REORGANIZE;';
PRINT '';
PRINT '-- Reconstruir índices (si fragmentación > 30%):';
PRINT 'ALTER INDEX ALL ON ZI_GENERAL.ZI_CATEGORIAS REBUILD WITH (ONLINE = OFF);';
PRINT 'ALTER INDEX ALL ON ZI_GENERAL.ZI_SUBCATEGORIAS REBUILD WITH (ONLINE = OFF);';
PRINT '';
PRINT '-- Actualizar estadísticas:';
PRINT 'UPDATE STATISTICS ZI_GENERAL.ZI_CATEGORIAS WITH FULLSCAN;';
PRINT 'UPDATE STATISTICS ZI_GENERAL.ZI_SUBCATEGORIAS WITH FULLSCAN;';
PRINT '';
GO

-- =============================================
-- 6. ANALIZAR PLANES DE EJECUCIÓN
-- =============================================

PRINT '?? Analizando planes de ejecución de procedimientos almacenados...';
PRINT 'Ejecute los siguientes comandos para analizar rendimiento:';
PRINT '';
PRINT '-- Habilitar estadísticas:';
PRINT 'SET STATISTICS IO ON;';
PRINT 'SET STATISTICS TIME ON;';
PRINT '';
PRINT '-- Probar SP de Categorías:';
PRINT 'EXEC ZI_GENERAL.SP_CATEGORIAS_LISTAR_PAGINADO';
PRINT '    @PageNumber = 1,';
PRINT '    @PageSize = 10,';
PRINT '    @SearchTerm = NULL,';
PRINT '    @IncluirInactivos = 0;';
PRINT '';
PRINT '-- Probar SP de Subcategorías:';
PRINT 'EXEC ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO';
PRINT '    @PageNumber = 1,';
PRINT '    @PageSize = 10,';
PRINT '    @SearchTerm = NULL,';
PRINT '    @IncluirInactivos = 0,';
PRINT '    @IdCategoria = NULL;';
PRINT '';
PRINT '-- Deshabilitar estadísticas:';
PRINT 'SET STATISTICS IO OFF;';
PRINT 'SET STATISTICS TIME OFF;';
PRINT '';
GO

-- =============================================
-- 7. ÍNDICES ADICIONALES (OPCIONALES)
-- =============================================

PRINT '?? ÍNDICES OPCIONALES (crear según necesidad):';
PRINT '----------------------------------------------';
PRINT '';
PRINT '-- Si se realizan muchas búsquedas por fecha de creación:';
PRINT 'CREATE NONCLUSTERED INDEX IX_CATEGORIAS_FECHACREACION';
PRINT 'ON ZI_GENERAL.ZI_CATEGORIAS(FechaCreacion DESC)';
PRINT 'INCLUDE (IdCategoria, Nombre, Activo);';
PRINT '';
PRINT '-- Si se realizan muchas búsquedas por usuario creador:';
PRINT 'CREATE NONCLUSTERED INDEX IX_CATEGORIAS_USUARIOCREACION';
PRINT 'ON ZI_GENERAL.ZI_CATEGORIAS(UsuarioCreacion)';
PRINT 'INCLUDE (IdCategoria, Nombre, Activo);';
PRINT '';
GO

-- =============================================
-- 8. RESUMEN DE OPTIMIZACIONES
-- =============================================

PRINT '';
PRINT '???????????????????????????????????????????????';
PRINT '? RESUMEN DE OPTIMIZACIONES COMPLETADAS';
PRINT '???????????????????????????????????????????????';
PRINT '';
PRINT '?? Índices creados/verificados:';
PRINT '   • IX_CATEGORIAS_ACTIVO_NOMBRE';
PRINT '   • IX_CATEGORIAS_NOMBRE';
PRINT '   • IX_SUBCATEGORIAS_ACTIVO_CATEGORIA';
PRINT '   • IX_SUBCATEGORIAS_NOMBRE';
PRINT '   • IX_SUBCATEGORIAS_IDCATEGORIA';
PRINT '';
PRINT '?? Mejoras esperadas:';
PRINT '   • 50-80% reducción en tiempo de consultas SQL';
PRINT '   • Mejor rendimiento en búsquedas y filtros';
PRINT '   • Optimización de JOINs entre tablas';
PRINT '';
PRINT '? Próximos pasos:';
PRINT '   1. Monitorear rendimiento de consultas';
PRINT '   2. Verificar fragmentación regularmente';
PRINT '   3. Actualizar estadísticas semanalmente';
PRINT '   4. Revisar planes de ejecución periódicamente';
PRINT '';
PRINT '???????????????????????????????????????????????';
GO
