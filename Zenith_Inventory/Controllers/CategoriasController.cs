using CapaComun;
using CapaComun.Excepciones;
using CapaEntidad.DTOs.Categoria;
using CapaNegocio.Categoria;
using System;
using System.Web.Mvc;

namespace Zenith_Inventory.Controllers
{
    [RoutePrefix("Categorias")]
    public class CategoriasController : BaseController
    {
        private readonly CN_Categoria _categoriaNegocio;

        public CategoriasController()
        {
            _categoriaNegocio = new CN_Categoria();
        }

        [HttpGet]
        [Route("")]
        public ActionResult Index()
        {
            if (!EstaAutenticado())
                return RedirectToAction("Login", "Account");

            return ViewOrPartial();
        }

        [HttpGet]
        [Route("Listar")]
        public JsonResult Listar(int pageNumber = 1, int pageSize = 10, string searchTerm = null)
        {
            try
            {
                if (!EstaAutenticado())
                    return JsonAccessDenied("Debe iniciar sesión");

                var resultado = _categoriaNegocio.ObtenerCategoriasPaginadas(
                       pageNumber,
                    pageSize,
                   searchTerm
                            );

                return Json(new
                {
                    success = true,
                    data = resultado.Items,
                    pagination = new
                    {
                        currentPage = resultado.PageNumber,
                        pageSize = resultado.PageSize,
                        totalPages = resultado.TotalPages,
                        totalRecords = resultado.TotalRecords,
                        hasPreviousPage = resultado.HasPreviousPage,
                        hasNextPage = resultado.HasNextPage
                    }
                }, JsonRequestBehavior.AllowGet);
            }
            catch (ValidationException ex)
            {
                return Json(new
                {
                    success = false,
                    message = ex.Message,
                    errorType = "validation"
                }, JsonRequestBehavior.AllowGet);
            }
            catch (BusinessLogicException ex)
            {
                return Json(new
                {
                    success = false,
                    message = ex.Message,
                    errorType = "business"
                }, JsonRequestBehavior.AllowGet);
            }
            catch (DataAccessException ex)
            {
                ErrorLogger.Log(ex, "Error al listar categorías");
                return Json(new
                {
                    success = false,
                    message = "Error al acceder a los datos. Por favor, intente nuevamente.",
                    errorType = "data"
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error inesperado al listar categorías");
                return Json(new
                {
                    success = false,
                    message = "Ha ocurrido un error inesperado. Contacte al administrador.",
                    errorType = "unexpected"
                }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [Route("Obtener/{id}")]
        public JsonResult Obtener(int id)
        {
            try
            {
                if (!EstaAutenticado())
                    return JsonAccessDenied("Debe iniciar sesión");

                return JsonSuccess("Categoría obtenida", new { id = id });
            }
            catch (ValidationException ex)
            {
                return Json(new
                {
                    success = false,
                    message = ex.Message,
                    errorType = "validation"
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al obtener categoría {id}");
                return JsonError("Error al obtener la categoría");
            }
        }

        [HttpPost]
        [Route("Crear")]
        [ValidateAntiForgeryToken]
        public JsonResult Crear(CE_CategoriaCreateDTO categoria)
        {
            try
            {
                if (!EstaAutenticado())
                    return JsonAccessDenied("Debe iniciar sesión");

                if (!ModelState.IsValid)
                {
                    return Json(new
                    {
                        success = false,
                        message = "Datos de entrada inválidos",
                        errors = ModelState.Values,
                        errorType = "validation"
                    });
                }

                return JsonSuccess("Categoría creada exitosamente", new { id = 1 });
            }
            catch (ValidationException ex)
            {
                return Json(new
                {
                    success = false,
                    message = ex.Message,
                    errorType = "validation"
                });
            }
            catch (BusinessLogicException ex)
            {
                return Json(new
                {
                    success = false,
                    message = ex.Message,
                    errorType = "business"
                });
            }
            catch (DataAccessException ex)
            {
                ErrorLogger.Log(ex, "Error al crear categoría");
                return JsonError("Error al guardar la categoría");
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error inesperado al crear categoría");
                return JsonError("Ha ocurrido un error inesperado");
            }
        }

        [HttpPost]
        [Route("Actualizar")]
        [ValidateAntiForgeryToken]
        public JsonResult Actualizar(CE_CategoriaUpdateDTO categoria)
        {
            try
            {
                if (!EstaAutenticado())
                    return JsonAccessDenied("Debe iniciar sesión");

                if (!ModelState.IsValid)
                {
                    return JsonError("Datos de entrada inválidos");
                }

                return JsonSuccess("Categoría actualizada exitosamente");
            }
            catch (ValidationException ex)
            {
                return JsonError(ex.Message);
            }
            catch (BusinessLogicException ex)
            {
                return JsonError(ex.Message);
            }
            catch (DataAccessException ex)
            {
                ErrorLogger.Log(ex, "Error al actualizar categoría");
                return JsonError("Error al actualizar la categoría");
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error inesperado al actualizar categoría");
                return JsonError("Ha ocurrido un error inesperado");
            }
        }

        [HttpPost]
        [Route("Eliminar/{id}")]
        [ValidateAntiForgeryToken]
        public JsonResult Eliminar(int id)
        {
            try
            {
                if (!EstaAutenticado())
                    return JsonAccessDenied("Debe iniciar sesión");

                // TODO: Implementar método en capa de negocio
                // var resultado = _categoriaNegocio.EliminarCategoria(id);

                return JsonSuccess("Categoría eliminada exitosamente");
            }
            catch (ValidationException ex)
            {
                return JsonError(ex.Message);
            }
            catch (BusinessLogicException ex)
            {
                return JsonError(ex.Message);
            }
            catch (DataAccessException ex)
            {
                ErrorLogger.Log(ex, $"Error al eliminar categoría {id}");
                return JsonError("Error al eliminar la categoría");
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error inesperado al eliminar categoría {id}");
                return JsonError("Ha ocurrido un error inesperado");
            }
        }

        [HttpPost]
        [Route("CambiarEstado/{id}")]
        [ValidateAntiForgeryToken]
        public JsonResult CambiarEstado(int id, bool activo)
        {
            try
            {
                if (!EstaAutenticado())
                    return JsonAccessDenied("Debe iniciar sesión");

                // TODO: Implementar método en capa de negocio
                // var resultado = _categoriaNegocio.CambiarEstadoCategoria(id, activo);

                string mensaje = activo ? "Categoría activada" : "Categoría desactivada";
                return JsonSuccess(mensaje);
            }
            catch (ValidationException ex)
            {
                return JsonError(ex.Message);
            }
            catch (BusinessLogicException ex)
            {
                return JsonError(ex.Message);
            }
            catch (DataAccessException ex)
            {
                ErrorLogger.Log(ex, $"Error al cambiar estado de categoría {id}");
                return JsonError("Error al cambiar el estado de la categoría");
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error inesperado al cambiar estado de categoría {id}");
                return JsonError("Ha ocurrido un error inesperado");
            }
        }
    }
}
