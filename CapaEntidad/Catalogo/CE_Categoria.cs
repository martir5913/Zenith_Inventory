using System;

namespace CapaEntidad.Catalogo
{
    /// <summary>
    /// Entidad para la tabla ZI_CATEGORIAS
    /// </summary>
    public class CE_Categoria
    {
        public int CAT_Id { get; set; }
        public string CAT_Nombre { get; set; }
        public string CAT_Descripcion { get; set; }
        public bool CAT_Estado { get; set; }

        // Campos de Auditoría
        public DateTime CAT_FechaCreacion { get; set; }
        public string CAT_UsuarioCreacion { get; set; }
        public DateTime? CAT_FechaModificacion { get; set; }
        public string CAT_UsuarioModificacion { get; set; }
        public string CAT_IpCreacion { get; set; }
        public string CAT_IpModificacion { get; set; }

        // Propiedades calculadas o adicionales
        public int TotalSubcategorias { get; set; }
    }
}
