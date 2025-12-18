using CapaComun.Excepciones;
using CapaEntidad.DTOs.Common;
using CapaEntidad.DTOs.Usuario;
using CapaNegocio.Usuario;
using System;
using System.Linq;
using System.Web.Mvc;
using Zenith_Inventory.Filters;

namespace Zenith_Inventory.Controllers.Usuarios
{
    [AuthenticationFilter]
    public class UsuariosController : BaseController
    {
        private readonly CN_UsuarioGestion _negocioUsuario;

        public UsuariosController()
        {
            _negocioUsuario = new CN_UsuarioGestion();
        }

        #region Vistas Principales

        [PermissionFilter("USUARIOS", "LEER")]
        public ActionResult Index(int page = 1, string search = null)
        {
            ViewBag.Title = "Gestión de Usuarios";
            return View();
        }

        [PermissionFilter("USUARIOS", "LEER")]
        public ActionResult Detalle(int id)
        {
            ViewBag.Title = "Detalle de Usuario";
            ViewBag.UsuarioId = id;
            return View();
        }

        [PermissionFilter("USUARIOS", "ACTUALIZAR")]
        public ActionResult AsignarRoles(int id)
        {
            ViewBag.Title = "Asignar Roles";
            ViewBag.UsuarioId = id;
            return View();
        }

        #endregion

        #region Operaciones CRUD de Usuarios

        [HttpGet]
        [PermissionFilter("USUARIOS", "LEER")]
        public JsonResult GetUsuarios(int page = 1, int pageSize = 10, string search = null, bool incluirInactivos = false, bool soloBloqueados = false)
        {
            try
            {
                CE_PagedResult<CE_UsuarioListDTO> resultado = _negocioUsuario.ObtenerUsuariosPaginados(
                    page,
                    pageSize,
                    search,
                    incluirInactivos,
                    soloBloqueados
                );

                return JsonSuccess("Usuarios obtenidos exitosamente", new
                {
                    items = resultado.Items.Select(u => new
                    {
                        idUsuario = u.IdUsuario,
                        codigo = u.Codigo,
                        username = u.Username,
                        nombre = u.Nombre,
                        apellido = u.Apellido,
                        nombreCompleto = u.NombreCompleto,
                        correo = u.Correo,
                        telefono = u.Telefono,
                        departamento = u.Departamento,
                        puesto = u.Puesto,
                        activo = u.Activo,
                        bloqueado = u.Bloqueado,
                        estadoTexto = u.EstadoTexto,
                        intentosFallidos = u.IntentosFallidos,
                        fechaBloqueo = u.FechaBloqueo?.ToString("dd/MM/yyyy HH:mm"),
                        ultimoLogin = u.UltimoLogin?.ToString("dd/MM/yyyy HH:mm"),
                        requiereCambioPassword = u.RequiereCambioPassword,
                        totalRoles = u.TotalRoles,
                        rolesAsignados = u.RolesAsignados,
                        fechaCreacion = u.FechaCreacion?.ToString("dd/MM/yyyy HH:mm"),
                        usuarioCreacion = u.UsuarioCreacion
                    }),
                    pagination = new
                    {
                        currentPage = resultado.PageNumber,
                        pageSize = resultado.PageSize,
                        totalRecords = resultado.TotalRecords,
                        totalPages = resultado.TotalPages,
                        hasPreviousPage = resultado.HasPreviousPage,
                        hasNextPage = resultado.HasNextPage
                    }
                });
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener usuarios", ex.Message);
            }
        }

        [HttpGet]
        [PermissionFilter("USUARIOS", "LEER")]
        public JsonResult GetUsuarioDetalle(int id)
        {
            try
            {
                CE_UsuarioDetalleDTO usuario = _negocioUsuario.ObtenerUsuarioPorId(id);

                if (usuario == null)
                {
                    return JsonError("Usuario no encontrado", "No existe un usuario con el ID especificado");
                }

                return JsonSuccess("Detalles obtenidos exitosamente", new
                {
                    // Información básica
                    idUsuario = usuario.IdUsuario,
                    codigo = usuario.Codigo,
                    username = usuario.Username,
                    nombre = usuario.Nombre,
                    apellido = usuario.Apellido,
                    nombreCompleto = usuario.NombreCompleto,
                    correo = usuario.Correo,
                    telefono = usuario.Telefono,
                    departamento = usuario.Departamento,
                    puesto = usuario.Puesto,
                    // Estado
                    activo = usuario.Activo,
                    bloqueado = usuario.Bloqueado,
                    estadoTexto = usuario.EstadoTexto,
                    intentosFallidos = usuario.IntentosFallidos,
                    fechaBloqueo = usuario.FechaBloqueo?.ToString("dd/MM/yyyy HH:mm"),
                    ultimoLogin = usuario.UltimoLogin?.ToString("dd/MM/yyyy HH:mm"),
                    requiereCambioPassword = usuario.RequiereCambioPassword,
                    // Roles asignados
                    roles = usuario.Roles.Select(r => new
                    {
                        idRol = r.IdRol,
                        nombre = r.Nombre,
                        descripcion = r.Descripcion,
                        fechaAsignacion = r.FechaAsignacion.ToString("dd/MM/yyyy HH:mm"),
                        activo = r.Activo
                    }),
                    // Permisos efectivos
                    permisos = usuario.Permisos.Select(p => new
                    {
                        idPermiso = p.IdPermiso,
                        nombre = p.Nombre,
                        descripcion = p.Descripcion,
                        modulo = p.Modulo,
                        accion = p.Accion
                    }),
                    // Auditoría
                    fechaCreacion = usuario.FechaCreacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioCreacion = usuario.UsuarioCreacion,
                    fechaModificacion = usuario.FechaModificacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioModificacion = usuario.UsuarioModificacion,
                    ipCreacion = usuario.IpCreacion,
                    ipModificacion = usuario.IpModificacion
                });
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener detalles del usuario", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("USUARIOS", "CREAR")]
        public JsonResult CreateUsuario(CE_UsuarioCreateDTO usuario)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    var errores = ModelState.Values
                        .SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage)
                        .ToList();

                    return JsonError("Datos de entrada inválidos", string.Join("; ", errores));
                }

