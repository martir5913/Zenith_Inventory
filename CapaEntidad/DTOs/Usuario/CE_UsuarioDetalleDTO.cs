using System.Collections.Generic;

namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para detalle completo de usuario
    /// </summary>
    public class CE_UsuarioDetalleDTO : CE_UsuarioListDTO
    {
        public string IpCreacion { get; set; }
        public string IpModificacion { get; set; }

        // Roles asignados (detallados)
        public List<CE_RolAsignadoDTO> Roles { get; set; }

        // Permisos efectivos del usuario
        public List<CE_PermisoDTO> Permisos { get; set; }

        public CE_UsuarioDetalleDTO()
        {
            Roles = new List<CE_RolAsignadoDTO>();
            Permisos = new List<CE_PermisoDTO>();
        }
    }

    /// <summary>
    /// DTO para rol asignado a usuario
    /// </summary>
    public class CE_RolAsignadoDTO
    {
        public int IdRol { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public System.DateTime FechaAsignacion { get; set; }
        public bool Activo { get; set; }
    }

    /// <summary>
    /// DTO para permiso
    /// </summary>
    public class CE_PermisoDTO
    {
        public int IdPermiso { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public string Modulo { get; set; }
        public string Accion { get; set; }
    }
}
