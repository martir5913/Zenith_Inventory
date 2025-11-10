namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para crear un nuevo permiso
    /// </summary>
    public class CE_PermisoCreateDTO
    {
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public string Modulo { get; set; }
        public string Accion { get; set; }
        public bool Activo { get; set; } = true;

        // Auditoría (se llena automáticamente)
        public string UsuarioCreacion { get; set; }
        public string IpCreacion { get; set; }
    }
}
