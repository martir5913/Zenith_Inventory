namespace CapaEntidad.DTOs.Catalogo
{
    /// <summary>
    /// DTO para crear una nueva marca
    /// </summary>
    public class CE_MarcaCreateDTO
    {
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; } = true;
    }
}
