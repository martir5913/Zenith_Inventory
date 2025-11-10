using CapaComun;
using CapaComun.Excepciones;
using CapaDatos.Usuario;
using CapaEntidad.DTOs.Common;
using CapaEntidad.DTOs.Usuario;
using System;
using System.Collections.Generic;

namespace CapaNegocio.Usuario
{
    /// <summary>
    /// Capa de negocio para gestión de permisos
    /// </summary>
    public class CN_Permiso
    {
        private readonly CD_Permiso _datosPermiso;

        public CN_Permiso()
        {
            _datosPermiso = new CD_Permiso();
        }

        /// <summary>
        /// Obtiene permisos paginados con validaciones
        /// </summary>
        public CE_PagedResult<CE_PermisoListDTO> ObtenerPermisosPaginados(
            int pageNumber,
            int pageSize,
            string searchTerm = null,
            bool incluirInactivos = false,
            string modulo = null,
            string accion = null)  // ? AGREGADO
        {
            try
            {
                // Validaciones
                if (pageNumber < 1)
                    throw new ValidationException("El número de página debe ser mayor a 0");

                if (pageSize < 1 || pageSize > 100)
                    throw new ValidationException("El tamaño de página debe estar entre 1 y 100");

                return _datosPermiso.ObtenerPermisosPaginados(
                    pageNumber,
                    pageSize,
                    searchTerm,
                    incluirInactivos,
                    modulo,
                    accion  // ? AGREGADO
                );
            }
            catch (ValidationException)
            {
                throw;
            }
            catch (DataAccessException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new BusinessLogicException($"Error al obtener permisos paginados: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene detalle completo de un permiso
        /// </summary>
        public CE_PermisoDetalleDTO ObtenerPermisoPorId(int idPermiso)
        {
            try
            {
                if (idPermiso <= 0)
                    throw new ValidationException("El ID del permiso debe ser mayor a 0");

                var permiso = _datosPermiso.ObtenerPermisoPorId(idPermiso);

                if (permiso == null)
                    throw new ValidationException("El permiso no existe");

                return permiso;
            }
            catch (ValidationException)
            {
                throw;
            }
            catch (DataAccessException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new BusinessLogicException($"Error al obtener permiso por ID: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Crea un nuevo permiso con validaciones de negocio
        /// </summary>
        public int CrearPermiso(CE_PermisoCreateDTO permiso, string usuarioCreacion)
        {
            try
            {
                // Validaciones
                ValidarPermisoCreate(permiso);

                // Obtener IP del contexto web
                string ipCreacion = CC_ContextoWeb.ObtenerDireccionIP();

                int idPermiso = _datosPermiso.CrearPermiso(permiso, usuarioCreacion, ipCreacion);

                ErrorLogger.LogCustom($"Permiso '{permiso.Nombre}' creado exitosamente (ID: {idPermiso}) por {usuarioCreacion}");

                return idPermiso;
            }
            catch (ValidationException)
            {
                throw;
            }
            catch (DataAccessException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new BusinessLogicException($"Error al crear permiso: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Actualiza un permiso existente con validaciones
        /// </summary>
        public bool ActualizarPermiso(CE_PermisoUpdateDTO permiso, string usuarioModificacion)
        {
            try
            {
                // Validaciones
                ValidarPermisoUpdate(permiso);

                // Verificar que el permiso existe
                var permisoExistente = _datosPermiso.ObtenerPermisoPorId(permiso.IdPermiso);
                if (permisoExistente == null)
                    throw new ValidationException("El permiso no existe");

                // Obtener IP del contexto web
                string ipModificacion = CC_ContextoWeb.ObtenerDireccionIP();

                int filasAfectadas = _datosPermiso.ActualizarPermiso(permiso, usuarioModificacion, ipModificacion);

                bool exitoso = (filasAfectadas != 0 || filasAfectadas == -1);

                if (exitoso)
                {
                    ErrorLogger.LogCustom($"Permiso {permiso.IdPermiso} actualizado exitosamente por {usuarioModificacion}");
                    return true;
                }
                else
                {
                    ErrorLogger.LogCustom($"ADVERTENCIA: No se actualizó ninguna fila para permiso {permiso.IdPermiso}");
                    return false;
                }
            }
            catch (ValidationException)
            {
                throw;
            }
            catch (DataAccessException)
            {
                throw;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al actualizar permiso {permiso?.IdPermiso}");
                throw new BusinessLogicException($"Error al actualizar permiso: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Elimina (desactiva) un permiso con validaciones
        /// </summary>
        public bool EliminarPermiso(int idPermiso, string usuarioEliminacion)
        {
            try
            {
                if (idPermiso <= 0)
                    throw new ValidationException("El ID del permiso debe ser mayor a 0");

                // Verificar que el permiso existe
                var permiso = _datosPermiso.ObtenerPermisoPorId(idPermiso);
                if (permiso == null)
                    throw new ValidationException("El permiso no existe");

                // Validar que no sea un permiso crítico del sistema
                if (EsPermisoCritico(permiso.Modulo, permiso.Accion))
                {
                    throw new ValidationException("No se puede eliminar un permiso crítico del sistema");
                }

                // Advertir si tiene roles asignados
                if (permiso.TotalRoles > 0)
                {
                    ErrorLogger.LogCustom($"ADVERTENCIA: El permiso {idPermiso} tiene {permiso.TotalRoles} rol(es) asignado(s). Se eliminará de todos los roles.");
                }

                // Obtener IP del contexto web
                string ipEliminacion = CC_ContextoWeb.ObtenerDireccionIP();

                int filasAfectadas = _datosPermiso.EliminarPermiso(idPermiso, usuarioEliminacion, ipEliminacion);

                bool exitoso = (filasAfectadas != 0 || filasAfectadas == -1);

                if (exitoso)
                {
                    ErrorLogger.LogCustom($"Permiso {idPermiso} eliminado exitosamente por {usuarioEliminacion}");
                    return true;
                }
                else
                {
                    ErrorLogger.LogCustom($"ADVERTENCIA: No se eliminó ninguna fila para permiso {idPermiso}");
                    return false;
                }
            }
            catch (ValidationException)
            {
                throw;
            }
            catch (DataAccessException)
            {
                throw;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al eliminar permiso {idPermiso}");
                throw new BusinessLogicException($"Error al eliminar permiso: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Reactiva un permiso previamente desactivado (borrado lógico)
        /// </summary>
        public bool ReactivarPermiso(int idPermiso, string usuarioModificacion)
        {
            try
            {
                if (idPermiso <= 0)
                    throw new ValidationException("El ID del permiso debe ser mayor a 0");

                // Verificar que el permiso existe
                var permiso = _datosPermiso.ObtenerPermisoPorId(idPermiso);
                if (permiso == null)
                    throw new ValidationException("El permiso no existe");

                // Verificar que esté inactivo
                if (permiso.Activo)
                {
                    throw new ValidationException("El permiso ya está activo");
                }

                // Obtener IP del contexto web
                string ipModificacion = CC_ContextoWeb.ObtenerDireccionIP();

                int filasAfectadas = _datosPermiso.ReactivarPermiso(idPermiso, usuarioModificacion, ipModificacion);

                bool exitoso = (filasAfectadas != 0 || filasAfectadas == -1);

                if (exitoso)
                {
                    ErrorLogger.LogCustom($"Permiso {idPermiso} reactivado exitosamente por {usuarioModificacion}");
                    return true;
                }
                else
                {
                    ErrorLogger.LogCustom($"ADVERTENCIA: No se reactivó ninguna fila para permiso {idPermiso}");
                    return false;
                }
            }
            catch (ValidationException)
            {
                throw;
            }
            catch (DataAccessException)
            {
                throw;
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error al reactivar permiso {idPermiso}");
                throw new BusinessLogicException($"Error al reactivar permiso: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene lista de módulos disponibles en el sistema
        /// </summary>
        public List<string> ObtenerModulosDisponibles()
        {
            try
            {
                return _datosPermiso.ObtenerModulosDisponibles();
            }
            catch (DataAccessException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new BusinessLogicException($"Error al obtener módulos disponibles: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene lista de acciones disponibles en el sistema
        /// </summary>
        public List<string> ObtenerAccionesDisponibles()
        {
            try
            {
                return _datosPermiso.ObtenerAccionesDisponibles();
            }
            catch (DataAccessException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new BusinessLogicException($"Error al obtener acciones disponibles: {ex.Message}", ex);
            }
        }

        #region Validaciones Privadas

        /// <summary>
        /// Valida los datos para crear un permiso
        /// </summary>
        private void ValidarPermisoCreate(CE_PermisoCreateDTO permiso)
        {
            if (permiso == null)
                throw new ValidationException("Los datos del permiso son requeridos");

            // Validar Nombre
            if (string.IsNullOrWhiteSpace(permiso.Nombre))
                throw new ValidationException("El nombre del permiso es requerido");

            if (permiso.Nombre.Length > 50)
                throw new ValidationException("El nombre del permiso no puede exceder 50 caracteres");

            // Validar Descripción
            if (!string.IsNullOrWhiteSpace(permiso.Descripcion) && permiso.Descripcion.Length > 255)
                throw new ValidationException("La descripción no puede exceder 255 caracteres");

            // Validar Módulo
            if (string.IsNullOrWhiteSpace(permiso.Modulo))
                throw new ValidationException("El módulo es requerido");

            if (permiso.Modulo.Length > 100)
                throw new ValidationException("El módulo no puede exceder 100 caracteres");

            // Normalizar módulo (convertir a MAYÚSCULAS)
            permiso.Modulo = permiso.Modulo.Trim().ToUpper();

            // Validar Acción
            if (string.IsNullOrWhiteSpace(permiso.Accion))
                throw new ValidationException("La acción es requerida");

            if (permiso.Accion.Length > 100)
                throw new ValidationException("La acción no puede exceder 100 caracteres");

            // Normalizar acción (convertir a MAYÚSCULAS)
            permiso.Accion = permiso.Accion.Trim().ToUpper();

            // Validar que la acción sea válida (CRUD estándar)
            if (!EsAccionValida(permiso.Accion))
            {
                ErrorLogger.LogCustom($"ADVERTENCIA: Acción no estándar detectada: {permiso.Accion}");
            }
        }

        /// <summary>
        /// Valida los datos para actualizar un permiso
        /// </summary>
        private void ValidarPermisoUpdate(CE_PermisoUpdateDTO permiso)
        {
            if (permiso == null)
                throw new ValidationException("Los datos del permiso son requeridos");

            // Validar ID
            if (permiso.IdPermiso <= 0)
                throw new ValidationException("El ID del permiso debe ser mayor a 0");

            // Validar Nombre
            if (string.IsNullOrWhiteSpace(permiso.Nombre))
                throw new ValidationException("El nombre del permiso es requerido");

            if (permiso.Nombre.Length > 50)
                throw new ValidationException("El nombre del permiso no puede exceder 50 caracteres");

            // Validar Descripción
            if (!string.IsNullOrWhiteSpace(permiso.Descripcion) && permiso.Descripcion.Length > 255)
                throw new ValidationException("La descripción no puede exceder 255 caracteres");

            // Validar Módulo
            if (string.IsNullOrWhiteSpace(permiso.Modulo))
                throw new ValidationException("El módulo es requerido");

            if (permiso.Modulo.Length > 100)
                throw new ValidationException("El módulo no puede exceder 100 caracteres");

            // Normalizar módulo
            permiso.Modulo = permiso.Modulo.Trim().ToUpper();

            // Validar Acción
            if (string.IsNullOrWhiteSpace(permiso.Accion))
                throw new ValidationException("La acción es requerida");

            if (permiso.Accion.Length > 100)
                throw new ValidationException("La acción no puede exceder 100 caracteres");

            // Normalizar acción
            permiso.Accion = permiso.Accion.Trim().ToUpper();

            // Validar que la acción sea válida
            if (!EsAccionValida(permiso.Accion))
            {
                ErrorLogger.LogCustom($"ADVERTENCIA: Acción no estándar detectada: {permiso.Accion}");
            }
        }

        /// <summary>
        /// Verifica si una acción es válida según el estándar CRUD
        /// </summary>
        private bool EsAccionValida(string accion)
        {
            var accionesValidas = new[]
            {
                "CREAR", "LEER", "ACTUALIZAR", "ELIMINAR",
                "VER", "EDITAR", "BORRAR",
                "ADMINISTRAR", "ACCESO_TOTAL",
                "EXPORTAR", "IMPORTAR", "IMPRIMIR"
            };

            return Array.Exists(accionesValidas, a => a.Equals(accion, StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// Verifica si un permiso es crítico del sistema
        /// </summary>
        private bool EsPermisoCritico(string modulo, string accion)
        {
            var modulosCriticos = new[] { "SISTEMA", "AUDITORIA", "SEGURIDAD" };
            var accionesCriticas = new[] { "ADMINISTRAR", "ACCESO_TOTAL", "ELIMINAR_TODO" };

            bool esModuloCritico = Array.Exists(modulosCriticos, m => m.Equals(modulo, StringComparison.OrdinalIgnoreCase));
            bool esAccionCritica = Array.Exists(accionesCriticas, a => a.Equals(accion, StringComparison.OrdinalIgnoreCase));

            return esModuloCritico && esAccionCritica;
        }

        #endregion
    }
}
