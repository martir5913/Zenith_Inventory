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

                return _SubCategoria.ObtenerSubCategoriasPaginadas(
                    pageNumber,
                    pageSize,
                    searchTerm,
                    incluirInactivos: activo.HasValue ? !activo.Value : false,
                    idCategoria: idCategoria
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
    }
}
