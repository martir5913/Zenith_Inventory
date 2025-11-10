# Guía de Integración - Módulo de Usuarios

## ?? Pasos para Activar el Módulo

### 1. Verificar Estructura de Archivos

Asegúrate de que todos estos archivos existan:

```
? Zenith_Inventory\Views\Usuarios\Index.cshtml
? Zenith_Inventory\Content\css\Usuarios\usuarios.css
? Zenith_Inventory\Scripts\Usuarios\usuarios.js
? Zenith_Inventory\Controllers\Usuarios\UsuariosController.cs
? Zenith_Inventory\Documentation\API_Usuarios_Endpoints.md
? Zenith_Inventory\Documentation\Frontend_Usuarios_Implementacion.md
```

---

### 2. Agregar SweetAlert2 al Layout

**Archivo:** `Zenith_Inventory\Views\Shared\_Layout.cshtml`

Agregar antes del cierre de `</head>`:

```html
<!-- SweetAlert2 -->
<link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
```

Agregar antes del cierre de `</body>`:

```html
<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
```

---

### 3. Configurar BundleConfig (Opcional)

**Archivo:** `Zenith_Inventory\App_Start\BundleConfig.cs`

Agregar los bundles para usuarios:

```csharp
// CSS Bundle para Usuarios
bundles.Add(new StyleBundle("~/Content/usuarios/css").Include(
    "~/Content/css/Usuarios/usuarios.css"
));

// JS Bundle para Usuarios
bundles.Add(new ScriptBundle("~/bundles/usuarios/js").Include(
    "~/Scripts/Usuarios/usuarios.js"
));
```

Si usas bundles, actualiza la vista `Index.cshtml`:

```razor
@section Styles {
    @Styles.Render("~/Content/usuarios/css")
}

@section Scripts {
    @Scripts.Render("~/bundles/usuarios/js")
}
```

---

### 4. Agregar Ruta (Si es necesario)

**Archivo:** `Zenith_Inventory\App_Start\RouteConfig.cs`

```csharp
routes.MapRoute(
    name: "Usuarios",
    url: "Usuarios/{action}/{id}",
    defaults: new { controller = "Usuarios", action = "Index", id = UrlParameter.Optional }
);
```

---

### 5. Agregar al Menú del Sidebar

**Archivo:** `Zenith_Inventory\Views\Shared\_Layout.cshtml`

Localizar la sección del sidebar y agregar:

```html
<li class="nav-item">
    <a href="#" class="nav-link" data-bs-toggle="collapse" data-bs-target="#usuariosSubmenu" aria-expanded="false">
        <i class="fas fa-users-cog"></i>
        <span class="nav-text">Administración</span>
        <i class="fas fa-chevron-down arrow-icon"></i>
    </a>
    <ul class="collapse submenu" id="usuariosSubmenu">
        <li>
            <a href="@Url.Action("Index", "Usuarios")" class="submenu-link">
                <span>Usuarios</span>
            </a>
        </li>
        <li>
            <a href="@Url.Action("Roles", "Usuarios")" class="submenu-link">
                <span>Roles y Permisos</span>
            </a>
        </li>
    </ul>
</li>
```

---

### 6. Verificar Permisos en Base de Datos

Ejecutar en SQL Server para crear los permisos necesarios:

