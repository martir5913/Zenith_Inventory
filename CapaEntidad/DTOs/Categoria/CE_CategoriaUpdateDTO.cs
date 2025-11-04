using System;

namespace CapaEntidad.DTOs.Categoria
{
    /// <summary>
    /// DTO para actualizar una categoría existente
    /// </summary>
    public class CE_CategoriaUpdateDTO
    {
        public int IdCategoria { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
    }
}
