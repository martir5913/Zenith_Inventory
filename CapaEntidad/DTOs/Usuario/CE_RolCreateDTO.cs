namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para crear un nuevo rol
    /// </summary>
    public class CE_RolCreateDTO
    {
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; } = true;
    }
}
