USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedure: SP_CATEGORIAS_LISTAR_PAGINADO
-- Descripción: Lista categorías con paginación y filtros
-- Incluye soporte para filtrar por estado (activos/inactivos/todos)
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_LISTAR_PAGINADO]
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar parámetros
    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 10;
    IF @PageSize > 100 SET @PageSize = 100;
    
    -- Calcular offset para paginación
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    -- Construir la consulta base
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @SQLCount NVARCHAR(MAX);
    DECLARE @WhereClause NVARCHAR(MAX) = N'WHERE 1=1 ';
    
    -- ? FILTRO POR ESTADO (CRÍTICO)
    IF @IncluirInactivos = 0
    BEGIN
        -- Solo activos
        SET @WhereClause = @WhereClause + N'AND CAT_Estado = 1 ';
    END
    -- Si @IncluirInactivos = 1, no agregamos filtro de estado (trae todos)
    
    -- ? FILTRO POR BÚSQUEDA
    IF @SearchTerm IS NOT NULL AND LEN(LTRIM(RTRIM(@SearchTerm))) > 0
    BEGIN
        SET @WhereClause = @WhereClause + N'AND (CAT_Nombre LIKE ''%' + @SearchTerm + N'%'' OR CAT_Descripcion LIKE ''%' + @SearchTerm + N'%'') ';
    END
    
    -- Contar total de registros
    SET @SQLCount = N'
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_CATEGORIAS
        ' + @WhereClause;
    
    EXEC sp_executesql @SQLCount, N'@TotalRegistros INT OUTPUT', @TotalRegistros OUTPUT;
    
    -- Consulta paginada
    SET @SQL = N'
        SELECT 
            CAT_Id AS IdCategoria,
            CAT_Nombre AS Nombre,
            CAT_Descripcion AS Descripcion,
            CAT_Estado AS Activo,
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_SUBCATEGORIAS 
             WHERE SUB_CategoriaId = CAT_Id 
             AND SUB_Estado = 1) AS TotalSubcategorias,
            CAT_FechaCreacion AS FechaCreacion,
            CAT_UsuarioCreacion AS UsuarioCreacion,
            CAT_FechaModificacion AS FechaModificacion,
            CAT_UsuarioModificacion AS UsuarioModificacion
        FROM ZI_GENERAL.ZI_CATEGORIAS
        ' + @WhereClause + N'
        ORDER BY CAT_Id DESC
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY';
    
    EXEC sp_executesql @SQL, 
        N'@Offset INT, @PageSize INT', 
        @Offset, @PageSize;
    
    -- ? DIAGNÓSTICO: Registrar en log
    DECLARE @LogMessage NVARCHAR(500) = 
        'SP_CATEGORIAS_LISTAR_PAGINADO ejecutado: @IncluirInactivos=' + CAST(@IncluirInactivos AS NVARCHAR(1)) + 
        ', @SearchTerm=' + ISNULL(@SearchTerm, 'NULL') + 
        ', @TotalRegistros=' + CAST(@TotalRegistros AS NVARCHAR(10));
    
    PRINT @LogMessage;
END
GO

-- =============================================
-- PRUEBAS DEL STORED PROCEDURE
-- =============================================
/*
-- Prueba 1: Solo categorías activas (comportamiento por defecto)
DECLARE @Total INT;
EXEC ZI_GENERAL.SP_CATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = NULL,
    @IncluirInactivos = 0,
    @TotalRegistros = @Total OUTPUT;
    
SELECT @Total AS TotalCategoríasActivas;

-- Prueba 2: Todas las categorías (activas e inactivas)
DECLARE @Total2 INT;
EXEC ZI_GENERAL.SP_CATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = NULL,
    @IncluirInactivos = 1,
    @TotalRegistros = @Total2 OUTPUT;
    
SELECT @Total2 AS TotalTodasLasCategorías;

-- Prueba 3: Verificar diferencia (debería mostrar cuántas inactivas hay)
DECLARE @TotalActivos INT, @TotalTodos INT;

EXEC ZI_GENERAL.SP_CATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 100,
    @SearchTerm = NULL,
    @IncluirInactivos = 0,
    @TotalRegistros = @TotalActivos OUTPUT;

EXEC ZI_GENERAL.SP_CATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 100,
    @SearchTerm = NULL,
    @IncluirInactivos = 1,
    @TotalRegistros = @TotalTodos OUTPUT;

SELECT 
    @TotalActivos AS CategoríasActivas,
    @TotalTodos AS TotalCategorías,
    (@TotalTodos - @TotalActivos) AS CategoríasInactivas;

-- Prueba 4: Ver las categorías inactivas directamente en SQL
SELECT 
    CAT_Id,
    CAT_Nombre,
    CAT_Estado,
    CASE WHEN CAT_Estado = 1 THEN 'Activo' ELSE 'Inactivo' END AS EstadoTexto
FROM ZI_GENERAL.ZI_CATEGORIAS
WHERE CAT_Estado = 0
ORDER BY CAT_Id DESC;
*/
