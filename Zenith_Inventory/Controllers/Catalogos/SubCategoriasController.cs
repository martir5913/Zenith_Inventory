using System.Web.Mvc;
using Zenith_Inventory.Filters;

namespace Zenith_Inventory.Controllers.Catalogos
{
    [AuthenticationFilter]
    public class SubCategoriasController : BaseController
    {
        // GET: SubCategorias
        public ActionResult Index()
        {
            return View();
        }
    }
}