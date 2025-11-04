namespace CapaEntidad.DTOs.Categoria
{
    /// <summary>
    /// DTO para listado de categorías (vista simplificada)
    /// </summary>
    public class CE_CategoriaListDTO
    {
        public int IdCategoria { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
        public int TotalSubcategorias { get; set; }
    }
}