USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedures para GESTIÓN DE USUARIOS
-- Incluye: Mantenimiento de usuarios, Reseteo de contraseñas, 
-- Gestión de roles y permisos
-- =============================================

-- =============================================
-- SP para listar usuarios con paginación
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_USUARIOS_LISTAR_PAGINADO', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_USUARIOS_LISTAR_PAGINADO;
GO

CREATE PROCEDURE ZI_GENERAL.SP_USUARIOS_LISTAR_PAGINADO
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @SoloBloqueados BIT = 0,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Calcular offset
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        
        -- Obtener total de registros
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_USUARIOS
        WHERE 
            (@IncluirInactivos = 1 OR USU_Activo = 1)
            AND (@SoloBloqueados = 0 OR USU_Bloqueado = 1)
            AND (@SearchTerm IS NULL OR 
                 USU_Username LIKE '%' + @SearchTerm + '%' OR 
                 USU_Nombre LIKE '%' + @SearchTerm + '%' OR
                 USU_Apellido LIKE '%' + @SearchTerm + '%' OR
                 USU_Correo LIKE '%' + @SearchTerm + '%');
        
        -- Obtener registros paginados con información de roles
        SELECT 
            USU_Id AS IdUsuario,
            USU_Codigo AS Codigo,
            USU_Username AS Username,
            USU_Nombre AS Nombre,
            USU_Apellido AS Apellido,
            USU_Correo AS Correo,
            USU_Telefono AS Telefono,
            USU_Departamento AS Departamento,
            USU_Puesto AS Puesto,
            USU_Activo AS Activo,
            USU_Bloqueado AS Bloqueado,
            USU_IntentosFallidos AS IntentosFallidos,
            USU_FechaBloqueo AS FechaBloqueo,
            USU_UltimoLogin AS UltimoLogin,
            USU_PassTemp AS RequiereCambioPassword,
            USU_FechaCreacion AS FechaCreacion,
            USU_UsuarioCreacion AS UsuarioCreacion,
            USU_FechaModificacion AS FechaModificacion,
            USU_UsuarioModificacion AS UsuarioModificacion,
            -- Información adicional
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_USUARIOSROLES 
             WHERE UR_UsrId = USU_Id AND UR_Activo = 1) AS TotalRoles,
            (SELECT STRING_AGG(r.ROL_Nombre, ', ')
             FROM ZI_GENERAL.ZI_USUARIOSROLES ur
             INNER JOIN ZI_GENERAL.ZI_ROLES r ON ur.UR_RolId = r.ROL_Id
             WHERE ur.UR_UsrId = USU_Id AND ur.UR_Activo = 1) AS RolesAsignados
        FROM ZI_GENERAL.ZI_USUARIOS
        WHERE 
            (@IncluirInactivos = 1 OR USU_Activo = 1)
            AND (@SoloBloqueados = 0 OR USU_Bloqueado = 1)
            AND (@SearchTerm IS NULL OR 
                 USU_Username LIKE '%' + @SearchTerm + '%' OR 
                 USU_Nombre LIKE '%' + @SearchTerm + '%' OR
                 USU_Apellido LIKE '%' + @SearchTerm + '%' OR
                 USU_Correo LIKE '%' + @SearchTerm + '%')
        ORDER BY USU_Nombre, USU_Apellido
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
-- SP para obtener usuario por ID con toda su información
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_USUARIOS_OBTENER_POR_ID', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_USUARIOS_OBTENER_POR_ID;
GO

