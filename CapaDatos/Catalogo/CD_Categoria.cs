using CapaComun;
using CapaComun.Excepciones;
using CapaEntidad.DTOs.Catalogo;
using CapaEntidad.DTOs.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDatos.Categoria
{
    public class CD_Categoria
    {
        private readonly CC_Conexion _conexion;

        public CD_Categoria()
        {
            _conexion = new CC_Conexion();
        }

        public CE_PagedResult<CE_CategoriaListDTO> ObtenerCategoriasPaginadas(int pageNumber = 1, int pageSize = 10, string searchTerm = null, bool incluirInactivos = false)
        {
            try
            {
                // Crear parámetros
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

                // Ejecutar procedimiento
                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_CATEGORIAS_LISTAR_PAGINADO", parametros);

                // Obtener total de registros del parámetro de salida
                int totalRegistros = parametros[4].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[4].Value)
                    : 0;

                // Convertir DataTable a lista de DTOs
                List<CE_CategoriaListDTO> categorias = new List<CE_CategoriaListDTO>();

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    foreach (DataRow row in ds.Tables[0].Rows)
                    {
                        categorias.Add(new CE_CategoriaListDTO
                        {
                            IdCategoria = Convert.ToInt32(row["IdCategoria"]),
                            Nombre = row["Nombre"].ToString(),
                            Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                            Activo = Convert.ToBoolean(row["Activo"]),
                            TotalSubcategorias = Convert.ToInt32(row["TotalSubcategorias"]),
                            // Campos de auditoría
                            FechaCreacion = row["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaCreacion"]) : (DateTime?)null,
                            UsuarioCreacion = row["UsuarioCreacion"] != DBNull.Value ? row["UsuarioCreacion"].ToString() : null,
                            FechaModificacion = row["FechaModificacion"] != DBNull.Value ? Convert.ToDateTime(row["FechaModificacion"]) : (DateTime?)null,
                            UsuarioModificacion = row["UsuarioModificacion"] != DBNull.Value ? row["UsuarioModificacion"].ToString() : null
                        });
                    }
                }

                // Retornar resultado paginado
                return new CE_PagedResult<CE_CategoriaListDTO>(
                    categorias,
                    totalRegistros,
                    pageNumber,
                    pageSize
                );
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al obtener categorias");
                throw new DataAccessException($"Error al obtener categorías paginadas: {ex.Message}", ex);
            }
        }

        public CE_CategoriaListDTO ObtenerCategoriaPorId(int idCategoria)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdCategoria", idCategoria, SqlDbType.Int)
                };

                DataSet ds = _conexion.EjecutarProcedimiento("ZI_GENERAL.SP_CATEGORIAS_OBTENER_POR_ID", parametros);

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    DataRow row = ds.Tables[0].Rows[0];
                    return new CE_CategoriaListDTO
                    {
                        IdCategoria = Convert.ToInt32(row["IdCategoria"]),
                        Nombre = row["Nombre"].ToString(),
                        Descripcion = row["Descripcion"] != DBNull.Value ? row["Descripcion"].ToString() : null,
                        Activo = Convert.ToBoolean(row["Activo"]),
                        TotalSubcategorias = Convert.ToInt32(row["TotalSubcategorias"]),
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
                ErrorLogger.Log(ex, "Error al obtener categoria por ID");
                throw new DataAccessException($"Error al obtener categoría por ID: {ex.Message}", ex);
            }
        }

        public int CrearCategoria(CE_CategoriaCreateDTO categoria, string usuarioCreacion, string ipCreacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@Nombre", categoria.Nombre, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Descripcion", categoria.Descripcion, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@Activo", categoria.Activo, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioCreacion", usuarioCreacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpCreacion", ipCreacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@IdCategoria", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimientoSinResultado("ZI_GENERAL.SP_CATEGORIAS_CREAR", parametros);

                return Convert.ToInt32(parametros[5].Value);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al crear categoria");
                throw new DataAccessException($"Error al crear categoría: {ex.Message}", ex);
            }
        }

        public int ActualizarCategoria(CE_CategoriaUpdateDTO categoria, string usuarioModificacion, string ipModificacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdCategoria", categoria.IdCategoria, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@Nombre", categoria.Nombre, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@Descripcion", categoria.Descripcion, SqlDbType.NVarChar, 500),
                    CC_Conexion.CrearParametro("@Activo", categoria.Activo, SqlDbType.Bit),
                    CC_Conexion.CrearParametro("@UsuarioModificacion", usuarioModificacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpModificacion", ipModificacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimientoSinResultado("ZI_GENERAL.SP_CATEGORIAS_ACTUALIZAR", parametros);
                
                // Obtener filas afectadas del parámetro OUTPUT
                int filasAfectadas = parametros[6].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[6].Value)
                    : 0;
                
                return filasAfectadas;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al actualizar categoria");
                throw new DataAccessException($"Error al actualizar categoría: {ex.Message}", ex);
            }
        }

        public int EliminarCategoria(int idCategoria, string usuarioEliminacion, string ipEliminacion)
        {
            try
            {
                var parametros = new List<SqlParameter>
                {
                    CC_Conexion.CrearParametro("@IdCategoria", idCategoria, SqlDbType.Int),
                    CC_Conexion.CrearParametro("@UsuarioEliminacion", usuarioEliminacion, SqlDbType.NVarChar, 100),
                    CC_Conexion.CrearParametro("@IpEliminacion", ipEliminacion, SqlDbType.NVarChar, 45),
                    new SqlParameter("@FilasAfectadas", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    }
                };

                _conexion.EjecutarProcedimientoSinResultado("ZI_GENERAL.SP_CATEGORIAS_ELIMINAR", parametros);
                
                // Obtener filas afectadas del parámetro OUTPUT
                int filasAfectadas = parametros[3].Value != DBNull.Value
                    ? Convert.ToInt32(parametros[3].Value)
                    : 0;
                
                return filasAfectadas;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error al eliminar categoria");
                throw new DataAccessException($"Error al eliminar categoría: {ex.Message}", ex);
            }
        }
    }
}
