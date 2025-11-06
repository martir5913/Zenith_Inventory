let currentPage = 1;
let pageSize = 10;
let searchTerm = '';
let filterCategoryId = '';
let filterStatus = '';
let isEditMode = false;
let editSubcategoryId = null;

$(document).ready(function () {
    loadCategoriesForSelect();
    loadCategoriesForFilter();
    loadSubcategories();

    $('#searchInput').on('input', function () {
        searchTerm = $(this).val().trim();
        currentPage = 1;
        loadSubcategories();
    });

    $('#filterCategory').on('change', function () {
        filterCategoryId = $(this).val();
        currentPage = 1;
        loadSubcategories();
    });

    $('#filterStatus').on('change', function () {
        filterStatus = $(this).val();
        currentPage = 1;
        loadSubcategories();
    });

    $('#btnAddSubcategory').click(function () {
        resetModal();
        $('#subcategoryModalLabel').text('Agregar Subcategoría');
        $('#modalIcon').removeClass('fa-edit').addClass('fa-plus');
        $('#subcategoryModal').modal('show');
        isEditMode = false;
        
        // Inicializar Select2 cuando se abre el modal
        setTimeout(function() {
            const select = $('#subcategoryCategory');
            if (!select.hasClass('select2-hidden-accessible')) {
                if (typeof select.select2 === 'function') {
                    select.select2({
                        placeholder: 'Seleccione una categoría',
                        allowClear: true,
                        width: '100%',
                        dropdownParent: $('#subcategoryModal')
                    });
                    console.log('Select2 initialized in modal');
                }
            }
        }, 100);
    });

    $('#btnSaveSubcategory').click(function () {
        saveSubcategory();
    });

    $(document).on('click', '.edit-subcategory-btn', function () {
        const subcategoryId = $(this).data('id');
        loadSubcategoryDetails(subcategoryId);
    });

    $(document).on('click', '.delete-subcategory-btn', function () {
        const subcategoryId = $(this).data('id');
        deleteSubcategory(subcategoryId);
    });

    $(document).on('click', '.view-subcategory-btn', function () {
        const subcategoryId = $(this).data('id');
        viewSubcategoryDetails(subcategoryId);
    });

    $(document).on('click', '.page-link', function (e) {
        e.preventDefault();
        currentPage = $(this).data('page');
        loadSubcategories();
    });
});

function loadCategoriesForSelect() {
    console.log('Loading categories for select...');
    $.ajax({
        url: '/Categorias/GetCategorias',
        type: 'GET',
        data: {
            page: 1,
            pageSize: 100,
            search: ''
        },
        success: function (response) {
            console.log('Categories response:', response);
            if (response.success) {
                const select = $('#subcategoryCategory');
                select.empty();
                select.append('<option value="">Seleccione una categoría</option>');
                response.data.items.forEach(function (data) {
                    console.log('Appending option:', data.IdCategoria, data.Nombre);
                    select.append('<option value="' + data.IdCategoria + '">' + escapeHtml(data.Nombre) + '</option>');
                });
                console.log('All options appended, total options:', select.find('option').length);
                // Select2 will be initialized when modal opens
                console.log('Select options loaded, ready for Select2');
            } else {
                console.error('Error in response:', response.message);
                toastr.error(response.message, 'Error');
            }
        },
        error: function (xhr, status, error) {
            console.error('AJAX error:', xhr, status, error);
            toastr.error('Error al cargar las categorías.', 'Error');
        }
    });
}

function detalleSubCategoria(idSubCat) {
    $.ajax({
        url: '/SubCategorias/DetalleSubCat',
        type: 'GET',
        data: { id: idSubCat },
        success: function (response) {
            if (response.success) {
                const data = response.data;
                
                // Información principal
                $('#viewSubcategoryId').text(data.idSubCat);
                $('#viewSubcategoryName').text(data.nombre);
                $('#viewSubcategoryCategory').text(data.nombreCat);
                $('#viewSubcategoryDescription').text(data.descripcion || 'Sin descripción disponible');
                
                // Badge de estado con clases Bootstrap
                const activeElement = $('#viewSubcategoryActive');
                if (data.estado) {
                    activeElement.text('Activo');
                    activeElement.removeClass('bg-secondary').addClass('bg-success');
                } else {
                    activeElement.text('Inactivo');
                    activeElement.removeClass('bg-success').addClass('bg-secondary');
                }
                
                // Estadísticas
                $('#viewSubcategoryModelsCount').text(data.totalModelos || '0');
                
                // Información de Registro (quien creó y cuándo)
                $('#viewSubcategoryCreator').text(data.usuarioCreacion || 'Sistema');
                $('#viewSubcategoryCreationDate').text(data.fechaCreacion || '--/--/----');
                
                // Configurar botón de editar desde el modal de vista
                $('#btnEditFromView').off('click').on('click', function() {
                    $('#viewSubcategoryModal').modal('hide');
                    setTimeout(function() {
                        loadSubcategoryDetails(idSubCat);
                    }, 300);
                });
                
                // Mostrar el modal
                $('#viewSubcategoryModal').modal('show');
            } else {
                console.error('Error en respuesta: ', response.message);
                toastr.error(response.message, 'Error');
            }
        },
        error: function (xhr, status, error) {
            console.error('Ajax error: ', xhr, status, error);
            toastr.error('Error al cargar la SubCategoría.', 'Error');
        }
    });
}

