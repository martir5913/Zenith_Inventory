using CapaComun;
using CapaComun.Excepciones;
using CapaEntidad.DTOs.Categoria;
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
        
        public CE_PagedResult<CE_CategoriaListDTO> ObtenerCategoriasPaginadas(int pageNumber = 1, int pageSize = 10, string searchTerm = null,  bool incluirInactivos = false)
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
                            Descripcion = row["Descripcion"].ToString(),
                            Activo = Convert.ToBoolean(row["Activo"]),
                            TotalSubcategorias = Convert.ToInt32(row["TotalSubcategorias"])
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
    }
}
