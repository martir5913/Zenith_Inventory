namespace CapaEntidad.DTOs.Catalogo
{
    /// <summary>
    /// DTO para actualizar una marca existente
    /// </summary>
    public class CE_MarcaUpdateDTO
    {
        public int IdMarca { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
    }
}
