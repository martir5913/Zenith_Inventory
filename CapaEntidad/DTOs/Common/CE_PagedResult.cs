using System.Collections.Generic;

namespace CapaEntidad.DTOs.Common
{
    /// <summary>
    /// Resultado paginado genérico
    /// </summary>
    /// <typeparam name="T">Tipo de entidad</typeparam>
    public class CE_PagedResult<T>
    {
        public List<T> Items { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public int TotalRecords { get; set; }
        public int TotalPages { get; set; }
        public bool HasPreviousPage => PageNumber > 1;
        public bool HasNextPage => PageNumber < TotalPages;

        public CE_PagedResult()
        {
            Items = new List<T>();
        }

        public CE_PagedResult(List<T> items, int totalRecords, int pageNumber, int pageSize)
        {
            Items = items ?? new List<T>();
            TotalRecords = totalRecords;
            PageNumber = pageNumber;
            PageSize = pageSize;
            TotalPages = (totalRecords + pageSize - 1) / pageSize; // Redondeo hacia arriba
        }
    }
}