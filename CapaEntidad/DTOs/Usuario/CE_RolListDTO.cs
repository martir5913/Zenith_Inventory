using System;

namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para listado de roles
    /// </summary>
    public class CE_RolListDTO
    {
        public int IdRol { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
        public int TotalUsuarios { get; set; }
        public int TotalPermisos { get; set; }

        // Campos de auditoría
        public DateTime? FechaCreacion { get; set; }
        public string UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string UsuarioModificacion { get; set; }
    }
}
