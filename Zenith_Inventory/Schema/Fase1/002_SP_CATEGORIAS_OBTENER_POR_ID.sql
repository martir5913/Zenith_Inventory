USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedure: SP_CATEGORIAS_OBTENER_POR_ID
-- Descripción: Obtiene los detalles completos de una categoría por su ID
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_OBTENER_POR_ID]
    @IdCategoria INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validar que el ID sea válido
        IF @IdCategoria <= 0
        BEGIN
            RAISERROR('El ID de la categoría debe ser mayor a 0', 16, 1);
            RETURN;
        END
        
        -- Validar que la categoría existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Id = @IdCategoria)
        BEGIN
            RAISERROR('La categoría no existe', 16, 1);
            RETURN;
        END
        
        -- Retornar los datos de la categoría
        SELECT 
            CAT_Id AS IdCategoria,
            CAT_Nombre AS Nombre,
            CAT_Descripcion AS Descripcion,
            CAT_Estado AS Activo,  -- ? CRÍTICO: Mapear CAT_Estado como Activo
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_SUBCATEGORIAS 
             WHERE SUB_CategoriaId = CAT_Id 
             AND SUB_Estado = 1) AS TotalSubcategorias,
            CAT_FechaCreacion AS FechaCreacion,
            CAT_UsuarioCreacion AS UsuarioCreacion,
            CAT_FechaModificacion AS FechaModificacion,
            CAT_UsuarioModificacion AS UsuarioModificacion
        FROM ZI_GENERAL.ZI_CATEGORIAS
        WHERE CAT_Id = @IdCategoria;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- PRUEBAS DEL STORED PROCEDURE
-- =============================================
/*
-- Prueba 1: Obtener una categoría activa
EXEC ZI_GENERAL.SP_CATEGORIAS_OBTENER_POR_ID @IdCategoria = 1;

-- Prueba 2: Obtener una categoría inactiva (si existe)
DECLARE @IdInactiva INT = (SELECT TOP 1 CAT_Id FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Estado = 0);

IF @IdInactiva IS NOT NULL
BEGIN
    PRINT 'Obteniendo categoría inactiva con ID: ' + CAST(@IdInactiva AS NVARCHAR(10));
    EXEC ZI_GENERAL.SP_CATEGORIAS_OBTENER_POR_ID @IdCategoria = @IdInactiva;
END
ELSE
BEGIN
    PRINT 'No hay categorías inactivas en la base de datos';
END

-- Prueba 3: Verificar el tipo de dato del campo Activo
-- (Debe retornar 0 o 1, que C# convierte automáticamente a bool)
SELECT 
    CAT_Id,
    CAT_Nombre,
    CAT_Estado AS Activo,
    CASE 
        WHEN CAT_Estado = 1 THEN 'true (activo)'
        WHEN CAT_Estado = 0 THEN 'false (inactivo)'
        ELSE 'desconocido'
    END AS EstadoTexto
FROM ZI_GENERAL.ZI_CATEGORIAS
ORDER BY CAT_Id DESC;
*/