CREATE PROCEDURE ZI_GENERAL.SP_USUARIOS_OBTENER_POR_ID
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Información del usuario
        SELECT 
            USU_Id AS IdUsuario,
            USU_Codigo AS Codigo,
            USU_Username AS Username,
            USU_Nombre AS Nombre,
            USU_Apellido AS Apellido,
            USU_Correo AS Correo,
            USU_Telefono AS Telefono,
            USU_Departamento AS Departamento,
            USU_Puesto AS Puesto,
            USU_Activo AS Activo,
            USU_Bloqueado AS Bloqueado,
            USU_IntentosFallidos AS IntentosFallidos,
            USU_FechaBloqueo AS FechaBloqueo,
            USU_UltimoLogin AS UltimoLogin,
            USU_PassTemp AS RequiereCambioPassword,
            USU_FechaCreacion AS FechaCreacion,
            USU_UsuarioCreacion AS UsuarioCreacion,
            USU_FechaModificacion AS FechaModificacion,
            USU_UsuarioModificacion AS UsuarioModificacion,
            USU_IpCreacion AS IpCreacion,
            USU_IpModificacion AS IpModificacion
        FROM ZI_GENERAL.ZI_USUARIOS
        WHERE USU_Id = @IdUsuario;

        -- Roles asignados
        SELECT 
            r.ROL_Id AS IdRol,
            r.ROL_Nombre AS Nombre,
            r.ROL_Descripcion AS Descripcion,
            ur.UR_FechaAsignacion AS FechaAsignacion,
            ur.UR_Activo AS Activo
        FROM ZI_GENERAL.ZI_USUARIOSROLES ur
        INNER JOIN ZI_GENERAL.ZI_ROLES r ON ur.UR_RolId = r.ROL_Id
        WHERE ur.UR_UsrId = @IdUsuario AND ur.UR_Activo = 1;

        -- Permisos efectivos (a través de roles)
        SELECT DISTINCT
            p.PER_Id AS IdPermiso,
            p.PER_Nombre AS Nombre,
            p.PER_Descripcion AS Descripcion,
            p.PER_Modulo AS Modulo,
            p.PER_Accion AS Accion
        FROM ZI_GENERAL.ZI_USUARIOSROLES ur
        INNER JOIN ZI_GENERAL.ZI_PERMISOSROLES pr ON ur.UR_RolId = pr.PRO_RolId
        INNER JOIN ZI_GENERAL.ZI_PERMISOS p ON pr.PRO_PermisoId = p.PER_Id
        WHERE ur.UR_UsrId = @IdUsuario 
        AND ur.UR_Activo = 1 
        AND p.PER_Activo = 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para crear usuario
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_USUARIOS_CREAR', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_USUARIOS_CREAR;
GO

CREATE PROCEDURE ZI_GENERAL.SP_USUARIOS_CREAR
    @Codigo INT,
    @Username NVARCHAR(100),
    @PasswordEncrypted NVARCHAR(500),
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(150) = NULL,
    @Correo NVARCHAR(100),
    @Telefono NVARCHAR(20) = NULL,
    @Departamento NVARCHAR(100) = NULL,
    @Puesto NVARCHAR(100) = NULL,
    @Activo BIT = 1,
    @PassTemp BIT = 1,
    @UsuarioCreacion NVARCHAR(100),
    @IpCreacion NVARCHAR(45),
    @IdUsuario INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista el username
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Username = @Username)
        BEGIN
            RAISERROR('Ya existe un usuario con ese nombre de usuario', 16, 1);
            RETURN;
        END

        -- Validar que no exista el código
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Codigo = @Codigo)
        BEGIN
            RAISERROR('Ya existe un usuario con ese código', 16, 1);
            RETURN;
        END

        -- Validar que no exista el correo
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Correo = @Correo)
        BEGIN
            RAISERROR('Ya existe un usuario con ese correo electrónico', 16, 1);
            RETURN;
        END

        -- Generar nuevo ID
        SELECT @IdUsuario = NEXT VALUE FOR ZI_GENERAL.Seq_Usuarios;

        -- Insertar usuario
        INSERT INTO ZI_GENERAL.ZI_USUARIOS (
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
            USU_PassTemp,
            USU_FechaCreacion,
            USU_UsuarioCreacion,
            USU_IpCreacion,
            USU_Estado
        ) VALUES (
            @IdUsuario,
            @Codigo,
            @Username,
            @PasswordEncrypted,
            @Nombre,
            @Apellido,
            @Correo,
            @Telefono,
            @Departamento,
            @Puesto,
            @Activo,
            @PassTemp,
            GETDATE(),
            @UsuarioCreacion,
            @IpCreacion,
            1
        );

        -- Registrar en bitácora
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdUsuario AS IdUsuario,
                @Username AS Username,
                @Nombre AS Nombre,
                @Apellido AS Apellido,
                @Correo AS Correo,
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
            'USUARIOS',
            @IdUsuario,
            'Usuario creado: ' + @Username,
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
-- SP para actualizar usuario
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_USUARIOS_ACTUALIZAR', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_USUARIOS_ACTUALIZAR;
GO

