using CapaComun;
using CapaEntidad;
using CapaEntidad.DTOs;
using CapaNegocio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Zenith_Inventory.Controllers
{
    public class AccountController : Controller
    {
        private readonly CN_Autenticacion _cnAutenticacion;
        private readonly CN_Usuario _cnUsuario;

        public AccountController()
        {
            _cnAutenticacion = new CN_Autenticacion();
            _cnUsuario = new CN_Usuario();
        }

        // GET: Account/Login
        public ActionResult Login()
        {
            // Si ya está autenticado, redirigir al dashboard
            if (EstaAutenticado())
            {
                return RedirectToAction("Index", "Home");
            }

            // Redirigir a la vista de login principal en Home
            return RedirectToAction("Login", "Home");
        }

        // POST: Account/Login
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(string username, string password, bool rememberMe = false)
        {
            try
            {
                // Validar entrada
                if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
                {
                    TempData["ErrorMessage"] = "Usuario y contraseña son requeridos";
                    TempData["Username"] = username;
                    return RedirectToAction("Login", "Home");
                }

                // Procesar login
                CE_LoginResponse loginResponse = _cnAutenticacion.ProcesarLogin(username, password);

                if (loginResponse.EsExitoso)
                {
                    // Login exitoso - establecer sesión
                    EstablecerSesionUsuario(loginResponse.Usuario, rememberMe);

                    // Verificar si la contraseña es temporal
                    if (loginResponse.Usuario.USU_PassTemp)
                    {
                        TempData["InfoMessage"] = "Debe cambiar su contraseña temporal antes de continuar.";
                        return RedirectToAction("ChangePassword");
                    }

                    // Mensaje de éxito
                    TempData["SuccessMessage"] = $"Bienvenido, {loginResponse.Usuario.NombreCompleto}";

                    // Redirigir al dashboard
                    return RedirectToAction("Index", "Home");
                }
                else
                {
                    // Login fallido - redirigir con mensaje de error
                    TempData["ErrorMessage"] = loginResponse.Mensaje;
                    TempData["Username"] = username; // Mantener el username en el formulario
                    return RedirectToAction("Login", "Home");
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Error interno del sistema. Por favor, intente nuevamente.";
                TempData["Username"] = username;

                // Log del error
                ErrorLogger.Log(ex, "Error en login");

                return RedirectToAction("Login", "Home");
            }
        }

        // GET: Account/Logout
        public ActionResult Logout()
        {
            try
            {
                // Limpiar sesión
                LimpiarSesion();

                // Mensaje de despedida
                TempData["InfoMessage"] = "Ha cerrado sesión exitosamente";

                return RedirectToAction("Login", "Home");
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en logout");
                return RedirectToAction("Login", "Home");
            }
        }

        // GET: Account/ChangePassword
        public ActionResult ChangePassword()
        {
            if (!EstaAutenticado())
            {
                return RedirectToAction("Login", "Home");
            }
            return View();
        }

        // POST: Account/ChangePassword
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ChangePassword(string newPassword, string confirmPassword)
        {
            try
            {
                if (!EstaAutenticado())
                {
                    return RedirectToAction("Login", "Home");
                }
                if (string.IsNullOrWhiteSpace(newPassword) || string.IsNullOrWhiteSpace(confirmPassword))
                {
                    TempData["ErrorMessage"] = "Ambos campos son requeridos";
                    return View();
                }
                if (newPassword != confirmPassword)
                {
                    TempData["ErrorMessage"] = "Las contraseñas no coinciden";
                    return View();
                }
                // Validar fortaleza de contraseña
                var validacion = _cnUsuario.ValidarFortalezaPassword(newPassword);
                if (!validacion.EsValida)
                {
                    TempData["ErrorMessage"] = validacion.Mensaje;
                    return View();
                }
                // Cambiar contraseña
                string encryptedPassword = _cnAutenticacion.EncriptarPassword(newPassword);
                var result = _cnUsuario.CambiarPassword(ObtenerUserIdSesion(), encryptedPassword, ObtenerUsernameSesion());
                if (result.Resultado == "EXITO")
                {
                    TempData["SuccessMessage"] = "Contraseña cambiada exitosamente";
                    return RedirectToAction("Index", "Home");
                }
                else
                {
                    TempData["ErrorMessage"] = result.Mensaje;
                    return View();
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Error interno del sistema";
                ErrorLogger.Log(ex, "Error en cambio de contraseña");
                return View();
            }
        }

        private void EstablecerSesionUsuario(CE_Usuario usuario, bool rememberMe)
        {
            Session["IsAuthenticated"] = true;
            Session["UserId"] = usuario.USU_Id;
            Session["Username"] = usuario.USU_Username;
            Session["UserName"] = usuario.NombreCompleto;
            Session["UserEmail"] = usuario.USU_Correo;
            Session["UserRoles"] = string.Join(", ", usuario.Roles.ConvertAll(r => r.ROL_Nombre));
            Session["LoginTime"] = DateTime.Now;

            // Establecer timeout de sesión
            Session.Timeout = rememberMe ? 480 : 30; // 8 horas si recuerda, 30 minutos si no

            // Guardar usuario completo en sesión para acceso rápido
            Session["CurrentUser"] = usuario;
        }

        /// <summary>
        /// Limpia toda la información de sesión
        /// </summary>
        private void LimpiarSesion()
        {
            Session.Clear();
            Session.Abandon();

            // Limpiar cookies si existen
            if (Request.Cookies["ASP.NET_SessionId"] != null)
            {
                Response.Cookies["ASP.NET_SessionId"].Value = string.Empty;
                Response.Cookies["ASP.NET_SessionId"].Expires = DateTime.Now.AddMonths(-1);
            }
        }

        /// <summary>
        /// Verifica si el usuario está autenticado
        /// </summary>
        /// <returns>True si está autenticado, False en caso contrario</returns>
        private bool EstaAutenticado()
        {
            return Session["IsAuthenticated"] != null &&
                   (bool)Session["IsAuthenticated"] &&
                   Session["UserId"] != null;
        }

        /// <summary>
        /// Obtiene el ID del usuario de la sesión
        /// </summary>
        /// <returns>ID del usuario</returns>
        private int ObtenerUserIdSesion()
        {
            if (Session["UserId"] != null)
            {
                return (int)Session["UserId"];
            }
            return 0;
        }
        private string ObtenerUsernameSesion()
        {
            return Session["Username"]?.ToString() ?? string.Empty;
        }
        private CE_Usuario ObtenerUsuarioSesion()
        {
            return Session["CurrentUser"] as CE_Usuario;
        }

        #region Métodos de Autorización

        protected bool TienePermiso(string modulo, string accion)
        {
            try
            {
                CE_Usuario usuario = ObtenerUsuarioSesion();
                return _cnAutenticacion.UsuarioTienePermiso(usuario, modulo, accion);
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Verifica si el usuario actual tiene un rol específico
        /// </summary>
        /// <param name="nombreRol">Nombre del rol</param>
        /// <returns>True si tiene el rol, False en caso contrario</returns>
        protected bool TieneRol(string nombreRol)
        {
            try
            {
                CE_Usuario usuario = ObtenerUsuarioSesion();
                return _cnAutenticacion.UsuarioTieneRol(usuario, nombreRol);
            }
            catch
            {
                return false;
            }
        }

        #endregion

        #region Métodos de Desarrollo (Remover en Producción)

        /// <summary>
        /// Acción temporal para configurar el sistema inicial
        /// NOTA: Remover en producción
        /// </summary>
        /// <returns>Resultado de la configuración</returns>
        public ActionResult ConfigurarSistemaInicial()
        {
            try
            {
                string reporte = CN_DesarrolloHelper.EjecutarVerificacionCompleta();
                ViewBag.Reporte = reporte;
                ViewBag.Title = "Configuración Inicial del Sistema";

                return View();
            }
            catch (Exception ex)
            {
                ViewBag.Error = $"Error en configuración inicial: {ex.Message}";
                ViewBag.Title = "Error en Configuración";
                return View();
            }
        }

        /// <summary>
        /// Acción AJAX para actualizar solo la contraseña del admin
        /// NOTA: Remover en producción
        /// </summary>
        /// <returns>Resultado JSON</returns>
        [HttpPost]
        public JsonResult ActualizarPasswordAdmin()
        {
            try
            {
                string passwordEncriptada = CN_DesarrolloHelper.ActualizarPasswordAdmin();

                return Json(new
                {
                    success = true,
                    message = "Contraseña del admin actualizada correctamente",
                    encryptedPassword = passwordEncriptada.Substring(0, Math.Min(50, passwordEncriptada.Length)) + "..."
                });
            }
            catch (Exception ex)
            {
                return Json(new
                {
                    success = false,
                    message = $"Error al actualizar contraseña: {ex.Message}"
                });
            }
        }

        #endregion

        // Método para limpiar sesión desde AJAX
        [HttpPost]
        public JsonResult LogoutAjax()
        {
            try
            {
                LimpiarSesion();
                return Json(new { success = true, message = "Sesión cerrada exitosamente" });
            }
            catch (Exception)
            {
                return Json(new { success = false, message = "Error al cerrar sesión" });
            }
        }

        // Método para verificar estado de sesión desde AJAX
        [HttpPost]
        public JsonResult VerificarSesion()
        {
            try
            {
                bool autenticado = EstaAutenticado();
                return Json(new
                {
                    authenticated = autenticado,
                    userId = autenticado ? ObtenerUserIdSesion() : 0,
                    username = autenticado ? ObtenerUsernameSesion() : string.Empty
                });
            }
            catch
            {
                return Json(new { authenticated = false, userId = 0, username = string.Empty });
            }
        }
    }
}