// ============================================
// GESTIÓN DE CATEGORÍAS - categorias.js
// ============================================

// Variables globales
var currentPage = 1;
var pageSize = 10;
var searchTerm = '';
var filterStatus = 'activos'; // ✅ AGREGADO: Filtro de estado
var isEditMode = false;
var editCategoryId = null;

$(document).ready(function () {
    // OPTIMIZACIÓN: Medir tiempo de carga inicial
    console.time('Carga Inicial Categorías');
    
    loadCategories().then(() => {
        console.timeEnd('Carga Inicial Categorías');
        console.log('✅ Categorías cargadas exitosamente');
    }).catch(error => {
        console.error('❌ Error al cargar categorías:', error);
    });

    // Event Handlers
    $('#searchInput').on('input', function () {
        searchTerm = $(this).val().trim();
        currentPage = 1;
        loadCategories();
    });

    // ✅ NUEVO: Event handler para filtro de estado
    $('#filterStatus').on('change', function () {
        filterStatus = $(this).val();
        currentPage = 1;
        loadCategories();
    });

    // ✅ NUEVO: Event handler para limpiar filtros
    $('#btnClearFilters').on('click', function () {
        limpiarFiltros();
    });

    // ✅ NUEVO: Event handler para refrescar
    $('#btnRefreshCategories').on('click', function () {
        const icon = $(this).find('i');
        icon.addClass('fa-spin');
        loadCategories().finally(() => {
            icon.removeClass('fa-spin');
        });
    });

    $('#btnAddCategory').click(function () {
        resetModal();
        $('#categoryModalLabel').text('Agregar Categoría');
        $('#categoryModalIcon').removeClass('fa-edit').addClass('fa-plus');
        $('#categoryModal').modal('show');
        isEditMode = false;
    });

    $('#btnSaveCategory').click(function () {
        saveCategory();
    });

    $(document).on('click', '.edit-category-btn', function () {
        var categoryId = $(this).data('id');
        loadCategoryDetails(categoryId);
    });

    $(document).on('click', '.delete-category-btn', function () {
        var categoryId = $(this).data('id');
        deleteCategory(categoryId);
    });

    // ✅ NUEVO: Event handler para reactivar categoría
    $(document).on('click', '.reactivate-category-btn', function () {
        var categoryId = $(this).data('id');
        var categoryName = $(this).data('nombre');
        reactivateCategory(categoryId, categoryName);
    });

    $(document).on('click', '.view-category-btn', function () {
        var categoryId = $(this).data('id');
        viewCategoryDetails(categoryId);
    });

    $(document).on('click', '.page-link', function (e) {
        e.preventDefault();
        currentPage = $(this).data('page');
        loadCategories();
    });
});

function loadCategories() {
    console.time('loadCategories');
    return new Promise((resolve, reject) => {
        // ✅ FIX CORRECTO: El filtrado debe hacerse en BACKEND, no en frontend
        let incluirInactivos = false;
        
        if (filterStatus === 'todos') {
            incluirInactivos = true;
        } else if (filterStatus === 'inactivos') {
            incluirInactivos = true;
        }
        // Si filterStatus === 'activos', incluirInactivos = false (solo activos)

        $.ajax({
            url: '/Categorias/GetCategorias',
            type: 'GET',
            data: {
                page: currentPage,
                pageSize: pageSize,
                search: searchTerm,
                incluirInactivos: incluirInactivos // ✅ Enviar al backend
            },
            success: function (response) {
                console.timeEnd('loadCategories');
                if (response.success) {
                    let items = response.data.items || [];
                    let pagination = response.data.pagination;
                    
                    // ✅ DIAGNÓSTICO: Ver los valores reales de Activo
                    console.log('=== DIAGNÓSTICO FILTRO CATEGORÍAS ===');
                    console.log('Filtro actual:', filterStatus);
                    console.log('incluirInactivos enviado al backend:', incluirInactivos);
                    console.log('Total items recibidos del backend:', items.length);
                    items.forEach((item, index) => {
                        const esActivo = item.Activo === true || item.Activo === 1 || item.Activo === "true" || item.Activo === "True";
                        console.log(`Item ${index}: ID=${item.IdCategoria}, Nombre="${item.Nombre}", Activo=${item.Activo}, esActivo=${esActivo}`);
                    });
                    
                    // ✅ IMPORTANTE: El filtrado de "solo inactivos" NO se hace aquí
                    // El backend debe retornar YA filtrado según el parámetro incluirInactivos
                    // Solo aplicamos filtro en cliente si es absolutamente necesario para casos edge
                    
                    if (filterStatus === 'inactivos') {
                        // ✅ Verificar que el backend retornó solo inactivos
                        const activosEnRespuesta = items.filter(c => {
                            const esActivo = c.Activo === true || c.Activo === 1 || c.Activo === "true" || c.Activo === "True";
                            return esActivo;
                        });
                        
                        if (activosEnRespuesta.length > 0) {
                            console.warn('⚠️ ADVERTENCIA: El backend retornó categorías ACTIVAS cuando se pidieron INACTIVAS');
                            console.warn('Categorías activas recibidas:', activosEnRespuesta);
                            
                            // Filtrar en cliente como fallback
                            items = items.filter(c => {
                                const esActivo = c.Activo === true || c.Activo === 1 || c.Activo === "true" || c.Activo === "True";
                                return !esActivo;
                            });
                            
                            console.log('Después del filtro en cliente:', items.length, 'items');
                        }
                        
                        if (items.length === 0) {
                            toastr.info('No se encontraron categorías inactivas', 'Información', {
                                timeOut: 3000
                            });
                        }
                    }
                    
                    populateCategoriesTable(items);
                    populatePagination(pagination);
                    resolve(response);
                } else {
                    toastr.error(response.message, 'Error');
                    reject(response.message);
                }
            },
            error: function (xhr, status, error) {
                console.timeEnd('loadCategories');
                toastr.error('Error al cargar las categorías.', 'Error');
                reject(error);
            }
        });
    });
}

