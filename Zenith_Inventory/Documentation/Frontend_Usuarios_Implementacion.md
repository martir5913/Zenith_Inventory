# Módulo de Gestión de Usuarios - Frontend Implementado

## ?? Resumen

Se ha completado la implementación del frontend para la gestión de usuarios siguiendo los estilos y patrones establecidos en el proyecto Zenith_Inventory.

---

## ?? Archivos Creados

### 1. Vistas
**`Zenith_Inventory\Views\Usuarios\Index.cshtml`**
- Vista principal de gestión de usuarios
- Tabla interactiva con búsqueda y filtros
- Modales para crear, editar y ver detalle
- Modal para resetear contraseñas
- Diseño responsive y moderno

### 2. Estilos CSS
**`Zenith_Inventory\Content\css\Usuarios\usuarios.css`**
- Estilos coherentes con el diseño del sistema
- Paleta de colores consistente
- Animaciones y transiciones
- Responsive design

### 3. JavaScript
**`Zenith_Inventory\Scripts\Usuarios\usuarios.js`**
- Lógica completa de CRUD
- Gestión de contraseñas
- Validaciones del lado del cliente
- Integración con SweetAlert2

---

## ? Características Implementadas

### Gestión de Usuarios
? **Listado Paginado**
- Búsqueda en tiempo real (username, nombre, correo)
- Filtros: Activos, Inactivos, Bloqueados, Todos
- Paginación funcional
- 10 registros por página

? **Crear Usuario**
- Formulario completo con validaciones
- Generación automática de contraseñas
- Asignación de roles en creación
- Campos organizados por secciones:
  - Información de Cuenta
  - Información Personal
  - Información Laboral
  - Roles y Estado

? **Editar Usuario**
- Pre-carga de datos existentes
- Validaciones del lado del cliente
- Username y código deshabilitados en edición
- Contraseña no se modifica en edición

? **Ver Detalle**
- Modal informativo con toda la información
- Roles asignados con badges
- Estadísticas de uso
- Información de auditoría completa
- Botón de editar desde el detalle

? **Eliminar Usuario**
- Confirmación con SweetAlert2
- Eliminación lógica (desactivación)
- Prevención de auto-eliminación
- Desactivación de roles asociados

### Gestión de Contraseñas
? **Resetear Contraseña**
- Generación automática de contraseña temporal
- Display seguro de la contraseña (solo una vez)
- Botón de copiar al portapapeles
- Marca usuario para cambio obligatorio

? **Generador de Contraseñas**
- Contraseñas aleatorias de 10 caracteres
- Cumple requisitos de seguridad automáticamente
- Integrado en formulario de creación

? **Toggle de Visibilidad**
- Mostrar/ocultar contraseña en campos
- Icono animado

### Gestión de Roles
? **Asignación de Roles**
- Checkboxes con descripción de cada rol
- Scroll vertical si hay muchos roles
- Selección múltiple
- Asignación en creación o edición

? **Visualización de Roles**
- Badges coloridos en tabla principal
- Badges detallados en modal de detalle
- Contador de roles asignados

### Gestión de Estado
? **Desbloquear Usuario**
- Acción directa desde la tabla
- Confirmación con SweetAlert2
- Resetea intentos fallidos

? **Estados Visuales**
- Badge de Activo (verde)
- Badge de Bloqueado (rojo)
- Badge de Inactivo (gris)

---

## ?? Diseño y Estilo

### Paleta de Colores Utilizada
```css
/* Colores principales */
--primary-blue: #0066CC
--primary-white: #FFFFFF
--primary-dark: #151B2E
--success: #28A745
--danger: #DC3545
--warning: #FFC107
--info: #17A2B8

/* Gradientes */
Header Modal: linear-gradient(135deg, #1a1f3a 0%, #2d3561 100%)
Badges: linear-gradient(135deg, #0066CC, #00C8FF)
```

### Componentes UI

**Tabla de Usuarios**
- Diseño limpio y moderno
- Hover effects en filas
- Iconos Font Awesome
- Acciones compactas con botones circulares

**Modales**
- Header con gradiente oscuro y ícono
- Secciones organizadas con títulos
- Formularios con iconos descriptivos
- Botones con iconos y colores semánticos

**Badges de Estado**
- Redondeados (border-radius: 20px)
- Colores distintivos por estado
- Tamaño apropiado para lectura

**Botones de Acción**
- Tamaño 32x32px
- Colores semánticos
- Efectos hover con elevación
- Tooltips descriptivos

---

## ?? Funcionalidades Técnicas

### Validaciones del Cliente

**Usuario:**
- Código: mayor a 0
- Username: 3-100 caracteres
- Contraseña: mínimo 6 caracteres
- Email: formato válido
- Nombre: mínimo 2 caracteres

**Contraseña (Backend):**
- Mínimo 6 caracteres
- Al menos una mayúscula
- Al menos una minúscula
- Al menos un número

### AJAX Requests

Todos los endpoints utilizan jQuery AJAX con:
- Loading overlay durante peticiones
- Manejo de errores con SweetAlert2
- Respuestas JSON estructuradas
- Timeouts y retry logic

### Debouncing

Búsqueda con debounce de 500ms para optimizar peticiones al servidor.

