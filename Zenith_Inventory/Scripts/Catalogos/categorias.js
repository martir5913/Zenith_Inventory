var currentPage = 1;
var pageSize = 10;
var searchTerm = '';
var isEditMode = false;
var editCategoryId = null;

$(document).ready(function () {
    loadCategories();

    $('#searchInput').on('input', function () {
        searchTerm = $(this).val().trim();
        currentPage = 1;
        loadCategories();
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
    $.ajax({
        url: '/Categorias/GetCategorias',
        type: 'GET',
        data: {
            page: currentPage,
            pageSize: pageSize,
            search: searchTerm
        },
        success: function (response) {
            if (response.success) {
                populateCategoriesTable(response.data.items);
                populatePagination(response.data.pagination);
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function () {
            toastr.error('Error al cargar las categorías.', 'Error');
        }
    });
}

function populateCategoriesTable(categories = []) {
    var tbody = $('#categoriesBody');
    tbody.empty();

    if (categories.length === 0) {
        tbody.append('<tr><td colspan="6" class="text-center">No se encontraron categorías.</td></tr>');
        return;
    }

    categories.forEach(function (category) {
        var row = '<tr>' +
            '<td>' + category.IdCategoria + '</td>' +
            '<td>' + escapeHtml(category.Nombre) + '</td>' +
            '<td>' + escapeHtml(category.Descripcion || '') + '</td>' +
            '<td><span class="badge ' + (category.Activo ? 'badge-success' : 'badge-secondary') + '">' + (category.Activo ? 'Activo' : 'Inactivo') + '</span></td>' +
            '<td class="text-center"><span class="subcategory-count">' + category.TotalSubcategorias + '</span></td>' +
            '<td class="action-buttons">' +
            '<button class="btn btn-info btn-sm btn-icon-only view-category-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Ver detalles" data-id="' + category.IdCategoria + '"><i class="fas fa-eye"></i></button> ' +
            '<button class="btn btn-warning btn-sm btn-icon-only edit-category-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Editar" data-id="' + category.IdCategoria + '"><i class="fas fa-edit"></i></button> ' +
            '<button class="btn btn-danger btn-sm btn-icon-only delete-category-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Eliminar" data-id="' + category.IdCategoria + '"><i class="fas fa-trash"></i></button>' +
            '</td>' +
            '</tr>';
        tbody.append(row);
    });

    // Initialize tooltips for new buttons
    $('[data-bs-toggle="tooltip"]').tooltip();
}

function populatePagination(pagination) {
    var container = $('#paginationContainer');
    container.empty();

    if (pagination.totalPages <= 1) {
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
                url: '/Categorias/DeleteCategoria',
                type: 'POST',
                data: { id: categoryId },
                success: function (response) {
                    if (response.success) {
                        loadCategories();
                        toastr.success(response.message, 'Éxito');
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