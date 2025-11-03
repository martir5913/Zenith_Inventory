using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CapaComun
{
    /// <summary>
    /// Clase para manejo de conexiones y operaciones de base de datos
    /// </summary>
    public class CC_Conexion
    {
        private readonly string _connectionString;

        public CC_Conexion()
        {
            // Cadena de conexión a la base de datos Portal Milésimo
            _connectionString = ConfigurationManager.ConnectionStrings["PortalMilesimoConnection"].ToString();

        }

        public CC_Conexion(string connectionString)
        {
            _connectionString = connectionString;
        }

        /// <summary>
        /// Obtiene una nueva conexión a la base de datos
        /// </summary>
        /// <returns>Conexión SQL</returns>
        public SqlConnection ObtenerConexion()
        {
            return new SqlConnection(_connectionString);
        }

        /// <summary>
        /// Ejecuta un procedimiento almacenado y devuelve un DataSet
        /// </summary>
        /// <param name="nombreProcedimiento">Nombre del procedimiento almacenado</param>
        /// <param name="parametros">Lista de parámetros</param>
        /// <returns>DataSet con los resultados</returns>
        public DataSet EjecutarProcedimiento(string nombreProcedimiento, List<SqlParameter> parametros = null)
        {
            DataSet dataSet = new DataSet();

            try
            {
                using (SqlConnection conexion = ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand(nombreProcedimiento, conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;
                        comando.CommandTimeout = 60;

                        if (parametros != null)
                        {
                            comando.Parameters.AddRange(parametros.ToArray());
                        }

                        using (SqlDataAdapter adapter = new SqlDataAdapter(comando))
                        {
                            conexion.Open();
                            adapter.Fill(dataSet);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al ejecutar procedimiento '{nombreProcedimiento}': {ex.Message}", ex);
            }

            return dataSet;
        }

        /// <summary>
        /// Ejecuta un procedimiento almacenado que no devuelve resultados
        /// </summary>
        /// <param name="nombreProcedimiento">Nombre del procedimiento almacenado</param>
        /// <param name="parametros">Lista de parámetros</param>
        /// <returns>Número de filas afectadas</returns>
        public int EjecutarProcedimientoSinResultado(string nombreProcedimiento, List<SqlParameter> parametros = null)
        {
            try
            {
                using (SqlConnection conexion = ObtenerConexion())
                {
                    using (SqlCommand comando = new SqlCommand(nombreProcedimiento, conexion))
                    {
                        comando.CommandType = CommandType.StoredProcedure;
                        comando.CommandTimeout = 60;

                        if (parametros != null)
                        {
                            comando.Parameters.AddRange(parametros.ToArray());
                        }

                        conexion.Open();
                        return comando.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al ejecutar procedimiento '{nombreProcedimiento}': {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Crea un parámetro SQL
        /// </summary>
        /// <param name="nombre">Nombre del parámetro</param>
        /// <param name="valor">Valor del parámetro</param>
        /// <param name="tipo">Tipo SQL del parámetro</param>
        /// <param name="tamaño">Tamaño del parámetro (opcional)</param>
        /// <returns>SqlParameter configurado</returns>
        public static SqlParameter CrearParametro(string nombre, object valor, SqlDbType tipo, int tamaño = 0)
        {
            SqlParameter parametro = new SqlParameter(nombre, tipo);

            if (tamaño > 0)
                parametro.Size = tamaño;

            parametro.Value = valor ?? DBNull.Value;

            return parametro;
        }

        /// <summary>
        /// Convierte un DataRow a una entidad usando reflexión
        /// </summary>
        /// <typeparam name="T">Tipo de entidad</typeparam>
        /// <param name="row">DataRow a convertir</param>
        /// <returns>Entidad del tipo especificado</returns>
        public static T ConvertirDataRowAEntidad<T>(DataRow row) where T : new()
        {
            T entidad = new T();

            foreach (var propiedad in typeof(T).GetProperties())
            {
                if (row.Table.Columns.Contains(propiedad.Name) && row[propiedad.Name] != DBNull.Value)
                {
                    object valor = row[propiedad.Name];

                    // Conversión de tipos si es necesario
                    if (propiedad.PropertyType != valor.GetType())
                    {
                        TypeConverter converter = TypeDescriptor.GetConverter(propiedad.PropertyType);
                        if (converter.CanConvertFrom(valor.GetType()))
                        {
                            valor = converter.ConvertFrom(valor);
                        }
                        else
                        {
                            valor = Convert.ChangeType(valor, propiedad.PropertyType);
                        }
                    }

                    propiedad.SetValue(entidad, valor);
                }
            }

            return entidad;
        }

        /// <summary>
        /// Convierte un DataTable a una lista de entidades
        /// </summary>
        /// <typeparam name="T">Tipo de entidad</typeparam>
        /// <param name="dataTable">DataTable a convertir</param>
        /// <returns>Lista de entidades</returns>
        public static List<T> ConvertirDataTableALista<T>(DataTable dataTable) where T : new()
        {
            List<T> lista = new List<T>();

            foreach (DataRow row in dataTable.Rows)
            {
                lista.Add(ConvertirDataRowAEntidad<T>(row));
            }

            return lista;
        }
    }
}