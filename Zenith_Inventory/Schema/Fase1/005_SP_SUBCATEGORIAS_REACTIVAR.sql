USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedure: SP_SUBCATEGORIAS_REACTIVAR
-- Descripción: Reactiva una subcategoría previamente desactivada (borrado lógico)
-- Patrón: Similar a SP_SUBCATEGORIAS_ELIMINAR pero invirtiendo el estado
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_REACTIVAR]
    @IdSubcategoria INT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la subcategoría existe y está inactiva
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_SUBCATEGORIAS WHERE SUB_Id = @IdSubcategoria)
        BEGIN
            RAISERROR('La subcategoría no existe', 16, 1);
            RETURN;
        END
        
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_SUBCATEGORIAS WHERE SUB_Id = @IdSubcategoria AND SUB_Estado = 1)
        BEGIN
            RAISERROR('La subcategoría ya está activa', 16, 1);
            RETURN;
        END
        
        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                SUB_Id AS IdSubcategoria,
                SUB_Nombre AS Nombre,
                SUB_CategoriaId AS IdCategoria,
                SUB_Descripcion AS Descripcion,
                SUB_Estado AS Estado
            FROM ZI_GENERAL.ZI_SUBCATEGORIAS
            WHERE SUB_Id = @IdSubcategoria
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        
        -- Reactivar subcategoría (cambiar estado a activo)
        UPDATE ZI_GENERAL.ZI_SUBCATEGORIAS
        SET 
            SUB_Estado = 1,
            SUB_FechaModificacion = GETDATE(),
            SUB_UsuarioModificacion = @UsuarioModificacion,
            SUB_IpModificacion = @IpModificacion
        WHERE SUB_Id = @IdSubcategoria;
        
        SET @FilasAfectadas = @@ROWCOUNT;
        
        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                SUB_Id AS IdSubcategoria,
                SUB_Nombre AS Nombre,
                SUB_CategoriaId AS IdCategoria,
                SUB_Descripcion AS Descripcion,
                SUB_Estado AS Estado
            FROM ZI_GENERAL.ZI_SUBCATEGORIAS
            WHERE SUB_Id = @IdSubcategoria
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        
        -- Obtener nombre de la subcategoría para la bitácora
        DECLARE @NombreSubcategoria NVARCHAR(100);
        DECLARE @NombreCategoria NVARCHAR(100);
        
        SELECT 
            @NombreSubcategoria = s.SUB_Nombre,
            @NombreCategoria = c.CAT_Nombre
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS s
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS c ON s.SUB_CategoriaId = c.CAT_Id
        WHERE s.SUB_Id = @IdSubcategoria;
        
        -- Registrar en bitácora de auditoría
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (
            BIT_AgenteId,
            BIT_Accion,
            BIT_Entidad,
            BIT_EntidadId,
            BIT_Detalles,
            BIT_ValoresAntiguos,
            BIT_ValoresNuevos,
            BIT_FechaHora
        ) VALUES (
            NULL, -- AgenteId (puede ser NULL si no hay agente asociado)
            'REACTIVAR',
            'SUBCATEGORIAS',
            @IdSubcategoria,
            'Subcategoría reactivada: ' + @NombreSubcategoria + ' [' + @NombreCategoria + '] (ID: ' + CAST(@IdSubcategoria AS NVARCHAR(10)) + ')',
            @ValoresAntiguos,
            @ValoresNuevos,
            GETDATE()
        );
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- PRUEBA DEL STORED PROCEDURE
-- =============================================
/*
-- Ejemplo de uso:

DECLARE @FilasAfectadas INT;

EXEC ZI_GENERAL.SP_SUBCATEGORIAS_REACTIVAR
    @IdSubcategoria = 10, -- ID de la subcategoría a reactivar
    @UsuarioModificacion = 'admin',
    @IpModificacion = '127.0.0.1',
    @FilasAfectadas = @FilasAfectadas OUTPUT;

SELECT @FilasAfectadas AS FilasAfectadas;

-- Verificar que se reactivó
SELECT * FROM ZI_GENERAL.ZI_SUBCATEGORIAS WHERE SUB_Id = 10;

-- Verificar bitácora
SELECT TOP 1 * FROM ZI_GENERAL.ZI_BITACORAAUDITORIA 
WHERE BIT_Entidad = 'SUBCATEGORIAS' AND BIT_Accion = 'REACTIVAR'
ORDER BY BIT_FechaHora DESC;
*/
