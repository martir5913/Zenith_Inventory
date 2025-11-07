using System;

namespace CapaEntidad.DTOs.Catalogo
{
    /// <summary>
    /// DTO para listado de modelos (vista simplificada con jerarquía completa)
    /// </summary>
    public class CE_ModeloListDTO
    {
        public int IdModelo { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }

        // Relación con Marca
        public int IdMarca { get; set; }
        public string NombreMarca { get; set; }

        // Relación con Subcategoría
        public int IdSubcategoria { get; set; }
        public string NombreSubcategoria { get; set; }

        // Relación con Categoría (a través de Subcategoría)
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; }

        public int TotalEquipos { get; set; }

        // Campos de Auditoría
        public DateTime? FechaCreacion { get; set; }
        public string UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string UsuarioModificacion { get; set; }
    }
}
