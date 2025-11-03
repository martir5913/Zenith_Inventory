using System;
using System.Web;

namespace CapaComun
{
    /// <summary>
    /// Clase para obtener información del contexto web
    /// </summary>
    public static class CC_ContextoWeb
    {
        /// <summary>
        /// Obtiene la dirección IP del cliente
        /// </summary>
        /// <returns>Dirección IP del cliente</returns>
        public static string ObtenerDireccionIP()
        {
            try
            {
                if (HttpContext.Current == null)
                    return "127.0.0.1";

                HttpRequest request = HttpContext.Current.Request;

                // Verificar headers de proxy
                string ip = request.ServerVariables["HTTP_X_FORWARDED_FOR"];

                if (string.IsNullOrEmpty(ip) || ip.ToLower() == "unknown")
                    ip = request.ServerVariables["HTTP_X_REAL_IP"];

                if (string.IsNullOrEmpty(ip) || ip.ToLower() == "unknown")
                    ip = request.ServerVariables["REMOTE_ADDR"];

                if (string.IsNullOrEmpty(ip))
                    ip = request.UserHostAddress;

                // Si hay múltiples IPs, tomar la primera
                if (!string.IsNullOrEmpty(ip) && ip.Contains(","))
                {
                    ip = ip.Split(',')[0].Trim();
                }

                return string.IsNullOrEmpty(ip) ? "127.0.0.1" : ip;
            }
            catch
            {
                return "127.0.0.1";
            }
        }

        /// <summary>
        /// Obtiene el User Agent del navegador
        /// </summary>
        /// <returns>User Agent del navegador</returns>
        public static string ObtenerUserAgent()
        {
            try
            {
                if (HttpContext.Current?.Request?.UserAgent != null)
                {
                    return HttpContext.Current.Request.UserAgent;
                }
                return "Unknown";
            }
            catch
            {
                return "Unknown";
            }
        }

        /// <summary>
        /// Obtiene el nombre del servidor
        /// </summary>
        /// <returns>Nombre del servidor</returns>
        public static string ObtenerNombreServidor()
        {
            try
            {
                if (HttpContext.Current?.Request?.ServerVariables != null)
                {
                    return HttpContext.Current.Request.ServerVariables["SERVER_NAME"] ?? Environment.MachineName;
                }
                return Environment.MachineName;
            }
            catch
            {
                return Environment.MachineName;
            }
        }

        /// <summary>
        /// Obtiene la URL completa de la solicitud actual
        /// </summary>
        /// <returns>URL completa</returns>
        public static string ObtenerUrlCompleta()
        {
            try
            {
                if (HttpContext.Current?.Request?.Url != null)
                {
                    return HttpContext.Current.Request.Url.ToString();
                }
                return string.Empty;
            }
            catch
            {
                return string.Empty;
            }
        }
    }
}