### Responsive Design

**Desktop (> 992px)**
- Tabla completa con todas las columnas
- Modales centrados con ancho máximo

**Tablet (768px - 992px)**
- Tabla ajustada con scroll horizontal
- Modales responsive

**Mobile (< 768px)**
- Botones de acción en vertical
- Campos de formulario apilados
- Modales full-width

---

## ?? Ejemplos de Uso

### 1. Crear un Nuevo Usuario

```javascript
// El usuario hace clic en "Nuevo Usuario"
$('#btnAddUser').click()

// Se abre el modal con:
- Código: 1001
- Username: jperez
- Password: (generada o manual)
- Nombre: Juan
- Apellido: Pérez
- Correo: jperez@empresa.com
- Roles: [Administrador, Usuario]

// Al guardar:
POST /Usuarios/CreateUsuario
{
    Codigo: 1001,
    Username: "jperez",
    Password: "Pass123!",
    Nombre: "Juan",
    Apellido: "Pérez",
    Correo: "jperez@empresa.com",
    RolesIds: [1, 2],
    ...
}
```

### 2. Resetear Contraseña

```javascript
// Usuario hace clic en icono de llave
openResetPasswordModal(userId)

// Se muestra modal de confirmación
// Al confirmar:
POST /Usuarios/ResetearPassword
{ id: 10 }

// Response:
{
    success: true,
    data: {
        passwordTemporal: "Xy9a2Bc!Df"
    }
}

// Se muestra la contraseña con botón de copiar
```

### 3. Filtrar Usuarios

```javascript
// Usuario selecciona "Solo Bloqueados"
$('#filterStatus').val('bloqueados').change()

// Se ejecuta:
GET /Usuarios/GetUsuarios?page=1&pageSize=10&soloBloqueados=true

// La tabla se actualiza con solo usuarios bloqueados
```

---

## ?? Integración con Backend

### Endpoints Consumidos

| Método | Endpoint | Acción |
|--------|----------|--------|
| GET | `/Usuarios/GetUsuarios` | Listar usuarios paginados |
| GET | `/Usuarios/GetUsuarioDetalle` | Obtener detalle de usuario |
| POST | `/Usuarios/CreateUsuario` | Crear usuario |
| POST | `/Usuarios/UpdateUsuario` | Actualizar usuario |
| POST | `/Usuarios/DeleteUsuario` | Eliminar usuario |
| POST | `/Usuarios/ResetearPassword` | Resetear contraseña |
| POST | `/Usuarios/DesbloquearUsuario` | Desbloquear usuario |
| GET | `/Usuarios/GetRolesDisponibles` | Obtener roles |
| GET | `/Usuarios/GenerarPasswordTemporal` | Generar contraseña |

### Formato de Respuestas

**Éxito:**
```json
{
    "success": true,
    "message": "Operación exitosa",
    "data": { ... }
}
```

**Error:**
```json
{
    "success": false,
    "message": "Descripción del error",
    "error": "Detalles adicionales"
}
```

---

## ?? Próximos Pasos

### Para Completar la Implementación:

1. **Configurar Rutas**
   - Agregar ruta en `RouteConfig.cs`
   - Configurar permisos en el sistema

2. **Agregar al Menú**
   - Agregar enlace en el sidebar
   - Configurar icono y orden

3. **Testing**
   - Probar todos los flujos
   - Validar permisos
   - Verificar responsive

4. **Optimizaciones**
   - Caché de roles
   - Lazy loading de imágenes
   - Compresión de JS/CSS

---

## ?? Documentación Adicional

### Estructura de Carpetas

```
Zenith_Inventory/
??? Views/
?   ??? Usuarios/
?       ??? Index.cshtml
??? Content/
?   ??? css/
?       ??? Usuarios/
?           ??? usuarios.css
??? Scripts/
?   ??? Usuarios/
?       ??? usuarios.js
??? Controllers/
    ??? Usuarios/
        ??? UsuariosController.cs
```

### Dependencias

**CSS:**
- Bootstrap 5
- Font Awesome 6
- layout.css (variables globales)

**JavaScript:**
- jQuery 3.x
- SweetAlert2
- Bootstrap 5 JS

---

## ?? Troubleshooting

### Problema: Los modales no se abren
**Solución:** Verificar que Bootstrap JS esté cargado

### Problema: Los roles no se cargan
**Solución:** Verificar endpoint `/Usuarios/GetRolesDisponibles`

### Problema: La paginación no funciona
**Solución:** Verificar que `changePage()` esté en el scope global

### Problema: SweetAlert2 no funciona
**Solución:** Agregar `<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>` al layout

---

## ? Checklist de Implementación

- [x] Vista principal creada
- [x] CSS con estilos consistentes
- [x] JavaScript con toda la lógica
- [x] CRUD completo
- [x] Gestión de contraseñas
- [x] Gestión de roles
- [x] Validaciones
- [x] Responsive design
- [x] Accesibilidad (aria-labels)
- [x] Documentación
- [ ] Agregar al menú
- [ ] Configurar rutas
- [ ] Testing completo
- [ ] Deploy a producción

---

¿Necesitas ayuda con algún aspecto específico de la implementación?
