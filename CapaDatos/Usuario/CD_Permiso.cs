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
    /// Capa de datos para gestión de permisos
    /// </summary>
    public class CD_Permiso
    {
        private readonly CC_Conexion _conexion;

        public CD_Permiso()
        {
            _conexion = new CC_Conexion();
        }

        /// <summary>
        /// Obtiene lista paginada de permisos
        /// </summary>
        public CE_PagedResult<CE_PermisoListDTO> ObtenerPermisosPaginados(
            int pageNumber = 1,
            int pageSize = 10,
            string searchTerm = null,
            bool incluirInactivos = false,
            string modulo = null,
            string accion = null)  // ? AGREGADO
        {
            try
            {
                // Convertir cadenas vacías a NULL
                if (string.IsNullOrWhiteSpace(searchTerm))
                    searchTerm = null;
                
                if (string.IsNullOrWhiteSpace(modulo))
                    modulo = null;

                if (string.IsNullOrWhiteSpace(accion))  // ? AGREGADO
                    accion = null;

                // Crear parámetros
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@PageNumber", pageNumber, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@PageSize", pageSize, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@SearchTerm", (object)searchTerm ?? DBNull.Value, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IncluirInactivos", incluirInactivos, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@Modulo", (object)modulo ?? DBNull.Value, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Accion", (object)accion ?? DBNull.Value, SqlDbType.NVarChar, 100),  // ? AGREGADO
                    new SqlParameter("@TotalRegistros", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                // Ejecutar procedimiento
                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_PERMISOS_LISTAR_PAGINADO", parametros);

                // Obtener total de registros del parámetro de salida
                int totalRegistros = parametros[6].Value != DBNull.Value  // ? ACTUALIZADO índice (era 5, ahora es 6)
                    ? Convert.ToInt32(parametros[6].Value)
                    : 0;

                // Convertir DataTable a lista de DTOs
                List<CE_PermisoListDTO> permisos = new List<CE_PermisoListDTO>();

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow row in ds.Tables[0].Rows)
                    {
                        permisos.Add(new CE_PermisoListDTO
                        {
                            IdPermiso = Convert.ToInt32(row["IdPermiso"]),
                            Nombre = row["Nombre"].ToString(),
                            Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                            Modulo = row["Modulo"].ToString(),
                            Accion = row["Accion"].ToString(),
                            Activo = Convert.ToBoolean(row["Activo"]),
                            TotalRoles = Convert.ToInt32(row["TotalRoles"]),
                            // Campos de auditoría
                            FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                            UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                            FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                            UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null
                        });
                    }
                }

                // Retornar resultado paginado
                return new CE_PagedResult<CE_PermisoListDTO>(
                    permisos,
                    totalRegistros,
                    pageNumber,
                    pageSize
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener permisos paginados");
                throw new DataAccessException($"Error al obtener permisos paginados: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene detalle completo de un permiso por ID
        /// </summary>
        public CE_PermisoDetalleDTO ObtenerPermisoPorId(int idPermiso)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdPermiso", idPermiso, SqlDbType.Int)
                };

                DataSet ds = _conexion.EjecutarProcedimiento("[ZI_GENERAL].SP_PERMISOS_OBTENER_POR_ID", parametros);

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    DataRow row = ds.Tables[0].Rows[0];

                    var permiso = new CE_PermisoDetalleDTO
                    {
                        IdPermiso = Convert.ToInt32(row["IdPermiso"]),
                        Nombre = row["Nombre"].ToString(),
                        Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                        Modulo = row["Modulo"].ToString(),
                        Accion = row["Accion"].ToString(),
                        Activo = Convert.ToBoolean(row["Activo"]),
                        TotalRoles = Convert.ToInt32(row["TotalRoles"]),
                        // Campos de auditoría completos
                        FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                        UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                        FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                        UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null,
                        IpCreacion = row["IpCreacion"] != DBNull.Value ? row["IpCreacion"].ToString() : null,
                        IpModificacion = row["IpModificacion"] != DBNull.Value ? row["IpModificacion"].ToString() : null,
                        Roles = new List<CE_PermisoRolDTO>()
                    };

                    // Segundo ResultSet: Roles que tienen este permiso
                    if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
                    {
                        foreach (DataRow rolRow in ds.Tables[1].Rows)
                        {
                            permiso.Roles.Add(new CE_PermisoRolDTO
                            {
                                IdRol = Convert.ToInt32(rolRow["IdRol"]),
                                Nombre = rolRow["Nombre"].ToString(),
                                Descripcion = rolRow["Descripcion"] != DBNull.Value ? rolRow["Descripcion"].ToString() : null,
                                Activo = Convert.ToBoolean(rolRow["Activo"]),
                                TotalUsuarios = Convert.ToInt32(rolRow["TotalUsuarios"])
                            });
                        }
                    }

                    return permiso;
                }

                return null;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener permiso por ID");
                throw new DataAccessException($"Error al obtener permiso por ID: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Crea un nuevo permiso
        /// </summary>
        public int CrearPermiso(CE_PermisoCreateDTO permiso, string usuarioCreacion, string ipCreacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@Nombre", permiso.Nombre, SqlDbType.NVarChar, 50),
                    CC_Conexion.CrearParametro("@Descripcion", (object)permiso.Descripcion ?? DBNull.Value, SqlDbType.NVarChar, 255),
                    CC_Conexion.CrearParametro("@Modulo", permiso.Modulo, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Accion", permiso.Accion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Activo", permiso.Activo, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioCreacion", usuarioCreacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpCreacion", ipCreacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@IdPermiso", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimientoSinResultado("[ZI_GENERAL].SP_PERMISOS_CREAR", parametros);

                return Convert.ToInt32(parametros[7].Value);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al crear permiso");
                throw new DataAccessException($"Error al crear permiso: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Actualiza un permiso existente
        /// </summary>
        public int ActualizarPermiso(CE_PermisoUpdateDTO permiso, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdPermiso", permiso.IdPermiso, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@Nombre", permiso.Nombre, SqlDbType.NVarChar, 50),
                    CC_Conexion.CrearParametro("@Descripcion", (object)permiso.Descripcion ?? DBNull.Value, SqlDbType.NVarChar, 255),
                    CC_Conexion.CrearParametro("@Modulo", permiso.Modulo, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Accion", permiso.Accion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Activo", permiso.Activo, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimientoSinResultado("[ZI_GENERAL].SP_PERMISOS_ACTUALIZAR", parametros);

                // Obtener filas afectadas del parámetro OUTPUT
                int filasAfectadas = parametros[8].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[8].Value)
                    : 0;

                return filasAfectadas;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al actualizar permiso");
                throw new DataAccessException($"Error al actualizar permiso: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Elimina (desactiva) un permiso
        /// </summary>
        public int EliminarPermiso(int idPermiso, string usuarioEliminacion, string ipEliminacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdPermiso", idPermiso, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@UsuarioEliminacion", usuarioEliminacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpEliminacion", ipEliminacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimientoSinResultado("[ZI_GENERAL].SP_PERMISOS_ELIMINAR", parametros);

                // Obtener filas afectadas del parámetro OUTPUT
                int filasAfectadas = parametros[3].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[3].Value)
                    : 0;

                return filasAfectadas;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al eliminar permiso");
                throw new DataAccessException($"Error al eliminar permiso: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene lista de módulos únicos del sistema (existentes + sugeridos)
        /// </summary>
        public List<string> ObtenerModulosDisponibles()
        {
            try
            {
                List<string> modulos = new List<string>();

                // Módulos sugeridos comunes del sistema
                var modulosSugeridos = new List<string>
                {
                    "USUARIOS",
                    "ROLES",
                    "PERMISOS",
                    "CATEGORIAS",
                    "SUB_CATEGORIAS",
                    "EQUIPOS",
                    "INVENTARIO",
                    "BODEGAS",
                    "MARCAS",
                    "MODELOS",
                    "CONTRATOS",
                    "AGENTES",
                    "REPORTES",
                    "AUDITORIA",
                    "CONFIGURACION",
                    "DASHBOARD"
                };

                // Obtener módulos existentes en la BD
                string query = @"
                    SELECT DISTINCT PER_Modulo 
                    FROM ZI_GENERAL.ZI_PERMISOS 
                    WHERE PER_Activo = 1 
                      AND PER_Modulo IS NOT NULL
                      AND PER_Modulo <> ''
                    ORDER BY PER_Modulo";

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand(query, conexion))
                    {
                        conexion.Open();

                        using (SqlDataReader reader = comando.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string modulo = reader["PER_Modulo"].ToString();
                                if (!string.IsNullOrWhiteSpace(modulo) && !modulos.Contains(modulo))
                                {
                                    modulos.Add(modulo);
                                }
                            }
                        }
                    }
                }

                // Agregar módulos sugeridos que no estén en la lista
                foreach (var moduloSugerido in modulosSugeridos)
                {
                    if (!modulos.Contains(moduloSugerido))
                    {
                        modulos.Add(moduloSugerido);
                    }
                }

                // Ordenar alfabéticamente
                modulos.Sort();

                return modulos;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener módulos disponibles");
                throw new DataAccessException($"Error al obtener módulos disponibles: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene lista de acciones únicas del sistema (existentes + sugeridas)
        /// </summary>
        public List<string> ObtenerAccionesDisponibles()
        {
            try
            {
                List<string> acciones = new List<string>();

                // Acciones sugeridas comunes (patrón CRUD estándar)
                var accionesSugeridas = new List<string>
                {
                    "CREAR",
                    "LEER",
                    "ACTUALIZAR",
                    "ELIMINAR",
                    "EXPORTAR",
                    "IMPORTAR",
                    "IMPRIMIR",
                    "APROBAR",
                    "RECHAZAR",
                    "ADMINISTRAR",
                    "ACCESO_TOTAL"
                };

                // Obtener acciones existentes en la BD
                string query = @"
                    SELECT DISTINCT PER_Accion 
                    FROM ZI_GENERAL.ZI_PERMISOS 
                    WHERE PER_Activo = 1 
                      AND PER_Accion IS NOT NULL
                      AND PER_Accion <> ''
                    ORDER BY PER_Accion";

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand(query, conexion))
                    {
                        conexion.Open();

                        using (SqlDataReader reader = comando.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string accion = reader["PER_Accion"].ToString();
                                if (!string.IsNullOrWhiteSpace(accion) && !acciones.Contains(accion))
                                {
                                    acciones.Add(accion);
                                }
                            }
                        }
                    }
                }

                // Agregar acciones sugeridas que no estén en la lista
                foreach (var accionSugerida in accionesSugeridas)
                {
                    if (!acciones.Contains(accionSugerida))
                    {
                        acciones.Add(accionSugerida);
                    }
                }

                // Ordenar alfabéticamente
                acciones.Sort();

                return acciones;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener acciones disponibles");
                throw new DataAccessException($"Error al obtener acciones disponibles: {ex.Message}", ex);
            }
        }
    }
}