                string usuarioCreacion = ObtenerUsernameSesion();
                CE_OperacionResultDTO resultado = _negocioUsuario.CrearUsuario(usuario, usuarioCreacion);

                if (resultado.Exitoso)
                {
                    return JsonSuccess(resultado.Mensaje, resultado.Datos);
                }
                else
                {
                    return JsonError(resultado.Mensaje);
                }
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al crear usuario", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("USUARIOS", "ACTUALIZAR")]
        public JsonResult UpdateUsuario(CE_UsuarioUpdateDTO usuario)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    var errores = ModelState.Values
                        .SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage)
                        .ToList();

                    return JsonError("Datos de entrada inválidos", string.Join("; ", errores));
                }

                string usuarioModificacion = ObtenerUsernameSesion();
                CE_OperacionResultDTO resultado = _negocioUsuario.ActualizarUsuario(usuario, usuarioModificacion);

                if (resultado.Exitoso)
                {
                    return JsonSuccess(resultado.Mensaje);
                }
                else
                {
                    return JsonError(resultado.Mensaje);
                }
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al actualizar usuario", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("USUARIOS", "ELIMINAR")]
        public JsonResult DeleteUsuario(int id)
        {
            try
            {
                // Validar que no se elimine a sí mismo
                int usuarioActualId = ObtenerUserIdSesion();
                if (id == usuarioActualId)
                {
                    return JsonError("No puede eliminar su propio usuario", "Acción no permitida");
                }

                string usuarioEliminacion = ObtenerUsernameSesion();
                CE_OperacionResultDTO resultado = _negocioUsuario.EliminarUsuario(id, usuarioEliminacion);

                if (resultado.Exitoso)
                {
                    return JsonSuccess(resultado.Mensaje);
                }
                else
                {
                    return JsonError(resultado.Mensaje);
                }
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al eliminar usuario", ex.Message);
            }
        }

        #endregion

        #region Gestión de Contraseñas

        [HttpPost]
        [PermissionFilter("USUARIOS", "ACTUALIZAR")]
        public JsonResult ResetearPassword(int id)
        {
            try
            {
                // Generar contraseña temporal
                string passwordTemporal = _negocioUsuario.GenerarPasswordTemporal();

                var resetDTO = new CE_ResetPasswordDTO
                {
                    IdUsuario = id,
                    NuevaPassword = passwordTemporal
                };

                string usuarioModificacion = ObtenerUsernameSesion();
                CE_OperacionResultDTO resultado = _negocioUsuario.ResetearPassword(resetDTO, usuarioModificacion);

                if (resultado.Exitoso)
                {
                    return JsonSuccess(resultado.Mensaje, new { passwordTemporal });
                }
                else
                {
                    return JsonError(resultado.Mensaje);
                }
            }
            catch (Exception ex)
            {
                return JsonError("Error al resetear contraseña", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("USUARIOS", "ACTUALIZAR")]
        public JsonResult ResetearPasswordCustom(int id, string nuevaPassword)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(nuevaPassword))
                {
                    return JsonError("La contraseña es requerida");
                }

                var resetDTO = new CE_ResetPasswordDTO
                {
                    IdUsuario = id,
                    NuevaPassword = nuevaPassword
                };

                string usuarioModificacion = ObtenerUsernameSesion();
                CE_OperacionResultDTO resultado = _negocioUsuario.ResetearPassword(resetDTO, usuarioModificacion);

                if (resultado.Exitoso)
                {
                    return JsonSuccess(resultado.Mensaje);
                }
                else
                {
                    return JsonError(resultado.Mensaje);
                }
            }
            catch (Exception ex)
            {
                return JsonError("Error al resetear contraseña", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("USUARIOS", "ACTUALIZAR")]
        public JsonResult DesbloquearUsuario(int id)
        {
            try
            {
                string usuarioModificacion = ObtenerUsernameSesion();
                CE_OperacionResultDTO resultado = _negocioUsuario.DesbloquearUsuario(id, usuarioModificacion);

                if (resultado.Exitoso)
                {
                    return JsonSuccess(resultado.Mensaje);
                }
                else
                {
                    return JsonError(resultado.Mensaje);
                }
            }
            catch (Exception ex)
            {
                return JsonError("Error al desbloquear usuario", ex.Message);
            }
        }

        [HttpGet]
        [PermissionFilter("USUARIOS", "ACTUALIZAR")]
        public JsonResult GenerarPasswordTemporal()
        {
            try
            {
                string passwordTemporal = _negocioUsuario.GenerarPasswordTemporal();
                return JsonSuccess("Contraseña generada exitosamente", new { passwordTemporal });
            }
            catch (Exception ex)
            {
                return JsonError("Error al generar contraseña", ex.Message);
            }
        }

        #endregion

        #region Gestión de Roles

        [HttpPost]
        [PermissionFilter("USUARIOS", "ACTUALIZAR")]
        public JsonResult AsignarRoles(int idUsuario, int[] rolesIds)
        {
            try
            {
                if (rolesIds == null || rolesIds.Length == 0)
                {
                    return JsonError("Debe seleccionar al menos un rol");
                }

                var asignarRolesDTO = new CE_AsignarRolesDTO
                {
                    IdUsuario = idUsuario,
                    RolesIds = rolesIds
                };

                string usuarioModificacion = ObtenerUsernameSesion();
                CE_OperacionResultDTO resultado = _negocioUsuario.AsignarRolesUsuario(asignarRolesDTO, usuarioModificacion);

                if (resultado.Exitoso)
                {
                    return JsonSuccess(resultado.Mensaje);
                }
                else
                {
                    return JsonError(resultado.Mensaje);
                }
            }
            catch (Exception ex)
            {
                return JsonError("Error al asignar roles", ex.Message);
            }
        }

        [HttpGet]
        [PermissionFilter("USUARIOS", "LEER")]
        public JsonResult GetRolesDisponibles()
        {
            try
            {
                var roles = _negocioUsuario.ObtenerRolesActivos();

                return JsonSuccess("Roles obtenidos exitosamente", new
                {
                    items = roles.Select(r => new
                    {
                        idRol = r.IdRol,
                        nombre = r.Nombre,
                        descripcion = r.Descripcion,
                        activo = r.Activo,
                        totalUsuarios = r.TotalUsuarios,
                        totalPermisos = r.TotalPermisos
                    })
                });
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener roles disponibles", ex.Message);
            }
        }

        [HttpGet]
        [PermissionFilter("USUARIOS", "LEER")]
        public JsonResult GetRolesPaginados(int page = 1, int pageSize = 10, string search = null, bool incluirInactivos = false)
        {
            try
            {
                CE_PagedResult<CE_RolListDTO> resultado = _negocioUsuario.ObtenerRolesPaginados(
                    page,
                    pageSize,
                    search,
                    incluirInactivos
                );

                return JsonSuccess("Roles obtenidos exitosamente", new
                {
                    items = resultado.Items.Select(r => new
                    {
                        idRol = r.IdRol,
                        nombre = r.Nombre,
                        descripcion = r.Descripcion,
                        activo = r.Activo,
                        totalUsuarios = r.TotalUsuarios,
                        totalPermisos = r.TotalPermisos,
                        fechaCreacion = r.FechaCreacion?.ToString("dd/MM/yyyy HH:mm"),
                        usuarioCreacion = r.UsuarioCreacion
                    }),
                    pagination = new
                    {
                        currentPage = resultado.PageNumber,
                        pageSize = resultado.PageSize,
                        totalRecords = resultado.TotalRecords,
                        totalPages = resultado.TotalPages,
                        hasPreviousPage = resultado.HasPreviousPage,
                        hasNextPage = resultado.HasNextPage
                    }
                });
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener roles", ex.Message);
            }
        }

        [HttpGet]
        [PermissionFilter("USUARIOS", "LEER")]
        public JsonResult GetPermisosRol(int idRol)
        {
            try
            {
                var permisos = _negocioUsuario.ObtenerPermisosRol(idRol);

                return JsonSuccess("Permisos obtenidos exitosamente", new
                {
                    items = permisos.Select(p => new
                    {
                        idPermiso = p.IdPermiso,
                        nombre = p.Nombre,
                        descripcion = p.Descripcion,
                        modulo = p.Modulo,
                        accion = p.Accion
                    })
                });
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener permisos del rol", ex.Message);
            }
        }

        #endregion

        #region Métodos de Soporte

        private bool ValidarNoModificarPropio(int idUsuario)
        {
            int usuarioActualId = ObtenerUserIdSesion();
            return idUsuario != usuarioActualId;
        }

        #endregion
    }
}
