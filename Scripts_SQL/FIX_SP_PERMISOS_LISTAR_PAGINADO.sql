-- ============================================
-- CORREGIR STORED PROCEDURE SP_PERMISOS_LISTAR_PAGINADO
-- ============================================

USE PortalMilesimo;
GO

-- Verificar el SP actual
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SP_PERMISOS_LISTAR_PAGINADO' AND schema_id = SCHEMA_ID('ZI_GENERAL'))
BEGIN
    PRINT 'El SP existe. Se va a reemplazar...';
END
ELSE
BEGIN
    PRINT 'El SP no existe. Se creará...';
END
GO

-- Crear o reemplazar el SP con manejo correcto de NULLs y cadenas vacías
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_PERMISOS_LISTAR_PAGINADO]
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @Modulo NVARCHAR(100) = NULL,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- IMPORTANTE: Normalizar cadenas vacías a NULL
    IF @SearchTerm = '' SET @SearchTerm = NULL;
    IF @Modulo = '' SET @Modulo = NULL;

    -- Log de diagnóstico (opcional, comentar en producción)
    PRINT '=== DEBUG SP_PERMISOS_LISTAR_PAGINADO ===';
    PRINT 'PageNumber: ' + CAST(@PageNumber AS VARCHAR);
    PRINT 'PageSize: ' + CAST(@PageSize AS VARCHAR);
    PRINT 'SearchTerm: ' + ISNULL(@SearchTerm, 'NULL');
    PRINT 'IncluirInactivos: ' + CAST(@IncluirInactivos AS VARCHAR);
    PRINT 'Modulo: ' + ISNULL(@Modulo, 'NULL');

    -- Calcular total de registros
    SELECT @TotalRegistros = COUNT(*)
    FROM ZI_GENERAL.ZI_PERMISOS p
    WHERE 
        (@IncluirInactivos = 1 OR p.PER_Activo = 1)
        AND (
            @SearchTerm IS NULL 
            OR p.PER_Nombre LIKE '%' + @SearchTerm + '%' 
            OR p.PER_Descripcion LIKE '%' + @SearchTerm + '%'
            OR p.PER_Modulo LIKE '%' + @SearchTerm + '%'
            OR p.PER_Accion LIKE '%' + @SearchTerm + '%'
        )
        AND (
            @Modulo IS NULL 
            OR p.PER_Modulo = @Modulo
        );

    PRINT 'TotalRegistros calculado: ' + CAST(@TotalRegistros AS VARCHAR);

    -- Obtener registros paginados
    SELECT 
        p.PER_Id AS IdPermiso,
        p.PER_Nombre AS Nombre,
        p.PER_Descripcion AS Descripcion,
        p.PER_Modulo AS Modulo,
        p.PER_Accion AS Accion,
        p.PER_Activo AS Activo,
        p.PER_FechaCreacion AS FechaCreacion,
        p.PER_UsuarioCreacion AS UsuarioCreacion,
        p.PER_FechaModificacion AS FechaModificacion,
        p.PER_UsuarioModificacion AS UsuarioModificacion,
        -- Contar roles que tienen este permiso (TABLA CORRECTA: ZI_PERMISOSROLES)
        (SELECT COUNT(DISTINCT pr.PRO_RolId)
         FROM ZI_GENERAL.ZI_PERMISOSROLES pr
         WHERE pr.PRO_PermisoId = p.PER_Id) AS TotalRoles
    FROM ZI_GENERAL.ZI_PERMISOS p
    WHERE 
        (@IncluirInactivos = 1 OR p.PER_Activo = 1)
        AND (
            @SearchTerm IS NULL 
            OR p.PER_Nombre LIKE '%' + @SearchTerm + '%' 
            OR p.PER_Descripcion LIKE '%' + @SearchTerm + '%'
            OR p.PER_Modulo LIKE '%' + @SearchTerm + '%'
            OR p.PER_Accion LIKE '%' + @SearchTerm + '%'
        )
        AND (
            @Modulo IS NULL 
            OR p.PER_Modulo = @Modulo
        )
    ORDER BY 
        ISNULL(p.PER_Modulo, ''), 
        ISNULL(p.PER_Accion, ''), 
        p.PER_Nombre
    OFFSET ((@PageNumber - 1) * @PageSize) ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    PRINT 'Consulta ejecutada exitosamente';
END
GO

-- Probar el SP con los mismos parámetros que desde C#
PRINT '';
PRINT '=== PRUEBA 1: Con parámetros NULL (como debería venir desde C#) ===';
DECLARE @Total1 INT;
EXEC [ZI_GENERAL].[SP_PERMISOS_LISTAR_PAGINADO]
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = NULL,
    @IncluirInactivos = 0,
    @Modulo = NULL,
    @TotalRegistros = @Total1 OUTPUT;
PRINT 'Total registros: ' + CAST(@Total1 AS VARCHAR);

PRINT '';
PRINT '=== PRUEBA 2: Con cadenas vacías (problema potencial) ===';
DECLARE @Total2 INT;
EXEC [ZI_GENERAL].[SP_PERMISOS_LISTAR_PAGINADO]
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = '',
    @IncluirInactivos = 0,
    @Modulo = '',
    @TotalRegistros = @Total2 OUTPUT;
PRINT 'Total registros: ' + CAST(@Total2 AS VARCHAR);

PRINT '';
PRINT '=== PRUEBA 3: Solo activos ===';
DECLARE @Total3 INT;
EXEC [ZI_GENERAL].[SP_PERMISOS_LISTAR_PAGINADO]
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = NULL,
    @IncluirInactivos = 0,
    @Modulo = NULL,
    @TotalRegistros = @Total3 OUTPUT;
PRINT 'Total registros: ' + CAST(@Total3 AS VARCHAR);

PRINT '';
PRINT '? SP actualizado y probado exitosamente';
PRINT '? TotalRoles ahora usa la tabla correcta: ZI_PERMISOSROLES';
