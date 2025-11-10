using CapaComun;
using CapaComun.Excepciones;
using CapaEntidad.DTOs.Common;
using CapaEntidad.DTOs.Usuario;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDatos.Usuario
{
    /// <summary>
    /// Capa de datos para gestión de usuarios
    /// </summary>
    public class CD_UsuarioGestion
    {
        private readonly CC_Conexion _conexion;

        public CD_UsuarioGestion()
        {
            _conexion = new CC_Conexion();
        }

        #region Operaciones CRUD de Usuarios

        /// <summary>
        /// Obtiene usuarios paginados
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
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@PageNumber", pageNumber, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@PageSize", pageSize, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@SearchTerm", (object)searchTerm ?? DBNull.Value, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IncluirInactivos", incluirInactivos, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@SoloBloqueados", soloBloqueados, SqlDbType.Bit),
                    new SqlParameter("@TotalRegistros", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_USUARIOS_LISTAR_PAGINADO", parametros);

                int totalRegistros = parametros[5].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[5].Value)
                    : 0;

                List<CE_UsuarioListDTO> usuarios = new List<CE_UsuarioListDTO>();

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow row in ds.Tables[0].Rows)
                    {
                        usuarios.Add(MapearUsuarioListDTO(row));
                    }
                }

                return new CE_PagedResult<CE_UsuarioListDTO>(
                    usuarios,
                    totalRegistros,
                    pageNumber,
                    pageSize
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener usuarios paginados");
                throw new DataAccessException($"Error al obtener usuarios paginados: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene un usuario por ID con toda su información
        /// </summary>
        public CE_UsuarioDetalleDTO ObtenerUsuarioPorId(int idUsuario)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdUsuario", idUsuario, SqlDbType.Int)
                };

                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_USUARIOS_OBTENER_POR_ID", parametros);

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    CE_UsuarioDetalleDTO usuario = MapearUsuarioDetalleDTO(ds.Tables[0].Rows[0]);

                    // Mapear roles asignados (segunda tabla)
                    if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
                    {
                        foreach (DataRow row in ds.Tables[1].Rows)
                        {
                            usuario.Roles.Add(new CE_RolAsignadoDTO
                            {
                                IdRol = Convert.ToInt32(row["IdRol"]),
                                Nombre = row["Nombre"].ToString(),
                                Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                                FechaAsignacion = Convert.ToDateTime(row["FechaAsignacion"]),
                                Activo = Convert.ToBoolean(row["Activo"])
                            });
                        }
                    }

                    // Mapear permisos efectivos (tercera tabla)
                    if (ds.Tables.Count > 2 && ds.Tables[2].Rows.Count > 0)
                    {
                        foreach (DataRow row in ds.Tables[2].Rows)
                        {
                            usuario.Permisos.Add(new CE_PermisoDTO
                            {
                                IdPermiso = Convert.ToInt32(row["IdPermiso"]),
                                Nombre = row["Nombre"].ToString(),
                                Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                                Modulo = row["Modulo"] != DBNull.Value ? row["Modulo"].ToString() : null,
                                Accion = row["Accion"] != DBNull.Value ? row["Accion"].ToString() : null
                            });
                        }
                    }

                    return usuario;
                }

                return null;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener usuario por ID");
                throw new DataAccessException($"Error al obtener usuario por ID: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Crea un nuevo usuario
        /// </summary>
        public int CrearUsuario(CE_UsuarioCreateDTO usuario, string passwordEncriptada, string usuarioCreacion, string ipCreacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@Codigo", usuario.Codigo, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@Username", usuario.Username, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@PasswordEncrypted", passwordEncriptada, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@Nombre", usuario.Nombre, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Apellido", usuario.Apellido, SqlDbType.NVarChar, 150),
                    CC_Conexion.CrearParametro("@Correo", usuario.Correo, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Telefono", usuario.Telefono, SqlDbType.NVarChar, 20),
                    CC_Conexion.CrearParametro("@Departamento", usuario.Departamento, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Puesto", usuario.Puesto, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Activo", usuario.Activo, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@PassTemp", usuario.PasswordTemporal, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioCreacion", usuarioCreacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpCreacion", ipCreacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@IdUsuario", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimientoSinResultado("ZI_GENERAL.SP_USUARIOS_CREAR", parametros);

                int idUsuarioCreado = Convert.ToInt32(parametros[13].Value);

                // Si tiene roles asignados, asignarlos
                if (usuario.RolesIds != null && usuario.RolesIds.Length > 0)
                {
                    AsignarRolesUsuario(idUsuarioCreado, usuario.RolesIds, usuarioCreacion, ipCreacion);
                }

                return idUsuarioCreado;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al crear usuario");
                throw new DataAccessException($"Error al crear usuario: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Actualiza un usuario
        /// </summary>
        public int ActualizarUsuario(CE_UsuarioUpdateDTO usuario, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdUsuario", usuario.IdUsuario, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@Nombre", usuario.Nombre, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Apellido", usuario.Apellido, SqlDbType.NVarChar, 150),
                    CC_Conexion.CrearParametro("@Correo", usuario.Correo, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Telefono", usuario.Telefono, SqlDbType.NVarChar, 20),
                    CC_Conexion.CrearParametro("@Departamento", usuario.Departamento, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Puesto", usuario.Puesto, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Activo", usuario.Activo, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimientoSinResultado("ZI_GENERAL.SP_USUARIOS_ACTUALIZAR", parametros);

                return parametros[10].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[10].Value)
                    : 0;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al actualizar usuario");
                throw new DataAccessException($"Error al actualizar usuario: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Elimina (desactiva) un usuario
        /// </summary>
        public int EliminarUsuario(int idUsuario, string usuarioEliminacion, string ipEliminacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdUsuario", idUsuario, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@UsuarioEliminacion", usuarioEliminacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpEliminacion", ipEliminacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimientoSinResultado("ZI_GENERAL.SP_USUARIOS_ELIMINAR", parametros);

                return parametros[3].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[3].Value)
                    : 0;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al eliminar usuario");
                throw new DataAccessException($"Error al eliminar usuario: {ex.Message}", ex);
            }
        }

        #endregion

        #region Gestión de Contraseñas

        /// <summary>
        /// Resetea la contraseña de un usuario
        /// </summary>
        public CE_OperacionResultDTO ResetearPassword(int idUsuario, string nuevaPasswordEncriptada, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdUsuario", idUsuario, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@NuevaPasswordEncriptada", nuevaPasswordEncriptada, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45)
                };

                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_USUARIOS_RESETEAR_PASSWORD", parametros);

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    DataRow row = ds.Tables[0].Rows[0];
                    string resultado = row["Resultado"].ToString();
                    string mensaje = row["Mensaje"].ToString();

                    return resultado == "EXITO"
                        ? CE_OperacionResultDTO.Exito(mensaje)
                        : CE_OperacionResultDTO.Error(mensaje);
                }

                return CE_OperacionResultDTO.Error("No se recibió respuesta del servidor");
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al resetear contraseña");
                throw new DataAccessException($"Error al resetear contraseña: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Desbloquea un usuario
        /// </summary>
        public CE_OperacionResultDTO DesbloquearUsuario(int idUsuario, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdUsuario", idUsuario, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45)
                };

                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_USUARIOS_DESBLOQUEAR", parametros);

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    DataRow row = ds.Tables[0].Rows[0];
                    string resultado = row["Resultado"].ToString();
                    string mensaje = row["Mensaje"].ToString();

                    return resultado == "EXITO"
                        ? CE_OperacionResultDTO.Exito(mensaje)
                        : CE_OperacionResultDTO.Error(mensaje);
                }

                return CE_OperacionResultDTO.Error("No se recibió respuesta del servidor");
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al desbloquear usuario");
                throw new DataAccessException($"Error al desbloquear usuario: {ex.Message}", ex);
            }
        }

        #endregion

        #region Gestión de Roles

        /// <summary>
        /// Asigna roles a un usuario
        /// </summary>
        public CE_OperacionResultDTO AsignarRolesUsuario(int idUsuario, int[] rolesIds, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                // Convertir array de IDs a string separado por comas
                string rolesIdsString = string.Join(",", rolesIds);

                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdUsuario", idUsuario, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@RolesIds", rolesIdsString, SqlDbType.NVarChar, -1), // -1 = MAX
                    CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45)
                };

                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_USUARIOS_ASIGNAR_ROLES", parametros);

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    DataRow row = ds.Tables[0].Rows[0];
                    string resultado = row["Resultado"].ToString();
                    string mensaje = row["Mensaje"].ToString();

                    return resultado == "EXITO"
                        ? CE_OperacionResultDTO.Exito(mensaje)
                        : CE_OperacionResultDTO.Error(mensaje);
                }

                return CE_OperacionResultDTO.Error("No se recibió respuesta del servidor");
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al asignar roles al usuario");
                throw new DataAccessException($"Error al asignar roles: {ex.Message}", ex);
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
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@PageNumber", pageNumber, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@PageSize", pageSize, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@SearchTerm", (object)searchTerm ?? DBNull.Value, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IncluirInactivos", incluirInactivos, SqlDbType.Bit),
                    new SqlParameter("@TotalRegistros", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_ROLES_LISTAR_PAGINADO", parametros);

                int totalRegistros = parametros[4].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[4].Value)
                    : 0;

                List<CE_RolListDTO> roles = new List<CE_RolListDTO>();

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow row in ds.Tables[0].Rows)
                    {
                        roles.Add(new CE_RolListDTO
                        {
                            IdRol = Convert.ToInt32(row["IdRol"]),
                            Nombre = row["Nombre"].ToString(),
                            Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                            Activo = Convert.ToBoolean(row["Activo"]),
                            TotalUsuarios = Convert.ToInt32(row["TotalUsuarios"]),
                            TotalPermisos = Convert.ToInt32(row["TotalPermisos"]),
                            FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                            UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                            FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                            UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null
                        });
                    }
                }

                return new CE_PagedResult<CE_RolListDTO>(
                    roles,
                    totalRegistros,
                    pageNumber,
                    pageSize
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener roles paginados");
                throw new DataAccessException($"Error al obtener roles paginados: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene los permisos de un rol
        /// </summary>
        public List<CE_PermisoDTO> ObtenerPermisosRol(int idRol)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdRol", idRol, SqlDbType.Int)
                };

                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_ROLES_OBTENER_PERMISOS", parametros);

                List<CE_PermisoDTO> permisos = new List<CE_PermisoDTO>();

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow row in ds.Tables[0].Rows)
                    {
                        permisos.Add(new CE_PermisoDTO
                        {
                            IdPermiso = Convert.ToInt32(row["IdPermiso"]),
                            Nombre = row["Nombre"].ToString(),
                            Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                            Modulo = row["Modulo"] != DBNull.Value ? row["Modulo"].ToString() : null,
                            Accion = row["Accion"] != DBNull.Value ? row["Accion"].ToString() : null
                        });
                    }
                }

                return permisos;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener permisos del rol");
                throw new DataAccessException($"Error al obtener permisos del rol: {ex.Message}", ex);
            }
        }

        #endregion

        #region Métodos Helper

        /// <summary>
        /// Mapea un DataRow a CE_UsuarioListDTO
        /// </summary>
        private CE_UsuarioListDTO MapearUsuarioListDTO(DataRow row)
        {
            return new CE_UsuarioListDTO
            {
                IdUsuario = Convert.ToInt32(row["IdUsuario"]),
                Codigo = Convert.ToInt32(row["Codigo"]),
                Username = row["Username"].ToString(),
                Nombre = row["Nombre"].ToString(),
                Apellido = row["Apellido"] != DBNull.Value ? row["Apellido"].ToString() : null,
                Correo = row["Correo"].ToString(),
                Telefono = row["Telefono"] != DBNull.Value ? row["Telefono"].ToString() : null,
                Departamento = row["Departamento"] != DBNull.Value ? row["Departamento"].ToString() : null,
                Puesto = row["Puesto"] != DBNull.Value ? row["Puesto"].ToString() : null,
                Activo = Convert.ToBoolean(row["Activo"]),
                Bloqueado = Convert.ToBoolean(row["Bloqueado"]),
                IntentosFallidos = Convert.ToInt32(row["IntentosFallidos"]),
                FechaBloqueo = row["FechaBloqueo"] != DBNull.Value ? Convert.ToDateTime(row["FechaBloqueo"]) : (DateTime?)null,
                UltimoLogin = row["UltimoLogin"] != DBNull.Value ? Convert.ToDateTime(row["UltimoLogin"]) : (DateTime?)null,
                RequiereCambioPassword = Convert.ToBoolean(row["RequiereCambioPassword"]),
                TotalRoles = Convert.ToInt32(row["TotalRoles"]),
                RolesAsignados = row["RolesAsignados"] != DBNull.Value ? row["RolesAsignados"].ToString() : null,
                FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null
            };
        }

        /// <summary>
        /// Mapea un DataRow a CE_UsuarioDetalleDTO
        /// </summary>
        private CE_UsuarioDetalleDTO MapearUsuarioDetalleDTO(DataRow row)
        {
            var usuario = new CE_UsuarioDetalleDTO
            {
                IdUsuario = Convert.ToInt32(row["IdUsuario"]),
                Codigo = Convert.ToInt32(row["Codigo"]),
                Username = row["Username"].ToString(),
                Nombre = row["Nombre"].ToString(),
                Apellido = row["Apellido"] != DBNull.Value ? row["Apellido"].ToString() : null,
                Correo = row["Correo"].ToString(),
                Telefono = row["Telefono"] != DBNull.Value ? row["Telefono"].ToString() : null,
                Departamento = row["Departamento"] != DBNull.Value ? row["Departamento"].ToString() : null,
                Puesto = row["Puesto"] != DBNull.Value ? row["Puesto"].ToString() : null,
                Activo = Convert.ToBoolean(row["Activo"]),
                Bloqueado = Convert.ToBoolean(row["Bloqueado"]),
                IntentosFallidos = Convert.ToInt32(row["IntentosFallidos"]),
                FechaBloqueo = row["FechaBloqueo"] != DBNull.Value ? Convert.ToDateTime(row["FechaBloqueo"]) : (DateTime?)null,
                UltimoLogin = row["UltimoLogin"] != DBNull.Value ? Convert.ToDateTime(row["UltimoLogin"]) : (DateTime?)null,
                RequiereCambioPassword = Convert.ToBoolean(row["RequiereCambioPassword"]),
                FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null,
                IpCreacion = row["IpCreacion"] != DBNull.Value ? row["IpCreacion"].ToString() : null,
                IpModificacion = row["IpModificacion"] != DBNull.Value ? row["IpModificacion"].ToString() : null
            };

            return usuario;
        }

        #endregion
    }
}
