using CapaComun;
using CapaDatos.Usuario;
using CapaEntidad.DTOs.Common; // ✅ CORREGIDO: Para CE_PagedResult
using CapaEntidad.DTOs.Usuario;
using System;
using System.Collections.Generic;

namespace CapaNegocio.Usuario
{
    /// <summary>
    /// Capa de Negocio para Gestión de Roles
    /// Patrón: Similar a CN_Permiso y CN_Categoria
    /// </summary>
    public class CN_Rol
    {
        private readonly CD_Rol _cdRol;

        public CN_Rol()
        {
            _cdRol = new CD_Rol();
        }

        #region LISTAR ROLES

        /// <summary>
        /// Obtiene un listado paginado de roles con validaciones de negocio
        /// </summary>
        public CE_PagedResult<CE_RolListDTO> ListarRoles(
            int numeroPagina = 1,
            int tamañoPagina = 10,
            string terminoBusqueda = null,
            bool incluirInactivos = false)
        {
            try
            {
                // Validar parámetros de paginación
                if (numeroPagina < 1)
                {
                    ErrorLogger.LogCustom("Número de página inválido: " + numeroPagina);
                    numeroPagina = 1;
                }

                if (tamañoPagina < 1 || tamañoPagina > 100)
                {
                    ErrorLogger.LogCustom("Tamaño de página inválido: " + tamañoPagina);
                    tamañoPagina = 10;
                }

                // Llamar a la capa de datos
                return _cdRol.ListarRolesPaginado(numeroPagina, tamañoPagina, terminoBusqueda, incluirInactivos);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, "Error en capa de negocio al listar roles");
                throw;
            }
        }

        #endregion

        #region OBTENER ROL POR ID

        /// <summary>
        /// Obtiene los detalles completos de un rol
        /// </summary>
        public CE_RolDetalleDTO ObtenerRolPorId(int idRol)
        {
            try
            {
                // Validar ID
                if (idRol <= 0)
                {
                    ErrorLogger.LogCustom($"ID de rol inválido: {idRol}");
                    throw new ArgumentException("El ID del rol debe ser mayor a cero");
                }

                return _cdRol.ObtenerRolPorId(idRol);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error en capa de negocio al obtener rol ID: {idRol}");
                throw;
            }
        }

        #endregion

        #region CREAR ROL

        /// <summary>
        /// Crea un nuevo rol con validaciones de negocio
        /// </summary>
        public int CrearRol(CE_RolCreateDTO dto, string usuarioCreacion, string ipCreacion = null)
        {
            try
            {
                // Validar datos obligatorios
                if (dto == null)
                {
                    ErrorLogger.LogCustom("DTO de creación de rol es nulo");
                    throw new ArgumentNullException(nameof(dto), "Los datos del rol no pueden ser nulos");
                }

                if (string.IsNullOrWhiteSpace(dto.Nombre))
                {
                    ErrorLogger.LogCustom("Nombre de rol vacío");
                    throw new ArgumentException("El nombre del rol es obligatorio");
                }

                if (dto.Nombre.Length > 50)
                {
                    ErrorLogger.LogCustom($"Nombre de rol demasiado largo: {dto.Nombre.Length} caracteres");
                    throw new ArgumentException("El nombre del rol no puede exceder los 50 caracteres");
                }

                if (!string.IsNullOrWhiteSpace(dto.Descripcion) && dto.Descripcion.Length > 255)
                {
                    ErrorLogger.LogCustom($"Descripción de rol demasiado larga: {dto.Descripcion.Length} caracteres");
                    throw new ArgumentException("La descripción del rol no puede exceder los 255 caracteres");
                }

                if (string.IsNullOrWhiteSpace(usuarioCreacion))
                {
                    ErrorLogger.LogCustom("Usuario de creación vacío");
                    throw new ArgumentException("El usuario de creación es obligatorio");
                }

                // Normalizar datos
                dto.Nombre = dto.Nombre.Trim().ToUpper();
                dto.Descripcion = dto.Descripcion?.Trim();

                // Llamar a la capa de datos
                return _cdRol.CrearRol(dto, usuarioCreacion, ipCreacion);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error en capa de negocio al crear rol: {dto?.Nombre}");
                throw;
            }
        }

        #endregion

        #region ACTUALIZAR ROL