CREATE PROCEDURE ZI_GENERAL.SP_USUARIOS_ACTUALIZAR
    @IdUsuario INT,
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(150) = NULL,
    @Correo NVARCHAR(100),
    @Telefono NVARCHAR(20) = NULL,
    @Departamento NVARCHAR(100) = NULL,
    @Puesto NVARCHAR(100) = NULL,
    @Activo BIT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Id = @IdUsuario)
        BEGIN
            RAISERROR('El usuario no existe', 16, 1);
            RETURN;
        END

        -- Validar que no exista otro usuario con el mismo correo
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOS 
                   WHERE USU_Correo = @Correo AND USU_Id <> @IdUsuario)
        BEGIN
            RAISERROR('Ya existe otro usuario con ese correo electrónico', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                USU_Id AS IdUsuario,
                USU_Username AS Username,
                USU_Nombre AS Nombre,
                USU_Apellido AS Apellido,
                USU_Correo AS Correo,
                USU_Telefono AS Telefono,
                USU_Departamento AS Departamento,
                USU_Puesto AS Puesto,
                USU_Activo AS Activo
            FROM ZI_GENERAL.ZI_USUARIOS
            WHERE USU_Id = @IdUsuario
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Actualizar usuario
        UPDATE ZI_GENERAL.ZI_USUARIOS SET
            USU_Nombre = @Nombre,
            USU_Apellido = @Apellido,
            USU_Correo = @Correo,
            USU_Telefono = @Telefono,
            USU_Departamento = @Departamento,
            USU_Puesto = @Puesto,
            USU_Activo = @Activo,
            USU_FechaModificacion = GETDATE(),
            USU_UsuarioModificacion = @UsuarioModificacion,
            USU_IpModificacion = @IpModificacion
        WHERE USU_Id = @IdUsuario;

        SET @FilasAfectadas = @@ROWCOUNT;

        -- Capturar valores nuevos
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdUsuario AS IdUsuario,
                USU_Username AS Username,
                @Nombre AS Nombre,
                @Apellido AS Apellido,
                @Correo AS Correo,
                @Telefono AS Telefono,
                @Departamento AS Departamento,
                @Puesto AS Puesto,
                @Activo AS Activo
            FROM ZI_GENERAL.ZI_USUARIOS
            WHERE USU_Id = @IdUsuario
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
            'USUARIOS',
            @IdUsuario,
            'Usuario actualizado (ID: ' + CAST(@IdUsuario AS NVARCHAR(10)) + ')',
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

-- =============================================
-- SP para desactivar/eliminar usuario (eliminación lógica)
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_USUARIOS_ELIMINAR', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_USUARIOS_ELIMINAR;
GO

CREATE PROCEDURE ZI_GENERAL.SP_USUARIOS_ELIMINAR
    @IdUsuario INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario existe
        DECLARE @Username NVARCHAR(100);
        SELECT @Username = USU_Username
        FROM ZI_GENERAL.ZI_USUARIOS
        WHERE USU_Id = @IdUsuario;

        IF @Username IS NULL
        BEGIN
            RAISERROR('El usuario no existe', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                USU_Id AS IdUsuario,
                USU_Username AS Username,
                USU_Nombre AS Nombre,
                USU_Activo AS Activo
            FROM ZI_GENERAL.ZI_USUARIOS
            WHERE USU_Id = @IdUsuario
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Marcar como inactivo
        UPDATE ZI_GENERAL.ZI_USUARIOS SET
            USU_Activo = 0,
            USU_Estado = 0,
            USU_FechaModificacion = GETDATE(),
            USU_UsuarioModificacion = @UsuarioEliminacion,
            USU_IpModificacion = @IpEliminacion
        WHERE USU_Id = @IdUsuario;

        SET @FilasAfectadas = @@ROWCOUNT;

        -- Desactivar roles asignados
        UPDATE ZI_GENERAL.ZI_USUARIOSROLES SET
            UR_Activo = 0,
            UR_FechaModificacion = GETDATE(),
            UR_UsuarioModificacion = @UsuarioEliminacion,
            UR_IpModificacion = @IpEliminacion
        WHERE UR_UsrId = @IdUsuario;

        -- Capturar valores nuevos
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdUsuario AS IdUsuario,
                @Username AS Username,
                (SELECT USU_Nombre FROM ZI_GENERAL.ZI_USUARIOS WHERE USU_Id = @IdUsuario) AS Nombre,
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
            'USUARIOS',
            @IdUsuario,
            'Usuario eliminado: ' + @Username + ' (ID: ' + CAST(@IdUsuario AS NVARCHAR(10)) + ')',
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

-- =============================================
-- SP para resetear contraseña (temporal)
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_USUARIOS_RESETEAR_PASSWORD', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_USUARIOS_RESETEAR_PASSWORD;
GO

CREATE PROCEDURE ZI_GENERAL.SP_USUARIOS_RESETEAR_PASSWORD
    @IdUsuario INT,
    @NuevaPasswordEncriptada NVARCHAR(500),
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario existe
        DECLARE @Username NVARCHAR(100);
        SELECT @Username = USU_Username
        FROM ZI_GENERAL.ZI_USUARIOS
        WHERE USU_Id = @IdUsuario AND USU_Activo = 1;

        IF @Username IS NULL
        BEGIN
            RAISERROR('Usuario no encontrado o inactivo', 16, 1);
            RETURN;
        END

        -- Actualizar contraseña y marcar como temporal
        UPDATE ZI_GENERAL.ZI_USUARIOS SET
            USU_PasswordEncrypted = @NuevaPasswordEncriptada,
            USU_PassTemp = 1,  -- Requiere cambio en el siguiente login
            USU_IntentosFallidos = 0,
            USU_Bloqueado = 0,
            USU_FechaBloqueo = NULL,
            USU_FechaModificacion = GETDATE(),
            USU_UsuarioModificacion = @UsuarioModificacion,
            USU_IpModificacion = @IpModificacion
        WHERE USU_Id = @IdUsuario;

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
            @IdUsuario,
            'RESETEAR_PASSWORD',
            'USUARIOS',
            @IdUsuario,
            'Contraseña reseteada para usuario: ' + @Username,
            NULL,
            NULL,
            GETDATE()
        );

        COMMIT TRANSACTION;

        SELECT 'EXITO' AS Resultado, 'Contraseña reseteada exitosamente' AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SELECT 'ERROR' AS Resultado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

-- =============================================
-- SP para desbloquear usuario
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_USUARIOS_DESBLOQUEAR', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_USUARIOS_DESBLOQUEAR;
GO

CREATE PROCEDURE ZI_GENERAL.SP_USUARIOS_DESBLOQUEAR
    @IdUsuario INT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario existe
        DECLARE @Username NVARCHAR(100);
        SELECT @Username = USU_Username
        FROM ZI_GENERAL.ZI_USUARIOS
        WHERE USU_Id = @IdUsuario AND USU_Activo = 1;

        IF @Username IS NULL
        BEGIN
            RAISERROR('Usuario no encontrado o inactivo', 16, 1);
            RETURN;
        END

        -- Desbloquear usuario
        UPDATE ZI_GENERAL.ZI_USUARIOS SET
            USU_Bloqueado = 0,
            USU_IntentosFallidos = 0,
            USU_FechaBloqueo = NULL,
            USU_FechaModificacion = GETDATE(),
            USU_UsuarioModificacion = @UsuarioModificacion,
            USU_IpModificacion = @IpModificacion
        WHERE USU_Id = @IdUsuario;

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
            @IdUsuario,
            'DESBLOQUEAR',
            'USUARIOS',
            @IdUsuario,
            'Usuario desbloqueado: ' + @Username,
            NULL,
            NULL,
            GETDATE()
        );

        COMMIT TRANSACTION;

        SELECT 'EXITO' AS Resultado, 'Usuario desbloqueado exitosamente' AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SELECT 'ERROR' AS Resultado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

