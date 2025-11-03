namespace CapaEntidad.DTOs
{
    /// <summary>
    /// DTO para las credenciales de login
    /// </summary>
    public class CE_LoginRequest
    {
        public string Username { get; set; }
        public string Password { get; set; }
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
    }
}