-- ============================================
-- SCRIPT DE DIAGNÓSTICO PARA PERMISOS
-- ============================================

USE PortalMilesimo;
GO

-- ============================================
-- 1. VERIFICAR SI EXISTEN DATOS EN LA TABLA
-- ============================================
SELECT COUNT(*) AS TotalPermisos
FROM ZI_GENERAL.ZI_PERMISOS;

SELECT TOP 10 *
FROM ZI_GENERAL.ZI_PERMISOS
ORDER BY PER_Id DESC;

-- ============================================
-- 2. VERIFICAR SI EL SP EXISTE
-- ============================================
SELECT 
    name AS NombreProcedimiento,
    create_date AS FechaCreacion,
    modify_date AS FechaModificacion
FROM sys.procedures
WHERE name LIKE '%PERMISOS%'
ORDER BY name;

-- ============================================
-- 3. PROBAR EL SP MANUALMENTE CON LOS MISMOS PARÁMETROS
-- ============================================
DECLARE @TotalRegistros INT;

EXEC [ZI_GENERAL].[SP_PERMISOS_LISTAR_PAGINADO]
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = NULL,
    @IncluirInactivos = 0,
    @Modulo = NULL,
    @TotalRegistros = @TotalRegistros OUTPUT;

PRINT 'Total de registros: ' + CAST(@TotalRegistros AS VARCHAR(10));

-- ============================================
-- 4. VERIFICAR ESTRUCTURA DEL SP
-- ============================================
SELECT OBJECT_DEFINITION(OBJECT_ID('[ZI_GENERAL].[SP_PERMISOS_LISTAR_PAGINADO]')) AS DefinicionProcedimiento;

