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
    public class PermisosController : BaseController
    {
        private readonly CN_Permiso _negocioPermiso;

        public PermisosController()
        {
            _negocioPermiso = new CN_Permiso();
        }

        #region Vistas Principales

        [PermissionFilter("PERMISOS", "LEER")]
        public ActionResult Index(int page = 1, string search = null, string modulo = null)
        {
            ViewBag.Title = "Gestión de Permisos";
            return View();
        }

        [PermissionFilter("PERMISOS", "LEER")]
        public ActionResult Detalle(int id)
        {
            ViewBag.Title = "Detalle de Permiso";
            ViewBag.PermisoId = id;
            return View();
        }

        #endregion

        #region Operaciones CRUD de Permisos

        [HttpGet]
        [PermissionFilter("PERMISOS", "LEER")]
        public JsonResult GetPermisos(
            int page = 1,
            int pageSize = 10,
            string search = null,
            bool incluirInactivos = false,
            string modulo = null,
            string accion = null)
        {
            try
            {
                CE_PagedResult<CE_PermisoListDTO> resultado = _negocioPermiso.ObtenerPermisosPaginados(
                    page,
                    pageSize,
                    search,
                    incluirInactivos,
                    modulo,
                    accion
                );

                return JsonSuccess("Permisos obtenidos exitosamente", new
                {
                    items = resultado.Items.Select(p => new
                    {
                        idPermiso = p.IdPermiso,
                        nombre = p.Nombre,
                        descripcion = p.Descripcion,
                        modulo = p.Modulo,
                        accion = p.Accion,
                        activo = p.Activo,
                        totalRoles = p.TotalRoles,
                        fechaCreacion = p.FechaCreacion?.ToString("dd/MM/yyyy HH:mm"),
                        usuarioCreacion = p.UsuarioCreacion,
                        fechaModificacion = p.FechaModificacion?.ToString("dd/MM/yyyy HH:mm"),
                        usuarioModificacion = p.UsuarioModificacion
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
                return JsonError("Error al obtener permisos", ex.Message);
            }
        }

        [HttpGet]
        [PermissionFilter("PERMISOS", "LEER")]
        public JsonResult GetPermisoDetalle(int id)
        {
            try
            {
                CE_PermisoDetalleDTO permiso = _negocioPermiso.ObtenerPermisoPorId(id);

                if (permiso == null)
                {
                    return JsonError("Permiso no encontrado", "No existe un permiso con el ID especificado");
                }

                return JsonSuccess("Detalles obtenidos exitosamente", new
                {
                    // Información básica
                    idPermiso = permiso.IdPermiso,
                    nombre = permiso.Nombre,
                    descripcion = permiso.Descripcion,
                    modulo = permiso.Modulo,
                    accion = permiso.Accion,
                    activo = permiso.Activo,
                    totalRoles = permiso.TotalRoles,
                    // Roles que tienen este permiso
                    roles = permiso.Roles.Select(r => new
                    {
                        idRol = r.IdRol,
                        nombre = r.Nombre,
                        descripcion = r.Descripcion,
                        activo = r.Activo,
                        totalUsuarios = r.TotalUsuarios
                    }),
                    // Auditoría
                    fechaCreacion = permiso.FechaCreacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioCreacion = permiso.UsuarioCreacion,
                    fechaModificacion = permiso.FechaModificacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioModificacion = permiso.UsuarioModificacion,
                    ipCreacion = permiso.IpCreacion,
                    ipModificacion = permiso.IpModificacion
                });
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener detalles del permiso", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("PERMISOS", "CREAR")]
        public JsonResult CreatePermiso(CE_PermisoCreateDTO permiso)
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
                int idPermiso = _negocioPermiso.CrearPermiso(permiso, usuarioCreacion);

                return JsonSuccess($"Permiso '{permiso.Nombre}' creado exitosamente", new
                {
                    idPermiso = idPermiso,
                    nombre = permiso.Nombre,
                    modulo = permiso.Modulo,
                    accion = permiso.Accion
                });
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (DataAccessException ex)
            {
                return JsonError("Error de base de datos", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al crear permiso", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("PERMISOS", "ACTUALIZAR")]
        public JsonResult UpdatePermiso(CE_PermisoUpdateDTO permiso)
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
                bool exitoso = _negocioPermiso.ActualizarPermiso(permiso, usuarioModificacion);

                if (exitoso)
                {
                    return JsonSuccess($"Permiso '{permiso.Nombre}' actualizado exitosamente", new
                    {
                        idPermiso = permiso.IdPermiso,
                        nombre = permiso.Nombre,
                        modulo = permiso.Modulo,
                        accion = permiso.Accion
                    });
                }
                else
                {
                    return JsonError("No se pudo actualizar el permiso", "No se afectó ningún registro");
                }
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (DataAccessException ex)
            {
                return JsonError("Error de base de datos", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al actualizar permiso", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("PERMISOS", "ELIMINAR")]
        public JsonResult DeletePermiso(int id)
        {
            try
            {
                string usuarioEliminacion = ObtenerUsernameSesion();
                bool exitoso = _negocioPermiso.EliminarPermiso(id, usuarioEliminacion);

                if (exitoso)
                {
                    return JsonSuccess("Permiso eliminado exitosamente", new { idPermiso = id });
                }
                else
                {
                    return JsonError("No se pudo eliminar el permiso", "No se afectó ningún registro");
                }
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (DataAccessException ex)
            {
                return JsonError("Error de base de datos", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al eliminar permiso", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("PERMISOS", "ACTUALIZAR")]
        public JsonResult ReactivarPermiso(int id)
        {
            try
            {
                string usuarioModificacion = ObtenerUsernameSesion();
                bool exitoso = _negocioPermiso.ReactivarPermiso(id, usuarioModificacion);

                if (exitoso)
                {
                    return JsonSuccess("Permiso reactivado exitosamente", new { idPermiso = id });
                }
                else
                {
                    return JsonError("No se pudo reactivar el permiso", "No se afectó ningún registro");
                }
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (DataAccessException ex)
            {
                return JsonError("Error de base de datos", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al reactivar permiso", ex.Message);
            }
        }

        #endregion

        #region Métodos Helper para Catálogos

        [HttpGet]
        [PermissionFilter("PERMISOS", "LEER")]
        public JsonResult GetModulosDisponibles()
        {
            try
            {
                var modulos = _negocioPermiso.ObtenerModulosDisponibles();

                return JsonSuccess("Módulos obtenidos exitosamente", new
                {
                    items = modulos.Select(m => new
                    {
                        value = m,
                        text = m
                    })
                });
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener módulos", ex.Message);
            }
        }

        [HttpGet]
        [PermissionFilter("PERMISOS", "LEER")]
        public JsonResult GetAccionesDisponibles()
        {
            try
            {
                var acciones = _negocioPermiso.ObtenerAccionesDisponibles();

                return JsonSuccess("Acciones obtenidas exitosamente", new
                {
                    items = acciones.Select(a => new
                    {
                        value = a,
                        text = a
                    })
                });
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener acciones", ex.Message);
            }
        }

        [HttpGet]
        [PermissionFilter("PERMISOS", "LEER")]
        public JsonResult GetCatalogos()
        {
            try
            {
                var modulos = _negocioPermiso.ObtenerModulosDisponibles();
                var acciones = _negocioPermiso.ObtenerAccionesDisponibles();

                return JsonSuccess("Catálogos obtenidos exitosamente", new
                {
                    modulos = modulos.Select(m => new { value = m, text = m }),
                    acciones = acciones.Select(a => new { value = a, text = a })
                });
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener catálogos", ex.Message);
            }
        }

        #endregion
    }
}
