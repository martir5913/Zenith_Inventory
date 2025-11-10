USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedure: SP_ROLES_REACTIVAR
-- Descripción: Reactiva un rol previamente desactivado (borrado lógico)
-- Patrón: Similar a SP_ROLES_ELIMINAR pero invirtiendo el estado
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_ROLES_REACTIVAR]
    @IdRol INT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el rol existe y está inactivo
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_ROLES WHERE ROL_Id = @IdRol)
        BEGIN
            RAISERROR('El rol no existe', 16, 1);
            RETURN;
        END
        
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_ROLES WHERE ROL_Id = @IdRol AND ROL_Activo = 1)
        BEGIN
            RAISERROR('El rol ya está activo', 16, 1);
            RETURN;
        END
        
        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                ROL_Id AS IdRol,
                ROL_Nombre AS Nombre,
                ROL_Descripcion AS Descripcion,
                ROL_Activo AS Activo
            FROM ZI_GENERAL.ZI_ROLES
            WHERE ROL_Id = @IdRol
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        
        -- Reactivar rol (cambiar estado a activo)
        UPDATE ZI_GENERAL.ZI_ROLES
        SET 
            ROL_Activo = 1,
            ROL_FechaModificacion = GETDATE(),
            ROL_UsuarioModificacion = @UsuarioModificacion,
            ROL_IpModificacion = @IpModificacion
        WHERE ROL_Id = @IdRol;
        
        SET @FilasAfectadas = @@ROWCOUNT;
        
        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                ROL_Id AS IdRol,
                ROL_Nombre AS Nombre,
                ROL_Descripcion AS Descripcion,
                ROL_Activo AS Activo
            FROM ZI_GENERAL.ZI_ROLES
            WHERE ROL_Id = @IdRol
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        
        -- Obtener nombre del rol para la bitácora
        DECLARE @NombreRol NVARCHAR(50);
        SELECT @NombreRol = ROL_Nombre FROM ZI_GENERAL.ZI_ROLES WHERE ROL_Id = @IdRol;
        
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
            'ROLES',
            @IdRol,
            'Rol reactivado: ' + @NombreRol + ' (ID: ' + CAST(@IdRol AS NVARCHAR(10)) + ')',
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

EXEC ZI_GENERAL.SP_ROLES_REACTIVAR
    @IdRol = 5, -- ID del rol a reactivar
    @UsuarioModificacion = 'admin',
    @IpModificacion = '127.0.0.1',
    @FilasAfectadas = @FilasAfectadas OUTPUT;

SELECT @FilasAfectadas AS FilasAfectadas;

-- Verificar que se reactivó
SELECT * FROM ZI_GENERAL.ZI_ROLES WHERE ROL_Id = 5;

-- Verificar bitácora
SELECT TOP 1 * FROM ZI_GENERAL.ZI_BITACORAAUDITORIA 
WHERE BIT_Entidad = 'ROLES' AND BIT_Accion = 'REACTIVAR'
ORDER BY BIT_FechaHora DESC;
*/
