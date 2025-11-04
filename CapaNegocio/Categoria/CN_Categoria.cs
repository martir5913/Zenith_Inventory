using CapaComun.Excepciones;
using CapaDatos.Categoria;
using CapaEntidad.DTOs.Categoria;
using CapaEntidad.DTOs.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
    }
}
