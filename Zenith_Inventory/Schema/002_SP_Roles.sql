USE [DB_Zenith_Inventory]
GO

-- =============================================
-- Stored Procedures para GESTIÓN DE ROLES
-- Patrón: Similar a Categorías/Permisos
-- Incluye: Auditoría, Validaciones, JSON
-- =============================================

-- =============================================
-- SP para CREAR un nuevo rol
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_ROLES_CREAR]
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(255) = NULL,
    @Activo BIT = 1,
    @UsuarioCreacion NVARCHAR(100),
    @IpCreacion NVARCHAR(45),
    @IdRol INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista un rol con el mismo nombre
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_ROLES 
                   WHERE ROL_Nombre = @Nombre 
                   AND ROL_Activo = 1)
        BEGIN
            RAISERROR('Ya existe un rol con ese nombre', 16, 1);
            RETURN;
        END

        -- Generar nuevo ID usando la secuencia
        SELECT @IdRol = NEXT VALUE FOR ZI_GENERAL.Seq_Roles;

        -- Insertar nuevo rol
        INSERT INTO ZI_GENERAL.ZI_ROLES (
            ROL_Id,
            ROL_Nombre,
            ROL_Descripcion,
            ROL_Activo,
            ROL_FechaCreacion,
            ROL_UsuarioCreacion,
            ROL_IpCreacion
        ) VALUES (
            @IdRol,
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
                @IdRol AS IdRol,
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
            'ROLES',
            @IdRol,
            'Rol creado: ' + @Nombre,
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
-- SP para ACTUALIZAR un rol
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_ROLES_ACTUALIZAR]
    @IdRol INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(255) = NULL,
    @Activo BIT,
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el rol existe
        IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_ROLES WHERE ROL_Id = @IdRol)
        BEGIN
            RAISERROR('El rol no existe', 16, 1);
            RETURN;
        END

        -- Validar que no exista otro rol con el mismo nombre
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_ROLES
                   WHERE ROL_Nombre = @Nombre 
                   AND ROL_Id <> @IdRol 
                   AND ROL_Activo = 1)
        BEGIN
            RAISERROR('Ya existe otro rol con ese nombre', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores en formato JSON
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                ROL_Id AS IdRol,
                ROL_Nombre AS Nombre,
                ROL_Descripcion AS Descripcion,
                ROL_Activo AS Activo
            FROM ZI_GENERAL.ZI_ROLES
            WHERE ROL_Id = @IdRol
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Actualizar rol
        UPDATE ZI_GENERAL.ZI_ROLES SET
            ROL_Nombre = @Nombre,
            ROL_Descripcion = @Descripcion,
            ROL_Activo = @Activo,
            ROL_FechaModificacion = GETDATE(),
            ROL_UsuarioModificacion = @UsuarioModificacion,
            ROL_IpModificacion = @IpModificacion
        WHERE ROL_Id = @IdRol;

        -- Capturar número de filas afectadas
        SET @FilasAfectadas = @@ROWCOUNT;

        -- Capturar valores nuevos en formato JSON
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdRol AS IdRol,
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
            'ROLES',
            @IdRol,
            'Rol actualizado: ' + @Nombre + ' (ID: ' + CAST(@IdRol AS NVARCHAR(10)) + ')',
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
-- SP para ELIMINAR un rol (eliminación lógica)
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_ROLES_ELIMINAR]
    @IdRol INT,
    @UsuarioEliminacion NVARCHAR(100),
    @IpEliminacion NVARCHAR(45),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el rol existe
        DECLARE @NombreRol NVARCHAR(50);
        SELECT @NombreRol = ROL_Nombre
        FROM ZI_GENERAL.ZI_ROLES
        WHERE ROL_Id = @IdRol;

        IF @NombreRol IS NULL
        BEGIN
            RAISERROR('El rol no existe', 16, 1);
            RETURN;
        END

        -- Validar que no tenga usuarios activos asignados
        IF EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_USUARIOSROLES
                   WHERE UR_RolId = @IdRol AND UR_Activo = 1)
        BEGIN
            RAISERROR('No se puede eliminar un rol que tiene usuarios asignados', 16, 1);
            RETURN;
        END

        -- Capturar valores anteriores
        DECLARE @ValoresAntiguos NVARCHAR(MAX) = (
            SELECT 
                ROL_Id AS IdRol,
                ROL_Nombre AS Nombre,
                ROL_Descripcion AS Descripcion,
                ROL_Activo AS Activo,
                (SELECT COUNT(*) FROM ZI_GENERAL.ZI_PERMISOSROLES WHERE PRO_RolId = ROL_Id) AS TotalPermisos
            FROM ZI_GENERAL.ZI_ROLES
            WHERE ROL_Id = @IdRol
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        -- Marcar como inactivo (eliminación lógica)
        UPDATE ZI_GENERAL.ZI_ROLES SET
            ROL_Activo = 0,
            ROL_FechaModificacion = GETDATE(),
            ROL_UsuarioModificacion = @UsuarioEliminacion,
            ROL_IpModificacion = @IpEliminacion
        WHERE ROL_Id = @IdRol;

        -- Capturar número de filas afectadas
        SET @FilasAfectadas = @@ROWCOUNT;

        -- Desactivar asignaciones de permisos (opcional, dependiendo de la lógica de negocio)
        -- UPDATE ZI_GENERAL.ZI_PERMISOSROLES SET ... WHERE PRO_RolId = @IdRol;

        -- Capturar valores nuevos
        DECLARE @ValoresNuevos NVARCHAR(MAX) = (
            SELECT 
                @IdRol AS IdRol,
                @NombreRol AS Nombre,
                (SELECT ROL_Descripcion FROM ZI_GENERAL.ZI_ROLES WHERE ROL_Id = @IdRol) AS Descripcion,
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
            'ROLES',
            @IdRol,
            'Rol eliminado: ' + @NombreRol + ' (ID: ' + CAST(@IdRol AS NVARCHAR(10)) + ')',
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
-- SP para LISTAR roles con paginación
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_ROLES_LISTAR_PAGINADO]
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
        FROM ZI_GENERAL.ZI_ROLES
        WHERE 
            (@IncluirInactivos = 1 OR ROL_Activo = 1)
            AND (@SearchTerm IS NULL OR 
                 ROL_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 ROL_Descripcion LIKE '%' + @SearchTerm + '%');
        
        -- Obtener registros paginados con información de auditoría
        SELECT 
            ROL_Id AS IdRol,
            ROL_Nombre AS Nombre,
            ROL_Descripcion AS Descripcion,
            ROL_Activo AS Activo,
            ROL_FechaCreacion AS FechaCreacion,
            ROL_UsuarioCreacion AS UsuarioCreacion,
            ROL_FechaModificacion AS FechaModificacion,
            ROL_UsuarioModificacion AS UsuarioModificacion,
            -- Información adicional útil
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_PERMISOSROLES 
             WHERE PRO_RolId = ROL_Id) AS TotalPermisos,
            (SELECT COUNT(*) 
             FROM ZI_GENERAL.ZI_USUARIOSROLES 
             WHERE UR_RolId = ROL_Id AND UR_Activo = 1) AS TotalUsuarios
        FROM ZI_GENERAL.ZI_ROLES
        WHERE 
            (@IncluirInactivos = 1 OR ROL_Activo = 1)
            AND (@SearchTerm IS NULL OR 
                 ROL_Nombre LIKE '%' + @SearchTerm + '%' OR 
                 ROL_Descripcion LIKE '%' + @SearchTerm + '%')
        ORDER BY ROL_Nombre ASC
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
-- SP para OBTENER rol por ID con detalles
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_ROLES_OBTENER_POR_ID]
    @IdRol INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Información básica del rol
        SELECT
            ROL_Id AS IdRol,
            ROL_Nombre AS Nombre,
            ROL_Descripcion AS Descripcion,
            ROL_Activo AS Activo,
            ROL_FechaCreacion AS FechaCreacion,
            ROL_UsuarioCreacion AS UsuarioCreacion,
            ROL_FechaModificacion AS FechaModificacion,
            ROL_UsuarioModificacion AS UsuarioModificacion,
            -- Información adicional útil
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_PERMISOSROLES
             WHERE PRO_RolId = ROL_Id) AS TotalPermisos,
            (SELECT COUNT(*)
             FROM ZI_GENERAL.ZI_USUARIOSROLES
             WHERE UR_RolId = ROL_Id AND UR_Activo = 1) AS TotalUsuarios
        FROM ZI_GENERAL.ZI_ROLES
        WHERE ROL_Id = @IdRol AND ROL_Activo = 1;

        -- Lista de permisos asignados al rol
        SELECT 
            P.PER_Id AS IdPermiso,
            P.PER_Nombre AS Nombre,
            P.PER_Descripcion AS Descripcion,
            P.PER_Modulo AS Modulo,
            P.PER_Accion AS Accion,
            P.PER_Activo AS Activo
        FROM ZI_GENERAL.ZI_PERMISOS P
        INNER JOIN ZI_GENERAL.ZI_PERMISOSROLES PR ON P.PER_Id = PR.PRO_PermisoId
        WHERE PR.PRO_RolId = @IdRol
        AND P.PER_Activo = 1
        ORDER BY P.PER_Nombre;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP para ASIGNAR PERMISOS a un rol
