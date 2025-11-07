using CapaDatos.Catalogo;
using CapaEntidad.DTOs.Catalogo;
using CapaEntidad.DTOs.Common;
using System;
using System.Collections.Generic;

namespace CapaNegocio.Catalogo
{
    public class CN_Marca
    {
        private readonly CD_Marca _datosMarca;

        public CN_Marca()
        {
            _datosMarca = new CD_Marca();
        }

        /// <summary>
        /// Crea una nueva marca
        /// </summary>
        public int CrearMarca(CE_MarcaCreateDTO marca, string usuarioCreacion, string ipCreacion)
        {
            // Validar datos de entrada
            ValidarMarcaCreate(marca);

            try
            {
                return _datosMarca.CrearMarca(marca, usuarioCreacion, ipCreacion);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error en la capa de negocio al crear marca: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Actualiza una marca existente
        /// </summary>
        public void ActualizarMarca(CE_MarcaUpdateDTO marca, string usuarioModificacion, string ipModificacion)
        {
            // Validar datos de entrada
            ValidarMarcaUpdate(marca);

            try
            {
                _datosMarca.ActualizarMarca(marca, usuarioModificacion, ipModificacion);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error en la capa de negocio al actualizar marca: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Elimina (lógicamente) una marca
        /// </summary>
        public void EliminarMarca(int idMarca, string usuarioEliminacion, string ipEliminacion)
        {
            if (idMarca <= 0)
            {
                throw new ArgumentException("El ID de la marca debe ser mayor a cero");
            }

            try
            {
                _datosMarca.EliminarMarca(idMarca, usuarioEliminacion, ipEliminacion);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error en la capa de negocio al eliminar marca: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene marcas paginadas
        /// </summary>
        public CE_PagedResult<CE_MarcaListDTO> ObtenerMarcasPaginadas(
            int pageNumber, 
            int pageSize, 
            string searchTerm, 
            bool? incluirInactivos)
        {
            if (pageNumber <= 0)
            {
                throw new ArgumentException("El número de página debe ser mayor a cero");
            }

            if (pageSize <= 0 || pageSize > 100)
            {
                throw new ArgumentException("El tamaño de página debe estar entre 1 y 100");
            }

            try
            {
                var (marcas, totalRegistros) = _datosMarca.ObtenerMarcasPaginadas(
                    pageNumber, 
                    pageSize, 
                    searchTerm, 
                    incluirInactivos);

                return new CE_PagedResult<CE_MarcaListDTO>
                {
                    Items = marcas,
                    PageNumber = pageNumber,
                    PageSize = pageSize,
                    TotalRecords = totalRegistros,
                    TotalPages = (int)Math.Ceiling(totalRegistros / (double)pageSize)
                };
            }
            catch (Exception ex)
            {
                throw new Exception($"Error en la capa de negocio al obtener marcas paginadas: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Obtiene una marca por ID
        /// </summary>
        public CE_MarcaListDTO ObtenerMarcaPorId(int idMarca)
        {
            if (idMarca <= 0)
            {
                throw new ArgumentException("El ID de la marca debe ser mayor a cero");
            }

            try
            {
                return _datosMarca.ObtenerMarcaPorId(idMarca);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error en la capa de negocio al obtener marca por ID: {ex.Message}", ex);
            }
        }

        #region Métodos de Validación

        private void ValidarMarcaCreate(CE_MarcaCreateDTO marca)
        {
            if (marca == null)
            {
                throw new ArgumentNullException(nameof(marca), "Los datos de la marca son requeridos");
            }

            if (string.IsNullOrWhiteSpace(marca.Nombre))
            {
                throw new ArgumentException("El nombre de la marca es requerido");
            }

            if (marca.Nombre.Length > 100)
            {
                throw new ArgumentException("El nombre de la marca no puede exceder 100 caracteres");
            }

            if (!string.IsNullOrEmpty(marca.Descripcion) && marca.Descripcion.Length > 500)
            {
                throw new ArgumentException("La descripción no puede exceder 500 caracteres");
            }
        }

        private void ValidarMarcaUpdate(CE_MarcaUpdateDTO marca)
        {
            if (marca == null)
            {
                throw new ArgumentNullException(nameof(marca), "Los datos de la marca son requeridos");
            }

            if (marca.IdMarca <= 0)
            {
                throw new ArgumentException("El ID de la marca debe ser mayor a cero");
            }

            if (string.IsNullOrWhiteSpace(marca.Nombre))
            {
                throw new ArgumentException("El nombre de la marca es requerido");
            }

            if (marca.Nombre.Length > 100)
            {
                throw new ArgumentException("El nombre de la marca no puede exceder 100 caracteres");
            }

            if (!string.IsNullOrEmpty(marca.Descripcion) && marca.Descripcion.Length > 500)
            {
                throw new ArgumentException("La descripción no puede exceder 500 caracteres");
            }
        }

        #endregion
    }
}
