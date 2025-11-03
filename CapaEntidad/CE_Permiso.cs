using System;

namespace CapaEntidad
{
    /// <summary>
    /// Entidad para la tabla ZI_PERMISOS
    /// </summary>
    public class CE_Permiso
    {
        public int PER_Id { get; set; }
        public string PER_Nombre { get; set; }
        public string PER_Descripcion { get; set; }
        public string PER_Modulo { get; set; }
        public string PER_Accion { get; set; }
        public bool PER_Activo { get; set; }

        // Campos de Auditoría
        public DateTime PER_FechaCreacion { get; set; }
        public string PER_UsuarioCreacion { get; set; }
        public DateTime? PER_FechaModificacion { get; set; }
        public string PER_UsuarioModificacion { get; set; }
        public string PER_IpCreacion { get; set; }
        public string PER_IpModificacion { get; set; }
    }
}