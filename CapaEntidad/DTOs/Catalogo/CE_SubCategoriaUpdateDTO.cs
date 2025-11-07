namespace CapaEntidad.DTOs.Catalogo
{
    public class CE_SubCategoriaUpdateDTO
    {
        public int IdSubCate { get; set; }
        public string Nombre { get; set; }
        public int IdCategoria { get; set; }
        public string Descripcion { get; set; }
        public bool activo { get; set; }
        public string usuarioModificacion { get; set; }
        public string ipModificacion { get; set; }
    }
}
