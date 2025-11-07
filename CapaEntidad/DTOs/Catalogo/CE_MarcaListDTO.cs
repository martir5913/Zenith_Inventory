using System;

namespace CapaEntidad.DTOs.Catalogo
{
    /// <summary>
    /// DTO para listado de marcas (vista simplificada)
    /// </summary>
    public class CE_MarcaListDTO
    {
        public int IdMarca { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
        public int TotalModelos { get; set; }

        // Campos de Auditoría
        public DateTime? FechaCreacion { get; set; }
        public string UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string UsuarioModificacion { get; set; }
    }
}
