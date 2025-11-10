namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para actualizar un rol existente
    /// </summary>
    public class CE_RolUpdateDTO
    {
        public int IdRol { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public bool Activo { get; set; }
    }
}
