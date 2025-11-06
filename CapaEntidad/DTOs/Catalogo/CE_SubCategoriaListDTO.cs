using System;

namespace CapaEntidad.DTOs.Catalogo
{
    /// <summary>
    /// DTO para listado de subcategorías (vista simplificada)
    /// </summary>
    public class CE_SubCategoriaListDTO
    {
        public int IdSubCategoria { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Estado { get; set; }
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; }
        public int TotalModelos { get; set; }

        // Campos de Auditoría
        public DateTime? FechaCreacion { get; set; }
        public string UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string UsuarioModificacion { get; set; }
    }
}
