using System;

namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para listado de permisos (vista simplificada con paginación)
    /// </summary>
    public class CE_PermisoListDTO
    {
        public int IdPermiso { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public string Modulo { get; set; }
        public string Accion { get; set; }
        public bool Activo { get; set; }
        public int TotalRoles { get; set; }

        // Campos de auditoría
        public DateTime? FechaCreacion { get; set; }
        public string UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string UsuarioModificacion { get; set; }
    }
}