-- =============================================
-- SP para asignar roles a un usuario
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_USUARIOS_ASIGNAR_ROLES', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_USUARIOS_ASIGNAR_ROLES;
GO

CREATE PROCEDURE ZI_GENERAL.SP_USUARIOS_ASIGNAR_ROLES
    @IdUsuario INT,
    @RolesIds NVARCHAR(MAX), -- IDs separados por coma
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario existe
        DECLARE @Username NVARCHAR(100);
        SELECT @Username = USU_Username
        FROM ZI_GENERAL.ZI_USUARIOS
        WHERE USU_Id = @IdUsuario AND USU_Activo = 1;

        IF @Username IS NULL
        BEGIN
            RAISERROR('Usuario no encontrado o inactivo', 16, 1);
            RETURN;
        END

        -- Desactivar todos los roles actuales
        UPDATE ZI_GENERAL.ZI_USUARIOSROLES SET
            UR_Activo = 0,
            UR_FechaModificacion = GETDATE(),
            UR_UsuarioModificacion = @UsuarioModificacion,
            UR_IpModificacion = @IpModificacion
        WHERE UR_UsrId = @IdUsuario;

        -- Tabla temporal para los roles
        CREATE TABLE #RolesTemp (RolId INT);

        -- Insertar los roles seleccionados en la tabla temporal
        INSERT INTO #RolesTemp (RolId)
        SELECT CAST(value AS INT)
        FROM STRING_SPLIT(@RolesIds, ',')
        WHERE RTRIM(value) <> '';

        -- Activar o insertar los roles seleccionados
        DECLARE @RolId INT;
        DECLARE rol_cursor CURSOR FOR SELECT RolId FROM #RolesTemp;
        
        OPEN rol_cursor;
        FETCH NEXT FROM rol_cursor INTO @RolId;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Verificar si ya existe la relación
            IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOSROLES 
                       WHERE UR_UsrId = @IdUsuario AND UR_RolId = @RolId)
            BEGIN
                -- Reactivar
                UPDATE ZI_GENERAL.ZI_USUARIOSROLES SET
                    UR_Activo = 1,
                    UR_FechaModificacion = GETDATE(),
                    UR_UsuarioModificacion = @UsuarioModificacion,
                    UR_IpModificacion = @IpModificacion
                WHERE UR_UsrId = @IdUsuario AND UR_RolId = @RolId;
            END
            ELSE
            BEGIN
                -- Insertar nueva relación
                DECLARE @NuevoUrId INT;
                SELECT @NuevoUrId = NEXT VALUE FOR ZI_GENERAL.Seq_ZI_UsuariosRoles;
                
                INSERT INTO ZI_GENERAL.ZI_USUARIOSROLES (
                    UR_Id,
                    UR_UsrId,
                    UR_RolId,
                    UR_UsuarioCreacion,
                    UR_IpCreacion
                ) VALUES (
                    @NuevoUrId,
                    @IdUsuario,
                    @RolId,
                    @UsuarioModificacion,
                    @IpModificacion
                );
            END
            
            FETCH NEXT FROM rol_cursor INTO @RolId;
        END
        
        CLOSE rol_cursor;
        DEALLOCATE rol_cursor;

        -- Registrar en bitácora
        DECLARE @RolesAsignados NVARCHAR(500);
        SELECT @RolesAsignados = STRING_AGG(ROL_Nombre, ', ')
        FROM ZI_GENERAL.ZI_ROLES
        WHERE ROL_Id IN (SELECT RolId FROM #RolesTemp);

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
            @IdUsuario,
            'ASIGNAR_ROLES',
            'USUARIOS',
            @IdUsuario,
            'Roles asignados a ' + @Username + ': ' + ISNULL(@RolesAsignados, 'Ninguno'),
            NULL,
            NULL,
            GETDATE()
        );

        DROP TABLE #RolesTemp;
        COMMIT TRANSACTION;

        SELECT 'EXITO' AS Resultado, 'Roles asignados exitosamente' AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        IF OBJECT_ID('tempdb..#RolesTemp') IS NOT NULL
            DROP TABLE #RolesTemp;
        
        SELECT 'ERROR' AS Resultado, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

