USE [DB_Zenith_Inventory]
GO

-- =============================================
-- SP para listar subcategorías paginadas
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_LISTAR_PAGINADO]
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

        -- Obtener total de registros
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE (@IncluirInactivos = 1 OR SUB.SUB_Estado = 1)
        AND (@SearchTerm IS NULL OR SUB.SUB_Nombre LIKE '%' + @SearchTerm + '%' 
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%');

        -- Obtener registros paginados
        SELECT
            SUB.SUB_Id AS IdSubcategoria,
            SUB.SUB_Nombre AS Nombre,
            SUB.SUB_Descripcion AS Descripcion,
            SUB.SUB_Estado AS Activo,
            SUB.SUB_CategoriaId AS IdCategoria,
            CAT.CAT_Nombre AS NombreCategoria,
            -- Información adicional útil
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_MODELOS
             WHERE MOD_SubcategoriaId = SUB.SUB_Id AND MOD_Estado = 1) AS TotalModelos
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE (@IncluirInactivos = 1 OR SUB.SUB_Estado = 1)
        AND (@SearchTerm IS NULL OR SUB.SUB_Nombre LIKE '%' + @SearchTerm + '%' 
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%')
        ORDER BY SUB.SUB_Nombre
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para obtener una subcategoría por ID
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_OBTENER_POR_ID]
    @IdSubcategoria INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            SUB.SUB_Id AS IdSubcategoria,
            SUB.SUB_Nombre AS Nombre,
            SUB.SUB_Descripcion AS Descripcion,
            SUB.SUB_Estado AS Activo,
            SUB.SUB_CategoriaId AS IdCategoria,
            CAT.CAT_Nombre AS NombreCategoria,
            -- Información adicional útil
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_MODELOS
             WHERE MOD_SubcategoriaId = SUB.SUB_Id AND MOD_Estado = 1) AS TotalModelos
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE SUB.SUB_Id = @IdSubcategoria AND SUB.SUB_Estado = 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para crear una nueva subcategoría
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_CREAR]
    @Nombre NVARCHAR(100),
    @CategoriaId INT,
    @Descripcion NVARCHAR(500) = NULL,
    @Activo BIT = 1,
    @UsuarioCreacion NVARCHAR(100),
    @IpCreacion NVARCHAR(45),
    @IdSubcategoria INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la categoría existe y está activa
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Id = @CategoriaId AND CAT_Estado = 1)
        BEGIN
            RAISERROR('La categoría especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista una subcategoría con el mismo nombre en la misma categoría
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_SUBCATEGORIAS WHERE SUB_Nombre = @Nombre AND SUB_CategoriaId = @CategoriaId AND SUB_Estado = 1)
        BEGIN
            RAISERROR('Ya existe una subcategoría con ese nombre en la categoría especificada', 16, 1);
            RETURN;
        END

        -- Generar nuevo ID usando la secuencia
        SELECT @IdSubcategoria = NEXT VALUE FOR ZI_GENERAL.Seq_Subcategorias;

        -- Insertar nueva subcategoría
        INSERT INTO ZI_GENERAL.ZI_SUBCATEGORIAS (
            SUB_Id,
            SUB_Nombre,
            SUB_CategoriaId,
            SUB_Descripcion,
            SUB_Estado
        ) VALUES (
            @IdSubcategoria,
            @Nombre,
            @CategoriaId,
            @Descripcion,
            @Activo
        );

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
            'SUBCATEGORIAS',
            @IdSubcategoria,
            'Subcategoría creada: ' + @Nombre,
            GETDATE()
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para actualizar una subcategoría
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_ACTUALIZAR]
    @IdSubcategoria INT,
    @Nombre NVARCHAR(100),
    @CategoriaId INT,
    @Descripcion NVARCHAR(500) = NULL,
    @Activo BIT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45)
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
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Id = @CategoriaId AND CAT_Estado = 1)
        BEGIN
            RAISERROR('La categoría especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista otra subcategoría con el mismo nombre en la misma categoría
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_SUBCATEGORIAS
                   WHERE SUB_Nombre = @Nombre AND SUB_CategoriaId = @CategoriaId AND SUB_Id <> @IdSubcategoria AND SUB_Estado = 1)
        BEGIN
            RAISERROR('Ya existe otra subcategoría con ese nombre en la categoría especificada', 16, 1);
            RETURN;
        END

        -- Actualizar subcategoría
        UPDATE ZI_GENERAL.ZI_SUBCATEGORIAS SET
            SUB_Nombre = @Nombre,
            SUB_CategoriaId = @CategoriaId,
            SUB_Descripcion = @Descripcion,
            SUB_Estado = @Activo
        WHERE SUB_Id = @IdSubcategoria;

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
            'SUBCATEGORIAS',
            @IdSubcategoria,
            'Subcategoría actualizada: ' + @Nombre + ' (ID: ' + CAST(@IdSubcategoria AS NVARCHAR(10)) + ')',
            GETDATE()
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para eliminar una subcategoría
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_ELIMINAR]
    @IdSubcategoria INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la subcategoría existe
        DECLARE @NombreSubcategoria NVARCHAR(100);
        SELECT @NombreSubcategoria = SUB_Nombre
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS
        WHERE SUB_Id = @IdSubcategoria;

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

        -- Marcar como inactiva (eliminación lógica)
        UPDATE ZI_GENERAL.ZI_SUBCATEGORIAS SET
            SUB_Estado = 0
        WHERE SUB_Id = @IdSubcategoria;

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
            'SUBCATEGORIAS',
            @IdSubcategoria,
            'Subcategoría eliminada: ' + @NombreSubcategoria + ' (ID: ' + CAST(@IdSubcategoria AS NVARCHAR(10)) + ')',
            GETDATE()
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO