let currentPage = 1;
let pageSize = 10;
let searchTerm = '';
let filterCategoryId = '';
let filterStatus = '';
let isEditMode = false;
let editSubcategoryId = null;

// OPTIMIZACIÓN: Caché de categorías
let cachedCategories = null;
const CACHE_KEY = 'zenith_categories';
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutos

// OPTIMIZACIÓN: Configuración centralizada de Select2
const select2DefaultConfig = {
    placeholder: 'Seleccione una categoría',
    allowClear: true,
    width: '100%',
    language: {
        noResults: function() {
            return "No se encontraron resultados";
        },
        searching: function() {
            return "Buscando...";
        }
    }
};

$(document).ready(function () {
    // OPTIMIZACIÓN: Cargar datos en paralelo usando Promise.all
    console.time('Carga Inicial Total');
    
    Promise.all([
        loadCategoriesOnce(),    // Una sola carga de categorías
        loadSubcategories()      // Cargar subcategorías en paralelo
    ]).then(() => {
        console.timeEnd('Carga Inicial Total');
        console.log('✅ Datos iniciales cargados exitosamente');
    }).catch(error => {
        console.error('❌ Error al cargar datos iniciales:', error);
        toastr.error('Error al cargar los datos iniciales.', 'Error');
    });

    // Event Handlers
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
            initializeSelect2('#subcategoryCategory', {
                dropdownParent: $('#subcategoryModal')
            });
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

// OPTIMIZACIÓN: Función centralizada para inicializar Select2
function initializeSelect2(selector, additionalOptions = {}) {
    const $element = $(selector);
    
    // Destruir instancia existente si existe
    if ($element.hasClass('select2-hidden-accessible')) {
        $element.select2('destroy');
    }
    
    // Combinar configuración por defecto con opciones adicionales
    const config = { ...select2DefaultConfig, ...additionalOptions };
    
    // Inicializar Select2
    if (typeof $element.select2 === 'function') {
        $element.select2(config);
        return true;
    } else {
        console.error('Select2 no está disponible');
        return false;
    }
}

// OPTIMIZACIÓN: Funciones de caché localStorage
function getCachedCategories() {
    try {
        const cached = localStorage.getItem(CACHE_KEY);
        if (cached) {
            const {data, timestamp} = JSON.parse(cached);
            if (Date.now() - timestamp < CACHE_DURATION) {
                console.log('✅ Usando categorías desde caché');
                return data;
            } else {
                console.log('⏰ Caché expirado, recargando...');
                localStorage.removeItem(CACHE_KEY);
            }
        }
    } catch (error) {
        console.error('Error al leer caché:', error);
        localStorage.removeItem(CACHE_KEY);
    }
    return null;
}

function setCachedCategories(data) {
    try {
        localStorage.setItem(CACHE_KEY, JSON.stringify({
            data: data,
            timestamp: Date.now()
        }));
        console.log('✅ Categorías guardadas en caché');
    } catch (error) {
        console.error('Error al guardar en caché:', error);
    }
}

function invalidateCategoriesCache() {
    localStorage.removeItem(CACHE_KEY);
    cachedCategories = null;
    console.log('🗑️ Caché de categorías invalidado');
}

// OPTIMIZACIÓN: Cargar categorías una sola vez (eliminando duplicación)
function loadCategoriesOnce() {
    console.time('loadCategoriesOnce');
    
    return new Promise((resolve, reject) => {
        // Verificar caché en memoria
        if (cachedCategories) {
            console.log('✅ Usando categorías desde memoria');
            populateCategorySelects(cachedCategories);
            console.timeEnd('loadCategoriesOnce');
            resolve(cachedCategories);
            return;
        }
        
        // Verificar caché localStorage
        const cached = getCachedCategories();
        if (cached) {
            cachedCategories = cached;
            populateCategorySelects(cachedCategories);
            console.timeEnd('loadCategoriesOnce');
            resolve(cachedCategories);
            return;
        }
        
        // Si no hay caché, cargar desde servidor
        console.log('🌐 Cargando categorías desde servidor...');
        $.ajax({
            url: '/Categorias/GetCategorias',
            type: 'GET',
            data: {
                page: 1,
                pageSize: 100,
                search: ''
            },
            success: function (response) {
                console.timeEnd('loadCategoriesOnce');
                if (response.success) {
                    cachedCategories = response.data.items;
                    setCachedCategories(cachedCategories);
                    populateCategorySelects(cachedCategories);
                    resolve(cachedCategories);
                } else {
                    console.error('Error en respuesta:', response.message);
                    toastr.error(response.message, 'Error');
                    reject(response.message);
                }
            },
            error: function (xhr, status, error) {
                console.timeEnd('loadCategoriesOnce');
                console.error('AJAX error:', xhr, status, error);
                toastr.error('Error al cargar las categorías.', 'Error');
                reject(error);
            }
        });
    });
}

// OPTIMIZACIÓN: Poblar ambos selects con las mismas categorías
function populateCategorySelects(categories) {
    // Poblar select del modal
    const modalSelect = $('#subcategoryCategory');
    modalSelect.empty();
    modalSelect.append('<option value="">Seleccione una categoría</option>');
    
    // Poblar select del filtro
    const filterSelect = $('#filterCategory');
    filterSelect.empty();
    filterSelect.append('<option value="">Todas las categorías</option>');
    
    // Agregar opciones a ambos selects
    categories.forEach(function (category) {
        const option = '<option value="' + category.IdCategoria + '">' + escapeHtml(category.Nombre) + '</option>';
        modalSelect.append(option);
        filterSelect.append(option);
    });
    
    // Inicializar Select2 en el filtro
    initializeSelect2('#filterCategory');
    
    console.log(`✅ ${categories.length} categorías cargadas en ambos selects`);
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
                
                // Estadísticas - CORRECCIÓN: totalModelos en lugar de totalMarcas
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

function loadSubcategories() {
    console.time('loadSubcategories');
    return new Promise((resolve, reject) => {
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
                console.timeEnd('loadSubcategories');
                if (response.success) {
                    populateSubcategoriesTable(response.data.items);
                    populatePagination(response.data.pagination);
                    resolve(response);
                } else {
                    toastr.error(response.message, 'Error');
                    reject(response.message);
                }
            },
            error: function (xhr, status, error) {
                console.timeEnd('loadSubcategories');
                toastr.error('Error al cargar las subcategorías.', 'Error');
                reject(error);
            }
        });
    });
}

