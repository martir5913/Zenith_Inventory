using CapaComun; // Agregado para acceder a CC_ContextoWeb
using CapaComun.Excepciones;
using CapaDatos.Categoria;
using CapaEntidad.DTOs.Catalogo;
using CapaEntidad.DTOs.Common;
using System;

namespace CapaNegocio.Categoria
{
    public class CN_Categoria
    {
        private readonly CD_Categoria _datosCategoria;

        public CN_Categoria()
        {
            _datosCategoria = new CD_Categoria();
        }

        public CE_PagedResult<CE_CategoriaListDTO> ObtenerCategoriasPaginadas(int pageNumber, int pageSize, string searchTerm = null)
        {
            try
            {
                // Validaciones
                if (pageNumber < 1)
                    throw new ValidationException("El número de página debe ser mayor a 0");

                if (pageSize < 1 || pageSize > 100)
                    throw new ValidationException("El tamaño de página debe estar entre 1 y 100");

                return _datosCategoria.ObtenerCategoriasPaginadas(
                    pageNumber,
                    pageSize,
                    searchTerm,
                    incluirInactivos: false
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
                throw new BusinessLogicException($"Error al obtener categorías paginadas: {ex.Message}", ex);
            }
        }

        public CE_CategoriaListDTO ObtenerCategoriaPorId(int idCategoria)
        {
            try
            {
                if (idCategoria <= 0)
                    throw new ValidationException("El ID de la categoría debe ser mayor a 0");

                var categoria = _datosCategoria.ObtenerCategoriaPorId(idCategoria);

                if (categoria == null)
                    throw new ValidationException("La categoría no existe");

                return categoria;
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
                throw new BusinessLogicException($"Error al obtener categoría por ID: {ex.Message}", ex);
            }
        }

        public int CrearCategoria(CE_CategoriaCreateDTO categoria, string usuarioCreacion)
        {
            try
            {
                // Validaciones
                if (categoria == null)
                    throw new ValidationException("Los datos de la categoría son requeridos");

                if (string.IsNullOrWhiteSpace(categoria.Nombre))
                    throw new ValidationException("El nombre de la categoría es requerido");

                if (categoria.Nombre.Length > 100)
                    throw new ValidationException("El nombre de la categoría no puede exceder 100 caracteres");

                if (!string.IsNullOrWhiteSpace(categoria.Descripcion) && categoria.Descripcion.Length > 500)
                    throw new ValidationException("La descripción no puede exceder 500 caracteres");

                // Obtener IP del contexto web
                string ipCreacion = CC_ContextoWeb.ObtenerDireccionIP();

                return _datosCategoria.CrearCategoria(categoria, usuarioCreacion, ipCreacion);
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
                throw new BusinessLogicException($"Error al crear categoría: {ex.Message}", ex);
            }
        }

        public void ActualizarCategoria(CE_CategoriaUpdateDTO categoria, string usuarioModificacion)
        {
            try
            {
                // Validaciones
                if (categoria == null)
                    throw new ValidationException("Los datos de la categoría son requeridos");

                if (categoria.IdCategoria <= 0)
                    throw new ValidationException("El ID de la categoría debe ser mayor a 0");

                if (string.IsNullOrWhiteSpace(categoria.Nombre))
                    throw new ValidationException("El nombre de la categoría es requerido");

                if (categoria.Nombre.Length > 100)
                    throw new ValidationException("El nombre de la categoría no puede exceder 100 caracteres");

                if (!string.IsNullOrWhiteSpace(categoria.Descripcion) && categoria.Descripcion.Length > 500)
                    throw new ValidationException("La descripción no puede exceder 500 caracteres");

                // Verificar que la categoría existe
                var categoriaExistente = _datosCategoria.ObtenerCategoriaPorId(categoria.IdCategoria);
                if (categoriaExistente == null)
                    throw new ValidationException("La categoría no existe");

                // Obtener IP del contexto web
                string ipModificacion = CC_ContextoWeb.ObtenerDireccionIP();

                _datosCategoria.ActualizarCategoria(categoria, usuarioModificacion, ipModificacion);
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
                throw new BusinessLogicException($"Error al actualizar categoría: {ex.Message}", ex);
            }
        }

        public void EliminarCategoria(int idCategoria, string usuarioEliminacion)
        {
            try
            {
                if (idCategoria <= 0)
                    throw new ValidationException("El ID de la categoría debe ser mayor a 0");

                // Verificar que la categoría existe
                var categoria = _datosCategoria.ObtenerCategoriaPorId(idCategoria);
                if (categoria == null)
                    throw new ValidationException("La categoría no existe");

                // Verificar que no tenga subcategorías activas
                if (categoria.TotalSubcategorias > 0)
                    throw new ValidationException("No se puede eliminar una categoría que tiene subcategorías activas");

                // Obtener IP del contexto web
                string ipEliminacion = CC_ContextoWeb.ObtenerDireccionIP();

                _datosCategoria.EliminarCategoria(idCategoria, usuarioEliminacion, ipEliminacion);
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
                throw new BusinessLogicException($"Error al eliminar categoría: {ex.Message}", ex);
            }
        }
    }
}
