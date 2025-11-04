using System;

namespace CapaEntidad.DTOs.Categoria
{
    /// <summary>
    /// DTO para crear una nueva categoría
    /// </summary>
    public class CE_CategoriaCreateDTO
    {
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; } = true;
    }
}
