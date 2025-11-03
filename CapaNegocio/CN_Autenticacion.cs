using CapaComun;
using CapaDatos;
using CapaEntidad;
using CapaEntidad.DTOs;
using System;

namespace CapaNegocio
{
    /// <summary>
    /// Capa de negocio para manejo de autenticación
    /// </summary>
    public class CN_Autenticacion
    {
        private readonly CD_Usuario _cdUsuario;
        private readonly CD_Configuracion _cdConfiguracion;

        public CN_Autenticacion()
        {
            _cdUsuario = new CD_Usuario();
            _cdConfiguracion = new CD_Configuracion();
        }

        /// <summary>
        /// Realiza el proceso completo de login
        /// </summary>
        /// <param name="username">Nombre de usuario</param>
        /// <param name="password">Contraseña en texto plano</param>
        /// <returns>Respuesta del login con información del usuario</returns>
        public CE_LoginResponse ProcesarLogin(string username, string password)
        {
            try
            {
                // Validar parámetros de entrada
                if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
                {
                    ErrorLogger.LogCustom("Usuario y contraseña son requeridos en ProcesarLogin");
                    return new CE_LoginResponse
                    {
                        Resultado = "ERROR",
                        Mensaje = "Usuario y contraseña son requeridos",
                        UserId = 0
                    };
                }

                // Obtener configuración de encriptación
                CE_EncryptionConfig encryptionConfig = _cdConfiguracion.ObtenerConfiguracionEncriptacion();

                if (encryptionConfig == null || string.IsNullOrEmpty(encryptionConfig.Key))
                {
                    ErrorLogger.LogCustom("Error de configuración del sistema en ProcesarLogin");
                    return new CE_LoginResponse
                    {
                        Resultado = "ERROR",
                        Mensaje = "Error de configuración del sistema",
                        UserId = 0
                    };
                }

                // Encriptar la contraseña
                string passwordEncriptada = CC_Encriptacion.Encriptar(password, encryptionConfig.Key, encryptionConfig.Salt, encryptionConfig.IV);

                // Crear objeto de request para login
                CE_LoginRequest loginRequest = new CE_LoginRequest
                {
                    Username = username.Trim(),
                    Password = passwordEncriptada,
                    IpAddress = CC_ContextoWeb.ObtenerDireccionIP(),
                    UserAgent = CC_ContextoWeb.ObtenerUserAgent()
                };

                // Validar credenciales en la base de datos
                CE_LoginResponse loginResponse = _cdUsuario.ValidarCredenciales(loginRequest);

                // Si el login es exitoso, obtener información completa del usuario
                if (loginResponse.EsExitoso)
                {
                    loginResponse.Usuario = _cdUsuario.ObtenerInformacionUsuario(loginResponse.UserId);

                    if (loginResponse.Usuario == null)
                    {
                        ErrorLogger.LogCustom("Error al obtener información del usuario en ProcesarLogin");
                        return new CE_LoginResponse
                        {
                            Resultado = "ERROR",
                            Mensaje = "Error al obtener información del usuario",
                            UserId = 0
                        };
                    }
                }

                return loginResponse;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en ProcesarLogin");
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = "Error en el proceso de login: " + ex.Message,
                    UserId = 0
                };
            }
        }

        /// <summary>
        /// Verifica si un usuario tiene un permiso específico
        /// </summary>
        /// <param name="usuario">Usuario a verificar</param>
        /// <param name="modulo">Módulo del permiso</param>
        /// <param name="accion">Acción del permiso</param>
        /// <returns>True si tiene el permiso, False en caso contrario</returns>
        public bool UsuarioTienePermiso(CE_Usuario usuario, string modulo, string accion)
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
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en UsuarioTienePermiso");
                return false;
            }
        }

        /// <summary>
        /// Verifica si un usuario tiene un rol específico
        /// </summary>
        /// <param name="usuario">Usuario a verificar</param>
        /// <param name="nombreRol">Nombre del rol</param>
        /// <returns>True si tiene el rol, False en caso contrario</returns>
        public bool UsuarioTieneRol(CE_Usuario usuario, string nombreRol)
        {
            try
            {
                if (usuario?.Roles == null)
                    return false;

                foreach (var rol in usuario.Roles)
                {
                    if (rol.ROL_Nombre.Equals(nombreRol, StringComparison.OrdinalIgnoreCase) && rol.ROL_Activo)
                    {
                        return true;
                    }
                }

                return false;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en UsuarioTieneRol");
                return false;
            }
        }

        /// <summary>
        /// Valida si un usuario está activo y no bloqueado
        /// </summary>
        /// <param name="usuario">Usuario a validar</param>
        /// <returns>True si está activo, False en caso contrario</returns>
        public bool ValidarEstadoUsuario(CE_Usuario usuario)
        {
            if (usuario == null)
                return false;

            return usuario.USU_Activo && !usuario.USU_Bloqueado;
        }

        /// <summary>
        /// Encripta una contraseña usando la configuración del sistema
        /// </summary>
        /// <param name="password">Contraseña en texto plano</param>
        /// <returns>Contraseña encriptada</returns>
        public string EncriptarPassword(string password)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(password))
                    return string.Empty;

                CE_EncryptionConfig encryptionConfig = _cdConfiguracion.ObtenerConfiguracionEncriptacion();

                if (encryptionConfig == null)
                    throw new Exception("No se pudo obtener la configuración de encriptación");

                return CC_Encriptacion.Encriptar(password, encryptionConfig.Key, encryptionConfig.Salt, encryptionConfig.IV);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al encriptar contraseña");
                throw new Exception($"Error al encriptar contraseña: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Desencripta una contraseña usando la configuración del sistema
        /// </summary>
        /// <param name="encryptedPassword">Contraseña encriptada</param>
        /// <returns>Contraseña en texto plano</returns>
        public string DesencriptarPassword(string encryptedPassword)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(encryptedPassword))
                    return string.Empty;

                CE_EncryptionConfig encryptionConfig = _cdConfiguracion.ObtenerConfiguracionEncriptacion();

                if (encryptionConfig == null)
                    throw new Exception("No se pudo obtener la configuración de encriptación");

                return CC_Encriptacion.Desencriptar(encryptedPassword, encryptionConfig.Key, encryptionConfig.Salt, encryptionConfig.IV);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al desencriptar contraseña");
                throw new Exception($"Error al desencriptar contraseña: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene información de un usuario por su ID
        /// </summary>
        /// <param name="userId">ID del usuario</param>
        /// <returns>Usuario con información completa</returns>
        public CE_Usuario ObtenerUsuario(int userId)
        {
            CE_Usuario usuario = _cdUsuario.ObtenerInformacionUsuario(userId);
            return usuario;
        }

        /// <summary>
        /// Obtiene información de un usuario por su username
        /// </summary>
        /// <param name="username">Nombre de usuario</param>
        /// <returns>Usuario encontrado</returns>
        public CE_Usuario ObtenerUsuarioPorUsername(string username)
        {
            try
            {
                return _cdUsuario.ObtenerUsuarioPorUsername(username);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener usuario por username");
                throw new Exception($"Error al obtener usuario por username: {ex.Message}", ex);
            }
        }
    }
}