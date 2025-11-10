// ============================================
// GESTIÓN DE PERMISOS - permisos.js
// ============================================

// Variables globales para permisos
let permisosCurrentPage = 1;
let permisosPageSize = 10;
let permisosSearchTerm = '';
let permisosFilterModulo = '';
let permisosFilterAccion = '';
let permisosFilterStatus = 'activos';
let isPermisosEditMode = false;
let editPermisoId = null;

// OPTIMIZACIÓN: Caché de módulos y acciones
let cachedModulos = null;
let cachedAcciones = null;
const PERMISOS_CACHE_DURATION = 5 * 60 * 1000; // 5 minutos

// ============================================
// INICIALIZACIÓN
// ============================================

$(document).ready(function () {
    console.log('✅ Inicializando gestión de permisos...');
    
    // ✅ DIAGNÓSTICO: Verificar que el elemento existe
    const searchInput = $('#searchPermisos');
    if (searchInput.length === 0) {
        console.error('❌ ERROR: No se encontró el elemento #searchPermisos');
        toastr.error('Error al inicializar búsqueda de permisos', 'Error Crítico');
        return;
    }
    
    // Cargar catálogos y permisos al iniciar
    cargarCatalogosPermisos();
    cargarPermisos();

    // ✅ Event Handler SIMPLE para búsqueda con protección defensiva
    searchInput.on('input', debounce(function (event) {
        // ✅ PROTECCIÓN: Asegurar que tenemos el elemento correcto
        const elemento = event.target || this;
        const valor = (elemento.value || '').trim();
        
        permisosSearchTerm = valor;
        permisosCurrentPage = 1;
        cargarPermisos();
    }, 500));
    
    // ✅ FALLBACK: Búsqueda con Enter con protección defensiva
    searchInput.on('keyup', function (e) {
        if (e.key === 'Enter') {
            // ✅ PROTECCIÓN: Usar event.target en lugar de this
            const elemento = e.target || this;
            const valor = (elemento.value || '').trim();
            
            permisosSearchTerm = valor;
            permisosCurrentPage = 1;
            cargarPermisos();
        }
    });

    // Event handlers para filtros SELECT (con Select2)
    $('#filterPermisosModulo').on('change', function () {
        permisosFilterModulo = $(this).val() || '';
        permisosCurrentPage = 1;
        cargarPermisos();
    });

    $('#filterPermisosAccion').on('change', function () {
        permisosFilterAccion = $(this).val() || '';
        permisosCurrentPage = 1;
        cargarPermisos();
    });

    $('#filterPermisosStatus').on('change', function () {
        permisosFilterStatus = $(this).val();
        permisosCurrentPage = 1;
        cargarPermisos();
    });

    // Event Handlers - Botones de Acción
    $('#btnClearFilters').on('click', function () {
        limpiarFiltrosPermisos();
    });

    $('#btnRefreshPermisos').on('click', function () {
        const icon = $(this).find('i');
        icon.addClass('fa-spin');
        cargarPermisos().finally(() => {
            icon.removeClass('fa-spin');
        });
    });

    $('#btnAddPermiso').on('click', function () {
        abrirModalCrearPermiso();
    });

    $('#btnSavePermiso').on('click', function () {
        guardarPermiso();
    });

    // Event Handlers - Tabla de Permisos (delegación de eventos)
    $(document).on('click', '.view-permiso-btn', function () {
        const permisoId = $(this).data('id');
        verDetallesPermiso(permisoId);
    });

    $(document).on('click', '.edit-permiso-btn', function () {
        const permisoId = $(this).data('id');
        editarPermiso(permisoId);
    });

    $(document).on('click', '.delete-permiso-btn', function () {
        const permisoId = $(this).data('id');
        eliminarPermiso(permisoId);
    });

    // Event Handler - Editar desde modal de detalles
    $('#btnEditPermisoFromView').on('click', function () {
        const permisoId = $('#viewPermisoId').text();
        $('#viewPermisoModal').modal('hide');
        setTimeout(() => editarPermiso(permisoId), 300);
    });

    // Event Handlers - Paginación (delegación)
    $(document).on('click', '#paginationPermisosContainer .page-link', function (e) {
        e.preventDefault();
        permisosCurrentPage = $(this).data('page');
        cargarPermisos();
    });
    
    // ✅ VERIFICACIÓN: Asegurar que Select2 NO se aplicó al input de búsqueda
    if (searchInput.hasClass('select2-hidden-accessible')) {
        console.error('❌ ADVERTENCIA: Select2 se aplicó incorrectamente a #searchPermisos');
        searchInput.select2('destroy');
    }
    
    console.log('✅ Inicialización completada');
});

