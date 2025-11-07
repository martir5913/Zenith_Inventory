USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedures para Marcas
-- Jerarquía: Categoría ? Subcategoría ? Marca ? Modelo
-- =============================================

-- =============================================
-- SP para crear una nueva marca
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_MARCAS_CREAR]
    @Nombre NVARCHAR(100),
    @SubcategoriaId INT,
    @Descripcion NVARCHAR(500) = NULL,
    @Activo BIT = 1,
    @UsuarioCreacion NVARCHAR(100),
    @IpCreacion NVARCHAR(45),
    @IdMarca INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la subcategoría existe y está activa
        DECLARE @NombreSubcategoria NVARCHAR(100);
        DECLARE @NombreCategoria NVARCHAR(100);
        
        SELECT 
            @NombreSubcategoria = SUB.SUB_Nombre,
            @NombreCategoria = CAT.CAT_Nombre
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE SUB.SUB_Id = @SubcategoriaId AND SUB.SUB_Estado = 1;

        IF @NombreSubcategoria IS NULL
        BEGIN
            RAISERROR('La subcategoría especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista una marca con el mismo nombre en la misma subcategoría
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MARCAS 
                   WHERE MAR_Nombre = @Nombre 
                   AND MAR_SubcategoriaId = @SubcategoriaId 
                   AND MAR_Estado = 1)
        BEGIN
            RAISERROR('Ya existe una marca con ese nombre en la subcategoría especificada', 16, 1);
            RETURN;
        END

        -- Generar nuevo ID usando la secuencia
        SELECT @IdMarca = NEXT VALUE FOR ZI_GENERAL.Seq_Marcas;

        -- Insertar nueva marca
        INSERT INTO ZI_GENERAL.ZI_MARCAS (
            MAR_Id,
            MAR_Nombre,
            MAR_SubcategoriaId,
            MAR_Descripcion,
            MAR_Estado,
            MAR_FechaCreacion,
            MAR_UsuarioCreacion,
            MAR_IpCreacion
        ) VALUES (
            @IdMarca,
            @Nombre,
            @SubcategoriaId,
            @Descripcion,
            @Activo,
            GETDATE(),
            @UsuarioCreacion,
            @IpCreacion
        );

        -- Registrar en bitácora con valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdMarca AS IdMarca,
                @Nombre AS Nombre,
                @SubcategoriaId AS IdSubcategoria,
                @NombreSubcategoria AS NombreSubcategoria,
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
            'MARCAS',
            @IdMarca,
            'Marca creada: ' + @Nombre + ' en subcategoría: ' + @NombreSubcategoria,
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
-- SP para actualizar una marca
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_MARCAS_ACTUALIZAR]
    @IdMarca INT,
    @Nombre NVARCHAR(100),
    @SubcategoriaId INT,
    @Descripcion NVARCHAR(500) = NULL,
    @Activo BIT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la marca existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MARCAS WHERE MAR_Id = @IdMarca)
        BEGIN
            RAISERROR('La marca no existe', 16, 1);
            RETURN;
        END

        -- Validar que la subcategoría existe y está activa
        DECLARE @NombreSubcategoria NVARCHAR(100);
        DECLARE @NombreCategoria NVARCHAR(100);
        
        SELECT 
            @NombreSubcategoria = SUB.SUB_Nombre,
            @NombreCategoria = CAT.CAT_Nombre
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE SUB.SUB_Id = @SubcategoriaId AND SUB.SUB_Estado = 1;

        IF @NombreSubcategoria IS NULL
        BEGIN
            RAISERROR('La subcategoría especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista otra marca con el mismo nombre en la misma subcategoría
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MARCAS
                   WHERE MAR_Nombre = @Nombre 
                   AND MAR_SubcategoriaId = @SubcategoriaId 
                   AND MAR_Id <> @IdMarca 
                   AND MAR_Estado = 1)
        BEGIN
            RAISERROR('Ya existe otra marca con ese nombre en la subcategoría especificada', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                MAR.MAR_Id AS IdMarca,
                MAR.MAR_Nombre AS Nombre,
                MAR.MAR_SubcategoriaId AS IdSubcategoria,
                SUB.SUB_Nombre AS NombreSubcategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                MAR.MAR_Descripcion AS Descripcion,
                MAR.MAR_Estado AS Activo
            FROM ZI_GENERAL.ZI_MARCAS MAR
            LEFT JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
            LEFT JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE MAR.MAR_Id = @IdMarca
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Actualizar marca
        UPDATE ZI_GENERAL.ZI_MARCAS SET
            MAR_Nombre = @Nombre,
            MAR_SubcategoriaId = @SubcategoriaId,
            MAR_Descripcion = @Descripcion,
            MAR_Estado = @Activo,
            MAR_FechaModificacion = GETDATE(),
            MAR_UsuarioModificacion = @UsuarioModificacion,
            MAR_IpModificacion = @IpModificacion
        WHERE MAR_Id = @IdMarca;

        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdMarca AS IdMarca,
                @Nombre AS Nombre,
                @SubcategoriaId AS IdSubcategoria,
                @NombreSubcategoria AS NombreSubcategoria,
                @NombreCategoria AS NombreCategoria,
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
            'MARCAS',
            @IdMarca,
            'Marca actualizada: ' + @Nombre + ' en subcategoría: ' + @NombreSubcategoria + ' (ID: ' + CAST(@IdMarca AS NVARCHAR(10)) + ')',
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
-- SP para eliminar una marca (eliminación lógica)
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_MARCAS_ELIMINAR]
    @IdMarca INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la marca existe
        DECLARE @NombreMarca NVARCHAR(100);
        DECLARE @NombreSubcategoria NVARCHAR(100);
        
        SELECT 
            @NombreMarca = MAR.MAR_Nombre,
            @NombreSubcategoria = SUB.SUB_Nombre
        FROM ZI_GENERAL.ZI_MARCAS MAR
        LEFT JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
        WHERE MAR.MAR_Id = @IdMarca;

        IF @NombreMarca IS NULL
        BEGIN
            RAISERROR('La marca no existe', 16, 1);
            RETURN;
        END

        -- Validar que no tenga modelos activos
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MODELOS
                   WHERE MOD_MarcaId = @IdMarca AND MOD_Estado = 1)
        BEGIN
            RAISERROR('No se puede eliminar una marca que tiene modelos activos', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                MAR.MAR_Id AS IdMarca,
                MAR.MAR_Nombre AS Nombre,
                MAR.MAR_SubcategoriaId AS IdSubcategoria,
                SUB.SUB_Nombre AS NombreSubcategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                MAR.MAR_Descripcion AS Descripcion,
                MAR.MAR_Estado AS Activo
            FROM ZI_GENERAL.ZI_MARCAS MAR
            LEFT JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
            LEFT JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE MAR.MAR_Id = @IdMarca
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Marcar como inactiva
        UPDATE ZI_GENERAL.ZI_MARCAS SET
            MAR_Estado = 0,
            MAR_FechaModificacion = GETDATE(),
            MAR_UsuarioModificacion = @UsuarioEliminacion,
            MAR_IpModificacion = @IpEliminacion
        WHERE MAR_Id = @IdMarca;

        -- Capturar valores nuevos
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                MAR.MAR_Id AS IdMarca,
                MAR.MAR_Nombre AS Nombre,
                MAR.MAR_SubcategoriaId AS IdSubcategoria,
                SUB.SUB_Nombre AS NombreSubcategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                MAR.MAR_Descripcion AS Descripcion,
                0 AS Activo
            FROM ZI_GENERAL.ZI_MARCAS MAR
            LEFT JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
            LEFT JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE MAR.MAR_Id = @IdMarca
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
            'MARCAS',
            @IdMarca,
            'Marca eliminada: ' + @NombreMarca + ISNULL(' de subcategoría: ' + @NombreSubcategoria, '') + ' (ID: ' + CAST(@IdMarca AS NVARCHAR(10)) + ')',
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
-- SP para listar marcas paginadas
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_MARCAS_LISTAR_PAGINADO]
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @IdSubcategoria INT = NULL,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        -- Obtener total de registros
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_MARCAS MAR
        LEFT JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
        LEFT JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE (@IncluirInactivos = 1 OR MAR.MAR_Estado = 1)
        AND (@SearchTerm IS NULL OR MAR.MAR_Nombre LIKE '%' + @SearchTerm + '%' 
             OR SUB.SUB_Nombre LIKE '%' + @SearchTerm + '%'
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%')
        AND (@IdSubcategoria IS NULL OR MAR.MAR_SubcategoriaId = @IdSubcategoria);

        -- Obtener registros paginados
        SELECT
            MAR.MAR_Id AS IdMarca,
            MAR.MAR_Nombre AS Nombre,
            MAR.MAR_Descripcion AS Descripcion,
            MAR.MAR_Estado AS Activo,
            MAR.MAR_SubcategoriaId AS IdSubcategoria,
            SUB.SUB_Nombre AS NombreSubcategoria,
            SUB.SUB_CategoriaId AS IdCategoria,
            CAT.CAT_Nombre AS NombreCategoria,
            MAR.MAR_FechaCreacion AS FechaCreacion,
            MAR.MAR_UsuarioCreacion AS UsuarioCreacion,
            MAR.MAR_FechaModificacion AS FechaModificacion,
            MAR.MAR_UsuarioModificacion AS UsuarioModificacion,
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_MODELOS
             WHERE MOD_MarcaId = MAR.MAR_Id AND MOD_Estado = 1) AS TotalModelos
        FROM ZI_GENERAL.ZI_MARCAS MAR
        LEFT JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
        LEFT JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE (@IncluirInactivos = 1 OR MAR.MAR_Estado = 1)
        AND (@SearchTerm IS NULL OR MAR.MAR_Nombre LIKE '%' + @SearchTerm + '%' 
             OR SUB.SUB_Nombre LIKE '%' + @SearchTerm + '%'
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%')
        AND (@IdSubcategoria IS NULL OR MAR.MAR_SubcategoriaId = @IdSubcategoria)
        ORDER BY MAR.MAR_Nombre
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
-- SP para obtener una marca por ID
-- =============================================
CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_MARCAS_OBTENER_POR_ID]
    @IdMarca INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            MAR.MAR_Id AS IdMarca,
            MAR.MAR_Nombre AS Nombre,
            MAR.MAR_Descripcion AS Descripcion,
            MAR.MAR_Estado AS Activo,
            MAR.MAR_SubcategoriaId AS IdSubcategoria,
            SUB.SUB_Nombre AS NombreSubcategoria,
            SUB.SUB_CategoriaId AS IdCategoria,
            CAT.CAT_Nombre AS NombreCategoria,
            MAR.MAR_FechaCreacion AS FechaCreacion,
            MAR.MAR_UsuarioCreacion AS UsuarioCreacion,
            MAR.MAR_FechaModificacion AS FechaModificacion,
            MAR.MAR_UsuarioModificacion AS UsuarioModificacion,
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_MODELOS
             WHERE MOD_MarcaId = MAR.MAR_Id AND MOD_Estado = 1) AS TotalModelos
        FROM ZI_GENERAL.ZI_MARCAS MAR
        LEFT JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
        LEFT JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE MAR.MAR_Id = @IdMarca AND MAR.MAR_Estado = 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'Stored Procedures para Marcas creados exitosamente';
PRINT 'Nueva jerarquía implementada: Categoría ? Subcategoría ? Marca ? Modelo';
GO
