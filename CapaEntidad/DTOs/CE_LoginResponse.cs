namespace CapaEntidad.DTOs
{
    /// <summary>
    /// DTO para la respuesta del login
    /// </summary>
    public class CE_LoginResponse
    {
        public string Resultado { get; set; }
        public string Mensaje { get; set; }
        public int UserId { get; set; }
        public bool EsExitoso { get; set; }
        public CE_Usuario Usuario { get; set; }

        public CE_LoginResponse()
        {
            Usuario = new CE_Usuario();
        }
    }
}