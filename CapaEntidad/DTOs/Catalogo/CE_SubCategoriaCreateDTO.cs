namespace CapaEntidad.DTOs.Catalogo
{
    public class CE_SubCategoriaCreateDTO
    {
        public string Nombre { get; set; }
        public int IdCategoria { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
        public string UsuarioCreacion { get; set; }
        public string IpCreacion { get; set; }
    }
}
