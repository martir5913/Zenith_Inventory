using CapaComun;
using CapaComun.Excepciones;
using CapaDatos.Catalogo;
using CapaEntidad.DTOs.Catalogo;
using CapaEntidad.DTOs.Common;
using System;

namespace CapaNegocio.Catalogo
{
    public class CN_SubCategoria
    {
        private readonly CD_SubCategoria _SubCategoria;

        public CN_SubCategoria()
        {
            _SubCategoria = new CD_SubCategoria();
        }

        public CE_PagedResult<CE_SubCategoriaListDTO> ObtenerSubCategoriasPaginadas(int pageNumber, int pageSize, string searchTerm = null, int? idCategoria = null, bool? activo = null)
        {
            try
            {
                if (pageNumber < 1)
                    throw new ValidationException("El número de página debe ser mayor a 0");

                if (pageSize < 1 || pageSize > 100)
                    throw new ValidationException("El tamaño de página debe estar entre 1 y 100");

                // ✅ FIX COMPLETO: Lógica corregida para manejar los tres estados
                bool incluirInactivos;
                bool? soloInactivos = null;
                
                if (!activo.HasValue)
                {
                    // Filtro "Todos" → Incluir activos e inactivos
                    incluirInactivos = true;
                    soloInactivos = null;
                }
                else if (activo.Value)
                {
                    // Filtro "Solo Activos" → Solo activos
                    incluirInactivos = false;
                    soloInactivos = null;
                }
                else
                {
                    // Filtro "Solo Inactivos" → Solo inactivos
                    incluirInactivos = true;
                    soloInactivos = true;
                }

                return _SubCategoria.ObtenerSubCategoriasPaginadas(
                    pageNumber,
                    pageSize,
                    searchTerm,
                    incluirInactivos: incluirInactivos,
                    idCategoria: idCategoria,
                    soloInactivos: soloInactivos
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
                throw new BusinessLogicException($"Error al obtener SubCategorías paginadas: {ex.Message}", ex);
            }
        }

        public CE_SubCategoriaListDTO SubCategoriaPorId(int idSubCat)
        {
            try
            {
                if (idSubCat <= 0)
                    throw new ValidationException("El id no puede ser menor a 0");

                var objSubCat = _SubCategoria.SubCategoriaPorId(idSubCat);

                if (objSubCat == null)
                    throw new ValidationException("La SubCategoria no existe");

                return objSubCat;

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
                throw new BusinessLogicException($"Error al obtener el id de la subcategoria: {ex.Message}", ex);
            }
        }

        public bool ActualizarSubCat(CE_SubCategoriaUpdateDTO SubCat)
        {
            try
            {
                // Validaciones
                if (SubCat == null)
                    throw new ValidationException("Los datos de la Subcategoría son requeridos");

                if (SubCat.IdSubCate <= 0)
                    throw new ValidationException("El ID de la Subcategoría debe ser mayor a 0");

                if (string.IsNullOrWhiteSpace(SubCat.Nombre))
                    throw new ValidationException("El nombre de la Aubcategoría es requerido");

                if (SubCat.Nombre.Length > 100)
                    throw new ValidationException("El nombre de la Subcategoría no puede exceder 100 caracteres");

                if (!string.IsNullOrWhiteSpace(SubCat.Descripcion) && SubCat.Descripcion.Length > 500)
                    throw new ValidationException("La descripción no puede exceder 500 caracteres");

                // Verificar que la Subcategoría existe
                var categoriaExistente = _SubCategoria.SubCategoriaPorId(SubCat.IdSubCate);
                if (categoriaExistente == null)
                    throw new ValidationException("La Subcategoría no existe");

                SubCat.ipModificacion = CC_ContextoWeb.ObtenerDireccionIP();

                int filasAfectadas = _SubCategoria.ActualizarSubCat(SubCat);

                bool exitoso = (filasAfectadas != 0 || filasAfectadas == -1);

                if (exitoso)
                {
                    ErrorLogger.LogCustom($"SubCategoría {SubCat.IdSubCate} actualizada exitosamente por {SubCat.usuarioModificacion}");
                    return true;
                }
                else
                {
                    ErrorLogger.LogCustom($"ADVERTENCIA: No se actualizó ninguna fila para Subcategoría {SubCat.IdSubCate}");
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
                ErrorLogger.Log(ex, $"Error al actualizar Subcategoría {SubCat?.IdCategoria}");
                throw new BusinessLogicException($"Error al actualizar Subcategoría: {ex.Message}", ex);
            }
        }

        public bool BorrarSubCat(int idSubCat, string usuarioDel)
        {
            try
            {
                if (idSubCat <= 0)
                    throw new ValidationException("El ID de la subcategoria debe ser mayor a 0");

                var categoriaExistente = _SubCategoria.SubCategoriaPorId(idSubCat);

                if (categoriaExistente == null)
                    throw new ValidationException("La subcategoria no existe");

                var ipDel = CC_ContextoWeb.ObtenerDireccionIP();

                int filasAfectadas = _SubCategoria.EliminarSubCat(idSubCat, usuarioDel, ipDel);

                bool exitoso = (filasAfectadas != 0 || filasAfectadas == -1);

                if (exitoso)
                {
                    ErrorLogger.LogCustom($"SubCategoría {idSubCat} desactivado exitosamente por {usuarioDel}");
                    return true;
                }
                else
                {
                    ErrorLogger.LogCustom($"ADVERTENCIA: No se desactivo ninguna fila para Subcategoría {idSubCat}");
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
                ErrorLogger.Log(ex, $"Error al desactivar la Subcategoría {idSubCat}");
                throw new BusinessLogicException($"Error al desactivar la Subcategoría: {ex.Message}", ex);
            }
        }

        public bool ReactivarSubCat(int idSubCat, string usuarioModificacion)
        {
            try
            {
                if (idSubCat <= 0)
                    throw new ValidationException("El ID de la subcategoría debe ser mayor a 0");

                // Verificar que la subcategoría existe
                var subcategoria = _SubCategoria.SubCategoriaPorId(idSubCat);
                if (subcategoria == null)
                    throw new ValidationException("La subcategoría no existe");

                // Verificar que esté inactiva
                if (subcategoria.Estado)
                {
                    throw new ValidationException("La subcategoría ya está activa");
                }

                // Obtener IP del contexto web
                string ipModificacion = CC_ContextoWeb.ObtenerDireccionIP();

                int filasAfectadas = _SubCategoria.ReactivarSubCat(idSubCat, usuarioModificacion, ipModificacion);
                
                bool exitoso = (filasAfectadas != 0 || filasAfectadas == -1);
                
                if (exitoso)
                {
                    ErrorLogger.LogCustom($"SubCategoría {idSubCat} reactivada exitosamente por {usuarioModificacion}");
                    return true;
                }
                else
                {
                    ErrorLogger.LogCustom($"ADVERTENCIA: No se reactivó ninguna fila para Subcategoría {idSubCat}");
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
                ErrorLogger.Log(ex, $"Error al reactivar Subcategoría {idSubCat}");
                throw new BusinessLogicException($"Error al reactivar Subcategoría: {ex.Message}", ex);
            }
        }

        public int CrearSubCat(CE_SubCategoriaCreateDTO subcate)
        {
            try
            {
                // Validaciones
                if (subcate == null)
                    throw new ValidationException("Los datos de la Subcategoría son requeridos");

                if (string.IsNullOrWhiteSpace(subcate.Nombre))
                    throw new ValidationException("El nombre de la Subcategoría es requerido");

                if (subcate.Nombre.Length > 100)
                    throw new ValidationException("El nombre de la Subcategoría no puede exceder 100 caracteres");

                if (!string.IsNullOrWhiteSpace(subcate.Descripcion) && subcate.Descripcion.Length > 500)
                    throw new ValidationException("La descripción no puede exceder 500 caracteres");

                // Obtener IP del contexto web
                subcate.IpCreacion = CC_ContextoWeb.ObtenerDireccionIP();

                return _SubCategoria.CrearSubCat(subcate);
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
                throw new BusinessLogicException($"Error al crear Subcategoría: {ex.Message}", ex);
            }
        }
    }
}
