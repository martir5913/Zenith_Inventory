using CapaComun;
using CapaEntidad.DTOs.Usuario;
using CapaNegocio.Usuario;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using Zenith_Inventory.Filters;

namespace Zenith_Inventory.Controllers.Usuarios
{
    /// <summary>
    /// Controlador para la gestión de Roles
    /// Patrón: Similar a PermisosController
    /// </summary>
    [AuthenticationFilter]
    public class RolesController : BaseController
    {
        private readonly CN_Rol _cnRol;
        private readonly CN_Permiso _cnPermiso;

        public RolesController()
        {
            _cnRol = new CN_Rol();
            _cnPermiso = new CN_Permiso();
        }

        // GET: Roles
        [PermissionFilter("ROLES", "LEER")]
        public ActionResult Index()
        {
            return View();
        }

        #region AJAX ENDPOINTS

        /// <summary>
        /// Obtiene el listado paginado de roles
        /// </summary>
        [HttpGet]
        [PermissionFilter("ROLES", "LEER")]
        public JsonResult GetRoles(
            int page = 1,
            int pageSize = 10,
            string search = "",
            bool incluirInactivos = false)
        {
            try
            {
                // ✅ FIX: Recibir CE_PagedResult en lugar de tupla
                var result = _cnRol.ListarRoles(page, pageSize, search, incluirInactivos);

                return Json(new
                {
                    success = true,
                    message = "Roles obtenidos exitosamente",
                    data = new
                    {
                        items = result.Items,
                        pagination = new
                        {
                            currentPage = result.PageNumber,
                            pageSize = result.PageSize,
                            totalRecords = result.TotalRecords,
                            totalPages = result.TotalPages,
                            hasPreviousPage = result.HasPreviousPage,
                            hasNextPage = result.HasNextPage
                        }
                    }
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener roles en controlador");
                return Json(new
                {
                    success = false,
                    message = "Error al cargar los roles",
                    error = ex.Message
                }, JsonRequestBehavior.AllowGet);
            }
        }

        /// <summary>
        /// Obtiene los detalles de un rol por ID
        /// </summary>
        [HttpGet]
        [PermissionFilter("ROLES", "LEER")]
        public JsonResult GetRolPorId(int id)
        {
            try
            {
                var rol = _cnRol.ObtenerRolPorId(id);

                return Json(new
                {
                    success = true,
                    message = "Rol obtenido exitosamente",
                    data = rol
                }, JsonRequestBehavior.AllowGet);
            }
            catch (KeyNotFoundException ex)
            {
                ErrorLogger.Log(ex, $"Rol no encontrado con ID: {id}");
                return Json(new
                {
                    success = false,
                    message = "Rol no encontrado",
                    error = ex.Message
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al obtener rol con ID: {id}");
                return Json(new
                {
                    success = false,
                    message = "Error al obtener el rol",
                    error = ex.Message
                }, JsonRequestBehavior.AllowGet);
            }
        }

        /// <summary>
        /// Crea un nuevo rol
        /// </summary>
        [HttpPost]
        [PermissionFilter("ROLES", "CREAR")]
        public JsonResult CrearRol(CE_RolCreateDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return Json(new
                    {
                        success = false,
                        message = "Datos inválidos",
                        errors = ModelState.Values
                    });
                }

                // Obtener información del usuario actual
                string usuarioActual = Session["NombreUsuario"]?.ToString() ?? "Sistema";
                string ipAddress = Request.UserHostAddress;

                int nuevoId = _cnRol.CrearRol(dto, usuarioActual, ipAddress);

                return Json(new
                {
                    success = true,
                    message = "Rol creado exitosamente",
                    data = new { idRol = nuevoId }
                });
            }
            catch (ArgumentException ex)
            {
                ErrorLogger.Log(ex, "Validación fallida al crear rol");
                return Json(new
                {
                    success = false,
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al crear rol en controlador");
                return Json(new
                {
                    success = false,
                    message = "Error al crear el rol",
                    error = ex.Message
                });
            }
        }

        /// <summary>
        /// Actualiza un rol existente
        /// </summary>
        [HttpPost]
        [PermissionFilter("ROLES", "ACTUALIZAR")]
        public JsonResult ActualizarRol(CE_RolUpdateDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return Json(new
                    {
                        success = false,
                        message = "Datos inválidos",
                        errors = ModelState.Values
                    });
                }

                // Obtener información del usuario actual
                string usuarioActual = Session["NombreUsuario"]?.ToString() ?? "Sistema";
                string ipAddress = Request.UserHostAddress;

                int filasAfectadas = _cnRol.ActualizarRol(dto, usuarioActual, ipAddress);

                return Json(new
                {
                    success = true,
                    message = "Rol actualizado exitosamente",
                    data = new { filasAfectadas = filasAfectadas }
                });
            }
            catch (KeyNotFoundException ex)
            {
                ErrorLogger.Log(ex, $"Rol no encontrado al actualizar ID: {dto.IdRol}");
                return Json(new
                {
                    success = false,
                    message = "Rol no encontrado"
                });
            }
            catch (ArgumentException ex)
            {
                ErrorLogger.Log(ex, "Validación fallida al actualizar rol");
                return Json(new
                {
                    success = false,
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al actualizar rol ID: {dto.IdRol}");
                return Json(new
                {
                    success = false,
                    message = "Error al actualizar el rol",
                    error = ex.Message
                });
            }
        }

        /// <summary>
        /// Elimina (desactiva) un rol
        /// </summary>
        [HttpPost]
        [PermissionFilter("ROLES", "ELIMINAR")]
        public JsonResult EliminarRol(int id)
        {
            try
            {
                // Obtener información del usuario actual
                string usuarioActual = Session["NombreUsuario"]?.ToString() ?? "Sistema";
                string ipAddress = Request.UserHostAddress;

                int filasAfectadas = _cnRol.EliminarRol(id, usuarioActual, ipAddress);

                return Json(new
                {
                    success = true,
                    message = "Rol eliminado exitosamente",
                    data = new { filasAfectadas = filasAfectadas }
                });
            }
            catch (KeyNotFoundException ex)
            {
                ErrorLogger.Log(ex, $"Rol no encontrado al eliminar ID: {id}");
                return Json(new
                {
                    success = false,
                    message = "Rol no encontrado"
                });
            }
            catch (InvalidOperationException ex)
            {
                ErrorLogger.Log(ex, $"No se puede eliminar rol protegido ID: {id}");
                return Json(new
                {
                    success = false,
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al eliminar rol ID: {id}");
                return Json(new
                {
                    success = false,
                    message = "Error al eliminar el rol",
                    error = ex.Message
                });
            }
        }

        /// <summary>
        /// Reactiva un rol previamente eliminado (borrado lógico)
        /// </summary>
        [HttpPost]
        [PermissionFilter("ROLES", "ACTUALIZAR")]
        public JsonResult ReactivarRol(int id)
        {
            try
            {
                // Obtener información del usuario actual
                string usuarioActual = Session["NombreUsuario"]?.ToString() ?? "Sistema";
                string ipAddress = Request.UserHostAddress;

                int filasAfectadas = _cnRol.ReactivarRol(id, usuarioActual, ipAddress);

                return Json(new
                {
                    success = true,
                    message = "Rol reactivado exitosamente",
                    data = new { filasAfectadas = filasAfectadas }
                });
            }
            catch (KeyNotFoundException ex)
            {
                ErrorLogger.Log(ex, $"Rol no encontrado al reactivar ID: {id}");
                return Json(new
                {
                    success = false,
                    message = "Rol no encontrado"
                });
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al reactivar rol ID: {id}");
                return Json(new
                {
                    success = false,
                    message = "Error al reactivar el rol",
                    error = ex.Message
                });
            }
        }

        /// <summary>
        /// Asigna permisos a un rol
        /// </summary>
        [HttpPost]
        [PermissionFilter("ROLES", "ACTUALIZAR")]
        public JsonResult AsignarPermisos(int idRol, List<int> permisosIds)
        {
            try
            {
                // Obtener información del usuario actual
                string usuarioActual = Session["NombreUsuario"]?.ToString() ?? "Sistema";
                string ipAddress = Request.UserHostAddress;

                _cnRol.AsignarPermisos(idRol, permisosIds, usuarioActual, ipAddress);

                return Json(new
                {
                    success = true,
                    message = "Permisos asignados exitosamente al rol"
                });
            }
            catch (KeyNotFoundException ex)
            {
                ErrorLogger.Log(ex, $"Rol no encontrado al asignar permisos ID: {idRol}");
                return Json(new
                {
                    success = false,
                    message = "Rol no encontrado"
                });
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al asignar permisos al rol ID: {idRol}");
                return Json(new
                {
                    success = false,
                    message = "Error al asignar permisos al rol",
                    error = ex.Message
                });
            }
        }

        /// <summary>
        /// Obtiene todos los permisos disponibles para asignar a un rol
        /// </summary>
        [HttpGet]
        [PermissionFilter("ROLES", "LEER")]
        public JsonResult GetPermisosDisponibles()
        {
            try
            {
                // ✅ FIX: Usar el método correcto de CN_Permiso
                var result = _cnPermiso.ObtenerPermisosPaginados(
                    pageNumber: 1,
                    pageSize: 1000, // Obtener todos los permisos activos
                    incluirInactivos: false
                );

                return Json(new
                {
                    success = true,
                    message = "Permisos obtenidos exitosamente",
                    data = result.Items // ✅ FIX: Usar result.Items en lugar de permisos
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener permisos disponibles");
                return Json(new
                {
                    success = false,
                    message = "Error al cargar los permisos disponibles",
                    error = ex.Message
                }, JsonRequestBehavior.AllowGet);
            }
        }

        /// <summary>
        /// Obtiene la matriz de permisos para mostrar en el modal de detalles
        /// Agrupa los permisos por módulo y acción para una visualización tipo tabla
        /// </summary>
        [HttpGet]
        [PermissionFilter("ROLES", "LEER")]
        public JsonResult GetPermisosMatriz(int idRol)
        {
            try
            {
                // Obtener el rol con sus permisos
                var rol = _cnRol.ObtenerRolPorId(idRol);

                // Obtener todos los permisos disponibles agrupados
                var todosLosPermisos = _cnPermiso.ObtenerPermisosPaginados(
                    pageNumber: 1,
                    pageSize: 100,
                    searchTerm: null,
                    incluirInactivos: false,
                    modulo: null,
                    accion: null
                );

                // Obtener módulos y acciones únicas
                var modulos = _cnPermiso.ObtenerModulosDisponibles();
                var acciones = _cnPermiso.ObtenerAccionesDisponibles();

                // Crear matriz de permisos
                var matriz = modulos.Select(modulo => new
                {
                    modulo = modulo,
                    permisos = acciones.Select(accion =>
                    {
                        // Buscar si existe un permiso para este módulo-acción
                        var permiso = todosLosPermisos.Items.FirstOrDefault(p =>
                            p.Modulo == modulo && p.Accion == accion);

                        if (permiso != null)
                        {
                            // Verificar si el rol tiene este permiso asignado
                            var tienePermiso = rol.Permisos != null &&
                                rol.Permisos.Any(rp => rp.IdPermiso == permiso.IdPermiso);

                            return new
                            {
                                idPermiso = permiso.IdPermiso,
                                nombre = permiso.Nombre,
                                accion = accion,
                                existe = true,
                                asignado = tienePermiso
                            };
                        }

                        return new
                        {
                            idPermiso = 0,
                            nombre = (string)null,
                            accion = accion,
                            existe = false,
                            asignado = false
                        };
                    }).ToList()
                }).ToList();

                return Json(new
                {
                    success = true,
                    message = "Matriz de permisos obtenida exitosamente",
                    data = new
                    {
                        modulos = modulos,
                        acciones = acciones,
                        matriz = matriz,
                        totalPermisos = rol.Permisos?.Count ?? 0
                    }
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al obtener matriz de permisos para rol {idRol}");
                return Json(new
                {
                    success = false,
                    message = "Error al cargar la matriz de permisos",
                    error = ex.Message
                }, JsonRequestBehavior.AllowGet);
            }
        }

        #endregion
    }
}
