using CapaComun;
using CapaComun.Excepciones;
using CapaEntidad.DTOs.Common; // ✅ CORREGIDO: Para CE_PagedResult
using CapaEntidad.DTOs.Usuario;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDatos.Usuario
{
    /// <summary>
    /// Capa de Datos para Gestión de Roles
    /// Patrón: Similar a CD_Permiso y CD_Categoria
    /// </summary>
    public class CD_Rol
    {
        private readonly CC_Conexion _conexion;

        public CD_Rol()
        {
            _conexion = new CC_Conexion();
        }

        #region LISTAR ROLES PAGINADO

        /// <summary>
        /// Obtiene un listado paginado de roles
        /// </summary>
        public CE_PagedResult<CE_RolListDTO> ListarRolesPaginado(
            int numeroPagina = 1,
            int tamañoPagina = 10,
            string terminoBusqueda = null,
            bool incluirInactivos = false)
        {
            List<CE_RolListDTO> roles = new List<CE_RolListDTO>(); // ✅ Solo se necesita esta lista

            try
            {
                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand("ZI_GENERAL.SP_ROLES_LISTAR_PAGINADO", conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;

                        // Parámetros de entrada
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@PageNumber", numeroPagina, SqlDbType.Int));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@PageSize", tamañoPagina, SqlDbType.Int));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@SearchTerm", terminoBusqueda, SqlDbType.NVarChar, 100));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IncluirInactivos", incluirInactivos, SqlDbType.Bit));

                        // Parámetro de salida
                        SqlParameter totalRegistrosParam = new SqlParameter("@TotalRegistros", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        comando.Parameters.Add(totalRegistrosParam);

                        conexion.Open();

                        using (SqlDataReader lector = comando.ExecuteReader())
                        {
                            while (lector.Read())
                            {
                                roles.Add(new CE_RolListDTO
                                {
                                    IdRol = lector.GetInt32(lector.GetOrdinal("IdRol")),
                                    Nombre = lector.GetString(lector.GetOrdinal("Nombre")),
                                    Descripcion = lector.IsDBNull(lector.GetOrdinal("Descripcion")) ? null : lector.GetString(lector.GetOrdinal("Descripcion")),
                                    Activo = lector.GetBoolean(lector.GetOrdinal("Activo")),
                                    FechaCreacion = lector.IsDBNull(lector.GetOrdinal("FechaCreacion")) ? (DateTime?)null : lector.GetDateTime(lector.GetOrdinal("FechaCreacion")),
                                    UsuarioCreacion = lector.IsDBNull(lector.GetOrdinal("UsuarioCreacion")) ? null : lector.GetString(lector.GetOrdinal("UsuarioCreacion")),
                                    FechaModificacion = lector.IsDBNull(lector.GetOrdinal("FechaModificacion")) ? (DateTime?)null : lector.GetDateTime(lector.GetOrdinal("FechaModificacion")),
                                    UsuarioModificacion = lector.IsDBNull(lector.GetOrdinal("UsuarioModificacion")) ? null : lector.GetString(lector.GetOrdinal("UsuarioModificacion")),
                                    TotalPermisos = lector.GetInt32(lector.GetOrdinal("TotalPermisos")),
                                    TotalUsuarios = lector.GetInt32(lector.GetOrdinal("TotalUsuarios"))
                                });
                            }
                        }

                        // Obtener total de registros del parámetro de salida
                        int totalRegistros = (int)totalRegistrosParam.Value;

                        // ✅ FIX: Retornar CE_PagedResult con el constructor correcto
                        ErrorLogger.LogCustom($"Roles listados exitosamente. Página {numeroPagina}, Total: {totalRegistros}");
                        return new CE_PagedResult<CE_RolListDTO>(roles, totalRegistros, numeroPagina, tamañoPagina);
                    }
                }
            }
            catch (SqlException ex)
            {
                ErrorLogger.Log(ex, "Error SQL al listar roles paginados");
                throw new DataAccessException("Error al obtener los roles", ex);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error inesperado al listar roles paginados");
                throw;
            }
        }

        #endregion

        #region OBTENER ROL POR ID

        /// <summary>
        /// Obtiene los detalles completos de un rol por ID (incluyendo permisos asignados)
        /// </summary>
        public CE_RolDetalleDTO ObtenerRolPorId(int idRol)
        {
            CE_RolDetalleDTO rol = null;

            try
            {
                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand("ZI_GENERAL.SP_ROLES_OBTENER_POR_ID", conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IdRol", idRol, SqlDbType.Int));

                        conexion.Open();

                        using (SqlDataReader lector = comando.ExecuteReader())
                        {
                            // Primer ResultSet: Información básica del rol
                            if (lector.Read())
                            {
                                rol = new CE_RolDetalleDTO
                                {
                                    IdRol = lector.GetInt32(lector.GetOrdinal("IdRol")),
                                    Nombre = lector.GetString(lector.GetOrdinal("Nombre")),
                                    Descripcion = lector.IsDBNull(lector.GetOrdinal("Descripcion")) ? null : lector.GetString(lector.GetOrdinal("Descripcion")),
                                    Activo = lector.GetBoolean(lector.GetOrdinal("Activo")),
                                    FechaCreacion = lector.IsDBNull(lector.GetOrdinal("FechaCreacion")) ? (DateTime?)null : lector.GetDateTime(lector.GetOrdinal("FechaCreacion")),
                                    UsuarioCreacion = lector.IsDBNull(lector.GetOrdinal("UsuarioCreacion")) ? null : lector.GetString(lector.GetOrdinal("UsuarioCreacion")),
                                    FechaModificacion = lector.IsDBNull(lector.GetOrdinal("FechaModificacion")) ? (DateTime?)null : lector.GetDateTime(lector.GetOrdinal("FechaModificacion")),
                                    UsuarioModificacion = lector.IsDBNull(lector.GetOrdinal("UsuarioModificacion")) ? null : lector.GetString(lector.GetOrdinal("UsuarioModificacion")),
                                    TotalPermisos = lector.GetInt32(lector.GetOrdinal("TotalPermisos")),
                                    TotalUsuarios = lector.GetInt32(lector.GetOrdinal("TotalUsuarios"))
                                };
                            }

                            // Segundo ResultSet: Permisos asignados al rol
                            if (rol != null && lector.NextResult())
                            {
                                while (lector.Read())
                                {
                                    rol.Permisos.Add(new CE_PermisoListDTO
                                    {
                                        IdPermiso = lector.GetInt32(lector.GetOrdinal("IdPermiso")),
                                        Nombre = lector.GetString(lector.GetOrdinal("Nombre")),
                                        Descripcion = lector.IsDBNull(lector.GetOrdinal("Descripcion")) ? null : lector.GetString(lector.GetOrdinal("Descripcion")),
                                        Modulo = lector.IsDBNull(lector.GetOrdinal("Modulo")) ? null : lector.GetString(lector.GetOrdinal("Modulo")),
                                        Accion = lector.IsDBNull(lector.GetOrdinal("Accion")) ? null : lector.GetString(lector.GetOrdinal("Accion")),
                                        Activo = lector.GetBoolean(lector.GetOrdinal("Activo"))
                                    });
                                }
                            }
                        }
                    }
                }

                if (rol == null)
                {
                    ErrorLogger.LogCustom($"Rol no encontrado con ID: {idRol}");
                    throw new KeyNotFoundException($"No se encontró el rol con ID: {idRol}");
                }

                ErrorLogger.LogCustom($"Rol obtenido exitosamente: {rol.Nombre} (ID: {idRol})");
                return rol;
            }
            catch (SqlException ex)
            {
                ErrorLogger.Log(ex, $"Error SQL al obtener rol por ID: {idRol}");
                throw new DataAccessException($"Error al obtener el rol con ID: {idRol}", ex);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error inesperado al obtener rol por ID: {idRol}");
                throw;
            }
        }

        #endregion

        #region CREAR ROL

        /// <summary>
        /// Crea un nuevo rol
        /// </summary>
        public int CrearRol(CE_RolCreateDTO dto, string usuarioCreacion, string ipCreacion)
        {
            try
            {
                int nuevoId = 0;

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand("ZI_GENERAL.SP_ROLES_CREAR", conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;

                        // Parámetros de entrada
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@Nombre", dto.Nombre, SqlDbType.NVarChar, 50));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@Descripcion", dto.Descripcion, SqlDbType.NVarChar, 255));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@Activo", dto.Activo, SqlDbType.Bit));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@UsuarioCreacion", usuarioCreacion, SqlDbType.NVarChar, 100));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IpCreacion", ipCreacion, SqlDbType.NVarChar, 45));

                        // Parámetro de salida
                        SqlParameter idRolParam = new SqlParameter("@IdRol", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        comando.Parameters.Add(idRolParam);

                        conexion.Open();
                        comando.ExecuteNonQuery();

                        nuevoId = (int)idRolParam.Value;
                    }
                }

                ErrorLogger.LogCustom($"Rol creado exitosamente: {dto.Nombre} (ID: {nuevoId})");
                return nuevoId;
            }
            catch (SqlException ex)
            {
                ErrorLogger.Log(ex, $"Error SQL al crear rol: {dto.Nombre}");
                throw new DataAccessException($"Error al crear el rol: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error inesperado al crear rol: {dto.Nombre}");
                throw;
            }
        }

        #endregion

        #region ACTUALIZAR ROL

        /// <summary>
        /// Actualiza un rol existente
        /// </summary>
        public int ActualizarRol(CE_RolUpdateDTO dto, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                int filasAfectadas = 0;

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand("ZI_GENERAL.SP_ROLES_ACTUALIZAR", conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;

                        // Parámetros de entrada
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IdRol", dto.IdRol, SqlDbType.Int));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@Nombre", dto.Nombre, SqlDbType.NVarChar, 50));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@Descripcion", dto.Descripcion, SqlDbType.NVarChar, 255));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@Activo", dto.Activo, SqlDbType.Bit));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45));

                        // Parámetro de salida
                        SqlParameter filasAfectadasParam = new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        comando.Parameters.Add(filasAfectadasParam);

                        conexion.Open();
                        comando.ExecuteNonQuery();

                        filasAfectadas = (int)filasAfectadasParam.Value;
                    }
                }

                if (filasAfectadas == 0)
                {
                    ErrorLogger.LogCustom($"No se actualizó ningún rol con ID: {dto.IdRol}");
                    throw new KeyNotFoundException($"No se encontró el rol con ID: {dto.IdRol}");
                }

                ErrorLogger.LogCustom($"Rol actualizado exitosamente: {dto.Nombre} (ID: {dto.IdRol})");
                return filasAfectadas;
            }
            catch (SqlException ex)
            {
                ErrorLogger.Log(ex, $"Error SQL al actualizar rol ID: {dto.IdRol}");
                throw new DataAccessException($"Error al actualizar el rol: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error inesperado al actualizar rol ID: {dto.IdRol}");
                throw;
            }
        }

        #endregion

        #region ELIMINAR ROL

        /// <summary>
        /// Elimina (desactiva) un rol
        /// </summary>
        public int EliminarRol(int idRol, string usuarioEliminacion, string ipEliminacion)
        {
            try
            {
                int filasAfectadas = 0;

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand("ZI_GENERAL.SP_ROLES_ELIMINAR", conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;

                        // Parámetros de entrada
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IdRol", idRol, SqlDbType.Int));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@UsuarioEliminacion", usuarioEliminacion, SqlDbType.NVarChar, 100));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IpEliminacion", ipEliminacion, SqlDbType.NVarChar, 45));

                        // Parámetro de salida
                        SqlParameter filasAfectadasParam = new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        comando.Parameters.Add(filasAfectadasParam);

                        conexion.Open();
                        comando.ExecuteNonQuery();

                        filasAfectadas = (int)filasAfectadasParam.Value;
                    }
                }

                if (filasAfectadas == 0)
                {
                    ErrorLogger.LogCustom($"No se eliminó ningún rol con ID: {idRol}");
                    throw new KeyNotFoundException($"No se encontró el rol con ID: {idRol}");
                }

                ErrorLogger.LogCustom($"Rol eliminado exitosamente (ID: {idRol})");
                return filasAfectadas;
            }
            catch (SqlException ex)
            {
                ErrorLogger.Log(ex, $"Error SQL al eliminar rol ID: {idRol}");
                throw new DataAccessException($"Error al eliminar el rol: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error inesperado al eliminar rol ID: {idRol}");
                throw;
            }
        }

        #endregion

        #region REACTIVAR ROL

        /// <summary>
        /// Reactiva un rol previamente desactivado (borrado lógico)
        /// </summary>
        public int ReactivarRol(int idRol, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                int filasAfectadas = 0;

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand("ZI_GENERAL.SP_ROLES_REACTIVAR", conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;

                        // Parámetros de entrada
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IdRol", idRol, SqlDbType.Int));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45));

                        // Parámetro de salida
                        SqlParameter filasAfectadasParam = new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        comando.Parameters.Add(filasAfectadasParam);

                        conexion.Open();
                        comando.ExecuteNonQuery();

                        filasAfectadas = (int)filasAfectadasParam.Value;
                    }
                }

                if (filasAfectadas == 0)
                {
                    ErrorLogger.LogCustom($"No se reactivó ningún rol con ID: {idRol}");
                    throw new KeyNotFoundException($"No se encontró el rol con ID: {idRol}");
                }

                ErrorLogger.LogCustom($"Rol reactivado exitosamente (ID: {idRol})");
                return filasAfectadas;
            }
            catch (SqlException ex)
            {
                ErrorLogger.Log(ex, $"Error SQL al reactivar rol ID: {idRol}");
                throw new DataAccessException($"Error al reactivar el rol: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error inesperado al reactivar rol ID: {idRol}");
                throw;
            }
        }

        #endregion

        #region ASIGNAR PERMISOS

        /// <summary>
        /// Asigna permisos a un rol
        /// </summary>
        public void AsignarPermisos(int idRol, List<int> permisosIds, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                string permisosIdsStr = permisosIds != null && permisosIds.Count > 0
                    ? string.Join(",", permisosIds)
                    : null;

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand("ZI_GENERAL.SP_ROLES_ASIGNAR_PERMISOS", conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;

                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IdRol", idRol, SqlDbType.Int));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@PermisosIds", permisosIdsStr, SqlDbType.NVarChar, -1)); // MAX
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100));
                        comando.Parameters.Add(CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45));

                        conexion.Open();
                        comando.ExecuteNonQuery();
                    }
                }

                ErrorLogger.LogCustom($"Permisos asignados exitosamente al rol ID: {idRol}");
            }
            catch (SqlException ex)
            {
                ErrorLogger.Log(ex, $"Error SQL al asignar permisos al rol ID: {idRol}");
                throw new DataAccessException($"Error al asignar permisos al rol: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error inesperado al asignar permisos al rol ID: {idRol}");
                throw;
            }
        }

        #endregion
    }
}
