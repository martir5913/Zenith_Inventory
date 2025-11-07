USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Agregar columnas de auditoría a ZI_CATEGORIAS si no existen
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_CATEGORIAS') AND name = 'CAT_FechaCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_CATEGORIAS ADD CAT_FechaCreacion DATETIME DEFAULT GETDATE() NOT NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_CATEGORIAS') AND name = 'CAT_UsuarioCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_CATEGORIAS ADD CAT_UsuarioCreacion NVARCHAR(100) NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_CATEGORIAS') AND name = 'CAT_FechaModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_CATEGORIAS ADD CAT_FechaModificacion DATETIME NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_CATEGORIAS') AND name = 'CAT_UsuarioModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_CATEGORIAS ADD CAT_UsuarioModificacion NVARCHAR(100) NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_CATEGORIAS') AND name = 'CAT_IpCreacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_CATEGORIAS ADD CAT_IpCreacion NVARCHAR(45) NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_CATEGORIAS') AND name = 'CAT_IpModificacion')
BEGIN
    ALTER TABLE ZI_GENERAL.ZI_CATEGORIAS ADD CAT_IpModificacion NVARCHAR(45) NULL;
END
GO

-- =============================================
-- SP para crear una nueva categoría
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_CREAR]
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
        BEGIN TRANSACTION;

        -- Validar que no exista una categoría con el mismo nombre
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_CATEGORIAS WHERE CAT_Nombre = @Nombre AND CAT_Estado = 1)
        BEGIN
            RAISERROR('Ya existe una categoría con ese nombre', 16, 1);
            RETURN;
        END

        -- Generar nuevo ID usando la secuencia
        SELECT @IdCategoria = NEXT VALUE FOR ZI_GENERAL.Seq_Categorias;

        -- Insertar nueva categoría
        INSERT INTO ZI_GENERAL.ZI_CATEGORIAS (
            CAT_Id,
            CAT_Nombre,
            CAT_Descripcion,
            CAT_Estado,
            CAT_FechaCreacion,
            CAT_UsuarioCreacion,
            CAT_IpCreacion
        ) VALUES (
            @IdCategoria,
            @Nombre,
            @Descripcion,
            @Activo,
            GETDATE(),
            @UsuarioCreacion,
            @IpCreacion
        );

        -- Registrar en bitácora con valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdCategoria AS IdCategoria,
                @Nombre AS Nombre,
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
            'CATEGORIAS',
            @IdCategoria,
            'Categoría creada: ' + @Nombre,
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
-- SP para actualizar una categoría
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_ACTUALIZAR]
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

        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdCategoria AS IdCategoria,
                @Nombre AS Nombre,
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
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para eliminar una categoría (eliminación lógica)
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_ELIMINAR]
    @IdCategoria INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45)
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

        -- Marcar como inactiva (eliminación lógica)
        UPDATE ZI_GENERAL.ZI_CATEGORIAS SET
            CAT_Estado = 0,
            CAT_FechaModificacion = GETDATE(),
            CAT_UsuarioModificacion = @UsuarioEliminacion,
            CAT_IpModificacion = @IpEliminacion
        WHERE CAT_Id = @IdCategoria;

        -- Capturar valores nuevos en formato JSON
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
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para listar categorías con paginación
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_LISTAR_PAGINADO]
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
        
        -- Obtener total de registros (para calcular páginas totales)
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_CATEGORIAS
        WHERE 
            (@IncluirInactivos = 1 OR CAT_Estado = 1)
            AND (@SearchTerm IS NULL OR 
                 CAT_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 CAT_Descripcion LIKE '%' + @SearchTerm + '%');
        
        -- Obtener registros paginados con información de auditoría
        SELECT 
            CAT_Id AS IdCategoria,
            CAT_Nombre AS Nombre,
            CAT_Descripcion AS Descripcion,
            CAT_Estado AS Activo,
            CAT_FechaCreacion AS FechaCreacion,
            CAT_UsuarioCreacion AS UsuarioCreacion,
            CAT_FechaModificacion AS FechaModificacion,
            CAT_UsuarioModificacion AS UsuarioModificacion,
            -- Información adicional útil
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_SUBCATEGORIAS 
             WHERE SUB_CategoriaId = CAT_Id AND SUB_Estado = 1) AS TotalSubcategorias
        FROM ZI_GENERAL.ZI_CATEGORIAS
        WHERE 
            (@IncluirInactivos = 1 OR CAT_Estado = 1)
            AND (@SearchTerm IS NULL OR 
                 CAT_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 CAT_Descripcion LIKE '%' + @SearchTerm + '%')
        ORDER BY CAT_Nombre ASC
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
-- SP para obtener categoría por ID
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_OBTENER_POR_ID]
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
            CAT_FechaCreacion AS FechaCreacion,
            CAT_UsuarioCreacion AS UsuarioCreacion,
            CAT_FechaModificacion AS FechaModificacion,
            CAT_UsuarioModificacion AS UsuarioModificacion,
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
