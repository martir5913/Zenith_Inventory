using CapaComun;
using CapaDatos;
using CapaEntidad;
using CapaEntidad.DTOs;
using System;
using System.Collections.Generic;

namespace CapaNegocio
{
    /// <summary>
    /// Capa de negocio para manejo de usuarios
    /// </summary>
    public class CN_Usuario
    {
        private readonly CD_Usuario _cdUsuario;
        private readonly CD_Configuracion _cdConfiguracion;

        public CN_Usuario()
        {
            _cdUsuario = new CD_Usuario();
            _cdConfiguracion = new CD_Configuracion();
        }

        /// <summary>
        /// Lista usuarios con paginación
        /// </summary>
        /// <param name="numeroPagina">Número de página</param>
        /// <param name="tamañoPagina">Tamaño de página</param>
        /// <param name="terminoBusqueda">Término de búsqueda</param>
        /// <param name="soloActivos">Solo usuarios activos</param>
        /// <returns>Lista de usuarios</returns>
        public List<CE_Usuario> ListarUsuarios(int numeroPagina = 1, int tamañoPagina = 50, string terminoBusqueda = null, bool soloActivos = true)
        {
            try
            {
                return _cdUsuario.ListarUsuarios(numeroPagina, tamañoPagina, terminoBusqueda, soloActivos);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al listar usuarios: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene un usuario por su ID
        /// </summary>
        /// <param name="userId">ID del usuario</param>
        /// <returns>Usuario encontrado</returns>
        public CE_Usuario ObtenerUsuario(int userId)
        {
            try
            {
                return _cdUsuario.ObtenerInformacionUsuario(userId);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener usuario: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Verifica si existe un username
        /// </summary>
        /// <param name="username">Nombre de usuario</param>
        /// <returns>True si existe, False en caso contrario</returns>
        public bool ExisteUsername(string username)
        {
            try
            {
                var usuario = _cdUsuario.ObtenerUsuarioPorUsername(username);
                return usuario != null;
            }
            catch (Exception)
            {
                return false;
            }
        }

        /// <summary>
        /// Crea un nuevo usuario
        /// </summary>
        /// <param name="usuario">Datos del usuario</param>
        /// <param name="password">Contraseña en texto plano</param>
        /// <param name="usuarioCreacion">Usuario que crea</param>
        /// <returns>Respuesta de la operación</returns>
        public CE_LoginResponse CrearUsuario(CE_Usuario usuario, string password, string usuarioCreacion)
        {
            try
            {
                // Validar datos de entrada
                if (usuario == null)
                {
                    return new CE_LoginResponse
                    {
                        Resultado = "ERROR",
                        Mensaje = "Los datos del usuario son requeridos",
                        UserId = 0
                    };
                }

                // Validar fortaleza de contraseña
                var validacionPassword = ValidarFortalezaPassword(password);
                if (!validacionPassword.EsValida)
                {
                    return new CE_LoginResponse
                    {
                        Resultado = "ERROR",
                        Mensaje = validacionPassword.Mensaje,
                        UserId = 0
                    };
                }

                // Encriptar contraseña
                CE_EncryptionConfig encryptionConfig = _cdConfiguracion.ObtenerConfiguracionEncriptacion();
                string passwordEncriptada = CC_Encriptacion.Encriptar(password, encryptionConfig.Key, encryptionConfig.Salt, encryptionConfig.IV);

                // Crear usuario
                string ipCreacion = CC_ContextoWeb.ObtenerDireccionIP();
                return _cdUsuario.CrearUsuario(usuario, passwordEncriptada, usuarioCreacion, ipCreacion);
            }
            catch (Exception ex)
            {
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = $"Error al crear usuario: {ex.Message}",
                    UserId = 0
                };
            }
        }

        /// <summary>
        /// Cambia la contraseña de un usuario
        /// </summary>
        /// <param name="userId">ID del usuario</param>
        /// <param name="newEncryptedPassword">Nueva contraseña encriptada</param>
        /// <param name="modifiedBy">Usuario que modifica</param>
        /// <returns>Respuesta de la operación</returns>
        public CE_LoginResponse CambiarPassword(int userId, string newEncryptedPassword, string modifiedBy)
        {
            try
            {
                string ipAddress = CC_ContextoWeb.ObtenerDireccionIP();
                return _cdUsuario.CambiarPassword(userId, newEncryptedPassword, modifiedBy, ipAddress);
            }
            catch (Exception ex)
            {
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = $"Error al cambiar contraseña: {ex.Message}",
                    UserId = 0
                };
            }
        }

        /// <summary>
        /// Crea un nuevo usuario con contraseña temporal
        /// </summary>
        /// <param name="usuario">Datos del usuario</param>
        /// <param name="passwordTemporal">Contraseña temporal</param>
        /// <param name="usuarioCreacion">Usuario que crea</param>
        /// <returns>Respuesta de la operación</returns>
        public CE_LoginResponse CrearUsuarioTemporal(CE_Usuario usuario, string passwordTemporal, string usuarioCreacion)
        {
            try
            {
                // Validar datos de entrada
                if (usuario == null)
                {
                    return new CE_LoginResponse
                    {
                        Resultado = "ERROR",
                        Mensaje = "Los datos del usuario son requeridos",
                        UserId = 0
                    };
                }

                // Validar fortaleza de contraseña (aunque sea temporal)
                var validacionPassword = ValidarFortalezaPassword(passwordTemporal);
                if (!validacionPassword.EsValida)
                {
                    return new CE_LoginResponse
                    {
                        Resultado = "ERROR",
                        Mensaje = "Error en generación de contraseña temporal",
                        UserId = 0
                    };
                }

                // Encriptar contraseña
                CE_EncryptionConfig encryptionConfig = _cdConfiguracion.ObtenerConfiguracionEncriptacion();
                string passwordEncriptada = CC_Encriptacion.Encriptar(passwordTemporal, encryptionConfig.Key, encryptionConfig.Salt, encryptionConfig.IV);

                // Crear usuario temporal
                string ipCreacion = CC_ContextoWeb.ObtenerDireccionIP();
                return _cdUsuario.CrearUsuarioTemporal(usuario, passwordEncriptada, usuarioCreacion, ipCreacion);
            }
            catch (Exception ex)
            {
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = $"Error al crear usuario temporal: {ex.Message}",
                    UserId = 0
                };
            }
        }

        /// <summary>
        /// Resetea la contraseña de un usuario a una temporal
        /// </summary>
        /// <param name="userId">ID del usuario</param>
        /// <param name="passwordTemporal">Nueva contraseña temporal</param>
        /// <param name="modifiedBy">Usuario que modifica</param>
        /// <returns>Respuesta de la operación</returns>
        public CE_LoginResponse ResetPasswordTemporal(int userId, string passwordTemporal, string modifiedBy)
        {
            try
            {
                // Encriptar contraseña
                CE_EncryptionConfig encryptionConfig = _cdConfiguracion.ObtenerConfiguracionEncriptacion();
                string passwordEncriptada = CC_Encriptacion.Encriptar(passwordTemporal, encryptionConfig.Key, encryptionConfig.Salt, encryptionConfig.IV);

                // Resetear contraseña
                string ipAddress = CC_ContextoWeb.ObtenerDireccionIP();
                return _cdUsuario.ResetPasswordTemporal(userId, passwordEncriptada, modifiedBy, ipAddress);
            }
            catch (Exception ex)
            {
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = $"Error al resetear contraseña: {ex.Message}",
                    UserId = 0
                };
            }
        }