-- ============================================
-- 5. SI EL SP NO EXISTE, CREARLO
-- ============================================
IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SP_PERMISOS_LISTAR_PAGINADO' AND schema_id = SCHEMA_ID('ZI_GENERAL'))
BEGIN
    PRINT 'ADVERTENCIA: El stored procedure SP_PERMISOS_LISTAR_PAGINADO no existe';
    PRINT 'Se creará el procedimiento...';

    EXEC('
    CREATE OR ALTER PROCEDURE [ZI_GENERAL].[SP_PERMISOS_LISTAR_PAGINADO]
        @PageNumber INT = 1,
        @PageSize INT = 10,
        @SearchTerm NVARCHAR(100) = NULL,
        @IncluirInactivos BIT = 0,
        @Modulo NVARCHAR(100) = NULL,
        @TotalRegistros INT OUTPUT
    AS
    BEGIN
        SET NOCOUNT ON;

        -- Calcular total de registros
        SELECT @TotalRegistros = COUNT(*)
        FROM ZI_GENERAL.ZI_PERMISOS p
        WHERE 
            (@IncluirInactivos = 1 OR p.PER_Activo = 1)
            AND (@SearchTerm IS NULL OR p.PER_Nombre LIKE ''%'' + @SearchTerm + ''%'' 
                OR p.PER_Descripcion LIKE ''%'' + @SearchTerm + ''%''
                OR p.PER_Modulo LIKE ''%'' + @SearchTerm + ''%''
                OR p.PER_Accion LIKE ''%'' + @SearchTerm + ''%'')
            AND (@Modulo IS NULL OR p.PER_Modulo = @Modulo);

        -- Obtener registros paginados
        SELECT 
            p.PER_Id AS IdPermiso,
            p.PER_Nombre AS Nombre,
            p.PER_Descripcion AS Descripcion,
            p.PER_Modulo AS Modulo,
            p.PER_Accion AS Accion,
            p.PER_Activo AS Activo,
            -- Contar roles que tienen este permiso
            (SELECT COUNT(DISTINCT rp.RP_RolId)
             FROM ZI_GENERAL.ZI_ROLESPERMISOS rp
             WHERE rp.RP_PermId = p.PER_Id AND rp.RP_Activo = 1) AS TotalRoles,
            -- Campos de auditoría
            p.PER_FechaCreacion AS FechaCreacion,
            p.PER_UsuarioCreacion AS UsuarioCreacion,
            p.PER_FechaModificacion AS FechaModificacion,
            p.PER_UsuarioModificacion AS UsuarioModificacion
        FROM ZI_GENERAL.ZI_PERMISOS p
        WHERE 
            (@IncluirInactivos = 1 OR p.PER_Activo = 1)
            AND (@SearchTerm IS NULL OR p.PER_Nombre LIKE ''%'' + @SearchTerm + ''%'' 
                OR p.PER_Descripcion LIKE ''%'' + @SearchTerm + ''%''
                OR p.PER_Modulo LIKE ''%'' + @SearchTerm + ''%''
                OR p.PER_Accion LIKE ''%'' + @SearchTerm + ''%'')
            AND (@Modulo IS NULL OR p.PER_Modulo = @Modulo)
        ORDER BY p.PER_Modulo, p.PER_Accion, p.PER_Nombre
        OFFSET ((@PageNumber - 1) * @PageSize) ROWS
        FETCH NEXT @PageSize ROWS ONLY;
    END
    ');

    PRINT 'Stored procedure creado exitosamente';
END
ELSE
BEGIN
    PRINT 'El stored procedure SP_PERMISOS_LISTAR_PAGINADO ya existe';
END;

-- ============================================
-- 6. VERIFICAR OTROS SPS NECESARIOS
-- ============================================
PRINT '';
PRINT '=== VERIFICACIÓN DE STORED PROCEDURES NECESARIOS ===';

IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SP_PERMISOS_OBTENER_POR_ID' AND schema_id = SCHEMA_ID('ZI_GENERAL'))
    PRINT '? FALTA: SP_PERMISOS_OBTENER_POR_ID';
ELSE
    PRINT '? EXISTE: SP_PERMISOS_OBTENER_POR_ID';

IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SP_PERMISOS_CREAR' AND schema_id = SCHEMA_ID('ZI_GENERAL'))
    PRINT '? FALTA: SP_PERMISOS_CREAR';
ELSE
    PRINT '? EXISTE: SP_PERMISOS_CREAR';

IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SP_PERMISOS_ACTUALIZAR' AND schema_id = SCHEMA_ID('ZI_GENERAL'))
    PRINT '? FALTA: SP_PERMISOS_ACTUALIZAR';
ELSE
    PRINT '? EXISTE: SP_PERMISOS_ACTUALIZAR';

IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SP_PERMISOS_ELIMINAR' AND schema_id = SCHEMA_ID('ZI_GENERAL'))
    PRINT '? FALTA: SP_PERMISOS_ELIMINAR';
ELSE
    PRINT '? EXISTE: SP_PERMISOS_ELIMINAR';

-- ============================================
-- 7. INSERTAR PERMISOS DE PRUEBA SI NO EXISTEN
-- ============================================
IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Modulo = 'PERMISOS')
BEGIN
    PRINT '';
    PRINT '=== INSERTANDO PERMISOS DE PRUEBA ===';

    INSERT INTO ZI_GENERAL.ZI_PERMISOS (
        PER_Nombre, PER_Descripcion, PER_Modulo, PER_Accion, PER_Activo,
        PER_UsuarioCreacion, PER_IpCreacion
    )
    VALUES
        ('Ver Permisos', 'Permite ver la lista de permisos del sistema', 'PERMISOS', 'LEER', 1, 'SYSTEM', '127.0.0.1'),
        ('Crear Permisos', 'Permite crear nuevos permisos', 'PERMISOS', 'CREAR', 1, 'SYSTEM', '127.0.0.1'),
        ('Editar Permisos', 'Permite modificar permisos existentes', 'PERMISOS', 'ACTUALIZAR', 1, 'SYSTEM', '127.0.0.1'),
        ('Eliminar Permisos', 'Permite eliminar permisos del sistema', 'PERMISOS', 'ELIMINAR', 1, 'SYSTEM', '127.0.0.1'),
        ('Ver Roles', 'Permite ver la lista de roles', 'ROLES', 'LEER', 1, 'SYSTEM', '127.0.0.1'),
        ('Crear Roles', 'Permite crear nuevos roles', 'ROLES', 'CREAR', 1, 'SYSTEM', '127.0.0.1'),
        ('Ver Usuarios', 'Permite ver la lista de usuarios', 'USUARIOS', 'LEER', 1, 'SYSTEM', '127.0.0.1'),
        ('Crear Usuarios', 'Permite crear nuevos usuarios', 'USUARIOS', 'CREAR', 1, 'SYSTEM', '127.0.0.1');

    PRINT 'Permisos de prueba insertados';
END
ELSE
BEGIN
    PRINT 'Ya existen permisos en el sistema';
END;

-- ============================================
-- 8. VERIFICACIÓN FINAL
-- ============================================
PRINT '';
PRINT '=== VERIFICACIÓN FINAL ===';
SELECT 
    'Total de permisos: ' + CAST(COUNT(*) AS VARCHAR(10)) AS Resumen
FROM ZI_GENERAL.ZI_PERMISOS;

SELECT 
    'Permisos activos: ' + CAST(COUNT(*) AS VARCHAR(10)) AS Resumen
FROM ZI_GENERAL.ZI_PERMISOS
WHERE PER_Activo = 1;

-- ============================================
-- 9. PROBAR NUEVAMENTE EL SP DESPUÉS DE LAS CORRECCIONES
-- ============================================
PRINT '';
PRINT '=== PRUEBA FINAL DEL SP ===';

DECLARE @TotalRegistrosFinal INT;

EXEC [ZI_GENERAL].[SP_PERMISOS_LISTAR_PAGINADO]
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = NULL,
    @IncluirInactivos = 0,
    @Modulo = NULL,
    @TotalRegistros = @TotalRegistrosFinal OUTPUT;

PRINT 'Total de registros devueltos: ' + CAST(@TotalRegistrosFinal AS VARCHAR(10));

