using System;

namespace CapaEntidad
{
    /// <summary>
    /// Entidad para la tabla ZI_ROLES
    /// </summary>
    public class CE_Rol
    {
        public int ROL_Id { get; set; }
        public string ROL_Nombre { get; set; }
        public string ROL_Descripcion { get; set; }
        public bool ROL_Activo { get; set; }

        // Campos de Auditoría
        public DateTime ROL_FechaCreacion { get; set; }
        public string ROL_UsuarioCreacion { get; set; }
        public DateTime? ROL_FechaModificacion { get; set; }
        public string ROL_UsuarioModificacion { get; set; }
        public string ROL_IpCreacion { get; set; }
        public string ROL_IpModificacion { get; set; }
    }
}