USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Corrección: Agregar parámetro OUTPUT para filas afectadas
-- =============================================

-- SP ACTUALIZAR con OUTPUT
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_ACTUALIZAR]
    @IdCategoria INT,
    @Nombre NVARCHAR(100),
    @Descripcion NVARCHAR(500) = NULL,
    @Activo BIT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la categoría existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Id = @IdCategoria)
        BEGIN
            RAISERROR('La categoría no existe', 16, 1);
            RETURN;
        END

        -- Validar que no exista otra categoría con el mismo nombre
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_CATEGORIAS
                   WHERE CAT_Nombre = @Nombre AND CAT_Id <> @IdCategoria AND CAT_Estado = 1)
        BEGIN
            RAISERROR('Ya existe otra categoría con ese nombre', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                CAT_Id AS IdCategoria,
                CAT_Nombre AS Nombre,
                CAT_Descripcion AS Descripcion,
                CAT_Estado AS Activo
            FROM ZI_GENERAL.ZI_CATEGORIAS
            WHERE CAT_Id = @IdCategoria
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Actualizar categoría
        UPDATE ZI_GENERAL.ZI_CATEGORIAS SET
            CAT_Nombre = @Nombre,
            CAT_Descripcion = @Descripcion,
            CAT_Estado = @Activo,
            CAT_FechaModificacion = GETDATE(),
            CAT_UsuarioModificacion = @UsuarioModificacion,
            CAT_IpModificacion = @IpModificacion
        WHERE CAT_Id = @IdCategoria;

        -- Capturar número de filas afectadas
        SET @FilasAfectadas = @@ROWCOUNT;

        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdCategoria AS IdCategoria,
                @Nombre AS Nombre,
                @Descripcion AS Descripcion,
                @Activo AS Activo
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Registrar en bitácora
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
            NULL,
            'ACTUALIZAR',
            'CATEGORIAS',
            @IdCategoria,
            'Categoría actualizada: ' + @Nombre + ' (ID: ' + CAST(@IdCategoria AS NVARCHAR(10)) + ')',
            @ValoresAntiguos,
            @ValoresNuevos,
            GETDATE()
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @FilasAfectadas = 0;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- SP ELIMINAR con OUTPUT
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_ELIMINAR]
    @IdCategoria INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la categoría existe
        DECLARE @NombreCategoria NVARCHAR(100);
        SELECT @NombreCategoria = CAT_Nombre
        FROM ZI_GENERAL.ZI_CATEGORIAS
        WHERE CAT_Id = @IdCategoria;

        IF @NombreCategoria IS NULL
        BEGIN
            RAISERROR('La categoría no existe', 16, 1);
            RETURN;
        END

        -- Validar que no tenga subcategorías activas
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_SUBCATEGORIAS
                   WHERE SUB_CategoriaId = @IdCategoria AND SUB_Estado = 1)
        BEGIN
            RAISERROR('No se puede eliminar una categoría que tiene subcategorías activas', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                CAT_Id AS IdCategoria,
                CAT_Nombre AS Nombre,
                CAT_Descripcion AS Descripcion,
                CAT_Estado AS Activo
            FROM ZI_GENERAL.ZI_CATEGORIAS
            WHERE CAT_Id = @IdCategoria
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Marcar como inactiva
        UPDATE ZI_GENERAL.ZI_CATEGORIAS SET
            CAT_Estado = 0,
            CAT_FechaModificacion = GETDATE(),
            CAT_UsuarioModificacion = @UsuarioEliminacion,
            CAT_IpModificacion = @IpEliminacion
        WHERE CAT_Id = @IdCategoria;

        -- Capturar número de filas afectadas
        SET @FilasAfectadas = @@ROWCOUNT;

        -- Capturar valores nuevos
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdCategoria AS IdCategoria,
                @NombreCategoria AS Nombre,
                (SELECT CAT_Descripcion FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Id = @IdCategoria) AS Descripcion,
                0 AS Activo
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Registrar en bitácora
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
            NULL,
            'ELIMINAR',
            'CATEGORIAS',
            @IdCategoria,
            'Categoría eliminada: ' + @NombreCategoria + ' (ID: ' + CAST(@IdCategoria AS NVARCHAR(10)) + ')',
            @ValoresAntiguos,
            @ValoresNuevos,
            GETDATE()
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @FilasAfectadas = 0;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '? SPs de Categorías actualizados con parámetro @FilasAfectadas OUTPUT';
GO