// ============================================
// FUNCIONES DE CARGA DE DATOS
// ============================================

function cargarPermisos() {
    return new Promise((resolve, reject) => {
        // ✅ FIX: Corregir lógica del filtro de estado
        let incluirInactivos = false;
        let soloInactivos = false;
        
        if (permisosFilterStatus === 'todos') {
            incluirInactivos = true;
        } else if (permisosFilterStatus === 'inactivos') {
            incluirInactivos = true;
            soloInactivos = true;
        }

        $.ajax({
            url: '/Permisos/GetPermisos',
            type: 'GET',
            data: {
                page: permisosCurrentPage,
                pageSize: permisosPageSize,
                search: permisosSearchTerm,
                incluirInactivos: incluirInactivos,
                modulo: permisosFilterModulo,
                accion: permisosFilterAccion
            },
            success: function (response) {
                // Detectar si la respuesta es HTML (página de error)
                if (typeof response === 'string' && (response.includes('<!DOCTYPE') || response.includes('<html') || response.includes('Acceso Denegado'))) {
                    console.error('❌ Acceso denegado o error de autenticación');
                    
                    const errorMsg = 'Acceso Denegado: No tiene permisos para ver esta sección';
                    
                    $('#permisosBody').html(`
                        <tr>
                            <td colspan="7" class="text-center py-5">
                                <div class="error-container" style="padding: 3rem; background: white; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.1);">
                                    <div class="error-icon" style="animation: pulse 2s infinite;">
                                        <i class="bi bi-shield-exclamation" style="font-size: 5rem; color: #dc3545;"></i>
                                    </div>
                                    <h4 class="mt-4">Acceso Denegado</h4>
                                    <p class="lead text-muted">No tiene los permisos necesarios para acceder a este recurso.</p>
                                    <hr class="my-4">
                                    <p class="mb-3">
                                        <strong>Solución:</strong> Ejecutar script SQL de configuración
                                    </p>
                                    <div class="text-start mx-auto" style="max-width: 600px;">
                                        <ol class="small">
                                            <li>Abrir archivo: <code>004_B_Acceso_Rapido_Usuario.sql</code></li>
                                            <li>Cambiar línea 11: <code>DECLARE @Username = 'su_usuario';</code></li>
                                            <li>Ejecutar script en SQL Server Management Studio</li>
                                            <li>Cerrar sesión y volver a iniciar sesión</li>
                                        </ol>
                                    </div>
                                    <p class="mt-3 mb-0 text-muted small">
                                        <i class="bi bi-info-circle me-1"></i>
                                        Si el problema persiste, contacte al administrador del sistema.
                                    </p>
                                </div>
                            </td>
                        </tr>
                    `);
                    
                    toastr.error('No tiene permisos para ver permisos. Ejecute el script de configuración.', 'Acceso Denegado', {
                        timeOut: 8000,
                        extendedTimeOut: 3000,
                        closeButton: true,
                        progressBar: true
                    });
                    
                    reject(errorMsg);
                    return;
                }
                
                if (response && response.success && response.data) {
                    // ✅ FIX: Filtrar en cliente si solo queremos inactivos
                    let items = response.data.items || [];
                    let pagination = response.data.pagination;
                    
                    if (soloInactivos) {
                        items = items.filter(p => !p.activo);
						
						// ✅ FIX: Ajustar la paginación cuando filtramos en cliente
						if (items.length === 0) {
							pagination = null;
							toastr.info('No se encontraron permisos inactivos', 'Información', {
								timeOut: 3000
							});
						} else {
							pagination = {
								currentPage: 1,
								pageSize: items.length,
								totalRecords: items.length,
								totalPages: 1,
								hasPreviousPage: false,
								hasNextPage: false
							};
						}
                    }
                    
                    poblarTablaPermisos(items);
                    poblarPaginacionPermisos(pagination);
                    resolve(response);
                } else {
                    const errorMsg = response?.message || 'Respuesta inválida del servidor';
                    console.error('❌ Error en respuesta:', errorMsg);
                    toastr.error(errorMsg, 'Error');
                    $('#permisosBody').html(`
                        <tr>
                            <td colspan="7" class="text-center text-warning py-4">
                                <i class="bi bi-exclamation-triangle" style="font-size: 3rem;"></i>
                                <p class="mt-3">${errorMsg}</p>
                            </td>
                        </tr>
                    `);
                    reject(errorMsg);
                }
            },
            error: function (xhr, status, error) {
                console.error('❌ Error AJAX al cargar permisos:', {status: xhr.status, error});
                
                let errorMsg = 'Error al cargar los permisos';
                let errorDetail = '';
                let iconClass = 'bi-exclamation-triangle';
                let iconColor = '#ffc107';
                
                // Detectar tipo de error
                if (xhr.status === 401) {
                    errorMsg = 'Sesión Expirada';
                    errorDetail = 'Por favor, inicie sesión nuevamente.';
                    iconClass = 'bi-door-closed';
                    iconColor = '#dc3545';
                } else if (xhr.status === 403) {
                    errorMsg = 'Acceso Denegado';
                    errorDetail = 'No tiene permisos para acceder a esta sección.';
                    iconClass = 'bi-shield-exclamation';
                    iconColor = '#dc3545';
                } else if (xhr.status === 404) {
                    errorMsg = 'Recurso No Encontrado';
                    errorDetail = 'La URL solicitada no existe.';
                    iconClass = 'bi-search';
                    iconColor = '#6c757d';
                } else if (xhr.status === 500) {
                    errorMsg = 'Error del Servidor';
                    errorDetail = 'Contacte al administrador del sistema.';
                    iconClass = 'bi-server';
                    iconColor = '#dc3545';
                } else {
                    errorDetail = `Status: ${xhr.status} - ${error}`;
                }
                
                toastr.error(errorDetail, errorMsg);
                
                $('#permisosBody').html(`
                    <tr>
                        <td colspan="7" class="text-center py-5">
                            <div class="error-container" style="padding: 2rem;">
                                <i class="${iconClass}" style="font-size: 4rem; color: ${iconColor};"></i>
                                <h5 class="mt-3">${errorMsg}</h5>
                                <p class="text-muted">${errorDetail}</p>
                            </div>
                        </td>
                    </tr>
                `);
                reject(error);
            }
        });
    });
}