        /// <summary>
        /// Valida la fortaleza de una contraseña
        /// </summary>
        /// <param name="password">Contraseña a validar</param>
        /// <returns>Resultado de la validación</returns>
        public CE_ValidacionPassword ValidarFortalezaPassword(string password)
        {
            var resultado = new CE_ValidacionPassword();

            if (string.IsNullOrWhiteSpace(password))
            {
                resultado.EsValida = false;
                resultado.Mensaje = "La contraseña es requerida";
                return resultado;
            }

            var errores = new List<string>();

            if (password.Length < 6)
                errores.Add("Debe tener al menos 6 caracteres");

            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"[A-Z]"))
                errores.Add("Debe contener al menos una letra mayúscula");

            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"[a-z]"))
                errores.Add("Debe contener al menos una letra minúscula");

            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"\d"))
                errores.Add("Debe contener al menos un número");

            if (errores.Count > 0)
            {
                resultado.EsValida = false;
                resultado.Mensaje = "La contraseña no cumple con los requisitos: " + string.Join(", ", errores);
            }
            else
            {
                resultado.EsValida = true;
                resultado.Mensaje = "Contraseña válida";
            }

            return resultado;
        }

        /// <summary>
        /// Obtiene la lista de roles disponibles
        /// </summary>
        /// <returns>Lista de roles activos</returns>
        public List<CE_Rol> ObtenerRolesDisponibles()
        {
            try
            {
                return _cdUsuario.ObtenerRolesDisponibles();
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener roles disponibles: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Asigna roles a un usuario
        /// </summary>
        /// <param name="userId">ID del usuario</param>
        /// <param name="roleIds">IDs de los roles a asignar</param>
        /// <returns>Respuesta de la operación</returns>
        public CE_LoginResponse AsignarRolesUsuario(int userId, int[] roleIds)
        {
            try
            {
                string usuarioModificacion = "Sistema"; // TODO: Obtener del contexto
                return _cdUsuario.AsignarRolesUsuario(userId, roleIds, usuarioModificacion);
            }
            catch (Exception ex)
            {
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = $"Error al asignar roles: {ex.Message}",
                    UserId = 0
                };
            }
        }
    }

    /// <summary>
    /// DTO para validación de contraseñas
    /// </summary>
    public class CE_ValidacionPassword
    {
        public bool EsValida { get; set; }
        public string Mensaje { get; set; }

        public CE_ValidacionPassword()
        {
            EsValida = false;
            Mensaje = string.Empty;
        }
    }
}