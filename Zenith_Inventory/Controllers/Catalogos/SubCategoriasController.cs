using CapaEntidad.DTOs.Catalogo;
using CapaEntidad.DTOs.Common;
using CapaNegocio.Catalogo;
using System;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;
using Zenith_Inventory.Filters;

namespace Zenith_Inventory.Controllers.Catalogos
{
    [AuthenticationFilter]
    public class SubCategoriasController : BaseController
    {
        public readonly CN_SubCategoria _negocioSubCategoria;

        public SubCategoriasController()
        {
            _negocioSubCategoria = new CN_SubCategoria();
        }
        [PermissionFilter("SUB_CATEGORIAS", "LEER")]
        public ActionResult Index(int page = 1, string search = null)
        {
            ViewBag.Title = "Gestión de SubCategorías";
            return View();
        }

        [HttpGet]
        [PermissionFilter("SUB_CATEGORIAS", "LEER")]
        public JsonResult GetSubCategorias(int page = 1, int pageSize = 10, string search = null, int? idCategoria = null, bool? activo = null)
        {
            try
            {
                CE_PagedResult<CE_SubCategoriaListDTO> resultado = _negocioSubCategoria.ObtenerSubCategoriasPaginadas(page, pageSize, search, idCategoria, activo);

                return JsonSuccess("SubCategorías obtenidas exitosamente", new
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
                return JsonError("Error al obtener Subcategorías", ex.Message);
            }
        }
        [HttpGet]
        [PermissionFilter("SUB_CATEGORIAS", "LEER")]
        public JsonResult DetalleSubCat(int id)
        {
            try
            {
                var resultado = _negocioSubCategoria.SubCategoriaPorId(id);

                return JsonSuccess("SubCategoria obtenida exitosamente", new
                {
                    idSubCat = resultado.IdSubCategoria,
                    nombre = resultado.Nombre,
                    descripcion = resultado.Descripcion,
                    estado = resultado.Estado,
                    idCat = resultado.IdCategoria,
                    nombreCat = resultado.NombreCategoria,
                    totalModelos = resultado.TotalModelos,
                    // Información de auditoría
                    fechaCreacion = resultado.FechaCreacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioCreacion = resultado.UsuarioCreacion,
                    fechaModificacion = resultado.FechaModificacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioModificacion = resultado.UsuarioModificacion
                });
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validacion", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener la Subcategoria", ex.Message);
            }
        }
        [HttpPost]
        [PermissionFilter("SUB_CATEGORIAS", "ACTUALIZAR")]
        public JsonResult UpdateSubCategoria(int id, string nombre, int idCategoria, string descripcion, bool activo)
        {
            try
            {
                var objSubCategoria = new CE_SubCategoriaUpdateDTO
                {
                    IdSubCate = id,
                    IdCategoria = idCategoria,
                    Nombre = nombre,
                    Descripcion = descripcion,
                    activo = activo
                };

                objSubCategoria.usuarioModificacion = ObtenerUsernameSesion();

                bool resultado = _negocioSubCategoria.ActualizarSubCat(objSubCategoria);

                if (resultado)
                {
                    return JsonSuccess("SubCategoría actualizada exitosamente");
                }
                else
                {
                    return JsonError("No se pudo actualizar la Subcategoría", "La operación no se completó");
                }
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al actualizar Subcategoría", ex.Message);
            }
        }
        [HttpPost]
        [PermissionFilter("SUB_CATEGORIAS", "ELIMINAR")]
        public JsonResult DeleteSubCategoria(int id)
        {
            try
            {
                string usuarioEliminacion = ObtenerUsernameSesion();
                bool resultado = _negocioSubCategoria.BorrarSubCat(id, usuarioEliminacion);

                if (resultado)
                {
                    return JsonSuccess("SubCategoría eliminada exitosamente");
                }
                else
                {
                    return JsonError("No se pudo eliminar la Subcategoría", "La operación no se completó");
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
        [HttpPost]
        [PermissionFilter("SUB_CATEGORIAS", "CREAR")]
        public JsonResult CreateSubcategoria(string nombre, int idCat, string descripcion, bool activo = true)
        {
            try
            {
                var subcategoria = new CE_SubCategoriaCreateDTO
                {
                    Nombre = nombre,
                    IdCategoria = idCat,
                    Descripcion = descripcion,
                    Activo = activo
                };

                subcategoria.UsuarioCreacion = ObtenerUsernameSesion();

                int idCategoria = _negocioSubCategoria.CrearSubCat(subcategoria);

                return JsonSuccess("SubCategoría creada exitosamente", new { idCategoria });
            }
            catch (ValidationException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError($"Error al crear Subcategoría {ex.Message}", ex.Message);
            }
        }
    }
}