function populateCategoriesTable(categories = []) {
    var tbody = $('#categoriesBody');
    tbody.empty();

    if (categories.length === 0) {
        // ✅ Mensaje personalizado según el filtro activo
        let mensaje = 'No se encontraron categorías';
        let icono = 'fas fa-inbox';
        
        if (filterStatus === 'inactivos') {
            mensaje = 'No hay categorías inactivas';
            icono = 'fas fa-check-circle text-success';
        } else if (searchTerm) {
            mensaje = `No se encontraron resultados para "${searchTerm}"`;
            icono = 'fas fa-search';
        }
        
        tbody.html(`
            <tr>
                <td colspan="6" class="text-center text-muted py-4">
                    <i class="${icono} fa-2x mb-3"></i>
                    <p>${mensaje}</p>
                </td>
            </tr>
        `);
        return;
    }

    categories.forEach(function (category) {
        // ✅ FIX: Normalizar el valor de Activo a booleano
        const esActivo = category.Activo === true || category.Activo === 1 || category.Activo === "true" || category.Activo === "True";
        
        const estadoBadge = esActivo
            ? '<span class="badge badge-success">Activo</span>'
            : '<span class="badge badge-secondary">Inactivo</span>';

        // ✅ Botones de acción según el estado de la categoría
        let botonesAccion = '';
        
        if (esActivo) {
            // Categoría activa: botones normales (Ver, Editar, Eliminar)
            botonesAccion = `
                <button class="btn btn-info btn-sm btn-icon-only view-category-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Ver detalles" 
                        data-id="${category.IdCategoria}">
                    <i class="fas fa-eye"></i>
                </button>
                <button class="btn btn-warning btn-sm btn-icon-only edit-category-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Editar" 
                        data-id="${category.IdCategoria}">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-danger btn-sm btn-icon-only delete-category-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Eliminar" 
                        data-id="${category.IdCategoria}">
                    <i class="fas fa-trash"></i>
                </button>
            `;
        } else {
            // Categoría inactiva: solo botón de ver y reactivar
            botonesAccion = `
                <button class="btn btn-info btn-sm btn-icon-only view-category-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Ver detalles" 
                        data-id="${category.IdCategoria}">
                    <i class="fas fa-eye"></i>
                </button>
                <button class="btn btn-primary btn-sm btn-icon-only reactivate-category-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Reactivar categoría" 
                        data-id="${category.IdCategoria}"
                        data-nombre="${escapeHtml(category.Nombre)}">
                    <i class="fas fa-undo"></i>
                </button>
            `;
        }

        var row = `
            <tr data-category-id="${category.IdCategoria}" class="${!esActivo ? 'table-secondary' : ''}">
                <td>${category.IdCategoria}</td>
                <td>${escapeHtml(category.Nombre)}</td>
                <td>${escapeHtml(category.Descripcion || '')}</td>
                <td>${estadoBadge}</td>
                <td class="text-center"><span class="subcategory-count">${category.TotalSubcategorias}</span></td>
                <td class="action-buttons">
                    ${botonesAccion}
                </td>
            </tr>
        `;
        tbody.append(row);
    });

    // OPTIMIZACIÓN: Lazy loading de tooltips
    initializeLazyTooltips();
}