-- =============================================
CREATE PROCEDURE [ZI_GENERAL].[SP_ROLES_ASIGNAR_PERMISOS]
    @IdRol INT,
    @PermisosIds NVARCHAR(MAX), -- Lista de IDs separados por comas: "1,2,3"
    @UsuarioModificacion NVARCHAR(100),
    @IpModificacion NVARCHAR(45)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el rol existe
        DECLARE @NombreRol NVARCHAR(50);
        SELECT @NombreRol = ROL_Nombre
        FROM ZI_GENERAL.ZI_ROLES
        WHERE ROL_Id = @IdRol AND ROL_Activo = 1;

        IF @NombreRol IS NULL
        BEGIN
            RAISERROR('El rol no existe o está inactivo', 16, 1);
            RETURN;
        END

        -- Capturar permisos actuales
        DECLARE @PermisosAnteriores NVARCHAR(MAX);
        SELECT @PermisosAnteriores = STRING_AGG(CAST(PRO_PermisoId AS NVARCHAR(10)), ',')
        FROM ZI_GENERAL.ZI_PERMISOSROLES
        WHERE PRO_RolId = @IdRol;

        -- Eliminar asignaciones actuales
        DELETE FROM ZI_GENERAL.ZI_PERMISOSROLES
        WHERE PRO_RolId = @IdRol;

        -- Insertar nuevas asignaciones
        IF @PermisosIds IS NOT NULL AND LEN(@PermisosIds) > 0
        BEGIN
            INSERT INTO ZI_GENERAL.ZI_PERMISOSROLES (PRO_RolId, PRO_PermisoId)
            SELECT @IdRol, CAST(value AS INT)
            FROM STRING_SPLIT(@PermisosIds, ',')
            WHERE value <> '';
        END

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
            'ASIGNAR_PERMISOS',
            'ROLES',
            @IdRol,
            'Permisos asignados al rol: ' + @NombreRol,
            @PermisosAnteriores,
            @PermisosIds,
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
