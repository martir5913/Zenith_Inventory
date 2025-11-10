using System;

namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para creación de usuario
    /// </summary>
    public class CE_UsuarioCreateDTO
    {
        public int Codigo { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Correo { get; set; }
        public string Telefono { get; set; }
        public string Departamento { get; set; }
        public string Puesto { get; set; }
        public bool Activo { get; set; } = true;
        public bool PasswordTemporal { get; set; } = true;
        public int[] RolesIds { get; set; }
    }
}