-- =============================================
-- SP para listar roles con paginación
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_ROLES_LISTAR_PAGINADO', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_ROLES_LISTAR_PAGINADO;
GO

CREATE PROCEDURE ZI_GENERAL.SP_ROLES_LISTAR_PAGINADO
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
        FROM ZI_GENERAL.ZI_ROLES
        WHERE 
            (@IncluirInactivos = 1 OR ROL_Activo = 1)
            AND (@SearchTerm IS NULL OR 
                 ROL_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 ROL_Descripcion LIKE '%' + @SearchTerm + '%');
        
        -- Obtener registros paginados
        SELECT 
            ROL_Id AS IdRol,
            ROL_Nombre AS Nombre,
            ROL_Descripcion AS Descripcion,
            ROL_Activo AS Activo,
            ROL_FechaCreacion AS FechaCreacion,
            ROL_UsuarioCreacion AS UsuarioCreacion,
            ROL_FechaModificacion AS FechaModificacion,
            ROL_UsuarioModificacion AS UsuarioModificacion,
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_USUARIOSROLES 
             WHERE UR_RolId = ROL_Id AND UR_Activo = 1) AS TotalUsuarios,
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_PERMISOSROLES 
             WHERE PRO_RolId = ROL_Id) AS TotalPermisos
        FROM ZI_GENERAL.ZI_ROLES
        WHERE 
            (@IncluirInactivos = 1 OR ROL_Activo = 1)
            AND (@SearchTerm IS NULL OR 
                 ROL_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 ROL_Descripcion LIKE '%' + @SearchTerm + '%')
        ORDER BY ROL_Nombre
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
-- SP para obtener permisos de un rol
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_ROLES_OBTENER_PERMISOS', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_ROLES_OBTENER_PERMISOS;
GO

