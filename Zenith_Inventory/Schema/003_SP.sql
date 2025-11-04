USE [DB_Zenith_Inventory]
GO
create PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_LISTAR_PAGINADO]
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Calcular offset
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        
        -- Obtener total de registros (para calcular páginas totales)
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_CATEGORIAS
        WHERE 
            (@IncluirInactivos = 1 OR CAT_Estado = 1)
            AND (@SearchTerm IS NULL OR 
                 CAT_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 CAT_Descripcion LIKE '%' + @SearchTerm + '%');
        
        -- Obtener registros paginados
        SELECT 
            CAT_Id AS IdCategoria,
            CAT_Nombre AS Nombre,
            CAT_Descripcion AS Descripcion,
            CAT_Estado AS Activo,
            -- Información adicional útil
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_SUBCATEGORIAS 
             WHERE SUB_CategoriaId = CAT_Id AND SUB_Estado = 1) AS TotalSubcategorias
        FROM ZI_GENERAL.ZI_CATEGORIAS
        WHERE 
            (@IncluirInactivos = 1 OR CAT_Estado = 1)
            AND (@SearchTerm IS NULL OR 
                 CAT_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 CAT_Descripcion LIKE '%' + @SearchTerm + '%')
        ORDER BY CAT_Nombre ASC
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
