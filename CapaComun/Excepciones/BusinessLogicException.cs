using System;

namespace CapaComun.Excepciones
{
    /// <summary>
    /// Excepción personalizada para errores en la lógica de negocio
    /// </summary>
    public class BusinessLogicException : Exception
    {
      /// <summary>
        /// Constructor con mensaje
    /// </summary>
        /// <param name="message">Mensaje de error</param>
 public BusinessLogicException(string message) : base(message)
        {
  }

        /// <summary>
        /// Constructor con mensaje y excepción interna
  /// </summary>
        /// <param name="message">Mensaje de error</param>
        /// <param name="innerException">Excepción interna</param>
        public BusinessLogicException(string message, Exception innerException) 
            : base(message, innerException)
      {
        }
    }
}
