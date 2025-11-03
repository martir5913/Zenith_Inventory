using CapaComun;
using CapaEntidad;
using CapaEntidad.DTOs;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDatos
{
    /// <summary>
    /// Capa de datos para manejo de usuarios
    /// </summary>
    public class CD_Usuario
    {
        private readonly CC_Conexion _conexion;

        public CD_Usuario()
        {
            _conexion = new CC_Conexion();
        }

        /// <summary>
        /// Valida las credenciales de un usuario
        /// </summary>
        /// <param name="loginRequest">Datos de login</param>
        /// <returns>Respuesta del login</returns>
        public CE_LoginResponse ValidarCredenciales(CE_LoginRequest loginRequest)
        {
            try
            {
                CE_LoginResponse response = new CE_LoginResponse();

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand("ZI_GENERAL.SP_VALIDATE_USER_LOGIN", conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@Username", loginRequest.Username, SqlDbType.NVarChar, 100));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@EncryptedPassword", loginRequest.Password, SqlDbType.NVarChar, 500));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IpAddress", loginRequest.IpAddress, SqlDbType.NVarChar, 45));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@UserAgent", loginRequest.UserAgent, SqlDbType.NVarChar, 1000));

                        using (SqlDataAdapter adapter = new SqlDataAdapter(comando))
                        {
                            DataTable dataTable = new DataTable();
                            adapter.Fill(dataTable);

                            if (dataTable.Rows.Count > 0)
                            {
                                DataRow row = dataTable.Rows[0];
                                response.Resultado = row["Resultado"].ToString();
                                response.Mensaje = row["Mensaje"].ToString();
                                response.UserId = Convert.ToInt32(row["UserId"]);

                                if (response.Resultado == "EXITO")
                                {
                                    response.EsExitoso = true;
                                    // Obtener información completa del usuario
                                    response.Usuario = ObtenerInformacionUsuario(response.UserId);
                                }
                                else
                                {
                                    response.EsExitoso = false;
                                }
                            }
                            else
                            {
                                response.Resultado = "ERROR";
                                response.Mensaje = "No se recibió respuesta del servidor";
                                response.UserId = 0;
                                response.EsExitoso = false;
                            }
                        }
                    }
                }

                return response;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al validar credenciales");
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = $"Error interno del sistema: {ex.Message}",
                    UserId = 0,
                    EsExitoso = false
                };
            }
        }

        /// <summary>
        /// Obtiene la información completa de un usuario
        /// </summary>
        /// <param name="userId">ID del usuario</param>
        /// <returns>Usuario con roles y permisos</returns>
        public CE_Usuario ObtenerInformacionUsuario(int userId)
        {
            try
            {
                CE_Usuario usuario = null;
                List<CE_Rol> roles = new List<CE_Rol>();
                List<CE_Permiso> permisos = new List<CE_Permiso>();

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand("ZI_GENERAL.SP_GET_USER_INFO", conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@UserId", userId, SqlDbType.Int));
                        conexion.Open();

                        using (SqlDataReader reader = comando.ExecuteReader())
                        {
                            // Leer información del usuario
                            if (reader.Read())
                            {
                                usuario = new CE_Usuario
                                {
                                    USU_Id = Convert.ToInt32(reader["USU_Id"]),
                                    USU_Username = reader["USU_Username"].ToString(),
                                    USU_PasswordEncrypted = reader["USU_PasswordEncrypted"].ToString(),
                                    USU_Nombre = reader["USU_Nombre"].ToString(),
                                    USU_Apellido = reader["USU_Apellido"].ToString(),
                                    USU_Correo = reader["USU_Correo"].ToString(),
                                    USU_Telefono = reader["USU_Telefono"].ToString(),
                                    USU_Activo = Convert.ToBoolean(reader["USU_Activo"]),
                                    USU_UltimoLogin = reader["USU_UltimoLogin"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["USU_UltimoLogin"]),
                                    USU_IntentosFallidos = Convert.ToInt32(reader["USU_IntentosFallidos"]),
                                    USU_Bloqueado = Convert.ToBoolean(reader["USU_Bloqueado"]),
                                    USU_FechaBloqueo = reader["USU_FechaBloqueo"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["USU_FechaBloqueo"]),
                                    USU_PassTemp = Convert.ToBoolean(reader["USU_PassTemp"]),
                                    USU_FechaCreacion = Convert.ToDateTime(reader["USU_FechaCreacion"]),
                                    USU_UsuarioCreacion = reader["USU_UsuarioCreacion"].ToString(),
                                    USU_FechaModificacion = reader["USU_FechaModificacion"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["USU_FechaModificacion"]),
                                    USU_UsuarioModificacion = reader["USU_UsuarioModificacion"].ToString(),
                                    USU_IpCreacion = reader["USU_IpCreacion"].ToString(),
                                    USU_IpModificacion = reader["USU_IpModificacion"].ToString()
                                };
                            }

                            // Leer roles
                            if (reader.NextResult())
                            {
                                while (reader.Read())
                                {
                                    roles.Add(new CE_Rol
                                    {
                                        ROL_Id = Convert.ToInt32(reader["ROL_Id"]),
                                        ROL_Nombre = reader["ROL_Nombre"].ToString(),
                                        ROL_Descripcion = reader["ROL_Descripcion"].ToString(),
                                        ROL_Activo = Convert.ToBoolean(reader["ROL_Activo"])
                                    });
                                }
                            }

                            // Leer permisos
                            if (reader.NextResult())
                            {
                                while (reader.Read())
                                {
                                    permisos.Add(new CE_Permiso
                                    {
                                        PER_Id = Convert.ToInt32(reader["PER_Id"]),
                                        PER_Nombre = reader["PER_Nombre"].ToString(),
                                        PER_Descripcion = reader["PER_Descripcion"].ToString(),
                                        PER_Modulo = reader["PER_Modulo"].ToString(),
                                        PER_Accion = reader["PER_Accion"].ToString(),
                                        PER_Activo = Convert.ToBoolean(reader["PER_Activo"])
                                    });
                                }
                            }
                        }
                    }
                }

                if (usuario != null)
                {
                    usuario.Roles = roles;
                    usuario.Permisos = permisos;
                }

                return usuario;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener información del usuario {userId}: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene un usuario por su username
        /// </summary>
        /// <param name="username">Nombre de usuario</param>
        /// <returns>Usuario encontrado o null</returns>
        public CE_Usuario ObtenerUsuarioPorUsername(string username)
        {
            try
            {
                List<SqlParameter> parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@Username", username, SqlDbType.NVarChar, 100)
                };

                string query = @"
                    SELECT USU_Id, USU_Username, USU_PasswordEncrypted, USU_Nombre, USU_Apellido, USU_Correo, USU_Telefono, USU_Activo, USU_UltimoLogin, USU_IntentosFallidos, USU_Bloqueado, USU_FechaBloqueo, USU_FechaCreacion, USU_UsuarioCreacion, USU_FechaModificacion, USU_UsuarioModificacion, USU_IpCreacion, USU_IpModificacion, USU_PassTemp
                    FROM ZI_GENERAL.ZI_USUARIOS 
                    WHERE USU_Username = @Username AND USU_Activo = 1";

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand(query, conexion))
                    {
                        comando.Parameters.AddRange(parametros.ToArray());
                        conexion.Open();

                        using (SqlDataReader reader = comando.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new CE_Usuario
                                {
                                    USU_Id = Convert.ToInt32(reader["USU_Id"]),
                                    USU_Username = reader["USU_Username"].ToString(),
                                    USU_PasswordEncrypted = reader["USU_PasswordEncrypted"].ToString(),
                                    USU_Nombre = reader["USU_Nombre"].ToString(),
                                    USU_Apellido = reader["USU_Apellido"].ToString(),
                                    USU_Correo = reader["USU_Correo"].ToString(),
                                    USU_Telefono = reader["USU_Telefono"].ToString(),
                                    USU_Activo = Convert.ToBoolean(reader["USU_Activo"]),
                                    USU_UltimoLogin = reader["USU_UltimoLogin"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["USU_UltimoLogin"]),
                                    USU_IntentosFallidos = Convert.ToInt32(reader["USU_IntentosFallidos"]),
                                    USU_Bloqueado = Convert.ToBoolean(reader["USU_Bloqueado"]),
                                    USU_FechaBloqueo = reader["USU_FechaBloqueo"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["USU_FechaBloqueo"]),
                                    USU_PassTemp = Convert.ToBoolean(reader["USU_PassTemp"]),
                                    USU_FechaCreacion = Convert.ToDateTime(reader["USU_FechaCreacion"]),
                                    USU_UsuarioCreacion = reader["USU_UsuarioCreacion"].ToString(),
                                    USU_FechaModificacion = reader["USU_FechaModificacion"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["USU_FechaModificacion"]),
                                    USU_UsuarioModificacion = reader["USU_UsuarioModificacion"].ToString(),
                                    USU_IpCreacion = reader["USU_IpCreacion"].ToString(),
                                    USU_IpModificacion = reader["USU_IpModificacion"].ToString()
                                };
                            }
                        }
                    }
                }

                return null;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener usuario por username '{username}': {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Crea un nuevo usuario
        /// </summary>
        /// <param name="usuario">Datos del usuario</param>
        /// <param name="passwordEncriptada">Contraseña encriptada</param>
        /// <param name="usuarioCreacion">Usuario que crea</param>
        /// <param name="ipCreacion">IP de creación</param>
        /// <returns>Respuesta de la operación</returns>
        public CE_LoginResponse CrearUsuario(CE_Usuario usuario, string passwordEncriptada, string usuarioCreacion, string ipAddress)
        {
            try
            {
                List<SqlParameter> parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@Username", usuario.USU_Username, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@EncryptedPassword", passwordEncriptada, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@Nombre", usuario.USU_Nombre, SqlDbType.NVarChar, 150),
                    CC_Conexion.CrearParametro("@Apellido", usuario.USU_Apellido, SqlDbType.NVarChar, 150),
                    CC_Conexion.CrearParametro("@Email", usuario.USU_Correo, SqlDbType.NVarChar, 255),
                    CC_Conexion.CrearParametro("@Telefono", usuario.USU_Telefono, SqlDbType.NVarChar, 20),
                    CC_Conexion.CrearParametro("@CreatedBy", usuarioCreacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpAddress", ipAddress, SqlDbType.NVarChar, 45)
                };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_CREATE_USER", parametros);

                if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                {
                    DataRow row = dataSet.Tables[0].Rows[0];

                    return new CE_LoginResponse
                    {
                        Resultado = row["Resultado"].ToString(),
                        Mensaje = row["Mensaje"].ToString(),
                        UserId = Convert.ToInt32(row["UserId"])
                    };
                }

                ErrorLogger.LogCustom("No se recibió respuesta del servidor al crear usuario");
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = "No se recibió respuesta del servidor",
                    UserId = 0
                };
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al crear usuario");
                throw new Exception($"Error al crear usuario: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Crea un nuevo usuario con contraseña temporal
        /// </summary>
        /// <param name="usuario">Datos del usuario</param>
        /// <param name="passwordEncriptada">Contraseña encriptada</param>
        /// <param name="usuarioCreacion">Usuario que crea</param>
        /// <param name="ipCreacion">IP de creación</param>
        /// <returns>Respuesta de la operación</returns>
        public CE_LoginResponse CrearUsuarioTemporal(CE_Usuario usuario, string passwordEncriptada, string usuarioCreacion, string ipCreacion)
        {
            try
            {
                List<SqlParameter> parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@Username", usuario.USU_Username, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@EncryptedPassword", passwordEncriptada, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@Nombre", usuario.USU_Nombre, SqlDbType.NVarChar, 150),
                    CC_Conexion.CrearParametro("@Apellido", usuario.USU_Apellido, SqlDbType.NVarChar, 150),
                    CC_Conexion.CrearParametro("@Email", usuario.USU_Correo, SqlDbType.NVarChar, 255),
                    CC_Conexion.CrearParametro("@Telefono", usuario.USU_Telefono, SqlDbType.NVarChar, 20),
                    CC_Conexion.CrearParametro("@CreatedBy", usuarioCreacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpAddress", ipCreacion, SqlDbType.NVarChar, 45)
                };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_CREATE_USER_TEMPORAL", parametros);

                if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                {
                    DataRow row = dataSet.Tables[0].Rows[0];

                    return new CE_LoginResponse
                    {
                        Resultado = row["Resultado"].ToString(),
                        Mensaje = row["Mensaje"].ToString(),
                        UserId = Convert.ToInt32(row["UserId"])
                    };
                }

                ErrorLogger.LogCustom("No se recibió respuesta del servidor al crear usuario temporal");
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = "No se recibió respuesta del servidor",
                    UserId = 0
                };
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al crear usuario temporal");
                throw new Exception($"Error al crear usuario temporal: {ex.Message}", ex);
            }
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
                List<SqlParameter> parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@PageNumber", numeroPagina, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@PageSize", tamañoPagina, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@SearchTerm", terminoBusqueda, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@ActiveOnly", soloActivos, SqlDbType.Bit)
                };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_LIST_USERS", parametros);

                if (dataSet.Tables.Count > 0)
                {
                    return CC_Conexion.ConvertirDataTableALista<CE_Usuario>(dataSet.Tables[0]);
                }

                return new List<CE_Usuario>();
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al listar usuarios");
                throw new Exception($"Error al listar usuarios: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Cambia la contrase�a de un usuario
        /// </summary>
        /// <param name="userId">ID del usuario</param>
        /// <param name="newEncryptedPassword">Nueva contrase�a encriptada</param>
        /// <param name="modifiedBy">Usuario que modifica</param>
        /// <param name="ipAddress">IP de modificaci�n</param>
        /// <returns>Respuesta de la operaci�n</returns>
        public CE_LoginResponse CambiarPassword(int userId, string newEncryptedPassword, string modifiedBy, string ipAddress)
        {
            try
            {
                List<SqlParameter> parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@UserId", userId, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@NewEncryptedPassword", newEncryptedPassword, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@ModifiedBy", modifiedBy, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpAddress", ipAddress, SqlDbType.NVarChar, 45)
                };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_CHANGE_PASSWORD", parametros);

                if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                {
                    DataRow row = dataSet.Tables[0].Rows[0];

                    return new CE_LoginResponse
                    {
                        Resultado = row["Resultado"].ToString(),
                        Mensaje = row["Mensaje"].ToString(),
                        UserId = userId
                    };
                }

                ErrorLogger.LogCustom("No se recibió respuesta del servidor al cambiar contraseña");
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = "No se recibió respuesta del servidor",
                    UserId = 0
                };
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al cambiar contrase?a");
                throw new Exception($"Error al cambiar contrase?a: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Resetea la contraseña de un usuario a una temporal
        /// </summary>
        /// <param name="userId">ID del usuario</param>
        /// <param name="newEncryptedPassword">Nueva contraseña encriptada</param>
        /// <param name="modifiedBy">Usuario que modifica</param>
        /// <param name="ipAddress">IP de modificación</param>
        /// <returns>Respuesta de la operación</returns>
        public CE_LoginResponse ResetPasswordTemporal(int userId, string newEncryptedPassword, string modifiedBy, string ipAddress)
        {
            try
            {
                List<SqlParameter> parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@UserId", userId, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@NewEncryptedPassword", newEncryptedPassword, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@ModifiedBy", modifiedBy, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpAddress", ipAddress, SqlDbType.NVarChar, 45)
                };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_RESET_PASSWORD_TEMPORAL", parametros);

                if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                {
                    DataRow row = dataSet.Tables[0].Rows[0];

                    return new CE_LoginResponse
                    {
                        Resultado = row["Resultado"].ToString(),
                        Mensaje = row["Mensaje"].ToString(),
                        UserId = userId
                    };
                }

                ErrorLogger.LogCustom("No se recibió respuesta del servidor al resetear contraseña");
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = "No se recibió respuesta del servidor",
                    UserId = 0
                };
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al resetear contraseña");
                throw new Exception($"Error al resetear contraseña: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene la lista de roles disponibles
        /// </summary>
        /// <returns>Lista de roles activos</returns>
        public List<CE_Rol> ObtenerRolesDisponibles()
        {
            try
            {
                string query = @"
                    SELECT ROL_Id, ROL_Nombre, ROL_Descripcion, ROL_Activo,
                           ROL_FechaCreacion, ROL_UsuarioCreacion,
                           ROL_FechaModificacion, ROL_UsuarioModificacion,
                           ROL_IpCreacion, ROL_IpModificacion
                    FROM ZI_GENERAL.ZI_ROLES 
                    WHERE ROL_Activo = 1
                    ORDER BY ROL_Nombre";

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand(query, conexion))
                    {
                        conexion.Open();

                        using (SqlDataAdapter adapter = new SqlDataAdapter(comando))
                        {
                            DataTable dataTable = new DataTable();
                            adapter.Fill(dataTable);

                            return CC_Conexion.ConvertirDataTableALista<CE_Rol>(dataTable);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener roles disponibles");
                throw new Exception($"Error al obtener roles disponibles: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Asigna roles a un usuario
        /// </summary>
        /// <param name="userId">ID del usuario</param>
        /// <param name="roleIds">IDs de los roles a asignar</param>
        /// <param name="modifiedBy">Usuario que modifica</param>
        /// <returns>Respuesta de la operación</returns>
        public CE_LoginResponse AsignarRolesUsuario(int userId, int[] roleIds, string modifiedBy)
        {
            try
            {
                string ipAddress = CC_ContextoWeb.ObtenerDireccionIP();

                // Obtener información del usuario para logging
                var usuario = ObtenerInformacionUsuario(userId);
                if (usuario == null)
                {
                    return new CE_LoginResponse
                    {
                        Resultado = "ERROR",
                        Mensaje = "Usuario no encontrado",
                        UserId = 0
                    };
                }

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    conexion.Open();
                    using (SqlTransaction transaction = conexion.BeginTransaction())
                    {
                        try
                        {
                            // 1. Desactivar todos los roles actuales del usuario
                            string queryDesactivar = @"
                                UPDATE ZI_GENERAL.ZI_USUARIOSROLES 
                                SET UR_Activo = 0,
                                    UR_FechaModificacion = GETDATE(),
                                    UR_UsuarioModificacion = @ModifiedBy,
                                    UR_IpModificacion = @IpAddress
                                WHERE UR_UsrId = @UserId AND UR_Activo = 1";

                            using (SqlCommand cmdDesactivar = new SqlCommand(queryDesactivar, conexion, transaction))
                            {
                                cmdDesactivar.Parameters.AddWithValue("@UserId", userId);
                                cmdDesactivar.Parameters.AddWithValue("@ModifiedBy", modifiedBy);
                                cmdDesactivar.Parameters.AddWithValue("@IpAddress", ipAddress);
                                cmdDesactivar.ExecuteNonQuery();
                            }

                            // 2. Activar los roles seleccionados
                            foreach (int roleId in roleIds)
                            {
                                // Verificar si ya existe la relación (activa o inactiva)
                                string queryExiste = @"
                                    SELECT COUNT(*) FROM ZI_GENERAL.ZI_USUARIOSROLES 
                                    WHERE UR_UsrId = @UserId AND UR_RolId = @RoleId";

                                int existe;
                                using (SqlCommand cmdExiste = new SqlCommand(queryExiste, conexion, transaction))
                                {
                                    cmdExiste.Parameters.AddWithValue("@UserId", userId);
                                    cmdExiste.Parameters.AddWithValue("@RoleId", roleId);
                                    existe = (int)cmdExiste.ExecuteScalar();
                                }

                                if (existe > 0)
                                {
                                    // Reactivar relación existente
                                    string queryReactivar = @"
                                        UPDATE ZI_GENERAL.ZI_USUARIOSROLES 
                                        SET UR_Activo = 1,
                                            UR_FechaModificacion = GETDATE(),
                                            UR_UsuarioModificacion = @ModifiedBy,
                                            UR_IpModificacion = @IpAddress
                                        WHERE UR_UsrId = @UserId AND UR_RolId = @RoleId";

                                    using (SqlCommand cmdReactivar = new SqlCommand(queryReactivar, conexion, transaction))
                                    {
                                        cmdReactivar.Parameters.AddWithValue("@UserId", userId);
                                        cmdReactivar.Parameters.AddWithValue("@RoleId", roleId);
                                        cmdReactivar.Parameters.AddWithValue("@ModifiedBy", modifiedBy);
                                        cmdReactivar.Parameters.AddWithValue("@IpAddress", ipAddress);
                                        cmdReactivar.ExecuteNonQuery();
                                    }
                                }
                                else
                                {
                                    // Crear nueva relación
                                    string queryInsertar = @"
                                        INSERT INTO ZI_GENERAL.ZI_USUARIOSROLES (
                                            UR_UsrId, UR_RolId, UR_UsuarioCreacion, UR_IpCreacion
                                        ) VALUES (
                                            @UserId, @RoleId, @CreatedBy, @IpAddress
                                        )";

                                    using (SqlCommand cmdInsertar = new SqlCommand(queryInsertar, conexion, transaction))
                                    {
                                        cmdInsertar.Parameters.AddWithValue("@UserId", userId);
                                        cmdInsertar.Parameters.AddWithValue("@RoleId", roleId);
                                        cmdInsertar.Parameters.AddWithValue("@CreatedBy", modifiedBy);
                                        cmdInsertar.Parameters.AddWithValue("@IpAddress", ipAddress);
                                        cmdInsertar.ExecuteNonQuery();
                                    }
                                }
                            }

                            // 3. Registrar en bitácora
                            string descripcion = $"Roles asignados al usuario {usuario.USU_Username}: {string.Join(", ", roleIds)}";
                            string queryBitacora = @"
                                INSERT INTO PM_BITACORA (
                                    BIT_USR_ID, BIT_ACCION, BIT_MODULO, BIT_DESCRIPCION, 
                                    BIT_IP_ADDRESS, BIT_RESULTADO
                                ) VALUES (
                                    @UserId, 'ASIGNAR_ROLES', 'USUARIOS', @Descripcion, 
                                    @IpAddress, 'EXITO'
                                )";

                            using (SqlCommand cmdBitacora = new SqlCommand(queryBitacora, conexion, transaction))
                            {
                                cmdBitacora.Parameters.AddWithValue("@UserId", userId);
                                cmdBitacora.Parameters.AddWithValue("@Descripcion", descripcion);
                                cmdBitacora.Parameters.AddWithValue("@IpAddress", ipAddress);
                                cmdBitacora.ExecuteNonQuery();
                            }

                            transaction.Commit();

                            return new CE_LoginResponse
                            {
                                Resultado = "EXITO",
                                Mensaje = $"Roles asignados exitosamente. {roleIds.Length} rol(es) asignado(s).",
                                UserId = userId
                            };
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            throw ex;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al asignar roles al usuario");
                return new CE_LoginResponse
                {
                    Resultado = "ERROR",
                    Mensaje = $"Error al asignar roles: {ex.Message}",
                    UserId = 0
                };
            }
        }
    }
}