// OPTIMIZACIÓN: Inicializar tooltips solo al hacer hover
function initializeLazyTooltips() {
    $('[data-bs-toggle="tooltip"]').off('mouseenter.tooltip').on('mouseenter.tooltip', function() {
        const $this = $(this);
        if (!$this.data('bs.tooltip')) {
            $this.tooltip({
                trigger: 'hover'
            });
            $this.tooltip('show');
        }
    });
}

function populatePagination(pagination) {
    var container = $('#paginationContainer');
    container.empty();

    if (!pagination || pagination.totalPages <= 1) {
        return;
    }

    var ul = $('<ul class="pagination"></ul>');

    if (pagination.hasPreviousPage) {
        ul.append('<li class="page-item"><a class="page-link" href="#" data-page="' + (pagination.currentPage - 1) + '">Anterior</a></li>');
    }

    for (var i = Math.max(1, pagination.currentPage - 2); i <= Math.min(pagination.totalPages, pagination.currentPage + 2); i++) {
        var activeClass = (i === pagination.currentPage) ? ' active' : '';
        ul.append('<li class="page-item' + activeClass + '"><a class="page-link" href="#" data-page="' + i + '">' + i + '</a></li>');
    }

    if (pagination.hasNextPage) {
        ul.append('<li class="page-item"><a class="page-link" href="#" data-page="' + (pagination.currentPage + 1) + '">Siguiente</a></li>');
    }

    container.append(ul);
}

function resetModal() {
    $('#categoryForm')[0].reset();
    $('#categoryActive').prop('checked', true);
}

