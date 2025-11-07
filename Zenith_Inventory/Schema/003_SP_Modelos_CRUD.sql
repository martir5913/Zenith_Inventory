USE [DB_Zenith_Inventory]
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_ACTUALIZAR]    Script Date: 5/11/2025 20:19:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para actualizar un modelo
-- =============================================
ALTER   PROCEDURE [ZI_GENERAL].[SP_MODELOS_ACTUALIZAR]
    @IdModelo INT,
    @Nombre NVARCHAR(100),
    @MarcaId INT,
    @Descripcion NVARCHAR(500) = NULL,
    @Activo BIT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el modelo existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MODELOS WHERE MOD_Id = @IdModelo)
        BEGIN
            RAISERROR('El modelo no existe', 16, 1);
            RETURN;
        END

        -- Validar que la marca existe y está activa, y obtener jerarquía completa
        DECLARE @NombreMarca NVARCHAR(100);
        DECLARE @NombreSubcategoria NVARCHAR(100);
        DECLARE @NombreCategoria NVARCHAR(100);
        DECLARE @SubcategoriaId INT;
        
        SELECT 
            @NombreMarca = MAR.MAR_Nombre,
            @SubcategoriaId = MAR.MAR_SubcategoriaId,
            @NombreSubcategoria = SUB.SUB_Nombre,
            @NombreCategoria = CAT.CAT_Nombre
        FROM ZI_GENERAL.ZI_MARCAS MAR
        INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE MAR.MAR_Id = @MarcaId AND MAR.MAR_Estado = 1;

        IF @NombreMarca IS NULL
        BEGIN
            RAISERROR('La marca especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista otro modelo con el mismo nombre en la misma marca
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MODELOS
                   WHERE MOD_Nombre = @Nombre 
                   AND MOD_MarcaId = @MarcaId 
                   AND MOD_Id <> @IdModelo 
                   AND MOD_Estado = 1)
        BEGIN
            RAISERROR('Ya existe otro modelo con ese nombre en la marca especificada', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores en formato JSON (con jerarquía completa)
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                MOD.MOD_Id AS IdModelo,
                MOD.MOD_Nombre AS Nombre,
                MOD.MOD_MarcaId AS IdMarca,
                MAR.MAR_Nombre AS NombreMarca,
                MAR.MAR_SubcategoriaId AS IdSubcategoria,
                SUB.SUB_Nombre AS NombreSubcategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                MOD.MOD_Descripcion AS Descripcion,
                MOD.MOD_Estado AS Activo
            FROM ZI_GENERAL.ZI_MODELOS MOD
            INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
            INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
            INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE MOD.MOD_Id = @IdModelo
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Actualizar modelo
        UPDATE ZI_GENERAL.ZI_MODELOS SET
            MOD_Nombre = @Nombre,
            MOD_MarcaId = @MarcaId,
            MOD_Descripcion = @Descripcion,
            MOD_Estado = @Activo,
            MOD_FechaModificacion = GETDATE(),
            MOD_UsuarioModificacion = @UsuarioModificacion,
            MOD_IpModificacion = @IpModificacion
        WHERE MOD_Id = @IdModelo;

        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdModelo AS IdModelo,
                @Nombre AS Nombre,
                @MarcaId AS IdMarca,
                @NombreMarca AS NombreMarca,
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
            'MODELOS',
            @IdModelo,
            'Modelo actualizado: ' + @Nombre + ' de marca: ' + @NombreMarca + ' (ID: ' + CAST(@IdModelo AS NVARCHAR(10)) + ')',
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
USE [DB_Zenith_Inventory]
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_CREAR]    Script Date: 5/11/2025 20:20:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Stored Procedures para Modelos
-- Jerarquía: Categoría → Subcategoría → Marca → Modelo
-- (Sin redundancia de MOD_SubcategoriaId)
-- =============================================

