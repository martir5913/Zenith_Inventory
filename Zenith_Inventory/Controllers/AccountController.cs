using CapaComun;
using CapaEntidad;
using CapaEntidad.DTOs;
using CapaNegocio;
using System;
using System.Web.Mvc;
using Zenith_Inventory.Filters;

namespace Zenith_Inventory.Controllers
{
    public class AccountController : BaseController
    {
        private readonly CN_Autenticacion _cnAutenticacion;
        private readonly CN_Usuario _cnUsuario;

        public AccountController()
        {
            _cnAutenticacion = new CN_Autenticacion();
            _cnUsuario = new CN_Usuario();
        }

        // GET: Account/Login
        [AllowAnonymous]
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
        [AllowAnonymous]
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
        [AuthenticationFilter]
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
        [AuthenticationFilter]
        public ActionResult ChangePassword()
        {
            return ViewOrPartial(); // Soporte SPA
        }

        // POST: Account/ChangePassword
        [HttpPost]
        [AuthenticationFilter]
        [ValidateAntiForgeryToken]
        public ActionResult ChangePassword(string newPassword, string confirmPassword)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(newPassword) || string.IsNullOrWhiteSpace(confirmPassword))
                {
                    TempData["ErrorMessage"] = "Ambos campos son requeridos";
                    return ViewOrPartial(); // Soporte SPA
                }

                if (newPassword != confirmPassword)
                {
                    TempData["ErrorMessage"] = "Las contraseñas no coinciden";
                    return ViewOrPartial(); // Soporte SPA
                }

                // Validar fortaleza de contraseña
                var validacion = _cnUsuario.ValidarFortalezaPassword(newPassword);
                if (!validacion.EsValida)
                {
                    TempData["ErrorMessage"] = validacion.Mensaje;
                    return ViewOrPartial(); // Soporte SPA
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
                    return ViewOrPartial(); // Soporte SPA
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Error interno del sistema";
                ErrorLogger.Log(ex, "Error en cambio de contraseña");
                return ViewOrPartial(); // Soporte SPA
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

        #region Métodos de Desarrollo (Remover en Producción)

        /// <summary>
        /// Acción temporal para configurar el sistema inicial
        /// NOTA: Remover en producción
        /// </summary>
        /// <returns>Resultado de la configuración</returns>
        [AllowAnonymous]
        public ActionResult ConfigurarSistemaInicial()
        {
            try
            {
                string reporte = CN_DesarrolloHelper.EjecutarVerificacionCompleta();
                ViewBag.Reporte = reporte;
                ViewBag.Title = "Configuración Inicial del Sistema";

                return ViewOrPartial(); // Soporte SPA
            }
            catch (Exception ex)
            {
                ViewBag.Error = $"Error en configuración inicial: {ex.Message}";
                ViewBag.Title = "Error en Configuración";
                return ViewOrPartial(); // Soporte SPA
            }
        }

        /// <summary>
        /// Acción AJAX para actualizar solo la contraseña del admin
        /// NOTA: Remover en producción
        /// </summary>
        /// <returns>Resultado JSON</returns>
        [HttpPost]
        [AllowAnonymous]
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
        [AllowAnonymous]
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
        [AllowAnonymous]
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