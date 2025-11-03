using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Zenith_Inventory.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            if (!EstaAutenticado())
            {
                return RedirectToAction("Login", "Home");
            }
            return View();
        }

        public ActionResult Login()
        {
            if (EstaAutenticado())
            {
                return RedirectToAction("Index", "Home");
            }
            return View();
        }

        private bool EstaAutenticado()
        {
            return Session["IsAuthenticated"] != null &&
                   (bool)Session["IsAuthenticated"] &&
                   Session["UserId"] != null;
        }
    }
}