function cargarCatalogosPermisos() {
    $.ajax({
        url: '/Permisos/GetCatalogos',
        type: 'GET',
        success: function (response) {
            // Detectar si la respuesta es HTML (página de error)
            if (typeof response === 'string' && (response.includes('<!DOCTYPE') || response.includes('<html') || response.includes('Acceso Denegado'))) {
                console.warn('⚠️ Sin permisos para cargar catálogos - filtros deshabilitados');
                toastr.warning('No tiene permisos para cargar los filtros. Algunas funciones pueden no estar disponibles.', 'Advertencia', {
                    timeOut: 5000,
                    closeButton: true
                });
                return;
            }
            
            if (response && response.success && response.data) {
                cachedModulos = response.data.modulos || [];
                cachedAcciones = response.data.acciones || [];
                poblarSelectModulos(cachedModulos);
                poblarSelectAcciones(cachedAcciones);
                poblarDatalistCatalogos(cachedModulos, cachedAcciones);
            } else {
                const errorMsg = response?.message || 'No se pudieron cargar los catálogos';
                console.error('❌ Error al cargar catálogos:', errorMsg);
                toastr.warning('No se pudieron cargar los filtros de módulos y acciones', 'Advertencia');
            }
        },
        error: function (xhr, status, error) {
            if (xhr.status === 403) {
                console.warn('⚠️ Sin permisos para cargar catálogos');
            } else {
                console.error('❌ Error AJAX al cargar catálogos:', {status: xhr.status, error});
                toastr.warning('No se pudieron cargar los filtros de módulos y acciones', 'Advertencia');
            }
        }
    });
}

// ============================================
// FUNCIONES DE RENDERIZADO
// ============================================

