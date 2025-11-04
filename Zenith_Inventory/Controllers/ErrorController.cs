using System.Web.Mvc;

namespace Zenith_Inventory.Controllers
{
    public class ErrorController : BaseController
    {
        // GET: Error/AccessDenied
        public ActionResult AccessDenied()
        {
     ViewBag.Title = "Acceso Denegado";
    return ViewOrPartial(); // Soporte SPA
        }

  // GET: Error/NotFound
        public ActionResult NotFound()
     {
            ViewBag.Title = "Página No Encontrada";
 return ViewOrPartial(); // Soporte SPA
    }

   // GET: Error/InternalError
  public ActionResult InternalError()
   {
       ViewBag.Title = "Error Interno";
         return ViewOrPartial(); // Soporte SPA
        }
    }
}