-- =============================================
-- SP para crear un nuevo modelo
-- =============================================
ALTER   PROCEDURE [ZI_GENERAL].[SP_MODELOS_CREAR]
    @Nombre NVARCHAR(100),
    @MarcaId INT,
    @Descripcion NVARCHAR(500) = NULL,
    @Activo BIT = 1,
    @UsuarioCreacion NVARCHAR(100),
    @IpCreacion NVARCHAR(45),
    @IdModelo INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la marca existe y está activa, y obtener jerarquía completa
        DECLARE @NombreMarca NVARCHAR(100);
        DECLARE @NombreSubcategoria NVARCHAR(100);
        DECLARE @NombreCategoria NVARCHAR(100);
        DECLARE @SubcategoriaId INT;
        
        SELECT 
            @NombreMarca = MAR.MAR_Nombre,
            @SubcategoriaId = MAR.MAR_SubcategoriaId,
            @NombreSubcategoria = SUB.SUB_Nombre,
            @NombreCategoria = CAT.CAT_Nombre
        FROM ZI_GENERAL.ZI_MARCAS MAR
        INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE MAR.MAR_Id = @MarcaId AND MAR.MAR_Estado = 1;

        IF @NombreMarca IS NULL
        BEGIN
            RAISERROR('La marca especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista un modelo con el mismo nombre en la misma marca
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MODELOS 
                   WHERE MOD_Nombre = @Nombre 
                   AND MOD_MarcaId = @MarcaId 
                   AND MOD_Estado = 1)
        BEGIN
            RAISERROR('Ya existe un modelo con ese nombre en la marca especificada', 16, 1);
            RETURN;
        END

        -- Generar nuevo ID usando la secuencia
        SELECT @IdModelo = NEXT VALUE FOR ZI_GENERAL.Seq_Modelos;

        -- Insertar nuevo modelo
        INSERT INTO ZI_GENERAL.ZI_MODELOS (
            MOD_Id,
            MOD_Nombre,
            MOD_MarcaId,
            MOD_Descripcion,
            MOD_Estado,
            MOD_FechaCreacion,
            MOD_UsuarioCreacion,
            MOD_IpCreacion
        ) VALUES (
            @IdModelo,
            @Nombre,
            @MarcaId,
            @Descripcion,
            @Activo,
            GETDATE(),
            @UsuarioCreacion,
            @IpCreacion
        );

        -- Registrar en bitácora con valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdModelo AS IdModelo,
                @Nombre AS Nombre,
                @MarcaId AS IdMarca,
                @NombreMarca AS NombreMarca,
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
            'MODELOS',
            @IdModelo,
            'Modelo creado: ' + @Nombre + ' de marca: ' + @NombreMarca,
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
USE [DB_Zenith_Inventory]
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_ELIMINAR]    Script Date: 5/11/2025 20:20:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para eliminar un modelo (eliminación lógica)
-- =============================================
ALTER   PROCEDURE [ZI_GENERAL].[SP_MODELOS_ELIMINAR]
    @IdModelo INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el modelo existe y obtener información
        DECLARE @NombreModelo NVARCHAR(100);
        DECLARE @NombreMarca NVARCHAR(100);
        
        SELECT 
            @NombreModelo = MOD.MOD_Nombre,
            @NombreMarca = MAR.MAR_Nombre
        FROM ZI_GENERAL.ZI_MODELOS MOD
        INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
        WHERE MOD.MOD_Id = @IdModelo;

        IF @NombreModelo IS NULL
        BEGIN
            RAISERROR('El modelo no existe', 16, 1);
            RETURN;
        END

        -- Validar que no tenga equipos activos
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_EQUIPOS
                   WHERE EQU_ModeloId = @IdModelo AND EQU_Estado = 1)
        BEGIN
            RAISERROR('No se puede eliminar un modelo que tiene equipos activos', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                MOD.MOD_Id AS IdModelo,
                MOD.MOD_Nombre AS Nombre,
                MOD.MOD_MarcaId AS IdMarca,
                MAR.MAR_Nombre AS NombreMarca,
                MAR.MAR_SubcategoriaId AS IdSubcategoria,
                SUB.SUB_Nombre AS NombreSubcategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                MOD.MOD_Descripcion AS Descripcion,
                MOD.MOD_Estado AS Activo
            FROM ZI_GENERAL.ZI_MODELOS MOD
            INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
            INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
            INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE MOD.MOD_Id = @IdModelo
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Marcar como inactivo
        UPDATE ZI_GENERAL.ZI_MODELOS SET
            MOD_Estado = 0,
            MOD_FechaModificacion = GETDATE(),
            MOD_UsuarioModificacion = @UsuarioEliminacion,
            MOD_IpModificacion = @IpEliminacion
        WHERE MOD_Id = @IdModelo;

        -- Capturar valores nuevos
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                MOD.MOD_Id AS IdModelo,
                MOD.MOD_Nombre AS Nombre,
                MOD.MOD_MarcaId AS IdMarca,
                MAR.MAR_Nombre AS NombreMarca,
                MAR.MAR_SubcategoriaId AS IdSubcategoria,
                SUB.SUB_Nombre AS NombreSubcategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                MOD.MOD_Descripcion AS Descripcion,
                0 AS Activo
            FROM ZI_GENERAL.ZI_MODELOS MOD
            INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
            INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
            INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE MOD.MOD_Id = @IdModelo
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
            'MODELOS',
            @IdModelo,
            'Modelo eliminado: ' + @NombreModelo + ' de marca: ' + @NombreMarca + ' (ID: ' + CAST(@IdModelo AS NVARCHAR(10)) + ')',
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
USE [DB_Zenith_Inventory]
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_LISTAR_PAGINADO]    Script Date: 5/11/2025 20:20:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para listar modelos paginados
-- =============================================
ALTER   PROCEDURE [ZI_GENERAL].[SP_MODELOS_LISTAR_PAGINADO]
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @IdMarca INT = NULL,
    @IdSubcategoria INT = NULL,
    @IdCategoria INT = NULL,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        -- Obtener total de registros
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_MODELOS MOD
        INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
        INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE (@IncluirInactivos = 1 OR MOD.MOD_Estado = 1)
        AND (@SearchTerm IS NULL OR MOD.MOD_Nombre LIKE '%' + @SearchTerm + '%' 
             OR MAR.MAR_Nombre LIKE '%' + @SearchTerm + '%'
             OR SUB.SUB_Nombre LIKE '%' + @SearchTerm + '%'
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%')
        AND (@IdMarca IS NULL OR MOD.MOD_MarcaId = @IdMarca)
        AND (@IdSubcategoria IS NULL OR MAR.MAR_SubcategoriaId = @IdSubcategoria)
        AND (@IdCategoria IS NULL OR SUB.SUB_CategoriaId = @IdCategoria);

        -- Obtener registros paginados con jerarquía completa
        SELECT
            MOD.MOD_Id AS IdModelo,
            MOD.MOD_Nombre AS Nombre,
            MOD.MOD_Descripcion AS Descripcion,
            MOD.MOD_Estado AS Activo,
            MOD.MOD_MarcaId AS IdMarca,
            MAR.MAR_Nombre AS NombreMarca,
            MAR.MAR_SubcategoriaId AS IdSubcategoria,
            SUB.SUB_Nombre AS NombreSubcategoria,
            SUB.SUB_CategoriaId AS IdCategoria,
            CAT.CAT_Nombre AS NombreCategoria,
            MOD.MOD_FechaCreacion AS FechaCreacion,
            MOD.MOD_UsuarioCreacion AS UsuarioCreacion,
            MOD.MOD_FechaModificacion AS FechaModificacion,
            MOD.MOD_UsuarioModificacion AS UsuarioModificacion,
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_EQUIPOS
             WHERE EQU_ModeloId = MOD.MOD_Id AND EQU_Estado = 1) AS TotalEquipos
        FROM ZI_GENERAL.ZI_MODELOS MOD
        INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
        INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE (@IncluirInactivos = 1 OR MOD.MOD_Estado = 1)
        AND (@SearchTerm IS NULL OR MOD.MOD_Nombre LIKE '%' + @SearchTerm + '%' 
             OR MAR.MAR_Nombre LIKE '%' + @SearchTerm + '%'
             OR SUB.SUB_Nombre LIKE '%' + @SearchTerm + '%'
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%')
        AND (@IdMarca IS NULL OR MOD.MOD_MarcaId = @IdMarca)
        AND (@IdSubcategoria IS NULL OR MAR.MAR_SubcategoriaId = @IdSubcategoria)
        AND (@IdCategoria IS NULL OR SUB.SUB_CategoriaId = @IdCategoria)
        ORDER BY MOD.MOD_Nombre
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
USE [DB_Zenith_Inventory]
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_OBTENER_POR_ID]    Script Date: 5/11/2025 20:20:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para obtener un modelo por ID
-- =============================================
ALTER   PROCEDURE [ZI_GENERAL].[SP_MODELOS_OBTENER_POR_ID]
    @IdModelo INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            MOD.MOD_Id AS IdModelo,
            MOD.MOD_Nombre AS Nombre,
            MOD.MOD_Descripcion AS Descripcion,
            MOD.MOD_Estado AS Activo,
            MOD.MOD_MarcaId AS IdMarca,
            MAR.MAR_Nombre AS NombreMarca,
            MAR.MAR_SubcategoriaId AS IdSubcategoria,
            SUB.SUB_Nombre AS NombreSubcategoria,
            SUB.SUB_CategoriaId AS IdCategoria,
            CAT.CAT_Nombre AS NombreCategoria,
            MOD.MOD_FechaCreacion AS FechaCreacion,
            MOD.MOD_UsuarioCreacion AS UsuarioCreacion,
            MOD.MOD_FechaModificacion AS FechaModificacion,
            MOD.MOD_UsuarioModificacion AS UsuarioModificacion,
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_EQUIPOS
             WHERE EQU_ModeloId = MOD.MOD_Id AND EQU_Estado = 1) AS TotalEquipos
        FROM ZI_GENERAL.ZI_MODELOS MOD
        INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
        INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MAR.MAR_SubcategoriaId = SUB.SUB_Id
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE MOD.MOD_Id = @IdModelo AND MOD.MOD_Estado = 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
