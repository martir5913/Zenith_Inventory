USE [DB_Zenith_Inventory]
GO

/****** Object:  StoredProcedure [ZI_GENERAL].[SP_CATEGORIAS_ACTUALIZAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Corrección: Agregar parámetro OUTPUT para filas afectadas
-- =============================================

-- SP ACTUALIZAR con OUTPUT
CREATE   PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_ACTUALIZAR]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_CATEGORIAS_CREAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para crear una nueva categoría
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_CREAR]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_CATEGORIAS_ELIMINAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SP ELIMINAR con OUTPUT
CREATE   PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_ELIMINAR]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_CATEGORIAS_LISTAR_PAGINADO]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para listar categorías con paginación
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_LISTAR_PAGINADO]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_CATEGORIAS_OBTENER_POR_ID]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para obtener categoría por ID
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_CATEGORIAS_OBTENER_POR_ID]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_CHANGE_PASSWORD]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimiento para cambiar contraseña
CREATE PROCEDURE [ZI_GENERAL].[SP_CHANGE_PASSWORD]
    @UserId INT,
    @NewEncryptedPassword NVARCHAR(500),
    @ModifiedBy NVARCHAR(100),
    @IpAddress NVARCHAR(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Result NVARCHAR(50) = 'ERROR';
    DECLARE @Message NVARCHAR(500) = '';
    DECLARE @Username NVARCHAR(100);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verificar si el usuario existe
        SELECT @Username = USU_Username 
        FROM ZI_GENERAL.ZI_USUARIOS 
        WHERE USU_Id = @UserId AND USU_Activo = 1;
        
        IF @Username IS NULL
        BEGIN
            SET @Message = 'Usuario no encontrado o inactivo';
            ROLLBACK TRANSACTION;
            SELECT @Result as Resultado, @Message as Mensaje;
            RETURN;
        END
        
        -- Actualizar contraseña
        UPDATE ZI_GENERAL.ZI_USUARIOS 
        SET USU_PasswordEncrypted = @NewEncryptedPassword,
            USU_FechaModificacion = GETDATE(),
            USU_UsuarioModificacion = @ModifiedBy,
            USU_IpModificacion = @IpAddress,
            USU_IntentosFallidos = 0,
            USU_Bloqueado = 0,
            USU_FechaBloqueo = NULL,
            USU_PassTemp = 0
        WHERE USU_Id = @UserId;
        
        -- Registrar en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (@UserId, 'CAMBIAR_PASSWORD', 'USUARIOS', @UserId, 'Contraseña cambiada para usuario: ' + @Username, GETDATE());
        
        SET @Result = 'EXITO';
        SET @Message = 'Contraseña actualizada exitosamente';
        
        COMMIT TRANSACTION;
        SELECT @Result as Resultado, @Message as Mensaje;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Message = 'Error al cambiar contraseña: ' + ERROR_MESSAGE();
        
        -- Registrar error en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (@UserId, 'CAMBIAR_PASSWORD', 'USUARIOS', ISNULL(@UserId, 0), 'Error al cambiar contraseña: ' + ISNULL(@Username, 'ID:' + CAST(@UserId AS NVARCHAR(10))), GETDATE());
        
        SELECT @Result as Resultado, @Message as Mensaje;
    END CATCH
END

GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_CREATE_USER]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimiento para crear usuario
CREATE PROCEDURE [ZI_GENERAL].[SP_CREATE_USER]
    @Username NVARCHAR(100),
    @EncryptedPassword NVARCHAR(500),
    @Nombre NVARCHAR(150),
    @Apellido NVARCHAR(150),
    @Email NVARCHAR(255),
    @Telefono NVARCHAR(20) = NULL,
    @CreatedBy NVARCHAR(100),
    @IpAddress NVARCHAR(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserId INT;
    DECLARE @Result NVARCHAR(50) = 'ERROR';
    DECLARE @Message NVARCHAR(500) = '';
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verificar si el username ya existe
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Username = @Username)
        BEGIN
            SET @Message = 'El nombre de usuario ya existe';
            ROLLBACK TRANSACTION;
            SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
            RETURN;
        END
        
        -- Verificar si el email ya existe
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Correo = @Email)
        BEGIN
            SET @Message = 'El email ya está registrado';
            ROLLBACK TRANSACTION;
            SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
            RETURN;
        END
        
        -- Insertar usuario
        INSERT INTO ZI_GENERAL.ZI_USUARIOS (
            USU_Username, USU_PasswordEncrypted, USU_Nombre, USU_Apellido, 
            USU_Correo, USU_Telefono, USU_UsuarioCreacion, USU_IpCreacion,
            USU_PassTemp
        ) VALUES (
            @Username, @EncryptedPassword, @Nombre, @Apellido, 
            @Email, @Telefono, @CreatedBy, @IpAddress,
            1
        );
        
        SET @UserId = SCOPE_IDENTITY();
        
        -- Registrar en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (@UserId, 'CREAR', 'USUARIOS', @UserId, 'Usuario creado: ' + @Username, GETDATE());
        
        SET @Result = 'EXITO';
        SET @Message = 'Usuario creado exitosamente';
        
        COMMIT TRANSACTION;
        SELECT @Result as Resultado, @Message as Mensaje, @UserId as UserId;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Message = 'Error al crear usuario: ' + ERROR_MESSAGE();
        
        -- Registrar error en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (NULL, 'CREAR', 'USUARIOS', 0, 'Error al crear usuario: ' + @Username, GETDATE());
        
        SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
    END CATCH
END

GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_GET_ENCRYPTION_CONFIG]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimiento para obtener configuración de encriptación
CREATE PROCEDURE [ZI_GENERAL].[SP_GET_ENCRYPTION_CONFIG]
AS
BEGIN
    SELECT ZIC_Clave, ZIC_Valor
    FROM ZI_GENERAL.ZI_CONFIGURACION
    WHERE ZIC_Clave IN ('ENCRYPT_KEY', 'ENCRYPT_SALT', 'ENCRYPT_IV')
    AND ZIC_Activo = 1
END

GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_GET_USER_INFO]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Crear procedimiento corregido
CREATE PROCEDURE [ZI_GENERAL].[SP_GET_USER_INFO]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
 
    BEGIN TRY
-- Información del usuario
        SELECT 
     USU_Id,
     USU_Codigo,
   USU_Username,
         USU_PasswordEncrypted,
  USU_Nombre,
            USU_Apellido,
        USU_Correo,
            USU_Telefono,
   USU_Departamento,
          USU_Puesto,
     USU_Activo,
      USU_UltimoLogin,
USU_IntentosFallidos,
       USU_Bloqueado,
            USU_FechaBloqueo,
   USU_PassTemp,
 USU_Estado,
     USU_FechaCreacion,
        USU_UsuarioCreacion,
         USU_FechaModificacion,
            USU_UsuarioModificacion,
 USU_IpCreacion,
            USU_IpModificacion
        FROM ZI_GENERAL.ZI_USUARIOS 
        WHERE USU_Id = @UserId AND USU_Activo = 1;
        
        -- Roles del usuario
      SELECT 
      r.ROL_Id,
        r.ROL_Nombre,
       r.ROL_Descripcion,
            r.ROL_Activo
     FROM ZI_GENERAL.ZI_ROLES r
        INNER JOIN ZI_GENERAL.ZI_USUARIOSROLES ur ON r.ROL_Id = ur.UR_RolId
        WHERE ur.UR_UsrId = @UserId 
 AND r.ROL_Activo = 1 
        AND ur.UR_Activo = 1;
        
        -- Permisos del usuario (corregido)
        SELECT DISTINCT
          p.PER_Id,
          p.PER_Nombre,
            p.PER_Descripcion,
    p.PER_Modulo,
            p.PER_Accion,
            p.PER_Activo
    FROM ZI_GENERAL.ZI_PERMISOS p
  INNER JOIN ZI_GENERAL.ZI_PERMISOSROLES pr ON p.PER_Id = pr.PRO_PermisoId
        INNER JOIN ZI_GENERAL.ZI_USUARIOSROLES ur ON pr.PRO_RolId = ur.UR_RolId
WHERE ur.UR_UsrId = @UserId 
        AND p.PER_Activo = 1
        AND ur.UR_Activo = 1;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_Ingresos_Create]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimientos almacenados con transacciones para cumplimiento de ACID
CREATE PROCEDURE [ZI_GENERAL].[SP_Ingresos_Create]
(
    @Usuario NVARCHAR(25),
    @Host NVARCHAR(25),
    @Dominio NVARCHAR(25),
    @BodegaId INT,
    @Fecha NVARCHAR(25),
    @Hora NVARCHAR(25),
    @Descripcion NVARCHAR(500),
    @Estado BIT,
    @TipoIngreso NVARCHAR(128),
    @TipoMovimiento INT,
    @DetalleEquipo ZI_GENERAL.T_DETALLE_EQUIPO READONLY,
    @Resultado BIT OUTPUT,
    @Mensaje NVARCHAR(500) OUTPUT
)
AS 
BEGIN
    BEGIN TRY
        DECLARE @IdMovimiento INT
        DECLARE @InsertedIds TABLE (Id INT)
        SET @Resultado = 1
        SET @Mensaje = ''

        BEGIN TRANSACTION REGISTRO

        INSERT INTO ZI_GENERAL.ZI_INGRESOS (ING_Usuario, ING_Host, ING_Dominio, ING_BodegaId, ING_Fecha, ING_Hora, ING_Descripcion, ING_Estado, ING_TipoIngreso)
        OUTPUT INSERTED.ING_Id INTO @InsertedIds
        VALUES (@Usuario, @Host, @Dominio, @BodegaId, @Fecha, @Hora, @Descripcion, @Estado, @TipoIngreso)

        SELECT @IdMovimiento = Id FROM @InsertedIds

        INSERT INTO ZI_GENERAL.ZI_EQUIPOS (EQU_Serie, EQU_ModeloId, EQU_ContratoId, EQU_BodegaId, EQU_EstadoEquipo, EQU_Descripcion, EQU_Estado)
        SELECT DET_Serie, DET_ModeloId, DET_ContratoId, DET_BodegaId, DET_EstadoEquipo, DET_Descripcion, DET_Estado FROM @DetalleEquipo

        INSERT INTO ZI_GENERAL.ZI_KARDEXEQUIPO (KAR_MovId, KAR_Serie, KAR_TipoMov, KAR_BodegaId, KAR_Estado)
        SELECT @IdMovimiento, DET_Serie, @TipoMovimiento, DET_BodegaId, @Estado FROM @DetalleEquipo

        COMMIT TRANSACTION REGISTRO
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
        SET @Mensaje = ERROR_MESSAGE()
        ROLLBACK TRANSACTION REGISTRO
    END CATCH
END
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MARCAS_ACTUALIZAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para actualizar una marca
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MARCAS_ACTUALIZAR]
    @IdMarca INT,
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

        -- Validar que la marca existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MARCAS WHERE MAR_Id = @IdMarca)
        BEGIN
            RAISERROR('La marca no existe', 16, 1);
            RETURN;
        END

        -- Validar que no exista otra marca con el mismo nombre
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MARCAS
                   WHERE MAR_Nombre = @Nombre 
                   AND MAR_Id <> @IdMarca 
                   AND MAR_Estado = 1)
        BEGIN
            RAISERROR('Ya existe otra marca con ese nombre', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                MAR_Id AS IdMarca,
                MAR_Nombre AS Nombre,
                MAR_Descripcion AS Descripcion,
                MAR_Estado AS Activo
            FROM ZI_GENERAL.ZI_MARCAS
            WHERE MAR_Id = @IdMarca
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Actualizar marca
        UPDATE ZI_GENERAL.ZI_MARCAS SET
            MAR_Nombre = @Nombre,
            MAR_Descripcion = @Descripcion,
            MAR_Estado = @Activo,
            MAR_FechaModificacion = GETDATE(),
            MAR_UsuarioModificacion = @UsuarioModificacion,
            MAR_IpModificacion = @IpModificacion
        WHERE MAR_Id = @IdMarca;

        -- Capturar valores nuevos
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdMarca AS IdMarca,
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
            'MARCAS',
            @IdMarca,
            'Marca actualizada: ' + @Nombre + ' (ID: ' + CAST(@IdMarca AS NVARCHAR(10)) + ')',
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MARCAS_CREAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Stored Procedures FINALES para Marcas
-- Marca INDEPENDIENTE (sin relación a Subcategoría)
-- =============================================

-- =============================================
-- SP para crear una nueva marca (INDEPENDIENTE)
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MARCAS_CREAR]
    @Nombre NVARCHAR(100),
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

        -- Validar que no exista una marca con el mismo nombre
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MARCAS 
                   WHERE MAR_Nombre = @Nombre 
                   AND MAR_Estado = 1)
        BEGIN
            RAISERROR('Ya existe una marca con ese nombre', 16, 1);
            RETURN;
        END

        -- Generar nuevo ID usando la secuencia
        SELECT @IdMarca = NEXT VALUE FOR ZI_GENERAL.Seq_Marcas;

        -- Insertar nueva marca
        INSERT INTO ZI_GENERAL.ZI_MARCAS (
            MAR_Id,
            MAR_Nombre,
            MAR_Descripcion,
            MAR_Estado,
            MAR_FechaCreacion,
            MAR_UsuarioCreacion,
            MAR_IpCreacion
        ) VALUES (
            @IdMarca,
            @Nombre,
            @Descripcion,
            @Activo,
            GETDATE(),
            @UsuarioCreacion,
            @IpCreacion
        );

        -- Registrar en bitácora
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdMarca AS IdMarca,
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
            'MARCAS',
            @IdMarca,
            'Marca creada: ' + @Nombre,
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MARCAS_ELIMINAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para eliminar una marca (eliminación lógica)
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MARCAS_ELIMINAR]
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
        SELECT @NombreMarca = MAR_Nombre
        FROM ZI_GENERAL.ZI_MARCAS
        WHERE MAR_Id = @IdMarca;

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

        -- Capturar valores anteriores
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                MAR_Id AS IdMarca,
                MAR_Nombre AS Nombre,
                MAR_Descripcion AS Descripcion,
                MAR_Estado AS Activo
            FROM ZI_GENERAL.ZI_MARCAS
            WHERE MAR_Id = @IdMarca
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
                MAR_Id AS IdMarca,
                MAR_Nombre AS Nombre,
                MAR_Descripcion AS Descripcion,
                0 AS Activo
            FROM ZI_GENERAL.ZI_MARCAS
            WHERE MAR_Id = @IdMarca
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
            'Marca eliminada: ' + @NombreMarca + ' (ID: ' + CAST(@IdMarca AS NVARCHAR(10)) + ')',
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MARCAS_LISTAR_PAGINADO]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para listar marcas paginadas
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MARCAS_LISTAR_PAGINADO]
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        -- Obtener total de registros
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_MARCAS
        WHERE (@IncluirInactivos = 1 OR MAR_Estado = 1)
        AND (@SearchTerm IS NULL OR MAR_Nombre LIKE '%' + @SearchTerm + '%');

        -- Obtener registros paginados
        SELECT
            MAR_Id AS IdMarca,
            MAR_Nombre AS Nombre,
            MAR_Descripcion AS Descripcion,
            MAR_Estado AS Activo,
            MAR_FechaCreacion AS FechaCreacion,
            MAR_UsuarioCreacion AS UsuarioCreacion,
            MAR_FechaModificacion AS FechaModificacion,
            MAR_UsuarioModificacion AS UsuarioModificacion,
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_MODELOS
             WHERE MOD_MarcaId = MAR_Id AND MOD_Estado = 1) AS TotalModelos
        FROM ZI_GENERAL.ZI_MARCAS
        WHERE (@IncluirInactivos = 1 OR MAR_Estado = 1)
        AND (@SearchTerm IS NULL OR MAR_Nombre LIKE '%' + @SearchTerm + '%')
        ORDER BY MAR_Nombre
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MARCAS_OBTENER_POR_ID]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para obtener una marca por ID
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MARCAS_OBTENER_POR_ID]
    @IdMarca INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            MAR_Id AS IdMarca,
            MAR_Nombre AS Nombre,
            MAR_Descripcion AS Descripcion,
            MAR_Estado AS Activo,
            MAR_FechaCreacion AS FechaCreacion,
            MAR_UsuarioCreacion AS UsuarioCreacion,
            MAR_FechaModificacion AS FechaModificacion,
            MAR_UsuarioModificacion AS UsuarioModificacion,
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_MODELOS
             WHERE MOD_MarcaId = MAR_Id AND MOD_Estado = 1) AS TotalModelos
        FROM ZI_GENERAL.ZI_MARCAS
        WHERE MAR_Id = @IdMarca AND MAR_Estado = 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_ACTUALIZAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para actualizar un modelo
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MODELOS_ACTUALIZAR]
    @IdModelo INT,
    @Nombre NVARCHAR(100),
    @MarcaId INT,
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

        -- Validar que el modelo existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MODELOS WHERE MOD_Id = @IdModelo)
        BEGIN
            RAISERROR('El modelo no existe', 16, 1);
            RETURN;
        END

        -- Validar que la marca existe y está activa
        DECLARE @NombreMarca NVARCHAR(100);
        SELECT @NombreMarca = MAR_Nombre
        FROM ZI_GENERAL.ZI_MARCAS 
        WHERE MAR_Id = @MarcaId AND MAR_Estado = 1;

        IF @NombreMarca IS NULL
        BEGIN
            RAISERROR('La marca especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que la subcategoría existe y está activa, y obtener jerarquía
        DECLARE @NombreSubcategoria NVARCHAR(100);
        DECLARE @NombreCategoria NVARCHAR(100);
        DECLARE @CategoriaId INT;
        
        SELECT 
            @NombreSubcategoria = SUB.SUB_Nombre,
            @CategoriaId = SUB.SUB_CategoriaId,
            @NombreCategoria = CAT.CAT_Nombre
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE SUB.SUB_Id = @SubcategoriaId AND SUB.SUB_Estado = 1;

        IF @NombreSubcategoria IS NULL
        BEGIN
            RAISERROR('La subcategoría especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista otro modelo con el mismo nombre, marca y subcategoría
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MODELOS
                   WHERE MOD_Nombre = @Nombre 
                   AND MOD_MarcaId = @MarcaId 
                   AND MOD_SubcategoriaId = @SubcategoriaId 
                   AND MOD_Id <> @IdModelo 
                   AND MOD_Estado = 1)
        BEGIN
            RAISERROR('Ya existe otro modelo con ese nombre en la marca y subcategoría especificadas', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores en formato JSON (con jerarquía completa)
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                MOD.MOD_Id AS IdModelo,
                MOD.MOD_Nombre AS Nombre,
                MOD.MOD_MarcaId AS IdMarca,
                MAR.MAR_Nombre AS NombreMarca,
                MOD.MOD_SubcategoriaId AS IdSubcategoria,
                SUB.SUB_Nombre AS NombreSubcategoria,
                SUB.SUB_CategoriaId AS IdCategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                MOD.MOD_Descripcion AS Descripcion,
                MOD.MOD_Estado AS Activo
            FROM ZI_GENERAL.ZI_MODELOS MOD
            INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
            INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MOD.MOD_SubcategoriaId = SUB.SUB_Id
            INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
            WHERE MOD.MOD_Id = @IdModelo
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Actualizar modelo
        UPDATE ZI_GENERAL.ZI_MODELOS SET
            MOD_Nombre = @Nombre,
            MOD_MarcaId = @MarcaId,
            MOD_SubcategoriaId = @SubcategoriaId,
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
                @CategoriaId AS IdCategoria,
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
            'Modelo actualizado: ' + @Nombre + ' (Marca: ' + @NombreMarca + ', Subcategoría: ' + @NombreSubcategoria + ', ID: ' + CAST(@IdModelo AS NVARCHAR(10)) + ')',
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_CREAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Stored Procedures FINALES para Modelos
-- Jerarquía: Categoría ? Subcategoría ? Modelo ? Marca (independiente)
-- MOD_SubcategoriaId Y MOD_MarcaId (ambos presentes)
-- =============================================

-- =============================================
-- SP para crear un nuevo modelo
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MODELOS_CREAR]
    @Nombre NVARCHAR(100),
    @MarcaId INT,
    @SubcategoriaId INT,
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

        -- Validar que la marca existe y está activa
        DECLARE @NombreMarca NVARCHAR(100);
        SELECT @NombreMarca = MAR_Nombre
        FROM ZI_GENERAL.ZI_MARCAS 
        WHERE MAR_Id = @MarcaId AND MAR_Estado = 1;

        IF @NombreMarca IS NULL
        BEGIN
            RAISERROR('La marca especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que la subcategoría existe y está activa, y obtener jerarquía
        DECLARE @NombreSubcategoria NVARCHAR(100);
        DECLARE @NombreCategoria NVARCHAR(100);
        DECLARE @CategoriaId INT;
        
        SELECT 
            @NombreSubcategoria = SUB.SUB_Nombre,
            @CategoriaId = SUB.SUB_CategoriaId,
            @NombreCategoria = CAT.CAT_Nombre
        FROM ZI_GENERAL.ZI_SUBCATEGORIAS SUB
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE SUB.SUB_Id = @SubcategoriaId AND SUB.SUB_Estado = 1;

        IF @NombreSubcategoria IS NULL
        BEGIN
            RAISERROR('La subcategoría especificada no existe o está inactiva', 16, 1);
            RETURN;
        END

        -- Validar que no exista un modelo con el mismo nombre, marca y subcategoría
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_MODELOS 
                   WHERE MOD_Nombre = @Nombre 
                   AND MOD_MarcaId = @MarcaId 
                   AND MOD_SubcategoriaId = @SubcategoriaId 
                   AND MOD_Estado = 1)
        BEGIN
            RAISERROR('Ya existe un modelo con ese nombre en la marca y subcategoría especificadas', 16, 1);
            RETURN;
        END

        -- Generar nuevo ID usando la secuencia
        SELECT @IdModelo = NEXT VALUE FOR ZI_GENERAL.Seq_Modelos;

        -- Insertar nuevo modelo
        INSERT INTO ZI_GENERAL.ZI_MODELOS (
            MOD_Id,
            MOD_Nombre,
            MOD_MarcaId,
            MOD_SubcategoriaId,
            MOD_Descripcion,
            MOD_Estado,
            MOD_FechaCreacion,
            MOD_UsuarioCreacion,
            MOD_IpCreacion
        ) VALUES (
            @IdModelo,
            @Nombre,
            @MarcaId,
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
                @IdModelo AS IdModelo,
                @Nombre AS Nombre,
                @MarcaId AS IdMarca,
                @NombreMarca AS NombreMarca,
                @SubcategoriaId AS IdSubcategoria,
                @NombreSubcategoria AS NombreSubcategoria,
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
            'MODELOS',
            @IdModelo,
            'Modelo creado: ' + @Nombre + ' (Marca: ' + @NombreMarca + ', Subcategoría: ' + @NombreSubcategoria + ')',
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_ELIMINAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para eliminar un modelo (eliminación lógica)
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MODELOS_ELIMINAR]
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
        DECLARE @NombreSubcategoria NVARCHAR(100);
        
        SELECT 
            @NombreModelo = MOD.MOD_Nombre,
            @NombreMarca = MAR.MAR_Nombre,
            @NombreSubcategoria = SUB.SUB_Nombre
        FROM ZI_GENERAL.ZI_MODELOS MOD
        INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
        INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MOD.MOD_SubcategoriaId = SUB.SUB_Id
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
                MOD.MOD_SubcategoriaId AS IdSubcategoria,
                SUB.SUB_Nombre AS NombreSubcategoria,
                SUB.SUB_CategoriaId AS IdCategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                MOD.MOD_Descripcion AS Descripcion,
                MOD.MOD_Estado AS Activo
            FROM ZI_GENERAL.ZI_MODELOS MOD
            INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
            INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MOD.MOD_SubcategoriaId = SUB.SUB_Id
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
                MOD.MOD_SubcategoriaId AS IdSubcategoria,
                SUB.SUB_Nombre AS NombreSubcategoria,
                SUB.SUB_CategoriaId AS IdCategoria,
                CAT.CAT_Nombre AS NombreCategoria,
                MOD.MOD_Descripcion AS Descripcion,
                0 AS Activo
            FROM ZI_GENERAL.ZI_MODELOS MOD
            INNER JOIN ZI_GENERAL.ZI_MARCAS MAR ON MOD.MOD_MarcaId = MAR.MAR_Id
            INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MOD.MOD_SubcategoriaId = SUB.SUB_Id
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
            'Modelo eliminado: ' + @NombreModelo + ' (Marca: ' + @NombreMarca + ', Subcategoría: ' + @NombreSubcategoria + ', ID: ' + CAST(@IdModelo AS NVARCHAR(10)) + ')',
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_LISTAR_PAGINADO]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para listar modelos paginados
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MODELOS_LISTAR_PAGINADO]
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
        INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MOD.MOD_SubcategoriaId = SUB.SUB_Id
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE (@IncluirInactivos = 1 OR MOD.MOD_Estado = 1)
        AND (@SearchTerm IS NULL OR MOD.MOD_Nombre LIKE '%' + @SearchTerm + '%' 
             OR MAR.MAR_Nombre LIKE '%' + @SearchTerm + '%'
             OR SUB.SUB_Nombre LIKE '%' + @SearchTerm + '%'
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%')
        AND (@IdMarca IS NULL OR MOD.MOD_MarcaId = @IdMarca)
        AND (@IdSubcategoria IS NULL OR MOD.MOD_SubcategoriaId = @IdSubcategoria)
        AND (@IdCategoria IS NULL OR SUB.SUB_CategoriaId = @IdCategoria);

        -- Obtener registros paginados con jerarquía completa
        SELECT
            MOD.MOD_Id AS IdModelo,
            MOD.MOD_Nombre AS Nombre,
            MOD.MOD_Descripcion AS Descripcion,
            MOD.MOD_Estado AS Activo,
            MOD.MOD_MarcaId AS IdMarca,
            MAR.MAR_Nombre AS NombreMarca,
            MOD.MOD_SubcategoriaId AS IdSubcategoria,
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
        INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MOD.MOD_SubcategoriaId = SUB.SUB_Id
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE (@IncluirInactivos = 1 OR MOD.MOD_Estado = 1)
        AND (@SearchTerm IS NULL OR MOD.MOD_Nombre LIKE '%' + @SearchTerm + '%' 
             OR MAR.MAR_Nombre LIKE '%' + @SearchTerm + '%'
             OR SUB.SUB_Nombre LIKE '%' + @SearchTerm + '%'
             OR CAT.CAT_Nombre LIKE '%' + @SearchTerm + '%')
        AND (@IdMarca IS NULL OR MOD.MOD_MarcaId = @IdMarca)
        AND (@IdSubcategoria IS NULL OR MOD.MOD_SubcategoriaId = @IdSubcategoria)
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_MODELOS_OBTENER_POR_ID]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para obtener un modelo por ID
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_MODELOS_OBTENER_POR_ID]
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
            MOD.MOD_SubcategoriaId AS IdSubcategoria,
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
        INNER JOIN ZI_GENERAL.ZI_SUBCATEGORIAS SUB ON MOD.MOD_SubcategoriaId = SUB.SUB_Id
        INNER JOIN ZI_GENERAL.ZI_CATEGORIAS CAT ON SUB.SUB_CategoriaId = CAT.CAT_Id
        WHERE MOD.MOD_Id = @IdModelo AND MOD.MOD_Estado = 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_SUBCATEGORIAS_ACTUALIZAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Corrección: Agregar parámetro OUTPUT @FilasAfectadas para Subcategorías
-- =============================================

-- SP ACTUALIZAR con OUTPUT
CREATE   PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_ACTUALIZAR]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_SUBCATEGORIAS_CREAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para crear una nueva subcategoría
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_CREAR]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_SUBCATEGORIAS_ELIMINAR]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SP ELIMINAR con OUTPUT
CREATE   PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_ELIMINAR]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_SUBCATEGORIAS_LISTAR_PAGINADO]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para listar subcategorías paginadas
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_LISTAR_PAGINADO]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_SUBCATEGORIAS_OBTENER_POR_ID]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP para obtener una subcategoría por ID
-- =============================================
CREATE   PROCEDURE [ZI_GENERAL].[SP_SUBCATEGORIAS_OBTENER_POR_ID]
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
/****** Object:  StoredProcedure [ZI_GENERAL].[SP_VALIDATE_USER_LOGIN]    Script Date: 7/11/2025 12:38:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimiento para validar login de usuario
CREATE PROCEDURE [ZI_GENERAL].[SP_VALIDATE_USER_LOGIN]
    @Username NVARCHAR(100),
    @EncryptedPassword NVARCHAR(500),
    @IpAddress NVARCHAR(45) = NULL,
    @UserAgent NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserId INT;
    DECLARE @IsBlocked BIT = 0;
    DECLARE @FailedAttempts INT = 0;
    DECLARE @MaxAttempts INT;
    DECLARE @BlockTimeMinutes INT;
    DECLARE @LastBlockTime DATETIME2;
    DECLARE @CurrentTime DATETIME2 = GETDATE();
    DECLARE @Result NVARCHAR(50) = 'ERROR';
    DECLARE @Message NVARCHAR(500) = '';
    
    BEGIN TRY
        -- Obtener configuraciones de seguridad
        SELECT @MaxAttempts = CAST(ZIC_VALOR AS INT) 
        FROM ZI_GENERAL.ZI_CONFIGURACION 
        WHERE ZIC_CLAVE = 'MAX_INTENTOS_LOGIN' AND ZIC_ACTIVO = 1;
        
        SELECT @BlockTimeMinutes = CAST(ZIC_VALOR AS INT) 
        FROM ZI_GENERAL.ZI_CONFIGURACION 
        WHERE ZIC_CLAVE = 'TIEMPO_BLOQUEO_MINUTOS' AND ZIC_ACTIVO = 1;
        
        SET @MaxAttempts = ISNULL(@MaxAttempts, 5);
        SET @BlockTimeMinutes = ISNULL(@BlockTimeMinutes, 30);
        
        -- Buscar usuario
        SELECT 
            @UserId = USU_Id,
            @IsBlocked = USU_Bloqueado,
            @FailedAttempts = USU_IntentosFallidos,
            @LastBlockTime = USU_FechaBloqueo
        FROM ZI_GENERAL.ZI_USUARIOS 
        WHERE USU_Username = @Username AND USU_Activo = 1;
        
        -- Verificar si el usuario existe
        IF @UserId IS NULL
        BEGIN
            SET @Result = 'ERROR';
            SET @Message = 'Usuario no encontrado o inactivo';
            
            -- Registrar intento fallido en bitácora
            INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
            VALUES (NULL, 'LOGIN', 'AUTENTICACION', 0, 'Intento de login con usuario inexistente: ' + @Username, @CurrentTime);
            
            SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
            RETURN;
        END
        
        -- Verificar si está bloqueado y si ya pasó el tiempo de bloqueo
        IF @IsBlocked = 1 AND @LastBlockTime IS NOT NULL
        BEGIN
            IF DATEDIFF(MINUTE, @LastBlockTime, @CurrentTime) >= @BlockTimeMinutes
            BEGIN
                -- Desbloquear usuario
                UPDATE ZI_GENERAL.ZI_USUARIOS 
                SET USU_Bloqueado = 0, 
                    USU_IntentosFallidos = 0,
                    USU_FechaBloqueo = NULL
                WHERE USU_Id = @UserId;
                
                SET @IsBlocked = 0;
                SET @FailedAttempts = 0;
            END
            ELSE
            BEGIN
                SET @Result = 'ERROR';
                SET @Message = 'Usuario bloqueado. Intente nuevamente en ' + CAST(@BlockTimeMinutes - DATEDIFF(MINUTE, @LastBlockTime, @CurrentTime) AS NVARCHAR(10)) + ' minutos.';
                
                -- Registrar intento en usuario bloqueado
                INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
                VALUES (@UserId, 'LOGIN', 'AUTENTICACION', @UserId, 'Intento de login en usuario bloqueado', @CurrentTime);
                
                SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
                RETURN;
            END
        END
        
        -- Verificar contraseña
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Id = @UserId AND USU_PasswordEncrypted = @EncryptedPassword)
        BEGIN
            -- Login exitoso
            UPDATE ZI_GENERAL.ZI_USUARIOS 
            SET USU_UltimoLogin = @CurrentTime,
                USU_IntentosFallidos = 0,
                USU_Bloqueado = 0,
                USU_FechaBloqueo = NULL
            WHERE USU_Id = @UserId;
            
            SET @Result = 'EXITO';
            SET @Message = 'Login exitoso';
            
            -- Registrar login exitoso
            INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
            VALUES (@UserId, 'LOGIN', 'AUTENTICACION', @UserId, 'Login exitoso', @CurrentTime);
            
            SELECT @Result as Resultado, @Message as Mensaje, @UserId as UserId;
        END
        ELSE
        BEGIN
            -- Contraseña incorrecta
            SET @FailedAttempts = @FailedAttempts + 1;
            
            IF @FailedAttempts >= @MaxAttempts
            BEGIN
                -- Bloquear usuario
                UPDATE ZI_GENERAL.ZI_USUARIOS 
                SET USU_IntentosFallidos = @FailedAttempts,
                    USU_Bloqueado = 1,
                    USU_FechaBloqueo = @CurrentTime
                WHERE USU_Id = @UserId;
                
                SET @Result = 'ERROR';
                SET @Message = 'Usuario bloqueado por exceder intentos máximos de login. Intente en ' + CAST(@BlockTimeMinutes AS NVARCHAR(10)) + ' minutos.';
            END
            ELSE
            BEGIN
                -- Incrementar intentos fallidos
                UPDATE ZI_GENERAL.ZI_USUARIOS 
                SET USU_IntentosFallidos = @FailedAttempts
                WHERE USU_Id = @UserId;
                
                SET @Result = 'ERROR';
                SET @Message = 'Contraseña incorrecta. Intentos restantes: ' + CAST(@MaxAttempts - @FailedAttempts AS NVARCHAR(10));
            END
            
            -- Registrar intento fallido
            INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
            VALUES (@UserId, 'LOGIN', 'AUTENTICACION', @UserId, 'Intento de login fallido', @CurrentTime);
            
            SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
        END
        
    END TRY
    BEGIN CATCH
        SET @Result = 'ERROR';
        SET @Message = 'Error interno del sistema: ' + ERROR_MESSAGE();
        
        -- Registrar error en bitácora
        INSERT INTO ZI_GENERAL.ZI_BITACORAAUDITORIA (BIT_AgenteId, BIT_Accion, BIT_Entidad, BIT_EntidadId, BIT_Detalles, BIT_FechaHora)
        VALUES (@UserId, 'LOGIN', 'AUTENTICACION', ISNULL(@UserId, 0), 'Error en proceso de login', @CurrentTime);
        
        SELECT @Result as Resultado, @Message as Mensaje, 0 as UserId;
    END CATCH
END

GO