        /// <summary>
        /// Actualiza un rol existente con validaciones de negocio
        /// </summary>
        public int ActualizarRol(CE_RolUpdateDTO dto, string usuarioModificacion, string ipModificacion = null)
        {
            try
            {
                // Validar datos obligatorios
                if (dto == null)
                {
                    ErrorLogger.LogCustom("DTO de actualización de rol es nulo");
                    throw new ArgumentNullException(nameof(dto), "Los datos del rol no pueden ser nulos");
                }

                if (dto.IdRol <= 0)
                {
                    ErrorLogger.LogCustom($"ID de rol inválido: {dto.IdRol}");
                    throw new ArgumentException("El ID del rol debe ser mayor a cero");
                }

                if (string.IsNullOrWhiteSpace(dto.Nombre))
                {
                    ErrorLogger.LogCustom("Nombre de rol vacío");
                    throw new ArgumentException("El nombre del rol es obligatorio");
                }

                if (dto.Nombre.Length > 50)
                {
                    ErrorLogger.LogCustom($"Nombre de rol demasiado largo: {dto.Nombre.Length} caracteres");
                    throw new ArgumentException("El nombre del rol no puede exceder los 50 caracteres");
                }

                if (!string.IsNullOrWhiteSpace(dto.Descripcion) && dto.Descripcion.Length > 255)
                {
                    ErrorLogger.LogCustom($"Descripción de rol demasiado larga: {dto.Descripcion.Length} caracteres");
                    throw new ArgumentException("La descripción del rol no puede exceder los 255 caracteres");
                }

                if (string.IsNullOrWhiteSpace(usuarioModificacion))
                {
                    ErrorLogger.LogCustom("Usuario de modificación vacío");
                    throw new ArgumentException("El usuario de modificación es obligatorio");
                }

                // Normalizar datos
                dto.Nombre = dto.Nombre.Trim().ToUpper();
                dto.Descripcion = dto.Descripcion?.Trim();

                // Llamar a la capa de datos
                return _cdRol.ActualizarRol(dto, usuarioModificacion, ipModificacion);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error en capa de negocio al actualizar rol ID: {dto?.IdRol}");
                throw;
            }
        }

        #endregion

        #region ELIMINAR ROL

        /// <summary>
        /// Elimina (desactiva) un rol con validaciones de negocio
        /// </summary>
        public int EliminarRol(int idRol, string usuarioEliminacion, string ipEliminacion = null)
        {
            try
            {
                // Validar ID
                if (idRol <= 0)
                {
                    ErrorLogger.LogCustom($"ID de rol inválido: {idRol}");
                    throw new ArgumentException("El ID del rol debe ser mayor a cero");
                }

                if (string.IsNullOrWhiteSpace(usuarioEliminacion))
                {
                    ErrorLogger.LogCustom("Usuario de eliminación vacío");
                    throw new ArgumentException("El usuario de eliminación es obligatorio");
                }

                // Validaciones adicionales de negocio (si aplican)
                // Por ejemplo: No permitir eliminar roles críticos como "Administrador"
                var rol = _cdRol.ObtenerRolPorId(idRol);
                if (rol.Nombre == "ADMINISTRADOR")
                {
                    ErrorLogger.LogCustom($"Intento de eliminar rol protegido: {rol.Nombre}");
                    throw new InvalidOperationException("No se puede eliminar el rol de Administrador");
                }

                // Llamar a la capa de datos
                return _cdRol.EliminarRol(idRol, usuarioEliminacion, ipEliminacion);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error en capa de negocio al eliminar rol ID: {idRol}");
                throw;
            }
        }

        #endregion

        #region REACTIVAR ROL

        /// <summary>
        /// Reactiva un rol previamente desactivado con validaciones de negocio
        /// </summary>
        public int ReactivarRol(int idRol, string usuarioModificacion, string ipModificacion = null)
        {
            try
            {
                // Validar ID
                if (idRol <= 0)
                {
                    ErrorLogger.LogCustom($"ID de rol inválido: {idRol}");
                    throw new ArgumentException("El ID del rol debe ser mayor a cero");
                }

                if (string.IsNullOrWhiteSpace(usuarioModificacion))
                {
                    ErrorLogger.LogCustom("Usuario de modificación vacío");
                    throw new ArgumentException("El usuario de modificación es obligatorio");
                }

                // Llamar a la capa de datos
                return _cdRol.ReactivarRol(idRol, usuarioModificacion, ipModificacion);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error en capa de negocio al reactivar rol ID: {idRol}");
                throw;
            }
        }

        #endregion

        #region ASIGNAR PERMISOS

        /// <summary>
        /// Asigna permisos a un rol with validaciones de negocio
        /// </summary>
        public void AsignarPermisos(int idRol, List<int> permisosIds, string usuarioModificacion, string ipModificacion = null)
        {
            try
            {
                // Validar ID de rol
                if (idRol <= 0)
                {
                    ErrorLogger.LogCustom($"ID de rol inválido: {idRol}");
                    throw new ArgumentException("El ID del rol debe ser mayor a cero");
                }

                if (string.IsNullOrWhiteSpace(usuarioModificacion))
                {
                    ErrorLogger.LogCustom("Usuario de modificación vacío");
                    throw new ArgumentException("El usuario de modificación es obligatorio");
                }

                // Validar que la lista no contenga IDs inválidos
                if (permisosIds != null)
                {
                    foreach (var permisoId in permisosIds)
                    {
                        if (permisoId <= 0)
                        {
                            ErrorLogger.LogCustom($"ID de permiso inválido en lista: {permisoId}");
                            throw new ArgumentException("Todos los IDs de permisos deben ser mayores a cero");
                        }
                    }
                }

                // Llamar a la capa de datos
                _cdRol.AsignarPermisos(idRol, permisosIds, usuarioModificacion, ipModificacion);
            }
            catch (Exception ex)
            {
                ErrorLogger.Log(ex, $"Error en capa de negocio al asignar permisos al rol ID: {idRol}");
                throw;
            }
        }

        #endregion
    }
}