function loadCategoriesForFilter() {
    console.log('Loading categories for filter...');
    $.ajax({
        url: '/Categorias/GetCategorias',
        type: 'GET',
        data: {
            page: 1,
            pageSize: 100,
            search: ''
        },
        success: function (response) {
            console.log('Filter categories response:', response);
            if (response.success) {
                const select = $('#filterCategory');
                select.empty();
                select.append('<option value="">Todas las categorías</option>');
                response.data.items.forEach(function (category) {
                    select.append('<option value="' + category.IdCategoria + '">' + escapeHtml(category.Nombre) + '</option>');
                });
                console.log('Filter select populated');
                
                // Initialize Select2 for filter
                if (typeof select.select2 === 'function') {
                    select.select2({
                        placeholder: 'Todas las categorías',
                        allowClear: true,
                        width: '100%'
                    });
                    console.log('Filter Select2 initialized');
                } else {
                    console.error('Select2 not loaded for filter');
                }
            } else {
                console.error('Error in filter response:', response.message);
                toastr.error(response.message, 'Error');
            }
        },
        error: function () {
            console.error('AJAX error for filter');
            toastr.error('Error al cargar las categorías para filtro.', 'Error');
        }
    });
}

function loadSubcategories() {
    $.ajax({
        url: '/SubCategorias/GetSubcategorias',
        type: 'GET',
        data: {
            page: currentPage,
            pageSize: pageSize,
            search: searchTerm,
            idCategoria: filterCategoryId,
           activo: filterStatus
        },
        success: function (response) {
            if (response.success) {
                populateSubcategoriesTable(response.data.items);
                populatePagination(response.data.pagination);
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function () {
            toastr.error('Error al cargar las subcategorías.', 'Error');
        }
    });
}

function populateSubcategoriesTable(subcategories) {
    const tbody = $('#subcategoriesBody');
    tbody.empty();

    if (subcategories.length === 0) {
        tbody.append('<tr><td colspan="6" class="text-center">No se encontraron subcategorías.</td></tr>');
        return;
    }

    subcategories.forEach(function (subcategory) {
        let row = '<tr>' +
            '<td>' + subcategory.IdSubCategoria + '</td>' +
            '<td>' + escapeHtml(subcategory.Nombre) + '</td>' +
            '<td>' + escapeHtml(subcategory.Descripcion || '') + '</td>' +
            '<td>' + escapeHtml(subcategory.NombreCategoria) + '</td>' +
            '<td><span class="badge ' + (subcategory.Estado ? 'badge-success' : 'badge-secondary') + '">' + (subcategory.Estado ? 'Activo' : 'Inactivo') + '</span></td>' +
            '<td class="text-center"><span class="marcas-count">' + subcategory.totalMarcas + '</span></td>' +
            '<td class="action-buttons">' +
            '<button class="btn btn-info btn-sm btn-icon-only view-subcategory-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Ver detalles" data-id="' + subcategory.IdSubCategoria + '"><i class="fas fa-eye"></i></button> ' +
            '<button class="btn btn-warning btn-sm btn-icon-only edit-subcategory-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Editar" data-id="' + subcategory.IdSubCategoria + '"><i class="fas fa-edit"></i></button> ' +
            '<button class="btn btn-danger btn-sm btn-icon-only delete-subcategory-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Eliminar" data-id="' + subcategory.IdSubCategoria + '"><i class="fas fa-trash"></i></button>' +
            '</td>' +
            '</tr>';
        tbody.append(row);
    });

    // Initialize tooltips for new buttons
    $('[data-bs-toggle="tooltip"]').tooltip();
}

function populatePagination(pagination) {
    const container = $('#paginationContainer');
    container.empty();

    if (pagination.totalPages <= 1) {
        return;
    }

    const ul = $('<ul class="pagination"></ul>');

    if (pagination.hasPreviousPage) {
        ul.append('<li class="page-item"><a class="page-link" href="#" data-page="' + (pagination.currentPage - 1) + '">Anterior</a></li>');
    }

    for (let i = Math.max(1, pagination.currentPage - 2); i <= Math.min(pagination.totalPages, pagination.currentPage + 2); i++) {
        const activeClass = (i === pagination.currentPage) ? ' active' : '';
        ul.append('<li class="page-item' + activeClass + '"><a class="page-link" href="#" data-page="' + i + '">' + i + '</a></li>');
    }

    if (pagination.hasNextPage) {
        ul.append('<li class="page-item"><a class="page-link" href="#" data-page="' + (pagination.currentPage + 1) + '">Siguiente</a></li>');
    }

    container.append(ul);
}

function resetModal() {
    $('#subcategoryForm')[0].reset();
    $('#subcategoryActive').prop('checked', true);
    $('#subcategoryCategory').val('').trigger('change'); // Reset Select2
}

function saveSubcategory() {
    const name = $('#subcategoryName').val().trim();
    const categoryId = $('#subcategoryCategory').val();
    const description = $('#subcategoryDescription').val().trim();
    const active = $('#subcategoryActive').is(':checked');

    if (!name) {
        toastr.warning('El nombre de la subcategoría es obligatorio.', 'Validación');
        return;
    }

    if (!categoryId) {
        toastr.warning('Debe seleccionar una categoría.', 'Validación');
        return;
    }

    const url = isEditMode ? '/SubCategorias/UpdateSubcategoria' : '/SubCategorias/CreateSubcategoria';
    const data = isEditMode ?
        { id: editSubcategoryId, nombre: name, idCategoria: categoryId, descripcion: description, activo: active } :
        { nombre: name, idCategoria: categoryId, descripcion: description, activo: active };

    $.ajax({
        url: url,
        type: 'POST',
        data: data,
        success: function (response) {
            console.log('Save subcategory success response:', response);
            if (response.success) {
                $('#subcategoryModal').modal('hide');
                loadSubcategories();
                toastr.success(response.message, 'Éxito');
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function (xhr, status, error) {
            console.log('Save subcategory error:', xhr, status, error);
            toastr.error('Error al guardar la subcategoría.', 'Error');
        }
    });
}

function loadSubcategoryDetails(subcategoryId) {
    $.ajax({
        url: '/SubCategorias/DetalleSubCat',
        type: 'GET',
        data: { id: subcategoryId },
        success: function (response) {
            if (response.success) {
                const subcategory = response.data;
                $('#subcategoryName').val(subcategory.nombre);
                $('#subcategoryDescription').val(subcategory.descripcion);
                $('#subcategoryActive').prop('checked', subcategory.estado);
                $('#subcategoryModalLabel').text('Editar Subcategoría');
                $('#modalIcon').removeClass('fa-plus').addClass('fa-edit');
                
                // Mostrar el modal primero
                $('#subcategoryModal').modal('show');
                
                // Inicializar Select2 y establecer el valor
                setTimeout(function() {
                    const select = $('#subcategoryCategory');
                    if (!select.hasClass('select2-hidden-accessible')) {
                        if (typeof select.select2 === 'function') {
                            select.select2({
                                placeholder: 'Seleccione una categoría',
                                allowClear: true,
                                width: '100%',
                                dropdownParent: $('#subcategoryModal')
                            });
                        }
                    }
                    // Establecer el valor después de inicializar Select2
                    select.val(subcategory.idCat).trigger('change');
                }, 100);
                
                isEditMode = true;
                editSubcategoryId = subcategoryId;
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function () {
            toastr.error('Error al cargar los detalles de la subcategoría.', 'Error');
        }
    });
}

function deleteSubcategory(subcategoryId) {
    Swal.fire({
        title: '¿Eliminar subcategoría?',
        text: 'Esta acción no se puede deshacer.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: '/SubCategorias/DeleteSubcategoria',
                type: 'POST',
                data: { id: subcategoryId },
                success: function (response) {
                    if (response.success) {
                        loadSubcategories();
                        toastr.success(response.message, 'Éxito');
                    } else {
                        toastr.error(response.message, 'Error');
                    }
                },
                error: function () {
                    toastr.error('Error al eliminar la subcategoría.', 'Error');
                }
            });
        }
    });
}

function viewSubcategoryDetails(subcategoryId) {
    detalleSubCategoria(subcategoryId);
}

function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return (text || '').replace(/[&<>"']/g, function (m) { return map[m]; });
}