function poblarTablaPermisos(permisos = []) {
    const tbody = $('#permisosBody');
    tbody.empty();

    if (permisos.length === 0) {
        // ✅ Mensaje personalizado según el filtro activo
        let mensaje = 'No se encontraron permisos';
        let icono = 'fas fa-inbox';
        
        if (permisosFilterStatus === 'inactivos') {
            mensaje = 'No hay permisos inactivos';
            icono = 'fas fa-check-circle text-success';
        } else if (permisosSearchTerm) {
            mensaje = `No se encontraron resultados para "${permisosSearchTerm}"`;
            icono = 'fas fa-search';
        }
        
        tbody.html(`
            <tr>
                <td colspan="7" class="text-center text-muted py-4">
                    <i class="${icono} fa-2x mb-3"></i>
                    <p>${mensaje}</p>
                </td>
            </tr>
        `);
        return;
    }

    permisos.forEach(function (permiso) {
        const estadoBadge = permiso.activo
            ? '<span class="badge badge-success">Activo</span>'
            : '<span class="badge badge-secondary">Inactivo</span>';

        const descripcionCorta = permiso.descripcion
            ? (permiso.descripcion.length > 50 
                ? permiso.descripcion.substring(0, 50) + '...' 
                : permiso.descripcion)
            : '<span class="text-muted">Sin descripción</span>';

        const row = `
            <tr data-permiso-id="${permiso.idPermiso}">
                <td>${escapeHtml(permiso.nombre)}</td>
                <td><span class="badge bg-primary">${escapeHtml(permiso.modulo)}</span></td>
                <td><span class="badge bg-info">${escapeHtml(permiso.accion)}</span></td>
                <td><small>${descripcionCorta}</small></td>
                <td class="text-center">
                    <span class="badge bg-secondary">${permiso.totalRoles}</span>
                </td>
                <td class="text-center">${estadoBadge}</td>
                <td class="action-buttons text-center">
                    <button class="btn btn-info btn-sm btn-icon-only view-permiso-btn" 
                            data-bs-toggle="tooltip" title="Ver detalles" 
                            data-id="${permiso.idPermiso}">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn btn-warning btn-sm btn-icon-only edit-permiso-btn" 
                            data-bs-toggle="tooltip" title="Editar" 
                            data-id="${permiso.idPermiso}">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-danger btn-sm btn-icon-only delete-permiso-btn" 
                            data-bs-toggle="tooltip" title="Eliminar" 
                            data-id="${permiso.idPermiso}">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `;
        tbody.append(row);
    });

    // Inicializar tooltips lazy
    initializeLazyTooltips();
}

function poblarSelectModulos(modulos) {
    const select = $('#filterPermisosModulo');
    
    // ✅ VALIDACIÓN CRÍTICA: Solo proceder si es un elemento SELECT
    if (!select.is('select')) {
        console.error('❌ #filterPermisosModulo NO es un elemento <select>');
        return;
    }
    
    select.empty();
    select.append('<option value="">Todos los módulos</option>');

    modulos.forEach(function (modulo) {
        select.append(`<option value="${modulo.value}">${modulo.text}</option>`);
    });

    // ✅ HABILITADO: Usar Select2 en filtros
    if ($.fn.select2) {
        // Destruir instancia previa si existe
        if (select.data('select2')) {
            select.select2('destroy');
        }

        // ✅ CONFIGURACIÓN RESTRICTIVA: Solo afecta a este elemento
        select.select2({
            theme: 'bootstrap-5',
            width: '100%',
            placeholder: 'Todos los módulos',
            allowClear: true,
            dropdownParent: select.parent(),
            language: {
                noResults: function () {
                    return "No se encontraron resultados";
                },
                searching: function () {
                    return "Buscando...";
                }
            },
            matcher: function(params, data) {
                if (!params || !data) {
                    return data;
                }
                
                if (!params.term || $.trim(params.term) === '') {
                    return data;
                }

                if (typeof data.text === 'undefined' || data.text === null) {
                    return null;
                }

                try {
                    const searchTerm = String(params.term).toLowerCase();
                    const optionText = String(data.text).toLowerCase();

                    if (optionText.indexOf(searchTerm) > -1) {
                        return data;
                    }
                } catch (e) {
                    console.warn('⚠️ Error en matcher de Select2:', e);
                    return null;
                }

                return null;
            }
        });

        // Evento de limpieza
        select.off('select2:clear').on('select2:clear', function () {
            permisosFilterModulo = '';
            permisosCurrentPage = 1;
            cargarPermisos();
        });
    }
}