CREATE PROCEDURE ZI_GENERAL.SP_ROLES_OBTENER_PERMISOS
    @IdRol INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            p.PER_Id AS IdPermiso,
            p.PER_Nombre AS Nombre,
            p.PER_Descripcion AS Descripcion,
            p.PER_Modulo AS Modulo,
            p.PER_Accion AS Accion,
            p.PER_Activo AS Activo
        FROM ZI_GENERAL.ZI_PERMISOSROLES pr
        INNER JOIN ZI_GENERAL.ZI_PERMISOS p ON pr.PRO_PermisoId = p.PER_Id
        WHERE pr.PRO_RolId = @IdRol AND p.PER_Activo = 1
        ORDER BY p.PER_Modulo, p.PER_Nombre;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'Stored Procedures de Gestión de Usuarios creados exitosamente';
GO

-- =============================================
-- =============================================
-- STORED PROCEDURES PARA GESTIÓN DE PERMISOS
-- =============================================
-- =============================================

-- =============================================
-- SP para listar permisos con paginación
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_PERMISOS_LISTAR_PAGINADO', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_PERMISOS_LISTAR_PAGINADO;
GO

CREATE PROCEDURE ZI_GENERAL.SP_PERMISOS_LISTAR_PAGINADO
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IncluirInactivos BIT = 0,
    @Modulo NVARCHAR(100) = NULL,
    @TotalRegistros INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Calcular offset
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        
        -- Obtener total de registros
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_PERMISOS
        WHERE 
            (@IncluirInactivos = 1 OR PER_Activo = 1)
            AND (@Modulo IS NULL OR PER_Modulo = @Modulo)
            AND (@SearchTerm IS NULL OR 
                 PER_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 PER_Descripcion LIKE '%' + @SearchTerm + '%' OR
                 PER_Modulo LIKE '%' + @SearchTerm + '%' OR
                 PER_Accion LIKE '%' + @SearchTerm + '%');
        
        -- Obtener registros paginados
        SELECT 
            PER_Id AS IdPermiso,
            PER_Nombre AS Nombre,
            PER_Descripcion AS Descripcion,
            PER_Modulo AS Modulo,
            PER_Accion AS Accion,
            PER_Activo AS Activo,
            PER_FechaCreacion AS FechaCreacion,
            PER_UsuarioCreacion AS UsuarioCreacion,
            PER_FechaModificacion AS FechaModificacion,
            PER_UsuarioModificacion AS UsuarioModificacion,
            -- Contar cuántos roles tienen este permiso
            (SELECT COUNT(DISTINCT PRO_RolId) 
             FROM ZI_GENERAL.ZI_PERMISOSROLES 
             WHERE PRO_PermisoId = PER_Id) AS TotalRoles
        FROM ZI_GENERAL.ZI_PERMISOS
        WHERE 
            (@IncluirInactivos = 1 OR PER_Activo = 1)
            AND (@Modulo IS NULL OR PER_Modulo = @Modulo)
            AND (@SearchTerm IS NULL OR 
                 PER_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 PER_Descripcion LIKE '%' + @SearchTerm + '%' OR
                 PER_Modulo LIKE '%' + @SearchTerm + '%' OR
                 PER_Accion LIKE '%' + @SearchTerm + '%')
        ORDER BY PER_Modulo, PER_Accion, PER_Nombre
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
-- SP para obtener permiso por ID con roles que lo usan
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_PERMISOS_OBTENER_POR_ID', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_PERMISOS_OBTENER_POR_ID;
GO

