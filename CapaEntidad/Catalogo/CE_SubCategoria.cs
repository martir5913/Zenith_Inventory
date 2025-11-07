using System;

namespace CapaEntidad.Catalogo
{
    /// <summary>
    /// Entidad para la tabla ZI_SUBCATEGORIAS
    /// </summary>
    public class CE_SubCategoria
    {
        public int SUB_Id { get; set; }
        public string SUB_Nombre { get; set; }
        public string SUB_Descripcion { get; set; }
        public int SUB_CategoriaId { get; set; }
        public bool SUB_Estado { get; set; }

        // Campos de Auditoría
        public DateTime SUB_FechaCreacion { get; set; }
        public string SUB_UsuarioCreacion { get; set; }
        public DateTime? SUB_FechaModificacion { get; set; }
        public string SUB_UsuarioModificacion { get; set; }
        public string SUB_IpCreacion { get; set; }
        public string SUB_IpModificacion { get; set; }

        // Propiedades adicionales o calculadas
        public string NombreCategoria { get; set; }
        public int TotalModelos { get; set; }
    }
}
