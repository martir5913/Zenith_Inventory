using System;

namespace CapaComun.Excepciones
{
    /// <summary>
    /// Excepción personalizada para errores en la capa de datos
    /// </summary>
    public class DataAccessException : Exception
    {
      /// <summary>
        /// Constructor con mensaje
        /// </summary>
        /// <param name="message">Mensaje de error</param>
        public DataAccessException(string message) : base(message)
    {
        }

     /// <summary>
        /// Constructor con mensaje y excepción interna
        /// </summary>
    /// <param name="message">Mensaje de error</param>
        /// <param name="innerException">Excepción interna</param>
   public DataAccessException(string message, Exception innerException) 
        : base(message, innerException)
  {
        }
    }
}
