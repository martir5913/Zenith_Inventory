namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para actualizar un permiso existente
    /// </summary>
    public class CE_PermisoUpdateDTO
    {
        public int IdPermiso { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public string Modulo { get; set; }
        public string Accion { get; set; }
        public bool Activo { get; set; }

        // Auditoría (se llena automáticamente)
        public string UsuarioModificacion { get; set; }
        public string IpModificacion { get; set; }
    }
}