```sql
-- Insertar módulo de usuarios si no existe
IF NOT EXISTS (SELECT 1 FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Modulo = 'USUARIOS')
BEGIN
    -- Leer usuarios
    INSERT INTO ZI_GENERAL.ZI_PERMISOS (PER_Id, PER_Nombre, PER_Descripcion, PER_Modulo, PER_Accion, PER_Activo)
    VALUES (NEXT VALUE FOR ZI_GENERAL.Seq_Permisos, 'Ver Usuarios', 'Permite visualizar usuarios', 'USUARIOS', 'LEER', 1);

    -- Crear usuarios
    INSERT INTO ZI_GENERAL.ZI_PERMISOS (PER_Id, PER_Nombre, PER_Descripcion, PER_Modulo, PER_Accion, PER_Activo)
    VALUES (NEXT VALUE FOR ZI_GENERAL.Seq_Permisos, 'Crear Usuarios', 'Permite crear nuevos usuarios', 'USUARIOS', 'CREAR', 1);

    -- Actualizar usuarios
    INSERT INTO ZI_GENERAL.ZI_PERMISOS (PER_Id, PER_Nombre, PER_Descripcion, PER_Modulo, PER_Accion, PER_Activo)
    VALUES (NEXT VALUE FOR ZI_GENERAL.Seq_Permisos, 'Actualizar Usuarios', 'Permite actualizar usuarios existentes', 'USUARIOS', 'ACTUALIZAR', 1);

    -- Eliminar usuarios
    INSERT INTO ZI_GENERAL.ZI_PERMISOS (PER_Id, PER_Nombre, PER_Descripcion, PER_Modulo, PER_Accion, PER_Activo)
    VALUES (NEXT VALUE FOR ZI_GENERAL.Seq_Permisos, 'Eliminar Usuarios', 'Permite eliminar usuarios', 'USUARIOS', 'ELIMINAR', 1);
END
GO

-- Asignar permisos al rol de Administrador
DECLARE @AdminRolId INT = (SELECT ROL_Id FROM ZI_GENERAL.ZI_ROLES WHERE ROL_Nombre = 'Administrador');

INSERT INTO ZI_GENERAL.ZI_PERMISOSROLES (PRO_Id, PRO_RolId, PRO_PermisoId)
SELECT 
    NEXT VALUE FOR ZI_GENERAL.Seq_PermisosRoles,
    @AdminRolId,
    PER_Id
FROM ZI_GENERAL.ZI_PERMISOS
WHERE PER_Modulo = 'USUARIOS'
AND NOT EXISTS (
    SELECT 1 FROM ZI_GENERAL.ZI_PERMISOSROLES 
    WHERE PRO_RolId = @AdminRolId AND PRO_PermisoId = PER_Id
);
GO
```

---

### 7. Testing Paso a Paso

#### Test 1: Acceso a la Vista
1. Compilar el proyecto
2. Ejecutar la aplicación
3. Iniciar sesión
4. Navegar a `/Usuarios` o hacer clic en el menú
5. **Resultado esperado:** Se carga la vista sin errores

#### Test 2: Listar Usuarios
1. La tabla debe mostrar usuarios existentes
2. Probar búsqueda escribiendo un nombre
3. Probar filtros (Activos, Bloqueados, etc.)
4. **Resultado esperado:** La tabla se actualiza correctamente

#### Test 3: Crear Usuario
1. Clic en "Nuevo Usuario"
2. Llenar formulario completo
3. Seleccionar roles
4. Clic en "Guardar Usuario"
5. **Resultado esperado:** Usuario creado, tabla actualizada

#### Test 4: Ver Detalle
1. Clic en botón de "ojo" en cualquier usuario
2. **Resultado esperado:** Modal con información completa

#### Test 5: Editar Usuario
1. Clic en botón de "editar"
2. Modificar datos
3. Guardar cambios
4. **Resultado esperado:** Usuario actualizado

#### Test 6: Resetear Contraseña
1. Clic en botón de "llave"
2. Confirmar reseteo
3. **Resultado esperado:** Nueva contraseña mostrada

#### Test 7: Eliminar Usuario
1. Clic en botón de "basura"
2. Confirmar eliminación
3. **Resultado esperado:** Usuario desactivado

---

### 8. Solución de Problemas Comunes

#### Error 404 al navegar a /Usuarios
**Causa:** Controlador no encontrado o ruta mal configurada
**Solución:**
```csharp
// Verificar que el controlador esté en el namespace correcto
namespace Zenith_Inventory.Controllers.Usuarios

// Verificar que herede de BaseController
public class UsuariosController : BaseController
```

#### Modales no se abren
**Causa:** Bootstrap JS no cargado o versión incompatible
**Solución:**
```html
<!-- Verificar en _Layout.cshtml -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
```

#### SweetAlert2 no funciona
**Causa:** Librería no cargada
**Solución:**
```html
<!-- Agregar en _Layout.cshtml -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
```

#### Estilos no se aplican
**Causa:** CSS no cargado o ruta incorrecta
**Solución:**
```html
<!-- Verificar en Index.cshtml -->
@section Styles {
    <link href="~/Content/css/Usuarios/usuarios.css" rel="stylesheet" />
}
```

