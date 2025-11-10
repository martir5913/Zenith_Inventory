USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedure: SP_PERMISOS_REACTIVAR
-- Descripción: Reactiva un permiso previamente desactivado (borrado lógico)
-- Patrón: Similar a SP_PERMISOS_ELIMINAR pero invirtiendo el estado
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_PERMISOS_REACTIVAR]
    @IdPermiso INT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el permiso existe y está inactivo
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Id = @IdPermiso)
        BEGIN
            RAISERROR('El permiso no existe', 16, 1);
            RETURN;
        END
        
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Id = @IdPermiso AND PER_Activo = 1)
        BEGIN
            RAISERROR('El permiso ya está activo', 16, 1);
            RETURN;
        END
        
        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                PER_Id AS IdPermiso,
                PER_Nombre AS Nombre,
                PER_Descripcion AS Descripcion,
                PER_Modulo AS Modulo,
                PER_Accion AS Accion,
                PER_Activo AS Activo
            FROM ZI_GENERAL.ZI_PERMISOS
            WHERE PER_Id = @IdPermiso
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        
        -- Reactivar permiso (cambiar estado a activo)
        UPDATE ZI_GENERAL.ZI_PERMISOS
        SET 
            PER_Activo = 1,
            PER_FechaModificacion = GETDATE(),
            PER_UsuarioModificacion = @UsuarioModificacion,
            PER_IpModificacion = @IpModificacion
        WHERE PER_Id = @IdPermiso;
        
        SET @FilasAfectadas = @@ROWCOUNT;
        
        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                PER_Id AS IdPermiso,
                PER_Nombre AS Nombre,
                PER_Descripcion AS Descripcion,
                PER_Modulo AS Modulo,
                PER_Accion AS Accion,
                PER_Activo AS Activo
            FROM ZI_GENERAL.ZI_PERMISOS
            WHERE PER_Id = @IdPermiso
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        
        -- Obtener nombre del permiso para la bitácora
        DECLARE @NombrePermiso NVARCHAR(50);
        DECLARE @ModuloPermiso NVARCHAR(100);
        DECLARE @AccionPermiso NVARCHAR(100);
        
        SELECT 
            @NombrePermiso = PER_Nombre,
            @ModuloPermiso = PER_Modulo,
            @AccionPermiso = PER_Accion
        FROM ZI_GENERAL.ZI_PERMISOS 
        WHERE PER_Id = @IdPermiso;
        
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
            'PERMISOS',
            @IdPermiso,
            'Permiso reactivado: ' + @NombrePermiso + ' (' + @ModuloPermiso + ' - ' + @AccionPermiso + ', ID: ' + CAST(@IdPermiso AS NVARCHAR(10)) + ')',
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

EXEC ZI_GENERAL.SP_PERMISOS_REACTIVAR
    @IdPermiso = 10, -- ID del permiso a reactivar
    @UsuarioModificacion = 'admin',
    @IpModificacion = '127.0.0.1',
    @FilasAfectadas = @FilasAfectadas OUTPUT;

SELECT @FilasAfectadas AS FilasAfectadas;

-- Verificar que se reactivó
SELECT * FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Id = 10;

-- Verificar bitácora
SELECT TOP 1 * FROM ZI_GENERAL.ZI_BITACORAAUDITORIA 
WHERE BIT_Entidad = 'PERMISOS' AND BIT_Accion = 'REACTIVAR'
ORDER BY BIT_FechaHora DESC;
*/
