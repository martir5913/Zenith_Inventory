USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedure: SP_CATEGORIAS_REACTIVAR
-- Descripción: Reactiva una categoría previamente desactivada (borrado lógico)
-- Patrón: Similar a SP_CATEGORIAS_ELIMINAR pero invirtiendo el estado
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_REACTIVAR]
    @IdCategoria INT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la categoría existe y está inactiva
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Id = @IdCategoria)
        BEGIN
            RAISERROR('La categoría no existe', 16, 1);
            RETURN;
        END
        
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Id = @IdCategoria AND CAT_Estado = 1)
        BEGIN
            RAISERROR('La categoría ya está activa', 16, 1);
            RETURN;
        END
        
        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                CAT_Id AS IdCategoria,
                CAT_Nombre AS Nombre,
                CAT_Descripcion AS Descripcion,
                CAT_Estado AS Estado
            FROM ZI_GENERAL.ZI_CATEGORIAS
            WHERE CAT_Id = @IdCategoria
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        
        -- Reactivar categoría (cambiar estado a activo)
        UPDATE ZI_GENERAL.ZI_CATEGORIAS
        SET 
            CAT_Estado = 1,
            CAT_FechaModificacion = GETDATE(),
            CAT_UsuarioModificacion = @UsuarioModificacion,
            CAT_IpModificacion = @IpModificacion
        WHERE CAT_Id = @IdCategoria;
        
        SET @FilasAfectadas = @@ROWCOUNT;
        
        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                CAT_Id AS IdCategoria,
                CAT_Nombre AS Nombre,
                CAT_Descripcion AS Descripcion,
                CAT_Estado AS Estado
            FROM ZI_GENERAL.ZI_CATEGORIAS
            WHERE CAT_Id = @IdCategoria
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        
        -- Obtener nombre de la categoría para la bitácora
        DECLARE @NombreCategoria NVARCHAR(100);
        SELECT @NombreCategoria = CAT_Nombre FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Id = @IdCategoria;
        
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
            'CATEGORIAS',
            @IdCategoria,
            'Categoría reactivada: ' + @NombreCategoria + ' (ID: ' + CAST(@IdCategoria AS NVARCHAR(10)) + ')',
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

EXEC ZI_GENERAL.SP_CATEGORIAS_REACTIVAR
    @IdCategoria = 5, -- ID de la categoría a reactivar
    @UsuarioModificacion = 'admin',
    @IpModificacion = '127.0.0.1',
    @FilasAfectadas = @FilasAfectadas OUTPUT;

SELECT @FilasAfectadas AS FilasAfectadas;

-- Verificar que se reactivó
SELECT * FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Id = 5;

-- Verificar bitácora
SELECT TOP 1 * FROM ZI_GENERAL.ZI_BITACORAAUDITORIA 
WHERE BIT_Entidad = 'CATEGORIAS' AND BIT_Accion = 'REACTIVAR'
ORDER BY BIT_FechaHora DESC;
*/