#### AJAX devuelve 401 Unauthorized
**Causa:** Usuario no autenticado o sesión expirada
**Solución:**
- Verificar que [AuthenticationFilter] esté aplicado
- Verificar que el usuario tenga los permisos correctos

#### No se cargan los roles
**Causa:** Endpoint GetRolesDisponibles falla
**Solución:**
```javascript
// Verificar en la consola del navegador (F12)
// Debería ver: GET /Usuarios/GetRolesDisponibles
// Si falla, revisar el método en el controlador
```

---

### 9. Validación Final

Completar esta checklist antes de dar por terminada la integración:

- [ ] ? La vista carga sin errores
- [ ] ? Se muestran usuarios existentes
- [ ] ? La búsqueda funciona correctamente
- [ ] ? Los filtros funcionan
- [ ] ? Se puede crear un usuario
- [ ] ? Se puede editar un usuario
- [ ] ? Se puede ver detalle de usuario
- [ ] ? Se puede eliminar un usuario
- [ ] ? Se puede resetear contraseña
- [ ] ? Se puede desbloquear usuario
- [ ] ? Los roles se asignan correctamente
- [ ] ? Las validaciones funcionan
- [ ] ? Los mensajes de error son claros
- [ ] ? Los mensajes de éxito aparecen
- [ ] ? La paginación funciona
- [ ] ? El diseño es responsive
- [ ] ? Los permisos se respetan
- [ ] ? La auditoría se registra

---

### 10. Configuración de Seguridad

#### Aplicar en Web.config (Si es necesario)

```xml
<system.web>
    <!-- Otros settings -->
    <sessionState timeout="60" />
    <authentication mode="Forms">
        <forms loginUrl="~/Account/Login" timeout="60" />
    </authentication>
</system.web>
```

#### Verificar Filtros de Seguridad

**AuthenticationFilter.cs:**
```csharp
// Verificar que redirija correctamente si no está autenticado
if (!estaAutenticado)
{
    filterContext.Result = new RedirectResult("~/Account/Login");
}
```

**PermissionFilter.cs:**
```csharp
// Verificar que valide permisos correctamente
if (!tienePermiso)
{
    filterContext.Result = new JsonResult
    {
        Data = new { success = false, accessDenied = true },
        JsonRequestBehavior = JsonRequestBehavior.AllowGet
    };
}
```

---

### 11. Performance y Optimización

#### Habilitar Caché para Roles
```csharp
// En CN_UsuarioGestion.cs
private static List<CE_RolListDTO> _rolesCache;
private static DateTime _cacheExpiration;

public List<CE_RolListDTO> ObtenerRolesActivos()
{
    if (_rolesCache == null || DateTime.Now > _cacheExpiration)
    {
        _rolesCache = _cdUsuarioGestion.ObtenerRolesPaginados(1, 100, null, false).Items.ToList();
        _cacheExpiration = DateTime.Now.AddMinutes(10);
    }
    return _rolesCache;
}
```

#### Minificar CSS y JS en Producción
```csharp
// En BundleConfig.cs
#if !DEBUG
    BundleTable.EnableOptimizations = true;
#endif
```

---

### 12. Monitoreo y Logs

#### Agregar Logging
```csharp
// En UsuariosController.cs
private static readonly log4net.ILog log = log4net.LogManager.GetLogger(typeof(UsuariosController));

[HttpPost]
public JsonResult CreateUsuario(CE_UsuarioCreateDTO usuario)
{
    try
    {
        log.Info($"Creando usuario: {usuario.Username}");
        // ... código existente
    }
    catch (Exception ex)
    {
        log.Error($"Error al crear usuario: {usuario.Username}", ex);
        return JsonError("Error al crear usuario", ex.Message);
    }
}
```

---

## ?? ¡Listo!

Tu módulo de gestión de usuarios está completamente implementado y listo para usar.

### Próximas Mejoras Sugeridas:

1. **Exportar a Excel**
   - Agregar botón para exportar lista de usuarios

2. **Importar Usuarios**
   - Carga masiva desde Excel/CSV

3. **Historial de Cambios**
   - Ver auditoría completa de cada usuario

4. **Gráficas y Reportes**
   - Dashboard de usuarios activos
   - Estadísticas de uso

5. **Notificaciones**
   - Email al crear usuario
   - Email al resetear contraseña

---

¿Necesitas ayuda con alguno de estos pasos?
