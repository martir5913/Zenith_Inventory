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

        public CE_PagedResult<CE_SubCategoriaListDTO> ObtenerSubCategoriasPaginadas(int pageNumber = 1, int pageSize = 10, string searchTerm = null, bool incluirInactivos = false, int? idCategoria = null, bool? soloInactivos = null)
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
                    CC_Conexion.CrearParametro("@SoloInactivos", (object)soloInactivos ?? DBNull.Value, SqlDbType.Bit),
                    new SqlParameter("@TotalRegistros", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                DataSet dataSet = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO", parametros);

                int totalRegistros = parametros[6].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[6].Value)
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

        public int ActualizarSubCat(CE_SubCategoriaUpdateDTO objSubCat)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdSubcategoria", objSubCat.IdSubCate, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@Nombre", objSubCat.Nombre, SqlDbType.NVarChar,100),
                    CC_Conexion.CrearParametro("@CategoriaId", objSubCat.IdCategoria, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@Descripcion", objSubCat.Descripcion, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@Activo", objSubCat.activo, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioModificacion", objSubCat.usuarioModificacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpModificacion", objSubCat.ipModificacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_SUBCATEGORIAS_ACTUALIZAR", parametros);

                int filasAfectadas = parametros[7].Value != DBNull.Value ? Convert.ToInt32(parametros[7].Value) : 0;

                return filasAfectadas;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al actualizar la Subcategoria");
                throw new DataAccessException($"Error al actualizar categoría: {ex.Message}", ex);
            }
        }

        public int EliminarSubCat(int idSubCat, string usuarioDel, string ipDel)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdSubcategoria", idSubCat, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@UsuarioEliminacion", usuarioDel, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpEliminacion", ipDel, SqlDbType.NVarChar, 45),
                    new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_SUBCATEGORIAS_ELIMINAR", parametros);

                int filasAfectadas = parametros[3].Value != DBNull.Value ? Convert.ToInt32(parametros[3].Value) : 0;

                return filasAfectadas;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al borrar la SubCategoria");
                throw new DataAccessException($"Error al borrar la subcategoria: {ex.Message}", ex);
            }
        }

        public int ReactivarSubCat(int idSubCat, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdSubcategoria", idSubCat, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_SUBCATEGORIAS_REACTIVAR", parametros);

                int filasAfectadas = parametros[3].Value != DBNull.Value ? Convert.ToInt32(parametros[3].Value) : 0;

                return filasAfectadas;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al reactivar la SubCategoria");
                throw new DataAccessException($"Error al reactivar la subcategoría: {ex.Message}", ex);
            }
        }

        public int CrearSubCat(CE_SubCategoriaCreateDTO subCate)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@Nombre", subCate.Nombre,SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@CategoriaId", subCate.IdCategoria,SqlDbType.Int),
                    CC_Conexion.CrearParametro("@Descripcion", subCate.Descripcion,SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@Activo", subCate.Activo,SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioCreacion", subCate.UsuarioCreacion,SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpCreacion", subCate.IpCreacion,SqlDbType.NVarChar, 45),
                    new SqlParameter("@IdSubcategoria", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_SUBCATEGORIAS_CREAR", parametros);

                int IdCreado = parametros[6].Value != DBNull.Value ? Convert.ToInt32(parametros[6].Value) : 0;

                return IdCreado;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al crear la SubCategoria");
                throw new DataAccessException($"Error al crear la subcategoria: {ex.Message}", ex);
            }
        }
    }
}
