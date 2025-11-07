using CapaComun;
using CapaEntidad.DTOs.Catalogo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDatos.Catalogo
{
    public class CD_Marca
    {
        private readonly CC_Conexion _conexion;

        public CD_Marca()
        {
            _conexion = new CC_Conexion();
        }

        /// <summary>
        /// Crea una nueva marca
        /// </summary>
        public int CrearMarca(CE_MarcaCreateDTO marca, string usuarioCreacion, string ipCreacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@Nombre", marca.Nombre, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Descripcion", (object)marca.Descripcion ?? DBNull.Value, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@Activo", marca.Activo, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioCreacion", usuarioCreacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpCreacion", ipCreacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@IdMarca", SqlDbType.Int) { Direction = ParameterDirection.Output }
                };

                _conexion.EjecutarProcedimientoSinResultado("ZI_GENERAL.SP_MARCAS_CREAR", parametros);

                return Convert.ToInt32(parametros[5].Value);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al crear marca: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Actualiza una marca existente
        /// </summary>
        public void ActualizarMarca(CE_MarcaUpdateDTO marca, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdMarca", marca.IdMarca, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@Nombre", marca.Nombre, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Descripcion", (object)marca.Descripcion ?? DBNull.Value, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@Activo", marca.Activo, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45)
                };

                _conexion.EjecutarProcedimientoSinResultado("ZI_GENERAL.SP_MARCAS_ACTUALIZAR", parametros);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al actualizar marca: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Elimina (lógicamente) una marca
        /// </summary>
        public void EliminarMarca(int idMarca, string usuarioEliminacion, string ipEliminacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdMarca", idMarca, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@UsuarioEliminacion", usuarioEliminacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpEliminacion", ipEliminacion, SqlDbType.NVarChar, 45)
                };

                _conexion.EjecutarProcedimientoSinResultado("ZI_GENERAL.SP_MARCAS_ELIMINAR", parametros);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al eliminar marca: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene marcas paginadas
        /// </summary>
        public (List<CE_MarcaListDTO> Marcas, int TotalRegistros) ObtenerMarcasPaginadas(
            int pageNumber, 
            int pageSize, 
            string searchTerm, 
            bool? incluirInactivos)
        {
            List<CE_MarcaListDTO> marcas = new List<CE_MarcaListDTO>();
            int totalRegistros = 0;

            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@PageNumber", pageNumber, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@PageSize", pageSize, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@SearchTerm", (object)searchTerm ?? DBNull.Value, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IncluirInactivos", incluirInactivos ?? false, SqlDbType.Bit),
                    new SqlParameter("@TotalRegistros", SqlDbType.Int) { Direction = ParameterDirection.Output }
                };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_MARCAS_LISTAR_PAGINADO", parametros);

                if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow row in dataSet.Tables[0].Rows)
                    {
                        marcas.Add(new CE_MarcaListDTO
                        {
                            IdMarca = Convert.ToInt32(row["IdMarca"]),
                            Nombre = row["Nombre"].ToString(),
                            Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                            Activo = Convert.ToBoolean(row["Activo"]),
                            TotalModelos = Convert.ToInt32(row["TotalModelos"]),
                            FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                            UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                            FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                            UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null
                        });
                    }
                }

                totalRegistros = parametros[4].Value != DBNull.Value 
                    ? Convert.ToInt32(parametros[4].Value) 
                    : 0;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener marcas paginadas: {ex.Message}", ex);
            }

            return (marcas, totalRegistros);
        }

        /// <summary>
        /// Obtiene una marca por ID
        /// </summary>
        public CE_MarcaListDTO ObtenerMarcaPorId(int idMarca)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdMarca", idMarca, SqlDbType.Int)
                };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_MARCAS_OBTENER_POR_ID", parametros);

                if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                {
                    DataRow row = dataSet.Tables[0].Rows[0];

                    return new CE_MarcaListDTO
                    {
                        IdMarca = Convert.ToInt32(row["IdMarca"]),
                        Nombre = row["Nombre"].ToString(),
                        Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                        Activo = Convert.ToBoolean(row["Activo"]),
                        TotalModelos = Convert.ToInt32(row["TotalModelos"]),
                        FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                        UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                        FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                        UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null
                    };
                }

                throw new Exception("Marca no encontrada");
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener marca por ID: {ex.Message}", ex);
            }
        }
    }
}