CREATE PROCEDURE ZI_GENERAL.SP_PERMISOS_OBTENER_POR_ID
    @IdPermiso INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Información del permiso
        SELECT 
            PER_Id AS IdPermiso,
            PER_Nombre AS Nombre,
            PER_Descripcion AS Descripcion,
            PER_Modulo AS Modulo,
            PER_Accion AS Accion,
            PER_Activo AS Activo,
            PER_FechaCreacion AS FechaCreacion,
            PER_UsuarioCreacion AS UsuarioCreacion,
            PER_FechaModificacion AS FechaModificacion,
            PER_UsuarioModificacion AS UsuarioModificacion,
            PER_IpCreacion AS IpCreacion,
            PER_IpModificacion AS IpModificacion,
            -- Contar roles
            (SELECT COUNT(DISTINCT PRO_RolId) 
             FROM ZI_GENERAL.ZI_PERMISOSROLES 
             WHERE PRO_PermisoId = PER_Id) AS TotalRoles
        FROM ZI_GENERAL.ZI_PERMISOS
        WHERE PER_Id = @IdPermiso;

        -- Roles que tienen este permiso
        SELECT 
            r.ROL_Id AS IdRol,
            r.ROL_Nombre AS Nombre,
            r.ROL_Descripcion AS Descripcion,
            r.ROL_Activo AS Activo,
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_USUARIOSROLES 
             WHERE UR_RolId = r.ROL_Id AND UR_Activo = 1) AS TotalUsuarios
        FROM ZI_GENERAL.ZI_PERMISOSROLES pr
        INNER JOIN ZI_GENERAL.ZI_ROLES r ON pr.PRO_RolId = r.ROL_Id
        WHERE pr.PRO_PermisoId = @IdPermiso AND r.ROL_Activo = 1
        ORDER BY r.ROL_Nombre;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para crear permiso
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_PERMISOS_CREAR', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_PERMISOS_CREAR;
GO

CREATE PROCEDURE ZI_GENERAL.SP_PERMISOS_CREAR
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(255) = NULL,
    @Modulo NVARCHAR(100),
    @Accion NVARCHAR(100),
    @Activo BIT = 1,
    @UsuarioCreacion NVARCHAR(100),
    @IpCreacion NVARCHAR(45),
    @IdPermiso INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista un permiso con el mismo módulo y acción
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_PERMISOS 
                   WHERE PER_Modulo = @Modulo 
                   AND PER_Accion = @Accion 
                   AND PER_Estado = 1)
        BEGIN
            RAISERROR('Ya existe un permiso con ese módulo y acción', 16, 1);
            RETURN;
        END

        -- Validar que no exista un permiso con el mismo nombre
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_PERMISOS 
                   WHERE PER_Nombre = @Nombre 
                   AND PER_Estado = 1)
        BEGIN
            RAISERROR('Ya existe un permiso con ese nombre', 16, 1);
            RETURN;
        END

        -- Generar nuevo ID
        SELECT @IdPermiso = NEXT VALUE FOR ZI_GENERAL.Seq_Permisos;

        -- Insertar permiso
        INSERT INTO ZI_GENERAL.ZI_PERMISOS (
            PER_Id,
            PER_Nombre,
            PER_Descripcion,
            PER_Modulo,
            PER_Accion,
            PER_Estado,
            PER_Activo,
            PER_FechaCreacion,
            PER_UsuarioCreacion,
            PER_IpCreacion
        ) VALUES (
            @IdPermiso,
            @Nombre,
            @Descripcion,
            @Modulo,
            @Accion,
            1,
            @Activo,
            GETDATE(),
            @UsuarioCreacion,
            @IpCreacion
        );

        -- Registrar en bitácora
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdPermiso AS IdPermiso,
                @Nombre AS Nombre,
                @Modulo AS Modulo,
                @Accion AS Accion,
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
            'PERMISOS',
            @IdPermiso,
            'Permiso creado: ' + @Nombre + ' (' + @Modulo + ' - ' + @Accion + ')',
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
-- SP para actualizar permiso
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_PERMISOS_ACTUALIZAR', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_PERMISOS_ACTUALIZAR;
GO

