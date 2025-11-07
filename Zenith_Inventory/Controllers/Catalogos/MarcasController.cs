using CapaComun;
using CapaEntidad.DTOs.Catalogo;
using CapaEntidad.DTOs.Common;
using CapaNegocio.Catalogo;
using System;
using System.Web.Mvc;
using Zenith_Inventory.Filters;

namespace Zenith_Inventory.Controllers.Catalogos
{
    [AuthenticationFilter]
    public class MarcasController : BaseController
    {
        private readonly CN_Marca _negocioMarca;

        public MarcasController()
        {
            _negocioMarca = new CN_Marca();
        }

        /// <summary>
        /// Vista principal de Marcas
        /// </summary>
        [PermissionFilter("MARCAS", "LEER")]
        public ActionResult Index(int page = 1, string search = null)
        {
            ViewBag.Title = "Gestión de Marcas";
            return View();
        }

        /// <summary>
        /// Obtiene el listado paginado de marcas
        /// </summary>
        [HttpGet]
        [PermissionFilter("MARCAS", "LEER")]
        public JsonResult GetMarcas(int page = 1, int pageSize = 10, string search = null, bool? activo = null)
        {
            try
            {
                CE_PagedResult<CE_MarcaListDTO> resultado = _negocioMarca.ObtenerMarcasPaginadas(
                    page, 
                    pageSize, 
                    search, 
                    activo);

                return JsonSuccess("Marcas obtenidas exitosamente", new
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
            catch (Exception ex)
            {
                return JsonError("Error al obtener marcas", ex.Message);
            }
        }

        /// <summary>
        /// Obtiene los detalles de una marca por ID
        /// </summary>
        [HttpGet]
        [PermissionFilter("MARCAS", "LEER")]
        public JsonResult GetMarcaDetalle(int id)
        {
            try
            {
                var marca = _negocioMarca.ObtenerMarcaPorId(id);

                return JsonSuccess("Marca obtenida exitosamente", new
                {
                    id = marca.IdMarca,
                    nombre = marca.Nombre,
                    descripcion = marca.Descripcion,
                    activo = marca.Activo,
                    totalModelos = marca.TotalModelos,
                    // Información de auditoría
                    fechaCreacion = marca.FechaCreacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioCreacion = marca.UsuarioCreacion,
                    fechaModificacion = marca.FechaModificacion?.ToString("dd/MM/yyyy HH:mm"),
                    usuarioModificacion = marca.UsuarioModificacion
                });
            }
            catch (ArgumentException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al obtener la marca", ex.Message);
            }
        }

        /// <summary>
        /// Crea una nueva marca
        /// </summary>
        [HttpPost]
        [PermissionFilter("MARCAS", "CREAR")]
        public JsonResult Create(CE_MarcaCreateDTO marca)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return JsonError("Datos inválidos", "Por favor complete todos los campos requeridos");
                }

                string usuario = ObtenerUsernameSesion();
                string ip = CC_ContextoWeb.ObtenerDireccionIP();

                int idMarca = _negocioMarca.CrearMarca(marca, usuario, ip);

                return JsonSuccess("Marca creada exitosamente", new { id = idMarca });
            }
            catch (ArgumentException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al crear la marca", ex.Message);
            }
        }

        /// <summary>
        /// Actualiza una marca existente
        /// </summary>
        [HttpPost]
        [PermissionFilter("MARCAS", "ACTUALIZAR")]
        public JsonResult Update(CE_MarcaUpdateDTO marca)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return JsonError("Datos inválidos", "Por favor complete todos los campos requeridos");
                }

                string usuario = ObtenerUsernameSesion();
                string ip = CC_ContextoWeb.ObtenerDireccionIP();

                _negocioMarca.ActualizarMarca(marca, usuario, ip);

                return JsonSuccess("Marca actualizada exitosamente", null);
            }
            catch (ArgumentException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al actualizar la marca", ex.Message);
            }
        }

        /// <summary>
        /// Elimina (lógicamente) una marca
        /// </summary>
        [HttpPost]
        [PermissionFilter("MARCAS", "ELIMINAR")]
        public JsonResult Delete(int id)
        {
            try
            {
                string usuario = ObtenerUsernameSesion();
                string ip = CC_ContextoWeb.ObtenerDireccionIP();

                _negocioMarca.EliminarMarca(id, usuario, ip);

                return JsonSuccess("Marca eliminada exitosamente", null);
            }
            catch (ArgumentException ex)
            {
                return JsonError("Error de validación", ex.Message);
            }
            catch (Exception ex)
            {
                return JsonError("Error al eliminar la marca", ex.Message);
            }
        }
    }
}
