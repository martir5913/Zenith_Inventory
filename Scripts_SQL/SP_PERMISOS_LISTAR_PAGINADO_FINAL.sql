-- ============================================
-- STORED PROCEDURE FINAL - SP_PERMISOS_LISTAR_PAGINADO
-- CON FILTRO DE ACCIÓN - VERSIÓN PRODUCCIÓN
-- ============================================

USE PortalMilesimo;
GO

-- Crear o reemplazar el SP
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_PERMISOS_LISTAR_PAGINADO]
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @Modulo NVARCHAR(100) = NULL,
    @Accion NVARCHAR(100) = NULL,  -- ? AGREGADO
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Normalizar cadenas vacías a NULL
    IF @SearchTerm = '' SET @SearchTerm = NULL;
    IF @Modulo = '' SET @Modulo = NULL;
    IF @Accion = '' SET @Accion = NULL;  -- ? AGREGADO

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
        )
        AND (  -- ? AGREGADO
            @Accion IS NULL 
            OR p.PER_Accion = @Accion
        );

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
        -- Contar roles que tienen este permiso
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
        AND (  -- ? AGREGADO
            @Accion IS NULL 
            OR p.PER_Accion = @Accion
        )
    ORDER BY 
        ISNULL(p.PER_Modulo, ''), 
        ISNULL(p.PER_Accion, ''), 
        p.PER_Nombre
    OFFSET ((@PageNumber - 1) * @PageSize) ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

PRINT '? Stored Procedure SP_PERMISOS_LISTAR_PAGINADO actualizado correctamente con filtro de Acción';
