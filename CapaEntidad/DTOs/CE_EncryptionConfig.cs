using System.Collections.Generic;

namespace CapaEntidad.DTOs
{
    /// <summary>
    /// DTO para la información de encriptación
    /// </summary>
    public class CE_EncryptionConfig
    {
        public string Key { get; set; }
        public string Salt { get; set; }
        public string IV { get; set; }
    }
}