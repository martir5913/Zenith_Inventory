using System;

namespace CapaEntidad
{
    /// <summary>
    /// Entidad para la tabla ZI_CONFIGURACION
    /// </summary>
    public class CE_Configuracion
    {
        public int ZIC_Id { get; set; }
        public string ZIC_Clave { get; set; }
        public string ZIC_Valor { get; set; }
        public string ZIC_Descripcion { get; set; }
        public string ZIC_Tipo { get; set; }
        public bool ZIC_Activo { get; set; }

        // Campos de Auditoría
        public DateTime ZIC_FechaCreacion { get; set; }
        public string ZIC_UsuarioCreacion { get; set; }
        public DateTime? ZIC_FechaModificacion { get; set; }
        public string ZIC_UsuarioModificacion { get; set; }
        public string ZIC_IpCreacion { get; set; }
        public string ZIC_IpModificacion { get; set; }
    }
}