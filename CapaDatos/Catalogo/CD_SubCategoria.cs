using CapaComun;
using CapaComun.Excepciones;
using CapaEntidad.DTOs.Catalogo;
using CapaEntidad.DTOs.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDatos.Catalogo
{
    public class CD_SubCategoria
    {
        private readonly CC_Conexion _conexion;

        public CD_SubCategoria()
        {
            _conexion = new CC_Conexion();
        }

        public CE_PagedResult<CE_SubCategoriaListDTO> ObtenerSubCategoriasPaginadas(int pageNumber = 1, int pageSize = 10, string searchTerm = null, bool incluirInactivos = false, int? idCategoria = null)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@PageNumber",pageNumber,SqlDbType.Int),
                     CC_Conexion.CrearParametro("@PageSize", pageSize, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@SearchTerm", (object)searchTerm ?? DBNull.Value, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IncluirInactivos", incluirInactivos, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@IdCategoria", (object)idCategoria ?? DBNull.Value, SqlDbType.Int),
                    new SqlParameter("@TotalRegistros", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO", parametros);

                int totalRegistros = parametros[5].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[5].Value)
                    : 0;

                List<CE_SubCategoriaListDTO> SubCategoria = new List<CE_SubCategoriaListDTO>();

                if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow row in dataSet.Tables[0].Rows)
                    {
                        SubCategoria.Add(new CE_SubCategoriaListDTO
                        {
                            IdSubCategoria = Convert.ToInt32(row["IdSubcategoria"]),
                            Nombre = row["Nombre"].ToString(),
                            Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                            Estado = Convert.ToBoolean(row["Activo"]),
                            IdCategoria = Convert.ToInt32(row["IdCategoria"]),
                            NombreCategoria = row["NombreCategoria"].ToString(),
                            TotalModelos = Convert.ToInt32(row["TotalModelos"]),
                            // Campos de auditoría
                            FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                            UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                            FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                            UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null
                        });
                    }
                }

                return new CE_PagedResult<CE_SubCategoriaListDTO>(
                    SubCategoria,
                    totalRegistros,
                    pageNumber,
                    pageSize
                    );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener las SubCategorias");
                throw new DataAccessException($"Error al obtener SubCategorías paginadas: {ex.Message}", ex);
            }
        }

        public CE_SubCategoriaListDTO SubCategoriaPorId(int idSubCat)
        {
            try
            {
                var parametros = new List<SqlParameter>
            {
                CC_Conexion.CrearParametro("@IdSubcategoria",idSubCat,SqlDbType.Int)
            };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_SUBCATEGORIAS_OBTENER_POR_ID", parametros);

                if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                {
                    DataRow row = dataSet.Tables[0].Rows[0];

                    return new CE_SubCategoriaListDTO
                    {
                        IdSubCategoria = Convert.ToInt32(row["IdSubcategoria"]),
                        Nombre = row["Nombre"].ToString(),
                        Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                        Estado = Convert.ToBoolean(row["Activo"]),
                        IdCategoria = Convert.ToInt32(row["IdCategoria"]),
                        NombreCategoria = row["NombreCategoria"].ToString(),
                        TotalModelos = Convert.ToInt32(row["TotalModelos"]),
                        // Campos de auditoría
                        FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                        UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                        FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                        UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null
                    };
                }

                return null;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener la SubCategoria");
                throw new DataAccessException($"Error al obtener Subcategoría por ID: {ex.Message}", ex); ;
            }
        }
    }
}