function poblarSelectAcciones(acciones) {
    const select = $('#filterPermisosAccion');
    
    // ✅ VALIDACIÓN CRÍTICA: Solo proceder si es un elemento SELECT
    if (!select.is('select')) {
        console.error('❌ #filterPermisosAccion NO es un elemento <select>');
        return;
    }
    
    select.empty();
    select.append('<option value="">Todas las acciones</option>');

    acciones.forEach(function (accion) {
        select.append(`<option value="${accion.value}">${accion.text}</option>`);
    });

    // ✅ HABILITADO: Usar Select2 en filtros
    if ($.fn.select2) {
        // Destruir instancia previa si existe
        if (select.data('select2')) {
            select.select2('destroy');
        }

        // ✅ CONFIGURACIÓN RESTRICTIVA: Solo afecta a este elemento
        select.select2({
            theme: 'bootstrap-5',
            width: '100%',
            placeholder: 'Todas las acciones',
            allowClear: true,
            dropdownParent: select.parent(),
            language: {
                noResults: function () {
                    return "No se encontraron resultados";
                },
                searching: function () {
                    return "Buscando...";
                }
            },
            matcher: function(params, data) {
                if (!params || !data) {
                    return data;
                }
                
                if (!params.term || $.trim(params.term) === '') {
                    return data;
                }

                if (typeof data.text === 'undefined' || data.text === null) {
                    return null;
                }

                try {
                    const searchTerm = String(params.term).toLowerCase();
                    const optionText = String(data.text).toLowerCase();

                    if (optionText.indexOf(searchTerm) > -1) {
                        return data;
                    }
                } catch (e) {
                    console.warn('⚠️ Error en matcher de Select2:', e);
                    return null;
                }

                return null;
            }
        });

        // Evento de limpieza
        select.off('select2:clear').on('select2:clear', function () {
            permisosFilterAccion = '';
            permisosCurrentPage = 1;
            cargarPermisos();
        });
    }
}

function poblarDatalistCatalogos(modulos, acciones) {
    // Poblar SELECT de módulos en modal de crear/editar
    const selectModulo = $('#permisoModulo');
    const selectAccion = $('#permisoAccion');
    
    // ✅ VALIDACIÓN CRÍTICA: Solo proceder si son elementos SELECT
    if (!selectModulo.is('select') || !selectAccion.is('select')) {
        console.error('❌ Los elementos del modal NO son <select>');
        return;
    }
    
    selectModulo.empty();
    selectModulo.append('<option value="">-- Seleccione un módulo --</option>');
    modulos.forEach(function (modulo) {
        selectModulo.append(`<option value="${modulo.value}">${modulo.text}</option>`);
    });

    selectAccion.empty();
    selectAccion.append('<option value="">-- Seleccione una acción --</option>');
    acciones.forEach(function (accion) {
        selectAccion.append(`<option value="${accion.value}">${accion.text}</option>`);
    });

    // ✅ HABILITADO: Usar Select2 en modal
    if ($.fn.select2) {
        // Destruir instancias previas si existen
        if (selectModulo.data('select2')) {
            selectModulo.select2('destroy');
        }
        if (selectAccion.data('select2')) {
            selectAccion.select2('destroy');
        }

        // ✅ Configuración restrictiva para Select2
        const select2ConfigRestrictivo = {
            theme: 'bootstrap-5',
            width: '100%',
            allowClear: true,
            dropdownParent: $('#permisoModal'),
            language: {
                noResults: function () {
                    return "No se encontraron resultados";
                },
                searching: function () {
                    return "Buscando...";
                }
            },
            matcher: function(params, data) {
                if (!params || !data) {
                    return data;
                }
                
                if (!params.term || $.trim(params.term) === '') {
                    return data;
                }

                if (typeof data.text === 'undefined' || data.text === null) {
                    return null;
                }

                try {
                    const searchTerm = String(params.term).toLowerCase();
                    const optionText = String(data.text).toLowerCase();

                    if (optionText.indexOf(searchTerm) > -1) {
                        return data;
                    }
                } catch (e) {
                    console.warn('⚠️ Error en matcher de Select2 (modal):', e);
                    return null;
                }

                return null;
            }
        };

        // ✅ Inicializar Select2 SOLO en estos elementos específicos
        selectModulo.select2({
            ...select2ConfigRestrictivo,
            placeholder: '-- Seleccione un módulo --'
        });

        selectAccion.select2({
            ...select2ConfigRestrictivo,
            placeholder: '-- Seleccione una acción --'
        });
    } else {
        console.warn('⚠️ Select2 no está disponible, usando select nativo');
    }
}