CREATE PROCEDURE ZI_GENERAL.SP_PERMISOS_ACTUALIZAR
    @IdPermiso INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(255) = NULL,
    @Modulo NVARCHAR(100),
    @Accion NVARCHAR(100),
    @Activo BIT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el permiso existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Id = @IdPermiso)
        BEGIN
            RAISERROR('El permiso no existe', 16, 1);
            RETURN;
        END

        -- Validar que no exista otro permiso con el mismo módulo y acción
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_PERMISOS 
                   WHERE PER_Modulo = @Modulo 
                   AND PER_Accion = @Accion 
                   AND PER_Id <> @IdPermiso 
                   AND PER_Estado = 1)
        BEGIN
            RAISERROR('Ya existe otro permiso con ese módulo y acción', 16, 1);
            RETURN;
        END

        -- Validar que no exista otro permiso with el mismo nombre
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_PERMISOS 
                   WHERE PER_Nombre = @Nombre 
                   AND PER_Id <> @IdPermiso 
                   AND PER_Estado = 1)
        BEGIN
            RAISERROR('Ya existe otro permiso con ese nombre', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                PER_Id AS IdPermiso,
                PER_Nombre AS Nombre,
                PER_Descripcion AS Descripcion,
                PER_Modulo AS Modulo,
                PER_Accion AS Accion,
                PER_Activo AS Activo
            FROM ZI_GENERAL.ZI_PERMISOS
            WHERE PER_Id = @IdPermiso
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Actualizar permiso
        UPDATE ZI_GENERAL.ZI_PERMISOS SET
            PER_Nombre = @Nombre,
            PER_Descripcion = @Descripcion,
            PER_Modulo = @Modulo,
            PER_Accion = @Accion,
            PER_Activo = @Activo,
            PER_FechaModificacion = GETDATE(),
            PER_UsuarioModificacion = @UsuarioModificacion,
            PER_IpModificacion = @IpModificacion
        WHERE PER_Id = @IdPermiso;

        SET @FilasAfectadas = @@ROWCOUNT;

        -- Capturar valores nuevos
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdPermiso AS IdPermiso,
                @Nombre AS Nombre,
                @Descripcion AS Descripcion,
                @Modulo AS Modulo,
                @Accion AS Accion,
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
            'PERMISOS',
            @IdPermiso,
            'Permiso actualizado: ' + @Nombre + ' (ID: ' + CAST(@IdPermiso AS NVARCHAR(10)) + ')',
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

-- =============================================
-- SP para eliminar permiso (eliminación lógica)
-- =============================================
IF OBJECT_ID('ZI_GENERAL.SP_PERMISOS_ELIMINAR', 'P') IS NOT NULL
    DROP PROCEDURE ZI_GENERAL.SP_PERMISOS_ELIMINAR;
GO

CREATE PROCEDURE ZI_GENERAL.SP_PERMISOS_ELIMINAR
    @IdPermiso INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el permiso existe
        DECLARE @NombrePermiso NVARCHAR(50);
        DECLARE @Modulo NVARCHAR(100);
        DECLARE @Accion NVARCHAR(100);
        
        SELECT 
            @NombrePermiso = PER_Nombre,
            @Modulo = PER_Modulo,
            @Accion = PER_Accion
        FROM ZI_GENERAL.ZI_PERMISOS
        WHERE PER_Id = @IdPermiso;

        IF @NombrePermiso IS NULL
        BEGIN
            RAISERROR('El permiso no existe', 16, 1);
            RETURN;
        END

        -- Validar que no sea un permiso crítico del sistema
        -- (Opcional: agregar validación de permisos que NO se pueden eliminar)
        IF @Modulo IN ('SISTEMA', 'AUDITORIA') AND @Accion IN ('ADMINISTRAR', 'ACCESO_TOTAL')
        BEGIN
            RAISERROR('No se puede eliminar un permiso crítico del sistema', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                PER_Id AS IdPermiso,
                PER_Nombre AS Nombre,
                PER_Modulo AS Modulo,
                PER_Accion AS Accion,
                PER_Activo AS Activo
            FROM ZI_GENERAL.ZI_PERMISOS
            WHERE PER_Id = @IdPermiso
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Marcar como inactivo (eliminación lógica)
        UPDATE ZI_GENERAL.ZI_PERMISOS SET
            PER_Estado = 0,
            PER_Activo = 0,
            PER_FechaModificacion = GETDATE(),
            PER_UsuarioModificacion = @UsuarioEliminacion,
            PER_IpModificacion = @IpEliminacion
        WHERE PER_Id = @IdPermiso;

        SET @FilasAfectadas = @@ROWCOUNT;

        -- Eliminar relaciones con roles (opcional: mantener registro histórico)
        DELETE FROM ZI_GENERAL.ZI_PERMISOSROLES
        WHERE PRO_PermisoId = @IdPermiso;

        -- Capturar valores nuevos
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdPermiso AS IdPermiso,
                @NombrePermiso AS Nombre,
                @Modulo AS Modulo,
                @Accion AS Accion,
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
            'PERMISOS',
            @IdPermiso,
            'Permiso eliminado: ' + @NombrePermiso + ' (' + @Modulo + ' - ' + @Accion + ', ID: ' + CAST(@IdPermiso AS NVARCHAR(10)) + ')',
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

PRINT 'Stored Procedures de Gestión de PERMISOS creados exitosamente';
GO
