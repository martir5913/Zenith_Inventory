using System;

namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para actualización de usuario
    /// </summary>
    public class CE_UsuarioUpdateDTO
    {
        public int IdUsuario { get; set; }
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Correo { get; set; }
        public string Telefono { get; set; }
        public string Departamento { get; set; }
        public string Puesto { get; set; }
        public bool Activo { get; set; }
    }
}