function poblarPaginacionPermisos(pagination) {
    const container = $('#paginationPermisosContainer');
    container.empty();

    if (!pagination || pagination.totalPages <= 1) {
        return;
    }

    const ul = $('<ul class="pagination"></ul>');

    // Botón Anterior
    if (pagination.hasPreviousPage) {
        ul.append(`
            <li class="page-item">
                <a class="page-link" href="#" data-page="${pagination.currentPage - 1}">
                    <i class="fas fa-chevron-left"></i> Anterior
                </a>
            </li>
        `);
    }

    // Páginas
    const startPage = Math.max(1, pagination.currentPage - 2);
    const endPage = Math.min(pagination.totalPages, pagination.currentPage + 2);

    for (let i = startPage; i <= endPage; i++) {
        const activeClass = (i === pagination.currentPage) ? ' active' : '';
        ul.append(`
            <li class="page-item${activeClass}">
                <a class="page-link" href="#" data-page="${i}">${i}</a>
            </li>
        `);
    }

    // Botón Siguiente
    if (pagination.hasNextPage) {
        ul.append(`
            <li class="page-item">
                <a class="page-link" href="#" data-page="${pagination.currentPage + 1}">
                    Siguiente <i class="fas fa-chevron-right"></i>
                </a>
            </li>
        `);
    }

    container.append(ul);
}

// ============================================
// FUNCIONES CRUD - MODAL
// ============================================

function abrirModalCrearPermiso() {
    resetearModalPermiso();
    $('#permisoModalLabel').text('Nuevo Permiso');
    $('#permisoModalIcon').removeClass('fa-edit').addClass('fa-shield-alt');
    $('#permisoModal').modal('show');
    isPermisosEditMode = false;
    editPermisoId = null;
}

function resetearModalPermiso() {
    $('#permisoForm')[0].reset();
    $('#permisoActivo').prop('checked', true);
    $('#permisoNombre').val('');
    $('#permisoModulo').val('');
    $('#permisoAccion').val('');
    $('#permisoDescripcion').val('');
}

