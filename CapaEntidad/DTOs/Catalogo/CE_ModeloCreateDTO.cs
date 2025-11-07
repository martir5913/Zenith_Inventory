namespace CapaEntidad.DTOs.Catalogo
{
    /// <summary>
    /// DTO para crear un nuevo modelo
    /// </summary>
    public class CE_ModeloCreateDTO
    {
        public string Nombre { get; set; }
        public int IdMarca { get; set; }
        public int IdSubcategoria { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; } = true;
    }
}