function saveCategory() {
    var name = $('#categoryName').val().trim();
    var description = $('#categoryDescription').val().trim();
    var active = $('#categoryActive').is(':checked');

    if (!name) {
        toastr.warning('El nombre de la categoría es obligatorio.', 'Validación');
        return;
    }

    var url = isEditMode ? '/Categorias/UpdateCategoria' : '/Categorias/CreateCategoria';
    var data = isEditMode ?
        { id: editCategoryId, nombre: name, descripcion: description, activo: active } :
        { nombre: name, descripcion: description, activo: active };

    $.ajax({
        url: url,
        type: 'POST',
        data: data,
        success: function (response) {
            console.log('Save category success response:', response);
            if (response.success) {
                $('#categoryModal').modal('hide');
                loadCategories();
                toastr.success(response.message, 'Éxito');
                
                // OPTIMIZACIÓN: Invalidar caché de categorías en subcategorías
                if (typeof invalidateCategoriesCache === 'function') {
                    invalidateCategoriesCache();
                }
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function (xhr, status, error) {
            console.log('Save category error:', xhr, status, error);
            toastr.error('Error al guardar la categoría.', 'Error');
        }
    });
}

function loadCategoryDetails(categoryId) {
    $.ajax({
        url: '/Categorias/GetCategoriaDetalle',
        type: 'GET',
        data: { id: categoryId },
        success: function (response) {
            if (response.success) {
                var category = response.data;
                $('#categoryName').val(category.nombre);
                $('#categoryDescription').val(category.descripcion);
                $('#categoryActive').prop('checked', category.activo);
                $('#categoryModalLabel').text('Editar Categoría');
                $('#categoryModalIcon').removeClass('fa-plus').addClass('fa-edit');
                $('#categoryModal').modal('show');
                isEditMode = true;
                editCategoryId = categoryId;
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function () {
            toastr.error('Error al cargar los detalles de la categoría.', 'Error');
        }
    });
}

function deleteCategory(categoryId) {
    Swal.fire({
        title: '¿Eliminar categoría?',
        text: 'Esta acción desactivará la categoría.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: '/Categorias/DeleteCategoria',
                type: 'POST',
                data: { id: categoryId },
                success: function (response) {
                    if (response.success) {
                        loadCategories();
                        toastr.success(response.message, 'Éxito');
                        
                        // OPTIMIZACIÓN: Invalidar caché de categorías
                        if (typeof invalidateCategoriesCache === 'function') {
                            invalidateCategoriesCache();
                        }
                    } else {
                        toastr.error(response.message, 'Error');
                    }
                },
                error: function () {
                    toastr.error('Error al eliminar la categoría.', 'Error');
                }
            });
        }
    });
}

// ============================================
// ✅ NUEVA FUNCIÓN: REACTIVAR CATEGORÍA
// ============================================
function reactivateCategory(categoryId, categoryName) {
    // Validar ID
    if (!categoryId || categoryId <= 0) {
        toastr.error('ID de categoría inválido', 'Error');
        return;
    }

    Swal.fire({
        title: `¿Reactivar "${categoryName}"?`,
        text: 'Esta acción volverá a activar la categoría.',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: '<i class="fas fa-undo me-1"></i>Sí, reactivar',
        cancelButtonText: '<i class="fas fa-times me-1"></i>Cancelar',
        showLoaderOnConfirm: true,
        preConfirm: () => {
            return $.ajax({
                url: '/Categorias/ReactivarCategoria',
                type: 'POST',
                data: { id: categoryId },
                timeout: 30000
            }).then(response => {
                if (response.success) {
                    return response;
                } else {
                    throw new Error(response.message || 'Error al reactivar la categoría');
                }
            }).catch(error => {
                let errorMessage = 'Error al reactivar la categoría';
                
                if (error.status === 403) {
                    errorMessage = 'No tiene permisos para reactivar esta categoría';
                } else if (error.status === 404) {
                    errorMessage = 'La categoría no existe';
                } else if (error.responseJSON && error.responseJSON.message) {
                    errorMessage = error.responseJSON.message;
                } else if (error.message) {
                    errorMessage = error.message;
                }
                
                Swal.showValidationMessage(errorMessage);
            });
        },
        allowOutsideClick: () => !Swal.isLoading()
    }).then((result) => {
        if (result.isConfirmed && result.value) {
            const response = result.value;
            
            // Recargar tabla
            loadCategories().then(() => {
                toastr.success(
                    response.message || 'Categoría reactivada exitosamente',
                    'Éxito',
                    {
                        timeOut: 3000,
                        progressBar: true
                    }
                );
                
                // Invalidar caché de categorías en subcategorías
                if (typeof invalidateCategoriesCache === 'function') {
                    invalidateCategoriesCache();
                }
                
                // Si el filtro es "inactivos", al reactivar debería desaparecer de la lista
                // Si es "todos", se debe actualizar el estado visualmente
                if (filterStatus !== 'inactivos') {
                    setTimeout(() => {
                        const $row = $(`tr[data-category-id="${categoryId}"]`);
                        if ($row.length > 0) {
                            $row.removeClass('table-secondary').addClass('table-success');
                            setTimeout(() => {
                                $row.removeClass('table-success');
                            }, 2000);
                        }
                    }, 500);
                }
            });

            console.log('Categoría reactivada:', { categoryId, categoryName, response });
        }
    });
}

// ============================================
// ✅ NUEVA FUNCIÓN: LIMPIAR FILTROS
// ============================================
function limpiarFiltros() {
    // Limpiar input de búsqueda
    $('#searchInput').val('');
    
    // Resetear variables globales
    searchTerm = '';
    filterStatus = 'activos';
    currentPage = 1;
    
    // Restablecer filtro de estado a "activos"
    $('#filterStatus').val('activos');
    
    // Mostrar notificación
    toastr.info('Filtros restablecidos. Mostrando todas las categorías activas.', 'Filtros Limpiados', {
        timeOut: 2000
    });
    
    // Recargar categorías
    loadCategories();
}

function viewCategoryDetails(categoryId) {
    $.ajax({
        url: '/Categorias/GetCategoriaDetalle',
        type: 'GET',
        data: { id: categoryId },
        success: function (response) {
            if (response.success) {
                var category = response.data;
                
                // Información principal
                $('#viewCategoryId').text(category.id);
                $('#viewCategoryName').text(category.nombre);
                $('#viewCategoryDescription').text(category.descripcion || 'Sin descripción disponible');
                
                // Badge de estado con clases Bootstrap
                var activeElement = $('#viewCategoryActive');
                if (category.activo) {
                    activeElement.text('Activo');
                    activeElement.removeClass('bg-secondary').addClass('bg-success');
                } else {
                    activeElement.text('Inactivo');
                    activeElement.removeClass('bg-success').addClass('bg-secondary');
                }
                
                // Estadísticas
                $('#viewCategorySubcategories').text(category.totalSubcategorias || '0');
                
                // Información de Registro (quien creó y cuándo)
                $('#viewCategoryCreator').text(category.usuarioCreacion || 'Sistema');
                $('#viewCategoryCreationDate').text(category.fechaCreacion || '--/--/----');
                
                // Configurar botón de editar desde el modal de vista
                $('#btnEditCategoryFromView').off('click').on('click', function() {
                    $('#viewCategoryModal').modal('hide');
                    setTimeout(function() {
                        loadCategoryDetails(categoryId);
                    }, 300);
                });
                
                // Mostrar el modal
                $('#viewCategoryModal').modal('show');
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function () {
            toastr.error('Error al cargar los detalles de la categoría.', 'Error');
        }
    });
}

function escapeHtml(text) {
    var map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return (text || '').replace(/[&<>"']/g, function (m) { return map[m]; });
}

// Exponer funciones globales si es necesario
window.invalidateCategoriesCache = function () {
    console.log('🗑️ Caché de categorías invalidado (llamado desde subcategorías)');
    // Si implementas caché localStorage en el futuro, invalidarlo aquí
    loadCategories();
};