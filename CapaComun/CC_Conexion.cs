using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CapaComun
{
    public class CC_Conexion
    {
        private readonly string _connectionString;

        public CC_Conexion()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["PortalMilesimoConnection"].ToString();
        }

        public CC_Conexion(string connectionString)
        {
            _connectionString = connectionString;
        }

        public SqlConnection ObtenerConexion()
        {
            return new SqlConnection(_connectionString);
        }

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

        public static SqlParameter CrearParametro(string nombre, object valor, SqlDbType tipo, int tamaño = 0)
        {
            SqlParameter parametro = new SqlParameter(nombre, tipo);

            if (tamaño > 0)
                parametro.Size = tamaño;

            parametro.Value = valor ?? DBNull.Value;

            return parametro;
        }

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