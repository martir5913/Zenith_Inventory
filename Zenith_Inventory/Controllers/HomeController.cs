using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Zenith_Inventory.Filters;

namespace Zenith_Inventory.Controllers
{
    public class HomeController : BaseController
    {
        [AuthenticationFilter]
        public ActionResult Index()
        {
            // Soporte SPA - Devuelve PartialView si es petición AJAX
            return ViewOrPartial();
        }

        [AllowAnonymous]
        public ActionResult Login()
        {
            if (EstaAutenticado())
            {
                return RedirectToAction("Index", "Home");
            }

            // Login siempre devuelve vista completa (con Layout)
            // No debe usar SPA porque no está autenticado
            return View();
        }
    }
}