using System;
using System.Collections.Generic;

namespace CapaEntidad
{
    /// <summary>
    /// Entidad para la tabla ZI_USUARIOS
    /// </summary>
    public class CE_Usuario
    {
        public int USU_Id { get; set; }
        public string USU_Username { get; set; }
        public string USU_PasswordEncrypted { get; set; }
        public string USU_Nombre { get; set; }
        public string USU_Apellido { get; set; }
        public string USU_Correo { get; set; }
        public string USU_Telefono { get; set; }
        public bool USU_Activo { get; set; }
        public DateTime? USU_UltimoLogin { get; set; }
        public int USU_IntentosFallidos { get; set; }
        public bool USU_Bloqueado { get; set; }
        public DateTime? USU_FechaBloqueo { get; set; }
        public bool USU_PassTemp { get; set; }

        // Campos de Auditoría
        public DateTime USU_FechaCreacion { get; set; }
        public string USU_UsuarioCreacion { get; set; }
        public DateTime? USU_FechaModificacion { get; set; }
        public string USU_UsuarioModificacion { get; set; }
        public string USU_IpCreacion { get; set; }
        public string USU_IpModificacion { get; set; }

        // Propiedades adicionales para carga de datos relacionados
        public List<CE_Rol> Roles { get; set; }
        public List<CE_Permiso> Permisos { get; set; }

        public CE_Usuario()
        {
            Roles = new List<CE_Rol>();
            Permisos = new List<CE_Permiso>();
        }

        // Propiedades calculadas
        public string NombreCompleto => $"{USU_Nombre} {USU_Apellido}";
        public bool EstaActivo => USU_Activo && !USU_Bloqueado;
    }
}