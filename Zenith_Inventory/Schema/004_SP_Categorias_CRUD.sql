USE [DB_Zenith_Inventory]
GO

-- =============================================
-- SP para obtener una categoría por ID
-- =============================================
create PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_OBTENER_POR_ID]
    @IdCategoria INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
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
        WHERE CAT_Id = @IdCategoria AND CAT_Estado = 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para crear una nueva categoría
-- =============================================
create PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_CREAR]
    @Nombre NVARCHAR(100),
    @Descripcion NVARCHAR(500) = NULL,
    @Activo BIT = 1,
    @UsuarioCreacion NVARCHAR(100),
    @IpCreacion NVARCHAR(45),
    @IdCategoria INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar que no exista una categoría con el mismo nombre
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Nombre = @Nombre AND CAT_Estado = 1)
        BEGIN
            RAISERROR('Ya existe una categoría con ese nombre', 16, 1);
            RETURN;
        END

        -- Insertar nueva categoría
        INSERT INTO ZI_GENERAL.ZI_CATEGORIAS (
            CAT_Nombre,
            CAT_Descripcion,
            CAT_Estado,
            CAT_FechaCreacion,
            CAT_UsuarioCreacion,
            CAT_IpCreacion
        ) VALUES (
            @Nombre,
            @Descripcion,
            @Activo,
            GETDATE(),
            @UsuarioCreacion,
            @IpCreacion
        );

        -- Obtener el ID generado
        SET @IdCategoria = SCOPE_IDENTITY();

        -- Registrar en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (
            BIT_AgenteId,
            BIT_Accion,
            BIT_Entidad,
            BIT_EntidadId,
            BIT_Detalles,
            BIT_FechaHora
        ) VALUES (
            NULL,
            'CREAR',
            'CATEGORIAS',
            @IdCategoria,
            'Categoría creada: ' + @Nombre,
            GETDATE()
        );

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para actualizar una categoría
-- =============================================
create PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_ACTUALIZAR]
    @IdCategoria INT,
    @Nombre NVARCHAR(100),
    @Descripcion NVARCHAR(500) = NULL,
    @Activo BIT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
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

        -- Actualizar categoría
        UPDATE ZI_GENERAL.ZI_CATEGORIAS SET
            CAT_Nombre = @Nombre,
            CAT_Descripcion = @Descripcion,
            CAT_Estado = @Activo,
            CAT_FechaModificacion = GETDATE(),
            CAT_UsuarioModificacion = @UsuarioModificacion,
            CAT_IpModificacion = @IpModificacion
        WHERE CAT_Id = @IdCategoria;

        -- Registrar en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (
            BIT_AgenteId,
            BIT_Accion,
            BIT_Entidad,
            BIT_EntidadId,
            BIT_Detalles,
            BIT_FechaHora
        ) VALUES (
            NULL,
            'ACTUALIZAR',
            'CATEGORIAS',
            @IdCategoria,
            'Categoría actualizada: ' + @Nombre + ' (ID: ' + CAST(@IdCategoria AS NVARCHAR(10)) + ')',
            GETDATE()
        );

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para eliminar una categoría
-- =============================================
create PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_ELIMINAR]
    @IdCategoria INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
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

        -- Marcar como inactiva (eliminación lógica)
        UPDATE ZI_GENERAL.ZI_CATEGORIAS SET
            CAT_Estado = 0,
            CAT_FechaModificacion = GETDATE(),
            CAT_UsuarioModificacion = @UsuarioEliminacion,
            CAT_IpModificacion = @IpEliminacion
        WHERE CAT_Id = @IdCategoria;

        -- Registrar en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (
            BIT_AgenteId,
            BIT_Accion,
            BIT_Entidad,
            BIT_EntidadId,
            BIT_Detalles,
            BIT_FechaHora
        ) VALUES (
            NULL,
            'ELIMINAR',
            'CATEGORIAS',
            @IdCategoria,
            'Categoría eliminada: ' + @NombreCategoria + ' (ID: ' + CAST(@IdCategoria AS NVARCHAR(10)) + ')',
            GETDATE()
        );

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
