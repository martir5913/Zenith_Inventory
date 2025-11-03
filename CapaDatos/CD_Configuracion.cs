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
    /// Capa de datos para manejo de configuraciones
    /// </summary>
    public class CD_Configuracion
    {
        private readonly CC_Conexion _conexion;

        public CD_Configuracion()
        {
            _conexion = new CC_Conexion();
        }

        /// <summary>
        /// Obtiene las configuraciones de encriptación desde la base de datos
        /// </summary>
        /// <returns>Configuración de encriptación</returns>
        public CE_EncryptionConfig ObtenerConfiguracionEncriptacion()
        {
            try
            {
                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_GET_ENCRYPTION_CONFIG");

                if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                {
                    CE_EncryptionConfig config = new CE_EncryptionConfig();

                    foreach (DataRow row in dataSet.Tables[0].Rows)
                    {
                        string clave = row["ZIC_Clave"].ToString();
                        string valor = row["ZIC_Valor"].ToString();

                        switch (clave)
                        {
                            case "ENCRYPT_KEY":
                                config.Key = valor;
                                break;
                            case "ENCRYPT_SALT":
                                config.Salt = valor;
                                break;
                            case "ENCRYPT_IV":
                                config.IV = valor;
                                break;
                        }
                    }

                    return config;
                }

                throw new Exception("No se encontraron configuraciones de encriptación en la base de datos.");
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener configuración de encriptación: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene una configuración específica por clave
        /// </summary>
        /// <param name="clave">Clave de la configuración</param>
        /// <returns>Entidad de configuración</returns>
        public CE_Configuracion ObtenerConfiguracionPorClave(string clave)
        {
            try
            {
                List<SqlParameter> parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@Clave", clave, SqlDbType.NVarChar, 100)
                };

                string query = @"
                    SELECT ZIC_Id, ZIC_Clave, ZIC_Valor, ZIC_Descripcion, ZIC_Tipo, ZIC_Activo,
                           ZIC_FechaCreacion, ZIC_UsuarioCreacion, ZIC_FechaModificacion, 
                           ZIC_UsuarioModificacion, ZIC_IpCreacion, ZIC_IpModificacion
                    FROM ZI_GENERAL.ZI_CONFIGURACION 
                    WHERE ZIC_Clave = @Clave AND ZIC_Activo = 1";

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
                                return new CE_Configuracion
                                {
                                    ZIC_Id = Convert.ToInt32(reader["ZIC_Id"]),
                                    ZIC_Clave = reader["ZIC_Clave"].ToString(),
                                    ZIC_Valor = reader["ZIC_Valor"].ToString(),
                                    ZIC_Descripcion = reader["ZIC_Descripcion"].ToString(),
                                    ZIC_Tipo = reader["ZIC_Tipo"].ToString(),
                                    ZIC_Activo = Convert.ToBoolean(reader["ZIC_Activo"]),
                                    ZIC_FechaCreacion = Convert.ToDateTime(reader["ZIC_FechaCreacion"]),
                                    ZIC_UsuarioCreacion = reader["ZIC_UsuarioCreacion"].ToString(),
                                    ZIC_FechaModificacion = reader["ZIC_FechaModificacion"] == DBNull.Value ?
                                        (DateTime?)null : Convert.ToDateTime(reader["ZIC_FechaModificacion"]),
                                    ZIC_UsuarioModificacion = reader["ZIC_UsuarioModificacion"].ToString(),
                                    ZIC_IpCreacion = reader["ZIC_IpCreacion"].ToString(),
                                    ZIC_IpModificacion = reader["ZIC_IpModificacion"].ToString()
                                };
                            }
                        }
                    }
                }

                return null;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener configuración por clave '{clave}': {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene todas las configuraciones activas
        /// </summary>
        /// <returns>Lista de configuraciones</returns>
        public List<CE_Configuracion> ObtenerTodasLasConfiguraciones()
        {
            try
            {
                string query = @"
                    SELECT ZIC_Id, ZIC_Clave, ZIC_Valor, ZIC_Descripcion, ZIC_Tipo, ZIC_Activo,
                           ZIC_FechaCreacion, ZIC_UsuarioCreacion, ZIC_FechaModificacion, 
                           ZIC_UsuarioModificacion, ZIC_IpCreacion, ZIC_IpModificacion
                    FROM ZI_GENERAL.ZI_CONFIGURACION 
                    WHERE ZIC_Activo = 1
                    ORDER BY ZIC_Clave";

                using (SqlConnection conexion = _conexion.ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand(query, conexion))
                    {
                        conexion.Open();

                        using (SqlDataAdapter adapter = new SqlDataAdapter(comando))
                        {
                            DataTable dataTable = new DataTable();
                            adapter.Fill(dataTable);

                            return CC_Conexion.ConvertirDataTableALista<CE_Configuracion>(dataTable);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener todas las configuraciones: {ex.Message}", ex);
            }
        }
    }
}