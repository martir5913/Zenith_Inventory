namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para resetear contraseña
    /// </summary>
    public class CE_ResetPasswordDTO
    {
        public int IdUsuario { get; set; }
        public string NuevaPassword { get; set; }
    }

    /// <summary>
    /// DTO para asignar roles
    /// </summary>
    public class CE_AsignarRolesDTO
    {
        public int IdUsuario { get; set; }
        public int[] RolesIds { get; set; }
    }

    /// <summary>
    /// DTO para respuesta de operación
    /// </summary>
    public class CE_OperacionResultDTO
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; }
        public object Datos { get; set; }

        public CE_OperacionResultDTO()
        {
            Exitoso = false;
            Mensaje = string.Empty;
        }

        public static CE_OperacionResultDTO Exito(string mensaje = "Operación exitosa", object datos = null)
        {
            return new CE_OperacionResultDTO
            {
                Exitoso = true,
                Mensaje = mensaje,
                Datos = datos
            };
        }

        public static CE_OperacionResultDTO Error(string mensaje = "Operación fallida", object datos = null)
        {
            return new CE_OperacionResultDTO
            {
                Exitoso = false,
                Mensaje = mensaje,
                Datos = datos
            };
        }
    }
}
