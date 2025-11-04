using CapaComun.Excepciones;
using CapaEntidad.DTOs.Categoria;
using CapaEntidad.DTOs.Common;
using CapaNegocio.Categoria;
using System;
using System.Web.Mvc;
using Zenith_Inventory.Filters;

namespace Zenith_Inventory.Controllers
{
    [AuthenticationFilter]
    public class EquiposController : BaseController
    {
        private readonly CN_Categoria _negocioCategoria;

        public EquiposController()
        {
            _negocioCategoria = new CN_Categoria();
        }

        #region Equipos

        [PermissionFilter("EQUIPOS", "LEER")]
        public ActionResult Index(int page = 1, string search = null)
        {
            ViewBag.Title = "Gestión de Equipos";
            return ViewOrPartial(); // Soporte SPA
        }

        [PermissionFilter("EQUIPOS", "CREAR")]
        public ActionResult Create()
        {
            ViewBag.Title = "Nuevo Equipo";
            return ViewOrPartial(); // Soporte SPA
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [PermissionFilter("EQUIPOS", "CREAR")]
        public ActionResult Create(FormCollection form)
        {
            return RedirectToAction("Index");
        }

        [PermissionFilter("EQUIPOS", "ACTUALIZAR")]
        public ActionResult Edit(int id)
        {
            ViewBag.Title = "Editar Equipo";
            return ViewOrPartial(); // Soporte SPA
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [PermissionFilter("EQUIPOS", "ACTUALIZAR")]
        public ActionResult Edit(int id, FormCollection form)
        {
            return RedirectToAction("Index");
        }

        [HttpPost]
        [PermissionFilter("EQUIPOS", "ELIMINAR")]
        public JsonResult Delete(int id)
        {
            return JsonSuccess("Equipo eliminado exitosamente");
        }

        #endregion

        #region Categorías

        [PermissionFilter("CATEGORIAS", "LEER")]
        public ActionResult Categorias(int page = 1, string search = null)
        {
            ViewBag.Title = "Gestión de Categorías";
            return View();
        }

        [HttpGet]
        [PermissionFilter("CATEGORIAS", "LEER")]
        public JsonResult GetCategorias(int page = 1, int pageSize = 10, string search = null)
        {
            try
            {
                CE_PagedResult<CE_CategoriaListDTO> resultado = _negocioCategoria.ObtenerCategoriasPaginadas(page, pageSize, search);

                return JsonSuccess("Categorías obtenidas exitosamente", new
                {
                    items = resultado.Items,
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
            catch (System.Exception ex)
            {
                return JsonError("Error al obtener categorías", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("CATEGORIAS", "CREAR")]
        public JsonResult CreateCategoria(string nombre, string descripcion, bool activo = true)
        {
            try
            {
                var categoriaDTO = new CE_CategoriaCreateDTO
                {
                    Nombre = nombre,
                    Descripcion = descripcion,
                    Activo = activo
                };

                string usuarioCreacion = ObtenerUsernameSesion();
                int idCategoria = _negocioCategoria.CrearCategoria(categoriaDTO, usuarioCreacion);

                return JsonSuccess("Categoría creada exitosamente", new { idCategoria });
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al crear categoría", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("CATEGORIAS", "ACTUALIZAR")]
        public JsonResult UpdateCategoria(int id, string nombre, string descripcion, bool activo)
        {
            try
            {
                var categoriaDTO = new CE_CategoriaUpdateDTO
                {
                    IdCategoria = id,
                    Nombre = nombre,
                    Descripcion = descripcion,
                    Activo = activo
                };

                string usuarioModificacion = ObtenerUsernameSesion();
                _negocioCategoria.ActualizarCategoria(categoriaDTO, usuarioModificacion);

                return JsonSuccess("Categoría actualizada exitosamente");
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al actualizar categoría", ex.Message);
            }
        }

        [HttpPost]
        [PermissionFilter("CATEGORIAS", "ELIMINAR")]
        public JsonResult DeleteCategoria(int id)
        {
            try
            {
                string usuarioEliminacion = ObtenerUsernameSesion();
                _negocioCategoria.EliminarCategoria(id, usuarioEliminacion);

                return JsonSuccess("Categoría eliminada exitosamente");
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al eliminar categoría", ex.Message);
            }
        }

        [HttpGet]
        [PermissionFilter("CATEGORIAS", "LEER")]
        public JsonResult GetCategoriaDetalle(int id)
        {
            try
            {
                var categoria = _negocioCategoria.ObtenerCategoriaPorId(id);

                return JsonSuccess("Detalles obtenidos exitosamente", new
                {
                    id = categoria.IdCategoria,
                    nombre = categoria.Nombre,
                    descripcion = categoria.Descripcion,
                    activo = categoria.Activo,
                    totalSubcategorias = categoria.TotalSubcategorias
                });
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener detalles de categoría", ex.Message);
            }
        }

        #endregion

        #region Marcas

        [PermissionFilter("MARCAS", "LEER")]
        public ActionResult Marcas(int page = 1, string search = null)
        {
            ViewBag.Title = "Gestión de Marcas";
            return ViewOrPartial(); // Soporte SPA
        }

        [HttpGet]
        [PermissionFilter("MARCAS", "LEER")]
        public JsonResult GetMarcas(int page = 1, int pageSize = 10, string search = null)
        {
            return JsonSuccess("Marcas obtenidas exitosamente", new
            {
                items = new object[] { },
                pagination = new
                {
                    currentPage = page,
                    pageSize = pageSize,
                    totalRecords = 0,
                    totalPages = 0,
                    hasPreviousPage = false,
                    hasNextPage = false
                }
            });
        }

        [HttpPost]
        [PermissionFilter("MARCAS", "CREAR")]
        public JsonResult CreateMarca(string nombre, string descripcion, bool activo = true)
        {
            return JsonSuccess("Marca creada exitosamente");
        }

        [HttpPost]
        [PermissionFilter("MARCAS", "ACTUALIZAR")]
        public JsonResult UpdateMarca(int id, string nombre, string descripcion, bool activo)
        {
            return JsonSuccess("Marca actualizada exitosamente");
        }

        [HttpPost]
        [PermissionFilter("MARCAS", "ELIMINAR")]
        public JsonResult DeleteMarca(int id)
        {
            return JsonSuccess("Marca eliminada exitosamente");
        }

        #endregion

        #region Modelos

        [PermissionFilter("MODELOS", "LEER")]
        public ActionResult Modelos(int page = 1, string search = null)
        {
            ViewBag.Title = "Gestión de Modelos";
            return ViewOrPartial(); // Soporte SPA
        }

        [HttpGet]
        [PermissionFilter("MODELOS", "LEER")]
        public JsonResult GetModelos(int page = 1, int pageSize = 10, string search = null, int? marcaId = null)
        {
            return JsonSuccess("Modelos obtenidos exitosamente", new
            {
                items = new object[] { },
                pagination = new
                {
                    currentPage = page,
                    pageSize = pageSize,
                    totalRecords = 0,
                    totalPages = 0,
                    hasPreviousPage = false,
                    hasNextPage = false
                }
            });
        }

        [HttpPost]
        [PermissionFilter("MODELOS", "CREAR")]
        public JsonResult CreateModelo(int marcaId, string nombre, string descripcion, bool activo = true)
        {
            return JsonSuccess("Modelo creado exitosamente");
        }

        [HttpPost]
        [PermissionFilter("MODELOS", "ACTUALIZAR")]
        public JsonResult UpdateModelo(int id, int marcaId, string nombre, string descripcion, bool activo)
        {
            return JsonSuccess("Modelo actualizado exitosamente");
        }

        [HttpPost]
        [PermissionFilter("MODELOS", "ELIMINAR")]
        public JsonResult DeleteModelo(int id)
        {
            return JsonSuccess("Modelo eliminado exitosamente");
        }

        #endregion
    }
}