function populateSubcategoriesTable(subcategories) {
    const tbody = $('#subcategoriesBody');
    tbody.empty();

    if (subcategories.length === 0) {
        tbody.append('<tr><td colspan="7" class="text-center">No se encontraron subcategorías.</td></tr>');
        return;
    }

    subcategories.forEach(function (subcategory) {
        let row = '<tr>' +
            '<td>' + subcategory.IdSubCategoria + '</td>' +
            '<td>' + escapeHtml(subcategory.Nombre) + '</td>' +
            '<td>' + escapeHtml(subcategory.Descripcion || '') + '</td>' +
            '<td>' + escapeHtml(subcategory.NombreCategoria) + '</td>' +
            '<td><span class="badge ' + (subcategory.Estado ? 'badge-success' : 'badge-secondary') + '">' + (subcategory.Estado ? 'Activo' : 'Inactivo') + '</span></td>' +
            '<td class="text-center"><span class="modelos-count">' + subcategory.TotalModelos + '</span></td>' +
            '<td class="action-buttons">' +
            '<button class="btn btn-info btn-sm btn-icon-only view-subcategory-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Ver detalles" data-id="' + subcategory.IdSubCategoria + '"><i class="fas fa-eye"></i></button> ' +
            '<button class="btn btn-warning btn-sm btn-icon-only edit-subcategory-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Editar" data-id="' + subcategory.IdSubCategoria + '"><i class="fas fa-edit"></i></button> ' +
            '<button class="btn btn-danger btn-sm btn-icon-only delete-subcategory-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="Eliminar" data-id="' + subcategory.IdSubCategoria + '"><i class="fas fa-trash"></i></button>' +
            '</td>' +
            '</tr>';
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
    const select = $('#subcategoryCategory');
    select.val('').trigger('change'); // Reset Select2
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

    const url = isEditMode ? '/SubCategorias/UpdateSubCategoria' : '/SubCategorias/CreateSubcategoria';
    const data = isEditMode ?
        { id: editSubcategoryId, nombre: name, idCategoria: categoryId, descripcion: description, activo: active } :
        { nombre: name, idCat: categoryId, descripcion: description, activo: active };

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
                    initializeSelect2('#subcategoryCategory', {
                        dropdownParent: $('#subcategoryModal')
                    });
                    // Establecer el valor después de inicializar Select2
                    $('#subcategoryCategory').val(subcategory.idCat).trigger('change');
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