using CapaEntidad;
using System;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace Zenith_Inventory.Filters
{
    /// <summary>
    /// Filtro para validar permisos específicos basados en módulo y acción
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false)]
    public class PermissionFilter : ActionFilterAttribute
    {
        public string Modulo { get; set; }
        public string Accion { get; set; }

        public PermissionFilter(string modulo, string accion)
        {
            Modulo = modulo;
            Accion = accion;
        }

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

            // Verificar autenticación primero
            bool estaAutenticado = session != null &&
                session["IsAuthenticated"] != null &&
                (bool)session["IsAuthenticated"] &&
                session["UserId"] != null;

            if (!estaAutenticado)
            {
                RedirectToLogin(filterContext);
                return;
            }

            // Obtener usuario de sesión
            CE_Usuario usuario = session["CurrentUser"] as CE_Usuario;

            if (usuario == null)
            {
                RedirectToLogin(filterContext);
                return;
            }

            // Verificar si tiene el permiso
            bool tienePermiso = TienePermiso(usuario, Modulo, Accion);

            if (!tienePermiso)
            {
                bool isAjaxRequest = filterContext.HttpContext.Request.IsAjaxRequest() ||
                filterContext.HttpContext.Request.QueryString["ajax"] == "true";

                if (isAjaxRequest)
                {
                    filterContext.Result = new ContentResult
                    {
                        Content = @"
     <div class='container mt-5'>
    <div class='alert alert-danger text-center' role='alert'>
     <i class='bi bi-shield-exclamation' style='font-size: 3rem;'></i>
    <h2 class='mt-3'>Acceso Denegado</h2>
             <p class='lead'>No tiene permisos para acceder a esta sección.</p>
         <hr>
          <p class='mb-0'>
     Si cree que esto es un error, contacte al administrador del sistema.
          </p>
  <button class='btn btn-primary mt-3' onclick='window.history.back()'>
     <i class='bi bi-arrow-left'></i> Volver
   </button>
       </div>
         </div>
             ",
                        ContentType = "text/html"
                    };
                }
                else
                {
                    // Redirigir a página de acceso denegado
                    filterContext.Result = new RedirectToRouteResult(
                        new RouteValueDictionary
                        {
                            { "controller", "Error" },
                            { "action", "AccessDenied" }
                        });
                }
            }

            base.OnActionExecuting(filterContext);
        }

        private bool TienePermiso(CE_Usuario usuario, string modulo, string accion)
        {
            try
            {
                if (usuario?.Permisos == null)
                    return false;

                foreach (var permiso in usuario.Permisos)
                {
                    if (permiso.PER_Modulo.Equals(modulo, StringComparison.OrdinalIgnoreCase) &&
                        permiso.PER_Accion.Equals(accion, StringComparison.OrdinalIgnoreCase) &&
                        permiso.PER_Activo)
                    {
                        return true;
                    }
                }

                return false;
            }
            catch
            {
                return false;
            }
        }

        private void RedirectToLogin(ActionExecutingContext filterContext)
        {
            bool isAjaxRequest = filterContext.HttpContext.Request.IsAjaxRequest() ||
          filterContext.HttpContext.Request.QueryString["ajax"] == "true";

            if (isAjaxRequest)
            {
                filterContext.Result = new JsonResult
                {
                    Data = new
                    {
                        success = false,
                        authenticated = false,
                        accessDenied = true,
                        message = "Su sesión ha expirado. Por favor, inicie sesión nuevamente."
                    },
                    JsonRequestBehavior = JsonRequestBehavior.AllowGet
                };
            }
            else
            {
                filterContext.Result = new RedirectToRouteResult(
                    new RouteValueDictionary
                    {
                        { "controller", "Home" },
                        { "action", "Login" }
                    });
            }
        }
    }
}
