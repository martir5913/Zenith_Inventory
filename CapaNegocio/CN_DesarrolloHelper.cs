using CapaComun;
using CapaDatos;
using CapaEntidad;
using CapaEntidad.DTOs;
using System;
using System.Data.SqlClient;

namespace CapaNegocio
{
    /// <summary>
    /// Clase temporal para ayudar en tareas de desarrollo
    /// NOTA: Esta clase debe ser removida en producción
    /// </summary>
    public static class CN_DesarrolloHelper
    {
        /// <summary>
        /// Encripta la contraseña 'admin' usando la configuración del sistema
        /// y la actualiza en la base de datos
        /// </summary>
        /// <returns>Contraseña encriptada</returns>
        public static string ActualizarPasswordAdmin()
        {
            try
            {
                CN_Autenticacion cnAuth = new CN_Autenticacion();

                // Encriptar la contraseña "admin"
                string passwordEncriptada = cnAuth.EncriptarPassword("admin");

                // Actualizar en la base de datos
                string query = @"
                    UPDATE PM_USUARIOS 
                    SET USR_PASSWORD_ENCRYPTED = @PasswordEncriptada,
                        USR_FECHA_MODIFICACION = GETDATE(),
                        USR_USUARIO_MODIFICACION = 'SYSTEM_SETUP',
                        USR_IP_MODIFICACION = '127.0.0.1'
                    WHERE USR_USERNAME = 'admin'";

                using (SqlConnection conexion = new CC_Conexion().ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand(query, conexion))
                    {
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@PasswordEncriptada", passwordEncriptada, System.Data.SqlDbType.NVarChar, 500));

                        conexion.Open();
                        int filasAfectadas = comando.ExecuteNonQuery();

                        if (filasAfectadas > 0)
                        {
                            return passwordEncriptada;
                        }
                        else
                        {
                            ErrorLogger.LogCustom("No se encontró el usuario admin o no se pudo actualizar en ActualizarPasswordAdmin");
                            throw new Exception("No se encontró el usuario admin o no se pudo actualizar");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al actualizar contraseña del admin en ActualizarPasswordAdmin");
                throw new Exception($"Error al actualizar contraseña del admin: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Verifica que la configuración de encriptación esté correcta
        /// </summary>
        /// <returns>Resultado de la verificación</returns>
        public static (bool EsCorrecta, string Mensaje, CE_EncryptionConfig Config) VerificarConfiguracionEncriptacion()
        {
            try
            {
                CD_Configuracion cdConfig = new CD_Configuracion();
                CE_EncryptionConfig config = cdConfig.ObtenerConfiguracionEncriptacion();

                if (config == null)
                {
                    ErrorLogger.LogCustom("No se pudo obtener la configuración de encriptación en VerificarConfiguracionEncriptacion");
                    return (false, "No se pudo obtener la configuración de encriptación", null);
                }

                if (string.IsNullOrEmpty(config.Key))
                {
                    ErrorLogger.LogCustom("La clave de encriptación está vacía en VerificarConfiguracionEncriptacion");
                    return (false, "La clave de encriptación está vacía", config);
                }

                if (string.IsNullOrEmpty(config.Salt))
                {
                    ErrorLogger.LogCustom("El salt de encriptación está vacío en VerificarConfiguracionEncriptacion");
                    return (false, "El salt de encriptación está vacío", config);
                }

                if (string.IsNullOrEmpty(config.IV))
                {
                    ErrorLogger.LogCustom("El vector inicial está vacío en VerificarConfiguracionEncriptacion");
                    return (false, "El vector inicial está vacío", config);
                }

                // Prueba de encriptación/desencriptación
                string pruebaTexto = "test123";
                string encriptado = CC_Encriptacion.Encriptar(pruebaTexto, config.Key, config.Salt, config.IV);
                string desencriptado = CC_Encriptacion.Desencriptar(encriptado, config.Key, config.Salt, config.IV);

                if (pruebaTexto != desencriptado)
                {
                    ErrorLogger.LogCustom("Error en la prueba de encriptación/desencriptación en VerificarConfiguracionEncriptacion");
                    return (false, "Error en la prueba de encriptación/desencriptación", config);
                }

                return (true, "Configuración de encriptación correcta", config);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al verificar configuración en VerificarConfiguracionEncriptacion");
                return (false, $"Error al verificar configuración: {ex.Message}", null);
            }
        }

        /// <summary>
        /// Prueba el login del usuario admin
        /// </summary>
        /// <returns>Resultado de la prueba</returns>
        public static (bool EsExitoso, string Mensaje) ProbarLoginAdmin()
        {
            try
            {
                CN_Autenticacion cnAuth = new CN_Autenticacion();
                CE_LoginResponse response = cnAuth.ProcesarLogin("admin", "admin");

                if (response.EsExitoso)
                {
                    return (true, $"Login exitoso. Usuario: {response.Usuario?.NombreCompleto ?? "Admin"}");
                }
                else
                {
                    ErrorLogger.LogCustom($"Login fallido: {response.Mensaje} en ProbarLoginAdmin");
                    return (false, $"Login fallido: {response.Mensaje}");
                }
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en prueba de login en ProbarLoginAdmin");
                return (false, $"Error en prueba de login: {ex.Message}");
            }
        }

        /// <summary>
        /// Ejecuta todas las verificaciones de configuración inicial
        /// </summary>
        /// <returns>Reporte completo</returns>
        public static string EjecutarVerificacionCompleta()
        {
            string reporte = "=== VERIFICACIÓN DE CONFIGURACIÓN INICIAL ===\n\n";

            try
            {
                // 1. Verificar configuración de encriptación
                reporte += "1. CONFIGURACIÓN DE ENCRIPTACIÓN:\n";
                var configResult = VerificarConfiguracionEncriptacion();
                reporte += $"   Estado: {(configResult.EsCorrecta ? "? CORRECTA" : "? ERROR")}\n";
                reporte += $"   Mensaje: {configResult.Mensaje}\n";

                if (configResult.Config != null)
                {
                    reporte += $"   Key: {configResult.Config.Key?.Substring(0, Math.Min(20, configResult.Config.Key.Length))}...\n";
                    reporte += $"   Salt: {configResult.Config.Salt?.Substring(0, Math.Min(20, configResult.Config.Salt.Length))}...\n";
                    reporte += $"   IV: {configResult.Config.IV?.Substring(0, Math.Min(15, configResult.Config.IV.Length))}...\n";
                }
                reporte += "\n";

                // 2. Actualizar contraseña admin si es necesario
                reporte += "2. CONTRASEÑA DEL USUARIO ADMIN:\n";
                try
                {
                    string passwordEncriptada = ActualizarPasswordAdmin();
                    reporte += "   Estado: ? ACTUALIZADA CORRECTAMENTE\n";
                    reporte += $"   Password encriptada: {passwordEncriptada.Substring(0, Math.Min(30, passwordEncriptada.Length))}...\n";
                }
                catch (Exception ex)
                {
                    reporte += $"   Estado: ? ERROR AL ACTUALIZAR\n";
                    reporte += $"   Error: {ex.Message}\n";
                }
                reporte += "\n";

                // 3. Probar login
                reporte += "3. PRUEBA DE LOGIN:\n";
                var loginResult = ProbarLoginAdmin();
                reporte += $"   Estado: {(loginResult.EsExitoso ? "? EXITOSO" : "? FALLIDO")}\n";
                reporte += $"   Mensaje: {loginResult.Mensaje}\n";
                reporte += "\n";

                reporte += "=== FIN DE VERIFICACIÓN ===\n";
                reporte += "\nCredenciales de prueba:\n";
                reporte += "Usuario: admin\n";
                reporte += "Contraseña: admin\n";

            }
            catch (Exception ex)
            {
                reporte += $"\nERROR GENERAL: {ex.Message}\n";
            }

            return reporte;
        }
    }
}