namespace CapaEntidad.DTOs.Catalogo
{
    /// <summary>
    /// DTO para actualizar un modelo existente
    /// </summary>
    public class CE_ModeloUpdateDTO
    {
        public int IdModelo { get; set; }
        public string Nombre { get; set; }
        public int IdMarca { get; set; }
        public int IdSubcategoria { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
    }
}
