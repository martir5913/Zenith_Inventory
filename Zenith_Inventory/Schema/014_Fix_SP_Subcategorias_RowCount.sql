USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Corrección: Agregar parámetro OUTPUT @FilasAfectadas para Subcategorías
-- =============================================

-- SP ACTUALIZAR con OUTPUT
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_ACTUALIZAR]
    @IdSubcategoria INT,
    @Nombre NVARCHAR(100),
    @CategoriaId INT,
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

        -- Validar que la subcategoría existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_SUBCATEGORIAS WHERE SUB_Id = @IdSubcategoria)
        BEGIN
            RAISERROR('La subcategoría no existe', 16, 1);
            RETURN;
        END

        -- Validar que la categoría existe y está activa
        DECLARE @NombreCategoria NVARCHAR(100);
        SELECT @NombreCategoria = CAT_Nombre
        FROM ZI_GENERAL.ZI_CATEGORIAS 
        WHERE CAT_Id = @CategoriaId AND CAT_Estado = 1;

        IF @NombreCategoria IS NULL
        BEGIN
            RAISERROR('La categoría especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista otra subcategoría con el mismo nombre en la misma categoría
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_SUBCATEGORIAS
                   WHERE SUB_Nombre = @Nombre 
                   AND SUB_CategoriaId = @CategoriaId 
                   AND SUB_Id <> @IdSubcategoria 
                   AND SUB_Estado = 1)
        BEGIN
            RAISERROR('Ya existe otra subcategoría con ese nombre en la categoría especificada', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                SUB.SUB_Id AS IdSubcategoria,
                SUB.SUB_Nombre AS Nombre,
                SUB.SUB_CategoriaId AS IdCategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                SUB.SUB_Descripcion AS Descripcion,
                SUB.SUB_Estado AS Activo
            FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
            INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE SUB.SUB_Id = @IdSubcategoria
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Actualizar subcategoría
        UPDATE ZI_GENERAL.ZI_SUBCATEGORIAS SET
            SUB_Nombre = @Nombre,
            SUB_CategoriaId = @CategoriaId,
            SUB_Descripcion = @Descripcion,
            SUB_Estado = @Activo,
            SUB_FechaModificacion = GETDATE(),
            SUB_UsuarioModificacion = @UsuarioModificacion,
            SUB_IpModificacion = @IpModificacion
        WHERE SUB_Id = @IdSubcategoria;

        -- Capturar número de filas afectadas
        SET @FilasAfectadas = @@ROWCOUNT;

        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdSubcategoria AS IdSubcategoria,
                @Nombre AS Nombre,
                @CategoriaId AS IdCategoria,
                @NombreCategoria AS NombreCategoria,
                @Descripcion AS Descripcion,
                @Activo AS Activo
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Registrar en bitácora con valores anteriores y nuevos
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
            'SUBCATEGORIAS',
            @IdSubcategoria,
            'Subcategoría actualizada: ' + @Nombre + ' en categoría: ' + @NombreCategoria + ' (ID: ' + CAST(@IdSubcategoria AS NVARCHAR(10)) + ')',
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
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_ELIMINAR]
    @IdSubcategoria INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la subcategoría existe
        DECLARE @NombreSubcategoria NVARCHAR(100);
        DECLARE @NombreCategoria NVARCHAR(100);
        
        SELECT 
            @NombreSubcategoria = SUB.SUB_Nombre,
            @NombreCategoria = CAT.CAT_Nombre
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE SUB.SUB_Id = @IdSubcategoria;

        IF @NombreSubcategoria IS NULL
        BEGIN
            RAISERROR('La subcategoría no existe', 16, 1);
            RETURN;
        END

        -- Validar que no tenga modelos activos
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MODELOS
                   WHERE MOD_SubcategoriaId = @IdSubcategoria AND MOD_Estado = 1)
        BEGIN
            RAISERROR('No se puede eliminar una subcategoría que tiene modelos activos', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                SUB.SUB_Id AS IdSubcategoria,
                SUB.SUB_Nombre AS Nombre,
                SUB.SUB_CategoriaId AS IdCategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                SUB.SUB_Descripcion AS Descripcion,
                SUB.SUB_Estado AS Activo
            FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
            INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE SUB.SUB_Id = @IdSubcategoria
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Marcar como inactiva (eliminación lógica)
        UPDATE ZI_GENERAL.ZI_SUBCATEGORIAS SET
            SUB_Estado = 0,
            SUB_FechaModificacion = GETDATE(),
            SUB_UsuarioModificacion = @UsuarioEliminacion,
            SUB_IpModificacion = @IpEliminacion
        WHERE SUB_Id = @IdSubcategoria;

        -- Capturar número de filas afectadas
        SET @FilasAfectadas = @@ROWCOUNT;

        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                SUB.SUB_Id AS IdSubcategoria,
                SUB.SUB_Nombre AS Nombre,
                SUB.SUB_CategoriaId AS IdCategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                SUB.SUB_Descripcion AS Descripcion,
                0 AS Activo
            FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
            INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE SUB.SUB_Id = @IdSubcategoria
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
            'SUBCATEGORIAS',
            @IdSubcategoria,
            'Subcategoría eliminada: ' + @NombreSubcategoria + ' de categoría: ' + @NombreCategoria + ' (ID: ' + CAST(@IdSubcategoria AS NVARCHAR(10)) + ')',
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

PRINT '? SPs de Subcategorías actualizados con parámetro @FilasAfectadas OUTPUT';
GO
