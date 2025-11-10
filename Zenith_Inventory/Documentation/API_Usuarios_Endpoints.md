# API de Gestión de Usuarios - Documentación de Endpoints

## Información General

**Base URL**: `/Usuarios`  
**Autenticación**: Todos los endpoints requieren autenticación  
**Formato de Respuesta**: JSON

---

## Índice de Endpoints

1. [Operaciones CRUD](#operaciones-crud)
   - [Listar Usuarios](#get-usuarios)
   - [Obtener Detalle](#get-usuariodetalle)
   - [Crear Usuario](#post-createusuario)
   - [Actualizar Usuario](#post-updateusuario)
   - [Eliminar Usuario](#post-deleteusuario)

2. [Gestión de Contraseñas](#gestión-de-contraseñas)
   - [Resetear Contraseña (Auto)](#post-resetearpassword)
   - [Resetear Contraseña (Custom)](#post-resetearpasswordcustom)
   - [Desbloquear Usuario](#post-desbloquearusuario)
   - [Generar Contraseña Temporal](#get-generarpasswordtemporal)

3. [Gestión de Roles](#gestión-de-roles)
   - [Asignar Roles](#post-asignarroles)
   - [Obtener Roles Disponibles](#get-getrolesdisponibles)
   - [Obtener Roles Paginados](#get-getrolespaginados)
   - [Obtener Permisos de Rol](#get-getpermisosrol)

---

## Operaciones CRUD

### GET /Usuarios/GetUsuarios

Obtiene una lista paginada de usuarios con filtros opcionales.

**Permisos Requeridos**: `USUARIOS:LEER`

**Parámetros Query String**:

```javascript
{
  page: 1,              // Número de página (default: 1)
  pageSize: 10,         // Tamaño de página (default: 10)
  search: "juan",       // Término de búsqueda (opcional)
  incluirInactivos: false, // Incluir usuarios inactivos (default: false)
  soloBloqueados: false   // Solo usuarios bloqueados (default: false)
}
```

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Usuarios obtenidos exitosamente",
  "data": {
    "items": [
      {
        "idUsuario": 1,
        "codigo": 1001,
        "username": "jperez",
        "nombre": "Juan",
        "apellido": "Pérez",
        "nombreCompleto": "Juan Pérez",
        "correo": "jperez@empresa.com",
        "telefono": "22334455",
        "departamento": "IT",
        "puesto": "Desarrollador",
        "activo": true,
        "bloqueado": false,
        "estadoTexto": "Activo",
        "intentosFallidos": 0,
        "fechaBloqueo": null,
        "ultimoLogin": "15/01/2025 09:30",
        "requiereCambioPassword": false,
        "totalRoles": 2,
        "rolesAsignados": "Administrador, Usuario",
        "fechaCreacion": "01/01/2025 10:00",
        "usuarioCreacion": "admin"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "pageSize": 10,
      "totalRecords": 25,
      "totalPages": 3,
      "hasPreviousPage": false,
      "hasNextPage": true
    }
  }
}
```

**Ejemplo de Uso (JavaScript/jQuery)**:

```javascript
$.ajax({
    url: '/Usuarios/GetUsuarios',
    type: 'GET',
    data: {
        page: 1,
        pageSize: 10,
        search: 'juan'
    },
    success: function(response) {
        if (response.success) {
            console.log('Usuarios:', response.data.items);
            console.log('Total páginas:', response.data.pagination.totalPages);
        }
    }
});
```

---

### GET /Usuarios/GetUsuarioDetalle

Obtiene el detalle completo de un usuario incluyendo roles y permisos.

**Permisos Requeridos**: `USUARIOS:LEER`

**Parámetros Query String**:

```javascript
{
  id: 1  // ID del usuario (requerido)
}
```

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Detalles obtenidos exitosamente",
  "data": {
    "idUsuario": 1,
    "codigo": 1001,
    "username": "jperez",
    "nombre": "Juan",
    "apellido": "Pérez",
    "nombreCompleto": "Juan Pérez",
    "correo": "jperez@empresa.com",
    "telefono": "22334455",
    "departamento": "IT",
    "puesto": "Desarrollador",
    "activo": true,
    "bloqueado": false,
    "estadoTexto": "Activo",
    "intentosFallidos": 0,
    "fechaBloqueo": null,
    "ultimoLogin": "15/01/2025 09:30",
    "requiereCambioPassword": false,
    "roles": [
      {
        "idRol": 1,
        "nombre": "Administrador",
        "descripcion": "Acceso completo al sistema",
        "fechaAsignacion": "01/01/2025 10:00",
        "activo": true
      }
    ],
    "permisos": [
      {
        "idPermiso": 1,
        "nombre": "Ver Usuarios",
        "descripcion": "Permite ver usuarios",
        "modulo": "USUARIOS",
        "accion": "LEER"
      }
    ],
    "fechaCreacion": "01/01/2025 10:00",
    "usuarioCreacion": "admin",
    "fechaModificacion": "15/01/2025 09:30",
    "usuarioModificacion": "admin",
    "ipCreacion": "192.168.1.1",
    "ipModificacion": "192.168.1.1"
  }
}
```

**Ejemplo de Uso**:

```javascript
$.ajax({
    url: '/Usuarios/GetUsuarioDetalle',
    type: 'GET',
    data: { id: 1 },
    success: function(response) {
        if (response.success) {
            var usuario = response.data;
            console.log('Usuario:', usuario.nombreCompleto);
            console.log('Roles:', usuario.roles);
            console.log('Permisos:', usuario.permisos);
        }
    }
});
```

---

### POST /Usuarios/CreateUsuario

Crea un nuevo usuario en el sistema.

**Permisos Requeridos**: `USUARIOS:CREAR`

**Parámetros (Form Data o JSON)**:

```javascript
{
  Codigo: 1001,                    // Código único del usuario (requerido)
  Username: "jperez",              // Nombre de usuario (requerido, único)
  Password: "Pass123!",            // Contraseña (requerido, mínimo 6 caracteres)
  Nombre: "Juan",                  // Nombre (requerido)
  Apellido: "Pérez",              // Apellido (opcional)
  Correo: "jperez@empresa.com",   // Correo electrónico (requerido, único)
  Telefono: "22334455",           // Teléfono (opcional)
  Departamento: "IT",             // Departamento (opcional)
  Puesto: "Desarrollador",        // Puesto (opcional)
  Activo: true,                   // Estado activo (default: true)
  PasswordTemporal: true,         // Si es contraseña temporal (default: true)
  RolesIds: [1, 2]               // Array de IDs de roles (opcional)
}
```

**Validaciones**:
- Username: 3-100 caracteres, solo letras, números, puntos, guiones
- Password: Mínimo 6 caracteres, debe incluir mayúsculas, minúsculas y números
- Correo: Formato de email válido
- Código: Mayor a 0, único
- Username: Único
- Correo: Único

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Usuario creado exitosamente",
  "data": {
    "IdUsuario": 10
  }
}
```

**Respuesta de Error (400)**:

```json
{
  "success": false,
  "message": "Error de validación",
  "error": "Ya existe un usuario con ese nombre de usuario"
}
```

**Ejemplo de Uso**:

```javascript
var nuevoUsuario = {
    Codigo: 1001,
    Username: "jperez",
    Password: "Pass123!",
    Nombre: "Juan",
    Apellido: "Pérez",
    Correo: "jperez@empresa.com",
    Telefono: "22334455",
    Departamento: "IT",
    Puesto: "Desarrollador",
    Activo: true,
    PasswordTemporal: true,
    RolesIds: [1, 2]
};

$.ajax({
    url: '/Usuarios/CreateUsuario',
    type: 'POST',
    contentType: 'application/json',
    data: JSON.stringify(nuevoUsuario),
    success: function(response) {
        if (response.success) {
            alert('Usuario creado con ID: ' + response.data.IdUsuario);
        } else {
            alert('Error: ' + response.message);
        }
    }
});
```

---

### POST /Usuarios/UpdateUsuario

Actualiza la información de un usuario existente.

**Permisos Requeridos**: `USUARIOS:ACTUALIZAR`

**Parámetros (Form Data o JSON)**:

```javascript
{
  IdUsuario: 1,                   // ID del usuario (requerido)
  Nombre: "Juan Carlos",          // Nombre (requerido)
  Apellido: "Pérez García",      // Apellido (opcional)
  Correo: "juan.perez@empresa.com", // Correo (requerido, único)
  Telefono: "22334455",          // Teléfono (opcional)
  Departamento: "IT",            // Departamento (opcional)
  Puesto: "Desarrollador Senior", // Puesto (opcional)
  Activo: true                   // Estado activo
}
```

**Nota**: No se puede modificar Username, Password, ni Código mediante este endpoint.

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Usuario actualizado exitosamente",
  "data": null
}
```

**Ejemplo de Uso**:

```javascript
var usuarioActualizar = {
    IdUsuario: 1,
    Nombre: "Juan Carlos",
    Apellido: "Pérez García",
    Correo: "juan.perez@empresa.com",
    Telefono: "22334455",
    Departamento: "IT",
    Puesto: "Desarrollador Senior",
    Activo: true
};

$.ajax({
    url: '/Usuarios/UpdateUsuario',
    type: 'POST',
    contentType: 'application/json',
    data: JSON.stringify(usuarioActualizar),
    success: function(response) {
        if (response.success) {
            alert('Usuario actualizado correctamente');
        }
    }
});
```

---

### POST /Usuarios/DeleteUsuario

Elimina (desactiva) un usuario del sistema. La eliminación es lógica, no física.

**Permisos Requeridos**: `USUARIOS:ELIMINAR`

**Parámetros (Form Data)**:

```javascript
{
  id: 10  // ID del usuario a eliminar (requerido)
}
```

**Restricciones**:
- No se puede eliminar el usuario actualmente autenticado
- Al eliminar un usuario se desactivan automáticamente sus roles

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Usuario eliminado exitosamente",
  "data": null
}
```

**Respuesta de Error (400)**:

```json
{
  "success": false,
  "message": "No puede eliminar su propio usuario",
  "error": "Acción no permitida"
}
```

**Ejemplo de Uso**:

```javascript
if (confirm('¿Está seguro de eliminar este usuario?')) {
    $.ajax({
        url: '/Usuarios/DeleteUsuario',
        type: 'POST',
        data: { id: 10 },
        success: function(response) {
            if (response.success) {
                alert('Usuario eliminado correctamente');
                // Recargar la tabla de usuarios
                cargarUsuarios();
            }
        }
    });
}
```

---

## Gestión de Contraseñas

### POST /Usuarios/ResetearPassword

Resetea la contraseña de un usuario generando una contraseña temporal automática.

**Permisos Requeridos**: `USUARIOS:ACTUALIZAR`

**Parámetros (Form Data)**:

```javascript
{
  id: 10  // ID del usuario (requerido)
}
```

**Características**:
- Genera una contraseña aleatoria de 10 caracteres
- Cumple automáticamente con todos los requisitos de seguridad
- Marca el usuario para cambio obligatorio de contraseña en el siguiente login
- Desbloquea el usuario si estaba bloqueado
- Resetea intentos fallidos a 0

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Contraseña reseteada exitosamente",
  "data": {
    "passwordTemporal": "Xy9a2Bc!Df"
  }
}
```

**Ejemplo de Uso**:

```javascript
$.ajax({
    url: '/Usuarios/ResetearPassword',
    type: 'POST',
    data: { id: 10 },
    success: function(response) {
        if (response.success) {
            var password = response.data.passwordTemporal;
            alert('Nueva contraseña temporal: ' + password);
            // IMPORTANTE: Enviar esta contraseña al usuario de forma segura
            // No mostrar en pantalla sin protección
        }
    }
});
```

---

### POST /Usuarios/ResetearPasswordCustom

Resetea la contraseña de un usuario con una contraseña específica.

**Permisos Requeridos**: `USUARIOS:ACTUALIZAR`

**Parámetros (Form Data)**:

```javascript
{
  id: 10,                    // ID del usuario (requerido)
  nuevaPassword: "Pass123!"  // Nueva contraseña (requerido)
}
```

**Validaciones de Contraseña**:
- Mínimo 6 caracteres
- Al menos una letra mayúscula
- Al menos una letra minúscula
- Al menos un número

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Contraseña reseteada exitosamente",
  "data": null
}
```

**Ejemplo de Uso**:

```javascript
var nuevaPassword = prompt('Ingrese la nueva contraseña:');

$.ajax({
    url: '/Usuarios/ResetearPasswordCustom',
    type: 'POST',
    data: { 
        id: 10,
        nuevaPassword: nuevaPassword
    },
    success: function(response) {
        if (response.success) {
            alert('Contraseña actualizada correctamente');
        } else {
            alert('Error: ' + response.message);
        }
    }
});
```

---

### POST /Usuarios/DesbloquearUsuario

Desbloquea un usuario que ha sido bloqueado por múltiples intentos fallidos de login.

**Permisos Requeridos**: `USUARIOS:ACTUALIZAR`

**Parámetros (Form Data)**:

```javascript
{
  id: 10  // ID del usuario (requerido)
}
```

**Efectos**:
- Establece `Bloqueado = false`
- Resetea `IntentosFallidos = 0`
- Elimina `FechaBloqueo`

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Usuario desbloqueado exitosamente",
  "data": null
}
```

**Ejemplo de Uso**:

```javascript
$.ajax({
    url: '/Usuarios/DesbloquearUsuario',
    type: 'POST',
    data: { id: 10 },
    success: function(response) {
        if (response.success) {
            alert('Usuario desbloqueado correctamente');
            // Actualizar el estado en la interfaz
            actualizarEstadoUsuario(10, 'activo');
        }
    }
});
```

---

### GET /Usuarios/GenerarPasswordTemporal

Genera una contraseña temporal aleatoria sin asignarla a ningún usuario.

**Permisos Requeridos**: `USUARIOS:ACTUALIZAR`

**Sin Parámetros**

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Contraseña generada exitosamente",
  "data": {
    "passwordTemporal": "Xy9a2Bc!Df"
  }
}
```

**Ejemplo de Uso**:

```javascript
// Útil para pre-visualizar la contraseña antes de asignarla
$.ajax({
    url: '/Usuarios/GenerarPasswordTemporal',
    type: 'GET',
    success: function(response) {
        if (response.success) {
            $('#passwordField').val(response.data.passwordTemporal);
        }
    }
});
```

---

## Gestión de Roles

### POST /Usuarios/AsignarRoles

Asigna uno o más roles a un usuario.

**Permisos Requeridos**: `USUARIOS:ACTUALIZAR`

**Parámetros (Form Data)**:

```javascript
{
  idUsuario: 10,         // ID del usuario (requerido)
  rolesIds: [1, 2, 3]   // Array de IDs de roles (requerido, mínimo 1)
}
```

**Comportamiento**:
- Desactiva todos los roles actuales del usuario
- Activa los roles especificados
- Si un rol ya existía, lo reactiva
- Si un rol es nuevo, lo crea

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Roles asignados exitosamente",
  "data": null
}
```

**Ejemplo de Uso**:

```javascript
var rolesSeleccionados = [1, 2, 3]; // IDs de los checkboxes seleccionados

$.ajax({
    url: '/Usuarios/AsignarRoles',
    type: 'POST',
    data: { 
        idUsuario: 10,
        rolesIds: rolesSeleccionados
    },
    traditional: true, // Importante para arrays
    success: function(response) {
        if (response.success) {
            alert('Roles asignados correctamente');
        }
    }
});
```

---

### GET /Usuarios/GetRolesDisponibles

Obtiene todos los roles activos disponibles en el sistema.

**Permisos Requeridos**: `USUARIOS:LEER`

**Sin Parámetros**

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Roles obtenidos exitosamente",
  "data": {
    "items": [
      {
        "idRol": 1,
        "nombre": "Administrador",
        "descripcion": "Acceso completo al sistema",
        "activo": true,
        "totalUsuarios": 5,
        "totalPermisos": 25
      },
      {
        "idRol": 2,
        "nombre": "Usuario",
        "descripcion": "Usuario estándar",
        "activo": true,
        "totalUsuarios": 20,
        "totalPermisos": 10
      }
    ]
  }
}
```

**Ejemplo de Uso**:

```javascript
// Cargar roles en un select o checklist
$.ajax({
    url: '/Usuarios/GetRolesDisponibles',
    type: 'GET',
    success: function(response) {
        if (response.success) {
            var roles = response.data.items;
            var html = '';
            
            roles.forEach(function(rol) {
                html += '<div class="checkbox">';
                html += '  <label>';
                html += '    <input type="checkbox" value="' + rol.idRol + '">';
                html += '    ' + rol.nombre + ' - ' + rol.descripcion;
                html += '  </label>';
                html += '</div>';
            });
            
            $('#rolesContainer').html(html);
        }
    }
});
```

---

### GET /Usuarios/GetRolesPaginados

Obtiene roles con paginación.

**Permisos Requeridos**: `USUARIOS:LEER`

**Parámetros Query String**:

```javascript
{
  page: 1,              // Número de página (default: 1)
  pageSize: 10,         // Tamaño de página (default: 10)
  search: "admin",      // Término de búsqueda (opcional)
  incluirInactivos: false // Incluir roles inactivos (default: false)
}
```

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Roles obtenidos exitosamente",
  "data": {
    "items": [
      {
        "idRol": 1,
        "nombre": "Administrador",
        "descripcion": "Acceso completo",
        "activo": true,
        "totalUsuarios": 5,
        "totalPermisos": 25,
        "fechaCreacion": "01/01/2025 10:00",
        "usuarioCreacion": "admin"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "pageSize": 10,
      "totalRecords": 5,
      "totalPages": 1,
      "hasPreviousPage": false,
      "hasNextPage": false
    }
  }
}
```

---

### GET /Usuarios/GetPermisosRol

Obtiene todos los permisos asignados a un rol específico.

**Permisos Requeridos**: `USUARIOS:LEER`

**Parámetros Query String**:

```javascript
{
  idRol: 1  // ID del rol (requerido)
}
```

**Respuesta Exitosa (200)**:

```json
{
  "success": true,
  "message": "Permisos obtenidos exitosamente",
  "data": {
    "items": [
      {
        "idPermiso": 1,
        "nombre": "Ver Usuarios",
        "descripcion": "Permite visualizar usuarios",
        "modulo": "USUARIOS",
        "accion": "LEER"
      },
      {
        "idPermiso": 2,
        "nombre": "Crear Usuarios",
        "descripcion": "Permite crear nuevos usuarios",
        "modulo": "USUARIOS",
        "accion": "CREAR"
      }
    ]
  }
}
```

**Ejemplo de Uso**:

```javascript
$.ajax({
    url: '/Usuarios/GetPermisosRol',
    type: 'GET',
    data: { idRol: 1 },
    success: function(response) {
        if (response.success) {
            var permisos = response.data.items;
            console.log('Permisos del rol:', permisos);
            // Mostrar permisos en una tabla o lista
        }
    }
});
```

---

## Respuestas Estándar

### Formato de Respuesta Exitosa

```json
{
  "success": true,
  "message": "Descripción de la operación exitosa",
  "data": {
    // Datos específicos del endpoint
  }
}
```

### Formato de Respuesta de Error

```json
{
  "success": false,
  "message": "Descripción del error",
  "error": "Detalles adicionales del error"
}
```

### Respuesta de Acceso Denegado

```json
{
  "success": false,
  "accessDenied": true,
  "message": "No tiene permisos para realizar esta acción"
}
```

---

## Códigos de Estado HTTP

- **200 OK**: Operación exitosa
- **400 Bad Request**: Datos de entrada inválidos
- **401 Unauthorized**: No autenticado
- **403 Forbidden**: No tiene permisos
- **404 Not Found**: Recurso no encontrado
- **500 Internal Server Error**: Error del servidor

---

## Ejemplos Completos de Integración

### Ejemplo 1: Tabla de Usuarios con DataTables

```javascript
$(document).ready(function() {
    var table = $('#usuariosTable').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: '/Usuarios/GetUsuarios',
            type: 'GET',
            data: function(d) {
                return {
                    page: (d.start / d.length) + 1,
                    pageSize: d.length,
                    search: d.search.value
                };
            },
            dataSrc: function(json) {
                json.recordsTotal = json.data.pagination.totalRecords;
                json.recordsFiltered = json.data.pagination.totalRecords;
                return json.data.items;
            }
        },
        columns: [
            { data: 'username' },
            { data: 'nombreCompleto' },
            { data: 'correo' },
            { data: 'estadoTexto' },
            { data: 'rolesAsignados' },
            { 
                data: null,
                render: function(data, type, row) {
                    return `
                        <button class="btn btn-sm btn-primary" onclick="verDetalle(${row.idUsuario})">
                            <i class="fa fa-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-warning" onclick="editar(${row.idUsuario})">
                            <i class="fa fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" onclick="eliminar(${row.idUsuario})">
                            <i class="fa fa-trash"></i>
                        </button>
                    `;
                }
            }
        ]
    });
});
```

### Ejemplo 2: Formulario de Crear Usuario

```javascript
$('#formCrearUsuario').on('submit', function(e) {
    e.preventDefault();
    
    var usuario = {
        Codigo: parseInt($('#codigo').val()),
        Username: $('#username').val(),
        Password: $('#password').val(),
        Nombre: $('#nombre').val(),
        Apellido: $('#apellido').val(),
        Correo: $('#correo').val(),
        Telefono: $('#telefono').val(),
        Departamento: $('#departamento').val(),
        Puesto: $('#puesto').val(),
        Activo: $('#activo').is(':checked'),
        PasswordTemporal: $('#passwordTemporal').is(':checked'),
        RolesIds: []
    };
    
    // Obtener roles seleccionados
    $('input[name="roles"]:checked').each(function() {
        usuario.RolesIds.push(parseInt($(this).val()));
    });
    
    $.ajax({
        url: '/Usuarios/CreateUsuario',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(usuario),
        success: function(response) {
            if (response.success) {
                alert('Usuario creado exitosamente');
                $('#modalCrearUsuario').modal('hide');
                table.ajax.reload();
            } else {
                alert('Error: ' + response.message);
            }
        },
        error: function(xhr) {
            alert('Error al crear usuario');
        }
    });
});
```

### Ejemplo 3: Gestión de Roles de Usuario

```javascript
function abrirAsignarRoles(idUsuario) {
    // Cargar usuario actual
    $.ajax({
        url: '/Usuarios/GetUsuarioDetalle',
        type: 'GET',
        data: { id: idUsuario },
        success: function(response) {
            if (response.success) {
                var usuario = response.data;
                $('#modalTitulo').text('Asignar Roles a ' + usuario.nombreCompleto);
                
                // Cargar roles disponibles
                cargarRolesDisponibles(idUsuario, usuario.roles);
            }
        }
    });
}

function cargarRolesDisponibles(idUsuario, rolesActuales) {
    $.ajax({
        url: '/Usuarios/GetRolesDisponibles',
        type: 'GET',
        success: function(response) {
            if (response.success) {
                var html = '';
                var rolesActualesIds = rolesActuales.map(r => r.idRol);
                
                response.data.items.forEach(function(rol) {
                    var checked = rolesActualesIds.includes(rol.idRol) ? 'checked' : '';
                    html += `
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" name="roles" value="${rol.idRol}" ${checked}>
                                <strong>${rol.nombre}</strong> - ${rol.descripcion}
                                <br>
                                <small class="text-muted">
                                    ${rol.totalUsuarios} usuarios • ${rol.totalPermisos} permisos
                                </small>
                            </label>
                        </div>
                    `;
                });
                
                $('#rolesContainer').html(html);
                $('#modalAsignarRoles').data('usuario-id', idUsuario).modal('show');
            }
        }
    });
}

function guardarRoles() {
    var idUsuario = $('#modalAsignarRoles').data('usuario-id');
    var rolesSeleccionados = [];
    
    $('input[name="roles"]:checked').each(function() {
        rolesSeleccionados.push(parseInt($(this).val()));
    });
    
    if (rolesSeleccionados.length === 0) {
        alert('Debe seleccionar al menos un rol');
        return;
    }
    
    $.ajax({
        url: '/Usuarios/AsignarRoles',
        type: 'POST',
        data: {
            idUsuario: idUsuario,
            rolesIds: rolesSeleccionados
        },
        traditional: true,
        success: function(response) {
            if (response.success) {
                alert('Roles asignados correctamente');
                $('#modalAsignarRoles').modal('hide');
                table.ajax.reload();
            } else {
                alert('Error: ' + response.message);
            }
        }
    });
}
```

---

## Notas de Seguridad

1. **Autenticación**: Todos los endpoints requieren que el usuario esté autenticado
2. **Autorización**: Se validan permisos específicos para cada operación
3. **Auditoría**: Todas las operaciones quedan registradas en `ZI_BITACORAAUDITORIA`
4. **Contraseñas**: 
   - Nunca se devuelven en las respuestas
   - Siempre se encriptan antes de guardarse
   - Se valida fortaleza en el backend
5. **IPs**: Se capturan automáticamente para auditoría
6. **Autoprotección**: No se puede eliminar o modificar el estado del propio usuario

---

## Troubleshooting

### Error: "No tiene permisos para realizar esta acción"
- Verificar que el usuario tiene el permiso requerido asignado a través de sus roles

### Error: "Ya existe un usuario con ese nombre de usuario"
- El username debe ser único en el sistema
- Verificar en la base de datos si existe el usuario

### Error: "La contraseña no cumple con los requisitos de seguridad"
- Mínimo 6 caracteres
- Al menos una mayúscula
- Al menos una minúscula
- Al menos un número

### Los roles no se guardan
- Verificar que el parámetro `traditional: true` esté presente en el AJAX
- Verificar que el array `rolesIds` se esté enviando correctamente

---

¿Necesitas ayuda con la implementación del frontend o algún aspecto específico de la API?
