using System;
using System.Collections.Generic;

namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para detalles completos de un rol (incluyendo permisos asignados)
    /// </summary>
    public class CE_RolDetalleDTO
    {
        public int IdRol { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
        
        // Auditoría
        public DateTime? FechaCreacion { get; set; }
        public string UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string UsuarioModificacion { get; set; }
        
        // Información adicional
        public int TotalPermisos { get; set; }
        public int TotalUsuarios { get; set; }
        
        // Lista de permisos asignados
        public List<CE_PermisoListDTO> Permisos { get; set; }

        public CE_RolDetalleDTO()
        {
            Permisos = new List<CE_PermisoListDTO>();
        }
    }
}
