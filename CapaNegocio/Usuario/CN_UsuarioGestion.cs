using CapaComun;
using CapaDatos;
using CapaDatos.Usuario;
using CapaEntidad.DTOs.Common;
using CapaEntidad.DTOs.Usuario;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace CapaNegocio.Usuario
{
    /// <summary>
    /// Capa de negocio para gestión de usuarios
    /// </summary>
    public class CN_UsuarioGestion
    {
        private readonly CD_UsuarioGestion _cdUsuarioGestion;
        private readonly CD_Configuracion _cdConfiguracion;

        public CN_UsuarioGestion()
        {
            _cdUsuarioGestion = new CD_UsuarioGestion();
            _cdConfiguracion = new CD_Configuracion();
        }

        #region Operaciones CRUD de Usuarios

        /// <summary>
        /// Obtiene usuarios paginados con filtros
        /// </summary>
        public CE_PagedResult<CE_UsuarioListDTO> ObtenerUsuariosPaginados(
            int pageNumber = 1,
            int pageSize = 10,
            string searchTerm = null,
            bool incluirInactivos = false,
            bool soloBloqueados = false)
        {
            try
            {
                return _cdUsuarioGestion.ObtenerUsuariosPaginados(
                    pageNumber,
                    pageSize,
                    searchTerm,
                    incluirInactivos,
                    soloBloqueados
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.ObtenerUsuariosPaginados");
                throw new Exception($"Error al obtener usuarios: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene un usuario por ID con toda su información
        /// </summary>
        public CE_UsuarioDetalleDTO ObtenerUsuarioPorId(int idUsuario)
        {
            try
            {
                if (idUsuario <= 0)
                {
                    throw new ArgumentException("El ID del usuario debe ser mayor a 0");
                }

                return _cdUsuarioGestion.ObtenerUsuarioPorId(idUsuario);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.ObtenerUsuarioPorId");
                throw new Exception($"Error al obtener usuario: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Crea un nuevo usuario
        /// </summary>
        public CE_OperacionResultDTO CrearUsuario(CE_UsuarioCreateDTO usuario, string usuarioCreacion)
        {
            try
            {
                // Validaciones de negocio
                var validacion = ValidarUsuarioCreate(usuario);
                if (!validacion.Exitoso)
                {
                    return validacion;
                }

                // Validar fortaleza de contraseña
                var validacionPassword = ValidarFortalezaPassword(usuario.Password);
                if (!validacionPassword.Exitoso)
                {
                    return validacionPassword;
                }

                // Encriptar contraseña
                var encryptionConfig = _cdConfiguracion.ObtenerConfiguracionEncriptacion();
                string passwordEncriptada = CC_Encriptacion.Encriptar(
                    usuario.Password,
                    encryptionConfig.Key,
                    encryptionConfig.Salt,
                    encryptionConfig.IV
                );

                // Obtener IP de creación
                string ipCreacion = CC_ContextoWeb.ObtenerDireccionIP();

                // Crear usuario
                int idUsuarioCreado = _cdUsuarioGestion.CrearUsuario(
                    usuario,
                    passwordEncriptada,
                    usuarioCreacion,
                    ipCreacion
                );

                return CE_OperacionResultDTO.Exito(
                    "Usuario creado exitosamente",
                    new { IdUsuario = idUsuarioCreado }
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.CrearUsuario");
                return CE_OperacionResultDTO.Error($"Error al crear usuario: {ex.Message}");
            }
        }

        /// <summary>
        /// Actualiza un usuario existente
        /// </summary>
        public CE_OperacionResultDTO ActualizarUsuario(CE_UsuarioUpdateDTO usuario, string usuarioModificacion)
        {
            try
            {
                // Validaciones de negocio
                var validacion = ValidarUsuarioUpdate(usuario);
                if (!validacion.Exitoso)
                {
                    return validacion;
                }

                // Obtener IP de modificación
                string ipModificacion = CC_ContextoWeb.ObtenerDireccionIP();

                // Actualizar usuario
                int filasAfectadas = _cdUsuarioGestion.ActualizarUsuario(
                    usuario,
                    usuarioModificacion,
                    ipModificacion
                );

                if (filasAfectadas > 0)
                {
                    return CE_OperacionResultDTO.Exito("Usuario actualizado exitosamente");
                }
                else
                {
                    return CE_OperacionResultDTO.Error("No se pudo actualizar el usuario");
                }
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.ActualizarUsuario");
                return CE_OperacionResultDTO.Error($"Error al actualizar usuario: {ex.Message}");
            }
        }

        /// <summary>
        /// Elimina (desactiva) un usuario
        /// </summary>
        public CE_OperacionResultDTO EliminarUsuario(int idUsuario, string usuarioEliminacion)
        {
            try
            {
                if (idUsuario <= 0)
                {
                    return CE_OperacionResultDTO.Error("El ID del usuario es inválido");
                }

                // Obtener IP de eliminación
                string ipEliminacion = CC_ContextoWeb.ObtenerDireccionIP();

                // Eliminar usuario
                int filasAfectadas = _cdUsuarioGestion.EliminarUsuario(
                    idUsuario,
                    usuarioEliminacion,
                    ipEliminacion
                );

                if (filasAfectadas > 0)
                {
                    return CE_OperacionResultDTO.Exito("Usuario eliminado exitosamente");
                }
                else
                {
                    return CE_OperacionResultDTO.Error("No se pudo eliminar el usuario");
                }
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.EliminarUsuario");
                return CE_OperacionResultDTO.Error($"Error al eliminar usuario: {ex.Message}");
            }
        }

        #endregion

        #region Gestión de Contraseñas

        /// <summary>
        /// Resetea la contraseña de un usuario
        /// </summary>
        public CE_OperacionResultDTO ResetearPassword(CE_ResetPasswordDTO resetPassword, string usuarioModificacion)
        {
            try
            {
                if (resetPassword.IdUsuario <= 0)
                {
                    return CE_OperacionResultDTO.Error("El ID del usuario es inválido");
                }

                // Validar fortaleza de contraseña
                var validacionPassword = ValidarFortalezaPassword(resetPassword.NuevaPassword);
                if (!validacionPassword.Exitoso)
                {
                    return validacionPassword;
                }

                // Encriptar contraseña
                var encryptionConfig = _cdConfiguracion.ObtenerConfiguracionEncriptacion();
                string passwordEncriptada = CC_Encriptacion.Encriptar(
                    resetPassword.NuevaPassword,
                    encryptionConfig.Key,
                    encryptionConfig.Salt,
                    encryptionConfig.IV
                );

                // Obtener IP de modificación
                string ipModificacion = CC_ContextoWeb.ObtenerDireccionIP();

                // Resetear contraseña
                return _cdUsuarioGestion.ResetearPassword(
                    resetPassword.IdUsuario,
                    passwordEncriptada,
                    usuarioModificacion,
                    ipModificacion
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.ResetearPassword");
                return CE_OperacionResultDTO.Error($"Error al resetear contraseña: {ex.Message}");
            }
        }

        /// <summary>
        /// Genera una contraseña temporal aleatoria
        /// </summary>
        public string GenerarPasswordTemporal()
        {
            const string caracteresValidos = "ABCDEFGHJKLMNOPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz0123456789!@#$%";
            var random = new Random();

            // Generar contraseña de 10 caracteres
            char[] password = new char[10];

            // Asegurar que tenga al menos una mayúscula
            password[0] = caracteresValidos[random.Next(0, 26)];

            // Asegurar que tenga al menos una minúscula
            password[1] = caracteresValidos[random.Next(26, 52)];

            // Asegurar que tenga al menos un número
            password[2] = caracteresValidos[random.Next(52, 62)];

            // Asegurar que tenga al menos un carácter especial
            password[3] = caracteresValidos[random.Next(62, caracteresValidos.Length)];

            // Rellenar el resto aleatoriamente
            for (int i = 4; i < password.Length; i++)
            {
                password[i] = caracteresValidos[random.Next(caracteresValidos.Length)];
            }

            // Mezclar los caracteres
            return new string(password.OrderBy(x => random.Next()).ToArray());
        }

        /// <summary>
        /// Desbloquea un usuario
        /// </summary>
        public CE_OperacionResultDTO DesbloquearUsuario(int idUsuario, string usuarioModificacion)
        {
            try
            {
                if (idUsuario <= 0)
                {
                    return CE_OperacionResultDTO.Error("El ID del usuario es inválido");
                }

                // Obtener IP de modificación
                string ipModificacion = CC_ContextoWeb.ObtenerDireccionIP();

                // Desbloquear usuario
                return _cdUsuarioGestion.DesbloquearUsuario(
                    idUsuario,
                    usuarioModificacion,
                    ipModificacion
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.DesbloquearUsuario");
                return CE_OperacionResultDTO.Error($"Error al desbloquear usuario: {ex.Message}");
            }
        }

        #endregion

        #region Gestión de Roles

        /// <summary>
        /// Asigna roles a un usuario
        /// </summary>
        public CE_OperacionResultDTO AsignarRolesUsuario(CE_AsignarRolesDTO asignarRoles, string usuarioModificacion)
        {
            try
            {
                if (asignarRoles.IdUsuario <= 0)
                {
                    return CE_OperacionResultDTO.Error("El ID del usuario es inválido");
                }

                if (asignarRoles.RolesIds == null || asignarRoles.RolesIds.Length == 0)
                {
                    return CE_OperacionResultDTO.Error("Debe seleccionar al menos un rol");
                }

                // Obtener IP de modificación
                string ipModificacion = CC_ContextoWeb.ObtenerDireccionIP();

                // Asignar roles
                return _cdUsuarioGestion.AsignarRolesUsuario(
                    asignarRoles.IdUsuario,
                    asignarRoles.RolesIds,
                    usuarioModificacion,
                    ipModificacion
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.AsignarRolesUsuario");
                return CE_OperacionResultDTO.Error($"Error al asignar roles: {ex.Message}");
            }
        }

        /// <summary>
        /// Obtiene roles paginados
        /// </summary>
        public CE_PagedResult<CE_RolListDTO> ObtenerRolesPaginados(
            int pageNumber = 1,
            int pageSize = 10,
            string searchTerm = null,
            bool incluirInactivos = false)
        {
            try
            {
                return _cdUsuarioGestion.ObtenerRolesPaginados(
                    pageNumber,
                    pageSize,
                    searchTerm,
                    incluirInactivos
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.ObtenerRolesPaginados");
                throw new Exception($"Error al obtener roles: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene todos los roles activos (para selección)
        /// </summary>
        public List<CE_RolListDTO> ObtenerRolesActivos()
        {
            try
            {
                var resultado = _cdUsuarioGestion.ObtenerRolesPaginados(1, 1000, null, false);
                return resultado.Items;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.ObtenerRolesActivos");
                throw new Exception($"Error al obtener roles activos: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene los permisos de un rol
        /// </summary>
        public List<CE_PermisoDTO> ObtenerPermisosRol(int idRol)
        {
            try
            {
                if (idRol <= 0)
                {
                    throw new ArgumentException("El ID del rol debe ser mayor a 0");
                }

                return _cdUsuarioGestion.ObtenerPermisosRol(idRol);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en CN_UsuarioGestion.ObtenerPermisosRol");
                throw new Exception($"Error al obtener permisos del rol: {ex.Message}", ex);
            }
        }

        #endregion

        #region Métodos de Validación

        /// <summary>
        /// Valida los datos de creación de usuario
        /// </summary>
        private CE_OperacionResultDTO ValidarUsuarioCreate(CE_UsuarioCreateDTO usuario)
        {
            if (usuario == null)
            {
                return CE_OperacionResultDTO.Error("Los datos del usuario son requeridos");
            }

            var errores = new List<string>();

            // Validar código
            if (usuario.Codigo <= 0)
            {
                errores.Add("El código debe ser mayor a 0");
            }

            // Validar username
            if (string.IsNullOrWhiteSpace(usuario.Username))
            {
                errores.Add("El nombre de usuario es requerido");
            }
            else if (usuario.Username.Length < 3 || usuario.Username.Length > 100)
            {
                errores.Add("El nombre de usuario debe tener entre 3 y 100 caracteres");
            }
            else if (!Regex.IsMatch(usuario.Username, @"^[a-zA-Z0-9._-]+$"))
            {
                errores.Add("El nombre de usuario solo puede contener letras, números, puntos, guiones y guiones bajos");
            }

            // Validar nombre
            if (string.IsNullOrWhiteSpace(usuario.Nombre))
            {
                errores.Add("El nombre es requerido");
            }
            else if (usuario.Nombre.Length < 2 || usuario.Nombre.Length > 100)
            {
                errores.Add("El nombre debe tener entre 2 y 100 caracteres");
            }

            // Validar correo
            if (string.IsNullOrWhiteSpace(usuario.Correo))
            {
                errores.Add("El correo es requerido");
            }
            else if (!Regex.IsMatch(usuario.Correo, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                errores.Add("El formato del correo es inválido");
            }

            // Validar contraseña
            if (string.IsNullOrWhiteSpace(usuario.Password))
            {
                errores.Add("La contraseña es requerida");
            }

            if (errores.Any())
            {
                return CE_OperacionResultDTO.Error(string.Join("; ", errores));
            }

            return CE_OperacionResultDTO.Exito();
        }

        /// <summary>
        /// Valida los datos de actualización de usuario
        /// </summary>
        private CE_OperacionResultDTO ValidarUsuarioUpdate(CE_UsuarioUpdateDTO usuario)
        {
            if (usuario == null)
            {
                return CE_OperacionResultDTO.Error("Los datos del usuario son requeridos");
            }

            var errores = new List<string>();

            // Validar ID
            if (usuario.IdUsuario <= 0)
            {
                errores.Add("El ID del usuario es inválido");
            }

            // Validar nombre
            if (string.IsNullOrWhiteSpace(usuario.Nombre))
            {
                errores.Add("El nombre es requerido");
            }
            else if (usuario.Nombre.Length < 2 || usuario.Nombre.Length > 100)
            {
                errores.Add("El nombre debe tener entre 2 y 100 caracteres");
            }

            // Validar correo
            if (string.IsNullOrWhiteSpace(usuario.Correo))
            {
                errores.Add("El correo es requerido");
            }
            else if (!Regex.IsMatch(usuario.Correo, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                errores.Add("El formato del correo es inválido");
            }

            if (errores.Any())
            {
                return CE_OperacionResultDTO.Error(string.Join("; ", errores));
            }

            return CE_OperacionResultDTO.Exito();
        }

        /// <summary>
        /// Valida la fortaleza de una contraseña
        /// </summary>
        private CE_OperacionResultDTO ValidarFortalezaPassword(string password)
        {
            if (string.IsNullOrWhiteSpace(password))
            {
                return CE_OperacionResultDTO.Error("La contraseña es requerida");
            }

            var errores = new List<string>();

            if (password.Length < 6)
            {
                errores.Add("Debe tener al menos 6 caracteres");
            }

            if (!Regex.IsMatch(password, @"[A-Z]"))
            {
                errores.Add("Debe contener al menos una letra mayúscula");
            }

            if (!Regex.IsMatch(password, @"[a-z]"))
            {
                errores.Add("Debe contener al menos una letra minúscula");
            }

            if (!Regex.IsMatch(password, @"\d"))
            {
                errores.Add("Debe contener al menos un número");
            }

            if (errores.Any())
            {
                return CE_OperacionResultDTO.Error(
                    "La contraseña no cumple con los requisitos de seguridad: " + string.Join(", ", errores)
                );
            }

            return CE_OperacionResultDTO.Exito("Contraseña válida");
        }

        #endregion
    }
}
