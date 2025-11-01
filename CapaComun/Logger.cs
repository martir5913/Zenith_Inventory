using System;
using System.Diagnostics;
using System.IO;

namespace CapaComun
{
    public static class ErrorLogger
    {
        private static readonly string LogDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Logs");
        private static readonly string LogFile = Path.Combine(LogDirectory, "Log_Portal.log");

        static ErrorLogger()
        {
            // Crear la carpeta de logs si no existe
            if (!Directory.Exists(LogDirectory))
            {
                Directory.CreateDirectory(LogDirectory);
            }
        }

        public static void LogWarning(string message, string layer = null)
        {
            string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] " +
                              $"[WARNING] Capa: {layer ?? "N/A"}\n" +
                              $"Mensaje: {message}\n" +
                              "----------------------------------------\n";

            try
            {
                File.AppendAllText(LogFile, logEntry);
            }
            catch
            {
                // Ignorar errores de log
            }
        }

        public static void LogError(Exception ex, string customMessage = null, string layer = null)
        {
            var st = new StackTrace(ex, true);
            var frame = st.GetFrames()?.Length > 0 ? st.GetFrame(0) : null;
            int line = frame?.GetFileLineNumber() ?? 0;
            string file = frame?.GetFileName() ?? "N/A";

            string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] " +
                              $"[ERROR] Capa: {layer ?? "N/A"}\n" +
                              $"Mensaje: {ex.Message}\n" +
                              $"Tipo: {ex.GetType().FullName}\n" +
                              $"Archivo: {file}\n" +
                              $"Línea: {line}\n" +
                              $"Custom: {customMessage}\n" +
                              $"StackTrace: {ex.StackTrace}\n" +
                              "----------------------------------------\n";

            try
            {
                File.AppendAllText(LogFile, logEntry);
            }
            catch
            {
                // Si falla el log, no lanzar excepción para no interrumpir el flujo
            }
        }

        public static void LogInfo(string message, string layer = null)
        {
            string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] " +
                              $"[INFO] Capa: {layer ?? "N/A"}\n" +
                              $"Mensaje: {message}\n" +
                              "----------------------------------------\n";
            try
            {
                File.AppendAllText(LogFile, logEntry);
            }
            catch
            {
                // Ignorar errores de log
            }
        }

        public static void Log(Exception ex, string customMessage = null, string layer = null)
        {
            LogError(ex, customMessage, layer);
        }

        public static void LogCustom(string message)
        {
            LogInfo(message);
        }
    }
}