function guardarPermiso() {
    const nombre = $('#permisoNombre').val().trim();
    const modulo = $('#permisoModulo').val().trim().toUpperCase();
    const accion = $('#permisoAccion').val().trim().toUpperCase();
    const descripcion = $('#permisoDescripcion').val().trim();
    const activo = $('#permisoActivo').is(':checked');

    // Validaciones
    if (!nombre) {
        toastr.warning('El nombre del permiso es obligatorio.', 'Validación');
        $('#permisoNombre').focus();
        return;
    }

    if (!modulo) {
        toastr.warning('El módulo es obligatorio.', 'Validación');
        $('#permisoModulo').focus();
        return;
    }

    if (!accion) {
        toastr.warning('La acción es obligatoria.', 'Validación');
        $('#permisoAccion').focus();
        return;
    }

    const url = isPermisosEditMode ? '/Permisos/UpdatePermiso' : '/Permisos/CreatePermiso';
    const data = isPermisosEditMode
        ? {
            idPermiso: editPermisoId,
            nombre: nombre,
            descripcion: descripcion,
            modulo: modulo,
            accion: accion,
            activo: activo
        }
        : {
            nombre: nombre,
            descripcion: descripcion,
            modulo: modulo,
            accion: accion,
            activo: activo
        };

    // Deshabilitar botón mientras se guarda
    const btnSave = $('#btnSavePermiso');
    btnSave.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-1"></i>Guardando...');

    $.ajax({
        url: url,
        type: 'POST',
        data: data,
        success: function (response) {
            if (response.success) {
                $('#permisoModal').modal('hide');
                cargarPermisos();
                toastr.success(response.message, 'Éxito');

                // Invalidar caché de catálogos si se creó uno nuevo
                if (!isPermisosEditMode) {
                    cachedModulos = null;
                    cargarCatalogosPermisos();
                }
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function (xhr, status, error) {
            console.error('Error al guardar permiso:', xhr, status, error);
            toastr.error('Error al guardar el permiso.', 'Error');
        },
        complete: function () {
            btnSave.prop('disabled', false).html('<i class="fas fa-save me-1"></i>Guardarlo');
        }
    });
}

function editarPermiso(permisoId) {
    $.ajax({
        url: '/Permisos/GetPermisoDetalle',
        type: 'GET',
        data: { id: permisoId },
        success: function (response) {
            if (response.success) {
                const permiso = response.data;

                // Llenar formulario
                $('#permisoNombre').val(permiso.nombre);
                $('#permisoModulo').val(permiso.modulo);
                $('#permisoAccion').val(permiso.accion);
                $('#permisoDescripcion').val(permiso.descripcion || '');
                $('#permisoActivo').prop('checked', permiso.activo);

                // Configurar modal
                $('#permisoModalLabel').text('Editar Permiso');
                $('#permisoModalIcon').removeClass('fa-shield-alt').addClass('fa-edit');
                $('#permisoModal').modal('show');

                isPermisosEditMode = true;
                editPermisoId = permisoId;
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function () {
            toastr.error('Error al cargar los detalles del permiso.', 'Error');
        }
    });
}

function eliminarPermiso(permisoId) {
    Swal.fire({
        title: '¿Eliminar permiso?',
        text: 'Esta acción desactivará el permiso y lo removerá de todos los roles.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: '<i class="fas fa-check me-1"></i>Sí, eliminar',
        cancelButtonText: '<i class="fas fa-times me-1"></i>Cancelar',
        customClass: {
            confirmButton: 'btn btn-danger',
            cancelButton: 'btn btn-secondary'
        },
        buttonsStyling: false
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: '/Permisos/DeletePermiso',
                type: 'POST',
                data: { id: permisoId },
                success: function (response) {
                    if (response.success) {
                        cargarPermisos();
                        toastr.success(response.message, 'Éxito');
                    } else {
                        toastr.error(response.message, 'Error');
                    }
                },
                error: function () {
                    toastr.error('Error al eliminar el permiso.', 'Error');
                }
            });
        }
    });
}

// ============================================
// FUNCIÓN PARA VER DETALLES
// ============================================

function verDetallesPermiso(permisoId) {
    $.ajax({
        url: '/Permisos/GetPermisoDetalle',
        type: 'GET',
        data: { id: permisoId },
        success: function (response) {
            if (response.success) {
                const permiso = response.data;

                // Información principal
                $('#viewPermisoId').text(permiso.idPermiso);
                $('#viewPermisoNombre').text(permiso.nombre);
                $('#viewPermisoModulo').text(permiso.modulo);
                $('#viewPermisoAccion').text(permiso.accion);
                $('#viewPermisoDescripcion').text(permiso.descripcion || 'Sin descripción disponible');

                // Badge de estado
                const activoElement = $('#viewPermisoActivo');
                if (permiso.activo) {
                    activoElement.text('Activo').removeClass('bg-secondary').addClass('bg-success');
                } else {
                    activoElement.text('Inactivo').removeClass('bg-success').addClass('bg-secondary');
                }

                // Total de roles
                $('#viewPermisoTotalRoles').text(permiso.totalRoles || 0);

                // Lista de roles
                const rolesContainer = $('#viewPermisoRolesList');
                rolesContainer.empty();

                if (permiso.roles && permiso.roles.length > 0) {
                    permiso.roles.forEach(function (rol) {
                        rolesContainer.append(`
                            <div class="role-item d-flex align-items-center justify-content-between p-2 mb-2 bg-white rounded border">
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-user-shield text-primary me-2"></i>
                                    <div>
                                        <strong>${escapeHtml(rol.nombre)}</strong>
                                        <br>
                                        <small class="text-muted">${escapeHtml(rol.descripcion || 'Sin descripción')}</small>
                                    </div>
                                </div>
                                <span class="badge bg-info">${rol.totalUsuarios} usuario(s)</span>
                            </div>
                        `);
                    });
                } else {
                    rolesContainer.html(`
                        <div class="text-center text-muted py-3">
                            <i class="fas fa-info-circle me-1"></i>
                            Este permiso no está asignado a ningún rol
                        </div>
                    `);
                }

                // Auditoría
                $('#viewPermisoUsuarioCreacion').text(permiso.usuarioCreacion || 'Sistema');
                $('#viewPermisoFechaCreacion').text(permiso.fechaCreacion || '--/--/----');
                $('#viewPermisoUsuarioModificacion').text(permiso.usuarioModificacion || '--');
                $('#viewPermisoFechaModificacion').text(permiso.fechaModificacion || '--/--/----');

                // Mostrar modal
                $('#viewPermisoModal').modal('show');
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function () {
            toastr.error('Error al cargar los detalles del permiso.', 'Error');
        }
    });
}

// ============================================
// FUNCIÓN PARA LIMPIAR FILTROS
// ============================================

/**
 * Limpia todos los filtros y búsqueda, y recarga todos los permisos
 */
function limpiarFiltrosPermisos() {
    // Limpiar input de búsqueda
    const searchInput = $('#searchPermisos');
    if (searchInput.length > 0) {
        searchInput.val('');
    }
    
    // Resetear variables globales
    permisosSearchTerm = '';
    permisosFilterModulo = '';
    permisosFilterAccion = '';
    permisosFilterStatus = 'activos';
    permisosCurrentPage = 1;
    
    // Resetear selects con Select2
    const filterModulo = $('#filterPermisosModulo');
    const filterAccion = $('#filterPermisosAccion');
    const filterStatus = $('#filterPermisosStatus');
    
    // Si tienen Select2, usar trigger('change') para actualizar la UI
    if (filterModulo.data('select2')) {
        filterModulo.val('').trigger('change');
    } else {
        filterModulo.val('');
    }
    
    if (filterAccion.data('select2')) {
        filterAccion.val('').trigger('change');
    } else {
        filterAccion.val('');
    }
    
    // Restablecer filtro de estado a "activos"
    filterStatus.val('activos');
    
    // Mostrar notificación
    toastr.info('Filtros restablecidos. Mostrando todos los permisos activos.', 'Filtros Limpiados', {
        timeOut: 2000
    });
    
    // Recargar permisos
    cargarPermisos();
}

// ============================================
// UTILIDADES
// ============================================

/**
 * Inicializa tooltips de forma lazy (solo al hacer hover)
 */
function initializeLazyTooltips() {
    $('[data-bs-toggle="tooltip"]').off('mouseenter.tooltip').on('mouseenter.tooltip', function () {
        const $this = $(this);
        if (!$this.data('bs.tooltip')) {
            $this.tooltip({ trigger: 'hover' });
            $this.tooltip('show');
        }
    });
}

/**
 * Escapa caracteres HTML para prevenir XSS
 * @param {*} text - Texto a escapar
 * @returns {string} - Texto escapado
 */
function escapeHtml(text) {
    // ✅ FIX: Validar entrada y convertir a string de forma segura
    if (text === null || text === undefined) {
        return '';
    }
    
    // Convertir a string de forma segura
    const str = String(text);
    
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    
    return str.replace(/[&<>"']/g, function (m) { return map[m]; });
}

/**
 * Función debounce para retrasar la ejecución de funciones
 * @param {Function} func - Función a ejecutar
 * @param {number} wait - Tiempo de espera en milisegundos
 * @returns {Function} - Función debounced
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// OPTIMIZACIÓN: Función centralizada para inicializar Select2
function initializeSelect2(selector, additionalOptions = {}) {
    const $element = $(selector);
    
    // PROTECCIÓN: Solo aplicar Select2 a elementos <select>
    if (!$element.is('select')) {
        console.warn(`⚠️ Intentando aplicar Select2 a un elemento que no es <select>: ${selector}`);
        return false;
    }
    
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

// Exponer funciones globales si es necesario
window.cargarPermisos = cargarPermisos;
window.invalidatePermisosCache = function () {
    cachedModulos = null;
    cachedAcciones = null;
    console.log('🗑️ Caché de permisos invalidado');
};
