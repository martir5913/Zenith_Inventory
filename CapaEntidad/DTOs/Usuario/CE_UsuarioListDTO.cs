using System;

namespace CapaEntidad.DTOs.Usuario
{
    /// <summary>
    /// DTO para listado de usuarios
    /// </summary>
    public class CE_UsuarioListDTO
    {
        public int IdUsuario { get; set; }
        public int Codigo { get; set; }
        public string Username { get; set; }
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Correo { get; set; }
        public string Telefono { get; set; }
        public string Departamento { get; set; }
        public string Puesto { get; set; }
        public bool Activo { get; set; }
        public bool Bloqueado { get; set; }
        public int IntentosFallidos { get; set; }
        public DateTime? FechaBloqueo { get; set; }
        public DateTime? UltimoLogin { get; set; }
        public bool RequiereCambioPassword { get; set; }
        public int TotalRoles { get; set; }
        public string RolesAsignados { get; set; }

        // Campos de auditoría
        public DateTime? FechaCreacion { get; set; }
        public string UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string UsuarioModificacion { get; set; }

        // Propiedades calculadas
        public string NombreCompleto => $"{Nombre} {Apellido}".Trim();
        public bool EstaActivo => Activo && !Bloqueado;
        public string EstadoTexto => Bloqueado ? "Bloqueado" : (Activo ? "Activo" : "Inactivo");
    }
}
