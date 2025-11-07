using System;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace Zenith_Inventory.Filters
{
    /// <summary>
    /// Filtro para validar que el usuario esté autenticado
    /// </summary>
    public class AuthenticationFilter : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            // Verificar si la acción o el controlador tienen el atributo AllowAnonymous
            var allowAnonymous = filterContext.ActionDescriptor.GetCustomAttributes(typeof(System.Web.Mvc.AllowAnonymousAttribute), true).Any() ||
                 filterContext.ActionDescriptor.ControllerDescriptor.GetCustomAttributes(typeof(System.Web.Mvc.AllowAnonymousAttribute), true).Any();

            if (allowAnonymous)
             {
                base.OnActionExecuting(filterContext);
                return;
            }

            HttpSessionStateBase session = filterContext.HttpContext.Session;

            // Verificar si el usuario está autenticado
            bool estaAutenticado = session != null &&
  session["IsAuthenticated"] != null &&
            (bool)session["IsAuthenticated"] &&
        session["UserId"] != null;

            if (!estaAutenticado)
 {
  // Si es una petición AJAX, devolver JSON
     if (filterContext.HttpContext.Request.IsAjaxRequest())
            {
         filterContext.Result = new JsonResult
   {
          Data = new
           {
        success = false,
   authenticated = false,
  message = "Su sesión ha expirado. Por favor, inicie sesión nuevamente."
            },
         JsonRequestBehavior = JsonRequestBehavior.AllowGet
        };
    }
         else
       {
          // Redirigir al login
            filterContext.Result = new RedirectToRouteResult(
         new RouteValueDictionary
 {
            { "controller", "Home" },
    { "action", "Login" }
         });
           }
     }

            base.OnActionExecuting(filterContext);
        }
    }
}
