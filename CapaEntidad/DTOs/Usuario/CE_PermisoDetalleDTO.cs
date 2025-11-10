using System;
using System.Collections.Generic;

namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para detalle completo de un permiso (incluye roles que lo tienen)
    /// </summary>
    public class CE_PermisoDetalleDTO
    {
        public int IdPermiso { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public string Modulo { get; set; }
        public string Accion { get; set; }
        public bool Activo { get; set; }
        public int TotalRoles { get; set; }

        // Campos de auditoría completos
        public DateTime? FechaCreacion { get; set; }
        public string UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string UsuarioModificacion { get; set; }
        public string IpCreacion { get; set; }
        public string IpModificacion { get; set; }

        // Roles que tienen este permiso
        public List<CE_PermisoRolDTO> Roles { get; set; }

        public CE_PermisoDetalleDTO()
        {
            Roles = new List<CE_PermisoRolDTO>();
        }
    }

    /// <summary>
    /// DTO para los roles que tienen un permiso específico
    /// </summary>
    public class CE_PermisoRolDTO
    {
        public int IdRol { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
        public int TotalUsuarios { get; set; }
    }
}
