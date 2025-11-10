USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedure: SP_SUBCATEGORIAS_LISTAR_PAGINADO
-- Descripción: Lista subcategorías con paginación y filtros
-- Incluye soporte para filtrar por estado (activos/inactivos/todos)
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_LISTAR_PAGINADO]
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @IdCategoria INT = NULL,
    @SoloInactivos BIT = NULL,
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
    
    -- ? FILTRO POR ESTADO (CRÍTICO - 3 ESTADOS POSIBLES)
    IF @SoloInactivos = 1
    BEGIN
        -- Solo inactivos
        SET @WhereClause = @WhereClause + N'AND s.SUB_Estado = 0 ';
    END
    ELSE IF @IncluirInactivos = 0
    BEGIN
        -- Solo activos
        SET @WhereClause = @WhereClause + N'AND s.SUB_Estado = 1 ';
    END
    -- Si @IncluirInactivos = 1 y @SoloInactivos IS NULL ? Trae todos (no filtra por estado)
    
    -- ? FILTRO POR CATEGORÍA
    IF @IdCategoria IS NOT NULL
    BEGIN
        SET @WhereClause = @WhereClause + N'AND s.SUB_CategoriaId = @IdCategoria ';
    END
    
    -- ? FILTRO POR BÚSQUEDA
    IF @SearchTerm IS NOT NULL AND LEN(LTRIM(RTRIM(@SearchTerm))) > 0
    BEGIN
        SET @WhereClause = @WhereClause + N'AND (s.SUB_Nombre LIKE ''%' + @SearchTerm + N'%'' OR s.SUB_Descripcion LIKE ''%' + @SearchTerm + N'%'') ';
    END
    
    -- Contar total de registros
    SET @SQLCount = N'
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS s
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS c ON s.SUB_CategoriaId = c.CAT_Id
        ' + @WhereClause;
    
    DECLARE @ParamsCount NVARCHAR(MAX) = N'@TotalRegistros INT OUTPUT, @IdCategoria INT';
    EXEC sp_executesql @SQLCount, @ParamsCount, @TotalRegistros OUTPUT, @IdCategoria;
    
    -- Consulta paginada
    SET @SQL = N'
        SELECT 
            s.SUB_Id AS IdSubcategoria,
            s.SUB_Nombre AS Nombre,
            s.SUB_Descripcion AS Descripcion,
            s.SUB_Estado AS Activo,
            s.SUB_CategoriaId AS IdCategoria,
            c.CAT_Nombre AS NombreCategoria,
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_MODELOS 
             WHERE MOD_SubcategoriaId = s.SUB_Id 
             AND MOD_Estado = 1) AS TotalModelos,
            s.SUB_FechaCreacion AS FechaCreacion,
            s.SUB_UsuarioCreacion AS UsuarioCreacion,
            s.SUB_FechaModificacion AS FechaModificacion,
            s.SUB_UsuarioModificacion AS UsuarioModificacion
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS s
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS c ON s.SUB_CategoriaId = c.CAT_Id
        ' + @WhereClause + N'
        ORDER BY s.SUB_Id DESC
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY';
    
    DECLARE @Params NVARCHAR(MAX) = N'@Offset INT, @PageSize INT, @IdCategoria INT';
    EXEC sp_executesql @SQL, @Params, @Offset, @PageSize, @IdCategoria;
    
    -- ? DIAGNÓSTICO: Registrar en log
    DECLARE @LogMessage NVARCHAR(500) = 
        'SP_SUBCATEGORIAS_LISTAR_PAGINADO ejecutado: @IncluirInactivos=' + CAST(@IncluirInactivos AS NVARCHAR(1)) + 
        ', @SoloInactivos=' + ISNULL(CAST(@SoloInactivos AS NVARCHAR(1)), 'NULL') +
        ', @IdCategoria=' + ISNULL(CAST(@IdCategoria AS NVARCHAR(10)), 'NULL') +
        ', @SearchTerm=' + ISNULL(@SearchTerm, 'NULL') + 
        ', @TotalRegistros=' + CAST(@TotalRegistros AS NVARCHAR(10));
    
    PRINT @LogMessage;
END
GO

-- =============================================
-- PRUEBAS DEL STORED PROCEDURE
-- =============================================
/*
-- Prueba 1: Solo subcategorías activas (comportamiento por defecto)
DECLARE @Total INT;
EXEC ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = NULL,
    @IncluirInactivos = 0,
    @IdCategoria = NULL,
    @SoloInactivos = NULL,
    @TotalRegistros = @Total OUTPUT;
    
SELECT @Total AS TotalSubcategoriasActivas;

-- Prueba 2: Todas las subcategorías (activas e inactivas)
DECLARE @Total2 INT;
EXEC ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = NULL,
    @IncluirInactivos = 1,
    @IdCategoria = NULL,
    @SoloInactivos = NULL,
    @TotalRegistros = @Total2 OUTPUT;
    
SELECT @Total2 AS TotalTodasLasSubcategorias;

-- Prueba 3: Solo subcategorías inactivas
DECLARE @Total3 INT;
EXEC ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 100,
    @SearchTerm = NULL,
    @IncluirInactivos = 1,
    @IdCategoria = NULL,
    @SoloInactivos = 1,
    @TotalRegistros = @Total3 OUTPUT;
    
SELECT @Total3 AS TotalSubcategoriasInactivas;

-- Prueba 4: Verificar diferencia (debería mostrar cuántas inactivas hay)
DECLARE @TotalActivos INT, @TotalTodos INT, @TotalInactivos INT;

EXEC ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 100,
    @SearchTerm = NULL,
    @IncluirInactivos = 0,
    @IdCategoria = NULL,
    @SoloInactivos = NULL,
    @TotalRegistros = @TotalActivos OUTPUT;

EXEC ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 100,
    @SearchTerm = NULL,
    @IncluirInactivos = 1,
    @IdCategoria = NULL,
    @SoloInactivos = NULL,
    @TotalRegistros = @TotalTodos OUTPUT;

EXEC ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 100,
    @SearchTerm = NULL,
    @IncluirInactivos = 1,
    @IdCategoria = NULL,
    @SoloInactivos = 1,
    @TotalRegistros = @TotalInactivos OUTPUT;

SELECT 
    @TotalActivos AS SubcategoríasActivas,
    @TotalInactivos AS SubcategoríasInactivas,
    @TotalTodos AS TotalSubcategorías;

-- Prueba 5: Ver las subcategorías inactivas directamente en SQL
SELECT 
    SUB_Id,
    SUB_Nombre,
    SUB_Estado,
    CASE WHEN SUB_Estado = 1 THEN 'Activo' ELSE 'Inactivo' END AS EstadoTexto
FROM ZI_GENERAL.ZI_SUBCATEGORIAS
WHERE SUB_Estado = 0
ORDER BY SUB_Id DESC;
*/
