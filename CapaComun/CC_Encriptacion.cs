using System;
using System.Security.Cryptography;
using System.Text;

namespace CapaComun
{
    /// <summary>
    /// Clase para manejo de encriptación AES
    /// </summary>
    public static class CC_Encriptacion
    {
        /// <summary>
        /// Encripta una cadena usando AES
        /// </summary>
        /// <param name="plainText">Texto a encriptar</param>
        /// <param name="key">Clave de encriptación</param>
        /// <param name="salt">Salt para la encriptación</param>
        /// <param name="iv">Vector inicial</param>
        /// <returns>Texto encriptado en Base64</returns>
        public static string Encriptar(string plainText, string key, string salt, string iv)
        {
            try
            {
                if (string.IsNullOrEmpty(plainText))
                    return string.Empty;

                byte[] plainTextBytes = Encoding.UTF8.GetBytes(plainText);
                byte[] keyBytes = DerivarClave(key, salt);
                byte[] ivBytes = Encoding.UTF8.GetBytes(iv.PadRight(16).Substring(0, 16));

                using (Aes aes = Aes.Create())
                {
                    aes.Key = keyBytes;
                    aes.IV = ivBytes;
                    aes.Mode = CipherMode.CBC;
                    aes.Padding = PaddingMode.PKCS7;

                    using (ICryptoTransform encryptor = aes.CreateEncryptor())
                    {
                        byte[] encryptedBytes = encryptor.TransformFinalBlock(plainTextBytes, 0, plainTextBytes.Length);
                        return Convert.ToBase64String(encryptedBytes);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al encriptar: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Desencripta una cadena usando AES
        /// </summary>
        /// <param name="encryptedText">Texto encriptado en Base64</param>
        /// <param name="key">Clave de encriptación</param>
        /// <param name="salt">Salt para la encriptación</param>
        /// <param name="iv">Vector inicial</param>
        /// <returns>Texto desencriptado</returns>
        public static string Desencriptar(string encryptedText, string key, string salt, string iv)
        {
            try
            {
                if (string.IsNullOrEmpty(encryptedText))
                    return string.Empty;

                byte[] encryptedBytes = Convert.FromBase64String(encryptedText);
                byte[] keyBytes = DerivarClave(key, salt);
                byte[] ivBytes = Encoding.UTF8.GetBytes(iv.PadRight(16).Substring(0, 16));

                using (Aes aes = Aes.Create())
                {
                    aes.Key = keyBytes;
                    aes.IV = ivBytes;
                    aes.Mode = CipherMode.CBC;
                    aes.Padding = PaddingMode.PKCS7;

                    using (ICryptoTransform decryptor = aes.CreateDecryptor())
                    {
                        byte[] decryptedBytes = decryptor.TransformFinalBlock(encryptedBytes, 0, encryptedBytes.Length);
                        return Encoding.UTF8.GetString(decryptedBytes);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al desencriptar: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Deriva una clave de 32 bytes usando PBKDF2
        /// </summary>
        /// <param name="password">Contraseña base</param>
        /// <param name="salt">Salt</param>
        /// <returns>Clave derivada de 32 bytes</returns>
        private static byte[] DerivarClave(string password, string salt)
        {
            using (var pbkdf2 = new Rfc2898DeriveBytes(password, Encoding.UTF8.GetBytes(salt), 10000))
            {
                return pbkdf2.GetBytes(32); // 256 bits para AES-256
            }
        }

        /// <summary>
        /// Genera un hash SHA-256 de una cadena
        /// </summary>
        /// <param name="input">Cadena a hashear</param>
        /// <returns>Hash SHA-256 en hexadecimal</returns>
        public static string GenerarHashSHA256(string input)
        {
            try
            {
                using (SHA256 sha256 = SHA256.Create())
                {
                    byte[] hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
                    StringBuilder sb = new StringBuilder();
                    foreach (byte b in hashBytes)
                    {
                        sb.Append(b.ToString("x2"));
                    }
                    return sb.ToString();
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al generar hash SHA-256: {ex.Message}", ex);
            }
        }
    }
}