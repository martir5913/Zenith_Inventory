USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Agregar columnas de auditoría a ZI_SUBCATEGORIAS si no existen
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS') AND name = 'SUB_FechaCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_SUBCATEGORIAS ADD SUB_FechaCreacion DATETIME DEFAULT GETDATE() NOT NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS') AND name = 'SUB_UsuarioCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_SUBCATEGORIAS ADD SUB_UsuarioCreacion NVARCHAR(100) NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS') AND name = 'SUB_FechaModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_SUBCATEGORIAS ADD SUB_FechaModificacion DATETIME NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS') AND name = 'SUB_UsuarioModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_SUBCATEGORIAS ADD SUB_UsuarioModificacion NVARCHAR(100) NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS') AND name = 'SUB_IpCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_SUBCATEGORIAS ADD SUB_IpCreacion NVARCHAR(45) NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS') AND name = 'SUB_IpModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_SUBCATEGORIAS ADD SUB_IpModificacion NVARCHAR(45) NULL;
END
GO

-- =============================================
-- SP para crear una nueva subcategoría
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_CREAR]
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
        DECLARE @NombreCategoria NVARCHAR(100);
        SELECT @NombreCategoria = CAT_Nombre
        FROM ZI_GENERAL.ZI_CATEGORIAS 
        WHERE CAT_Id = @CategoriaId AND CAT_Estado = 1;

        IF @NombreCategoria IS NULL
        BEGIN
            RAISERROR('La categoría especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista una subcategoría con el mismo nombre en la misma categoría
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_SUBCATEGORIAS 
                   WHERE SUB_Nombre = @Nombre AND SUB_CategoriaId = @CategoriaId AND SUB_Estado = 1)
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
            SUB_Estado,
            SUB_FechaCreacion,
            SUB_UsuarioCreacion,
            SUB_IpCreacion
        ) VALUES (
            @IdSubcategoria,
            @Nombre,
            @CategoriaId,
            @Descripcion,
            @Activo,
            GETDATE(),
            @UsuarioCreacion,
            @IpCreacion
        );

        -- Registrar en bitácora con valores nuevos en formato JSON
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
            'CREAR',
            'SUBCATEGORIAS',
            @IdSubcategoria,
            'Subcategoría creada: ' + @Nombre + ' en categoría: ' + @NombreCategoria,
            NULL,
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
-- SP para actualizar una subcategoría
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_ACTUALIZAR]
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
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para eliminar una subcategoría (eliminación lógica)
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_ELIMINAR]
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
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para listar subcategorías paginadas
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_LISTAR_PAGINADO]
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @IdCategoria INT = NULL,
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
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%')
        AND (@IdCategoria IS NULL OR SUB.SUB_CategoriaId = @IdCategoria);

        -- Obtener registros paginados con información de auditoría
        SELECT
            SUB.SUB_Id AS IdSubcategoria,
            SUB.SUB_Nombre AS Nombre,
            SUB.SUB_Descripcion AS Descripcion,
            SUB.SUB_Estado AS Activo,
            SUB.SUB_CategoriaId AS IdCategoria,
            CAT.CAT_Nombre AS NombreCategoria,
            SUB.SUB_FechaCreacion AS FechaCreacion,
            SUB.SUB_UsuarioCreacion AS UsuarioCreacion,
            SUB.SUB_FechaModificacion AS FechaModificacion,
            SUB.SUB_UsuarioModificacion AS UsuarioModificacion,
            -- Información adicional útil
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_MODELOS
             WHERE MOD_SubcategoriaId = SUB.SUB_Id AND MOD_Estado = 1) AS TotalModelos
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE (@IncluirInactivos = 1 OR SUB.SUB_Estado = 1)
        AND (@SearchTerm IS NULL OR SUB.SUB_Nombre LIKE '%' + @SearchTerm + '%' 
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%')
        AND (@IdCategoria IS NULL OR SUB.SUB_CategoriaId = @IdCategoria)
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
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_OBTENER_POR_ID]
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
            SUB.SUB_FechaCreacion AS FechaCreacion,
            SUB.SUB_UsuarioCreacion AS UsuarioCreacion,
            SUB.SUB_FechaModificacion AS FechaModificacion,
            SUB.SUB_UsuarioModificacion AS UsuarioModificacion,
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
