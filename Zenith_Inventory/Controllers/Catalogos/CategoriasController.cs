using CapaComun.Excepciones;
using CapaEntidad.DTOs.Catalogo;
using CapaEntidad.DTOs.Common;
using CapaNegocio.Categoria;
using System;
using System.Web.Mvc;
using Zenith_Inventory.Filters;

namespace Zenith_Inventory.Controllers.Catalogos
{
    [AuthenticationFilter]
    public class CategoriasController : BaseController
    {
        private readonly CN_Categoria _negocioCategoria;

        public CategoriasController()
        {
            _negocioCategoria = new CN_Categoria();
        }
        // GET: Categorias
        [PermissionFilter("CATEGORIAS", "LEER")]
        public ActionResult Index(int page = 1, string search = null)
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
                return JsonError($"Error al crear categoría {ex.Message}", ex.Message);
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
                bool resultado = _negocioCategoria.ActualizarCategoria(categoriaDTO, usuarioModificacion);

                if (resultado)
                {
                    return JsonSuccess("Categoría actualizada exitosamente");
                }
                else
                {
                    return JsonError("No se pudo actualizar la categoría", "La operación no se completó");
                }
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
                bool resultado = _negocioCategoria.EliminarCategoria(id, usuarioEliminacion);

                if (resultado)
                {
                    return JsonSuccess("Categoría eliminada exitosamente");
                }
                else
                {
                    return JsonError("No se pudo eliminar la categoría", "La operación no se completó");
                }
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
                    totalSubcategorias = categoria.TotalSubcategorias,
                    // Información de auditoría
                    fechaCreacion = categoria.FechaCreacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioCreacion = categoria.UsuarioCreacion,
                    fechaModificacion = categoria.FechaModificacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioModificacion = categoria.UsuarioModificacion
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
    }
}