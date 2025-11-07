using CapaNegocio.Categoria;
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
