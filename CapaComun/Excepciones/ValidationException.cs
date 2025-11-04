using System;

namespace CapaComun.Excepciones
{
    /// <summary>
    /// Excepción personalizada para errores de validación
    /// </summary>
    public class ValidationException : Exception
    {
        /// <summary>
        /// Constructor con mensaje
 /// </summary>
  /// <param name="message">Mensaje de error</param>
        public ValidationException(string message) : base(message)
        {
        }

        /// <summary>
        /// Constructor con mensaje y excepción interna
        /// </summary>
    /// <param name="message">Mensaje de error</param>
        /// <param name="innerException">Excepción interna</param>
        public ValidationException(string message, Exception innerException) 
   : base(message, innerException)
    {
        }
    }
}
