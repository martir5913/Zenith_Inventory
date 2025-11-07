using CapaEntidad;
using System.Web.Mvc;

namespace Zenith_Inventory.Controllers
{
    /// <summary>
    /// Controlador base con métodos de autenticación y autorización
    /// </summary>
    public class BaseController : Controller
    {
        /// <summary>
        /// Verifica si el usuario está autenticado
 /// </summary>
        /// <returns>True si está autenticado, False en caso contrario</returns>
        protected bool EstaAutenticado()
        {
            return Session["IsAuthenticated"] != null &&
          (bool)Session["IsAuthenticated"] &&
    Session["UserId"] != null;
        }

     /// <summary>
        /// Obtiene el ID del usuario de la sesión
   /// </summary>
        /// <returns>ID del usuario</returns>
 protected int ObtenerUserIdSesion()
        {
            if (Session["UserId"] != null)
   {
      return (int)Session["UserId"];
    }
      return 0;
        }

   /// <summary>
        /// Obtiene el username del usuario de la sesión
   /// </summary>
        /// <returns>Username del usuario</returns>
   protected string ObtenerUsernameSesion()
        {
            return Session["Username"]?.ToString() ?? string.Empty;
     }

        /// <summary>
        /// Obtiene el usuario completo de la sesión
        /// </summary>
      /// <returns>Usuario completo con roles y permisos</returns>
        protected CE_Usuario ObtenerUsuarioSesion()
      {
        return Session["CurrentUser"] as CE_Usuario;
        }

        /// <summary>
   /// Verifica si el usuario tiene un permiso específico
/// </summary>
        /// <param name="modulo">Módulo del permiso</param>
        /// <param name="accion">Acción del permiso</param>
        /// <returns>True si tiene el permiso, False en caso contrario</returns>
   protected bool TienePermiso(string modulo, string accion)
        {
            try
            {
  CE_Usuario usuario = ObtenerUsuarioSesion();
      
       if (usuario?.Permisos == null)
                    return false;

      foreach (var permiso in usuario.Permisos)
                {
 if (permiso.PER_Modulo.Equals(modulo, System.StringComparison.OrdinalIgnoreCase) &&
    permiso.PER_Accion.Equals(accion, System.StringComparison.OrdinalIgnoreCase) &&
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

        /// <summary>
        /// Verifica si el usuario tiene un rol específico
        /// </summary>
        /// <param name="nombreRol">Nombre del rol</param>
        /// <returns>True si tiene el rol, False en caso contrario</returns>
        protected bool TieneRol(string nombreRol)
        {
  try
      {
        CE_Usuario usuario = ObtenerUsuarioSesion();
             
     if (usuario?.Roles == null)
  return false;

              foreach (var rol in usuario.Roles)
      {
 if (rol.ROL_Nombre.Equals(nombreRol, System.StringComparison.OrdinalIgnoreCase) && 
         rol.ROL_Activo)
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

        /// <summary>
        /// Devuelve un JSON con éxito
  /// </summary>
      protected JsonResult JsonSuccess(string message, object data = null)
        {
       return Json(new
            {
   success = true,
       message = message,
                data = data
     }, JsonRequestBehavior.AllowGet);
   }

   /// <summary>
/// Devuelve un JSON con error
        /// </summary>
     protected JsonResult JsonError(string message, object error = null)
        {
            return Json(new
       {
    success = false,
      message = message,
                error = error
         }, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// Devuelve un JSON de acceso denegado
        /// </summary>
    protected JsonResult JsonAccessDenied(string message = "No tiene permisos para realizar esta acción")
    {
            return Json(new
 {
          success = false,
                accessDenied = true,
   message = message
            }, JsonRequestBehavior.AllowGet);
    }

     /// <summary>
/// Devuelve vista o vista parcial según sea petición AJAX
      /// </summary>
protected ActionResult ViewOrPartial(string viewName = null)
{
    bool isAjaxRequest = Request.IsAjaxRequest() || Request.QueryString["ajax"] == "true";
 
       if (isAjaxRequest)
        {
      return viewName != null ? PartialView(viewName) : PartialView();
    }
    
   return viewName != null ? View(viewName) : View();
        }

        /// <summary>
   /// Devuelve vista o vista parcial con modelo según sea petición AJAX
        /// </summary>
        protected ActionResult ViewOrPartial(object model)
        {
  bool isAjaxRequest = Request.IsAjaxRequest() || Request.QueryString["ajax"] == "true";
       
       if (isAjaxRequest)
 {
   return PartialView(model);
    }
   
       return View(model);
 }

     /// <summary>
        /// Devuelve vista o vista parcial con nombre y modelo según sea petición AJAX
        /// </summary>
  protected ActionResult ViewOrPartial(string viewName, object model)
{
    bool isAjaxRequest = Request.IsAjaxRequest() || Request.QueryString["ajax"] == "true";
       
  if (isAjaxRequest)
  {
 return PartialView(viewName, model);
    }
            
   return View(viewName, model);
        }

   /// <summary>
        /// Verifica si la petición es AJAX/SPA
/// </summary>
     protected bool EsPeticionAjax()
{
  return Request.IsAjaxRequest() || Request.QueryString["ajax"] == "true";
  }
  }
}
