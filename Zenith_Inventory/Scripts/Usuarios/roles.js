// ============================================
// GESTIÓN DE ROLES - roles.js
// ============================================

// Variables globales para roles
let rolesCurrentPage = 1;
let rolesPageSize = 10;
let rolesSearchTerm = '';
let rolesFilterStatus = 'activos';
let isRolesEditMode = false;
let editRolId = null;

// Caché de permisos disponibles
let cachedPermisosDisponibles = null;
const ROLES_CACHE_DURATION = 5 * 60 * 1000; // 5 minutos

// ============================================
// INICIALIZACIÓN
// ============================================

$(document).ready(function () {
    console.log('? Inicializando gestión de roles...');

    // Verificar que el elemento existe
    const searchInput = $('#searchRoles');
    if (searchInput.length === 0) {
        console.error('? ERROR: No se encontró el elemento #searchRoles');
        toastr.error('Error al inicializar búsqueda de roles', 'Error Crítico');
        return;
    }

    // Cargar roles al iniciar
    cargarRoles();

    // Event Handler para búsqueda con debounce
    searchInput.on('input', debounce(function (event) {
        const elemento = event.target || this;
        const valor = (elemento.value || '').trim();

        rolesSearchTerm = valor;
        rolesCurrentPage = 1;
        cargarRoles();
    }, 500));

    // Búsqueda con Enter
    searchInput.on('keyup', function (e) {
        if (e.key === 'Enter') {
            const elemento = e.target || this;
            const valor = (elemento.value || '').trim();

            rolesSearchTerm = valor;
            rolesCurrentPage = 1;
            cargarRoles();
        }
    });

    // Event handler para filtro de estado
    $('#filterRolesStatus').on('change', function () {
        rolesFilterStatus = $(this).val();
        rolesCurrentPage = 1;
        cargarRoles();
    });

    // Event Handlers - Botones de Acción
    $('#btnClearFilters').on('click', function () {
        limpiarFiltrosRoles();
    });

    $('#btnRefreshRoles').on('click', function () {
        const icon = $(this).find('i');
        icon.addClass('fa-spin');
        cargarRoles().finally(() => {
            icon.removeClass('fa-spin');
        });
    });

    $('#btnAddRol').on('click', function () {
        abrirModalCrearRol();
    });

    $('#btnSaveRol').on('click', function () {
        guardarRol();
    });

    // Event Handlers - Tabla de Roles (delegación de eventos)
    $(document).on('click', '.view-rol-btn', function () {
        const rolId = $(this).data('id');
        verDetallesRol(rolId);
    });

    $(document).on('click', '.edit-rol-btn', function () {
        const rolId = $(this).data('id');
        editarRol(rolId);
    });

    $(document).on('click', '.delete-rol-btn', function () {
        const rolId = $(this).data('id');
        eliminarRol(rolId);
    });

    $(document).on('click', '.reactivate-rol-btn', function () {
        const rolId = $(this).data('id');
        const rolNombre = $(this).data('nombre');
        reactivarRol(rolId, rolNombre);
    });

    $(document).on('click', '.assign-permisos-btn', function () {
        const rolId = $(this).data('id');
        const rolNombre = $(this).data('nombre');
        abrirModalAsignarPermisos(rolId, rolNombre);
    });

    // Event Handler - Editar desde modal de detalles
    $('#btnEditRolFromView').on('click', function () {
        const rolId = $('#viewRolId').text();
        $('#viewRolModal').modal('hide');
        setTimeout(() => editarRol(rolId), 300);
    });

    // Event Handler - Asignar permisos desde modal de detalles
    $('#btnAsignarPermisos').on('click', function () {
        const rolId = $('#viewRolId').text();
        const rolNombre = $('#viewRolNombre').text();
        $('#viewRolModal').modal('hide');
        setTimeout(() => abrirModalAsignarPermisos(rolId, rolNombre), 300);
    });

    // Event Handler - Guardar permisos asignados
    $('#btnGuardarPermisos').on('click', function () {
        guardarPermisosAsignados();
    });

    // Event Handler - Actualizar contador de permisos seleccionados
    $(document).on('change', '#permisosSelect', function () {
        const selectedCount = $(this).val()?.length || 0;
        $('#permisosSelectedCount').text(selectedCount);

        if (selectedCount > 0) {
            $('#permisosSelectedInfo').removeClass('d-none');
        } else {
            $('#permisosSelectedInfo').addClass('d-none');
        }
    });

    // Event Handlers - Paginación (delegación)
    $(document).on('click', '#paginationRolesContainer .page-link', function (e) {
        e.preventDefault();
        rolesCurrentPage = $(this).data('page');
        cargarRoles();
    });

    // Verificar que Select2 NO se aplicó al input de búsqueda
    if (searchInput.hasClass('select2-hidden-accessible')) {
        console.error('? ADVERTENCIA: Select2 se aplicó incorrectamente a #searchRoles');
        searchInput.select2('destroy');
    }

    console.log('? Inicialización completada');
});

// ============================================
// FUNCIONES DE CARGA DE DATOS
// ============================================

function cargarRoles() {
    return new Promise((resolve, reject) => {
        let incluirInactivos = false;
        
        // Determinar qué enviar al servidor
        if (rolesFilterStatus === 'todos') {
            incluirInactivos = true;
        } else if (rolesFilterStatus === 'inactivos') {
            incluirInactivos = true; // Necesitamos incluir inactivos para poder filtrarlos
        }

        $.ajax({
            url: '/Roles/GetRoles',
            type: 'GET',
            data: {
                page: rolesCurrentPage,
                pageSize: rolesPageSize,
                search: rolesSearchTerm,
                incluirInactivos: incluirInactivos
            },
            success: function (response) {
                // Detectar si la respuesta es HTML (página de error)
                if (typeof response === 'string' && (response.includes('<!DOCTYPE') || response.includes('<html') || response.includes('Acceso Denegado'))) {
                    console.error('❌ Acceso denegado o error de autenticación');
                    mostrarErrorAccesoDenegado();
                    reject('Acceso Denegado');
                    return;
                }
                
                if (response && response.success && response.data) {
                    let items = response.data.items || [];
                    let pagination = response.data.pagination;
                    
                    // Filtrar en cliente según el filtro seleccionado
                    if (rolesFilterStatus === 'activos') {
                        // Solo mostrar activos
                        items = items.filter(r => {
                            const activo = r.activo !== undefined ? r.activo : r.Activo;
                            return activo === true;
                        });
                    } else if (rolesFilterStatus === 'inactivos') {
                        // Solo mostrar inactivos
                        items = items.filter(r => {
                            const activo = r.activo !== undefined ? r.activo : r.Activo;
                            return activo === false;
                        });
                        
                        // Si no hay inactivos, mostrar mensaje
                        if (items.length === 0) {
                            pagination = null;
                            toastr.info('No se encontraron roles inactivos', 'Información', {
                                timeOut: 3000
                            });
                        } else {
                            // Recalcular paginación para items filtrados
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
                    // Si rolesFilterStatus === 'todos', mostrar items tal cual vienen
                    
                    devLog(`Filtro: ${rolesFilterStatus}, Items después de filtrar:`, items.length);
                    
                    poblarTablaRoles(items);
                    poblarPaginacionRoles(pagination);
                    resolve(response);
                } else {
                    const errorMsg = response?.message || 'Respuesta inválida del servidor';
                    console.error('❌ Error en respuesta:', errorMsg);
                    toastr.error(errorMsg, 'Error');
                    mostrarMensajeTabla(errorMsg, 'warning');
                    reject(errorMsg);
                }
            },
            error: function (xhr, status, error) {
                console.error('❌ Error AJAX al cargar roles:', {status: xhr.status, error});
                manejarErrorAjax(xhr, 'Error al cargar los roles');
                reject(error);
            }
        });
    });
}

function cargarPermisosDisponibles() {
    return new Promise((resolve, reject) => {
        // Verificar caché
        if (cachedPermisosDisponibles) {
            console.log('? Usando permisos desde caché');
            resolve(cachedPermisosDisponibles);
            return;
        }

        $.ajax({
            url: '/Roles/GetPermisosDisponibles',
            type: 'GET',
            success: function (response) {
                if (response && response.success && response.data) {
                    cachedPermisosDisponibles = response.data;
                    resolve(cachedPermisosDisponibles);
                } else {
                    const errorMsg = response?.message || 'No se pudieron cargar los permisos';
                    console.error('? Error al cargar permisos:', errorMsg);
                    toastr.error(errorMsg, 'Error');
                    reject(errorMsg);
                }
            },
            error: function (xhr, status, error) {
                console.error('? Error AJAX al cargar permisos:', { status: xhr.status, error });
                toastr.error('Error al cargar los permisos disponibles', 'Error');
                reject(error);
            }
        });
    });
}

// ============================================
// FUNCIONES DE RENDERIZADO
// ============================================

function poblarTablaRoles(roles = []) {
    const tbody = $('#rolesBody');
    tbody.empty();

    if (roles.length === 0) {
        let mensaje = 'No se encontraron roles';
        let icono = 'fas fa-inbox';

        if (rolesFilterStatus === 'inactivos') {
            mensaje = 'No hay roles inactivos';
            icono = 'fas fa-check-circle text-success';
        } else if (rolesSearchTerm) {
            mensaje = `No se encontraron resultados para "${rolesSearchTerm}"`;
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

    roles.forEach(function (rol) {
        // Soporte para ambos formatos de capitalización (camelCase y PascalCase)
        const idRol = rol.idRol || rol.IdRol;
        const nombre = rol.nombre || rol.Nombre;
        const descripcion = rol.descripcion || rol.Descripcion;
        const activo = rol.activo !== undefined ? rol.activo : rol.Activo;
        const totalUsuarios = rol.totalUsuarios || rol.TotalUsuarios || 0;
        const totalPermisos = rol.totalPermisos || rol.TotalPermisos || 0;

        const estadoBadge = activo
            ? '<span class="badge badge-success">Activo</span>'
            : '<span class="badge badge-secondary">Inactivo</span>';

        const descripcionCorta = descripcion
            ? (descripcion.length > 80
                ? descripcion.substring(0, 80) + '...'
                : descripcion)
            : '<span class="text-muted">Sin descripción</span>';

        // Botones de acción según el estado del rol
        let botonesAccion = '';
        
        if (activo) {
            // Rol activo: botones normales (Ver, Asignar Permisos, Editar, Eliminar)
            botonesAccion = `
                <button class="btn btn-info btn-sm btn-icon-only view-rol-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Ver detalles" 
                        data-id="${idRol}">
                    <i class="fas fa-eye"></i>
                </button>
                <button class="btn btn-success btn-sm btn-icon-only assign-permisos-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Asignar permisos" 
                        data-id="${idRol}"
                        data-nombre="${escapeHtml(nombre)}">
                    <i class="fas fa-shield-alt"></i>
                </button>
                <button class="btn btn-warning btn-sm btn-icon-only edit-rol-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Editar" 
                        data-id="${idRol}">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-danger btn-sm btn-icon-only delete-rol-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Eliminar" 
                        data-id="${idRol}">
                    <i class="fas fa-trash"></i>
                </button>
            `;
        } else {
            // Rol inactivo: solo botón de reactivar y ver detalles
            botonesAccion = `
                <button class="btn btn-info btn-sm btn-icon-only view-rol-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Ver detalles" 
                        data-id="${idRol}">
                    <i class="fas fa-eye"></i>
                </button>
                <button class="btn btn-primary btn-sm btn-icon-only reactivate-rol-btn" 
                        data-bs-toggle="tooltip" 
                        data-bs-placement="top"
                        title="Reactivar rol" 
                        data-id="${idRol}"
                        data-nombre="${escapeHtml(nombre)}">
                    <i class="fas fa-undo"></i>
                </button>
            `;
        }

        const row = `
            <tr class="${!activo ? 'table-secondary' : ''}">
                <td>${escapeHtml(nombre)}</td>
                <td>${descripcionCorta}</td>
                <td class="text-center">
                    <span class="badge bg-primary">${totalUsuarios}</span>
                </td>
                <td class="text-center">
                    <span class="badge bg-info">${totalPermisos}</span>
                </td>
                <td class="text-center">${estadoBadge}</td>
                <td class="action-buttons text-center">
                    ${botonesAccion}
                </td>
            </tr>
        `;
        tbody.append(row);
    });

    // Inicializar tooltips lazy
    initializeLazyTooltips();
}

function poblarPaginacionRoles(pagination) {
    const container = $('#paginationRolesContainer');
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

function poblarSelectPermisos(permisos, permisosAsignados = []) {
    const select = $('#permisosSelect');
    select.empty();

    // Agrupar permisos por módulo
    const permisosPorModulo = {};

    permisos.forEach(function (permiso) {
        // Soporte para ambos formatos de capitalización
        const modulo = permiso.modulo || permiso.Modulo;
        if (!permisosPorModulo[modulo]) {
            permisosPorModulo[modulo] = [];
        }
        permisosPorModulo[modulo].push(permiso);
    });

    // Agregar opciones agrupadas por módulo
    Object.keys(permisosPorModulo).sort().forEach(function (modulo) {
        const optgroup = $(`<optgroup label="${modulo}"></optgroup>`);

        permisosPorModulo[modulo].forEach(function (permiso) {
            // Soporte para ambos formatos
            const idPermiso = permiso.idPermiso || permiso.IdPermiso;
            const nombre = permiso.nombre || permiso.Nombre;
            const accion = permiso.accion || permiso.Accion;

            const option = $(`<option value="${idPermiso}">${nombre} (${accion})</option>`);

            // Marcar como seleccionado si está en permisosAsignados
            if (permisosAsignados.includes(idPermiso)) {
                option.prop('selected', true);
            }

            optgroup.append(option);
        });

        select.append(optgroup);
    });

    // Inicializar Select2
    if ($.fn.select2) {
        if (select.data('select2')) {
            select.select2('destroy');
        }

        select.select2({
            theme: 'bootstrap-5',
            width: '100%',
            placeholder: 'Seleccione los permisos',
            allowClear: true,
            dropdownParent: $('#asignarPermisosModal'),
            language: {
                noResults: function () {
                    return "No se encontraron permisos";
                },
                searching: function () {
                    return "Buscando...";
                }
            }
        });
    }

    // Actualizar contador inicial
    const selectedCount = permisosAsignados.length;
    $('#permisosSelectedCount').text(selectedCount);
    if (selectedCount > 0) {
        $('#permisosSelectedInfo').removeClass('d-none');
    }
}

// ============================================
// FUNCIONES CRUD - MODAL
// ============================================

function abrirModalCrearRol() {
    resetearModalRol();
    $('#rolModalLabel').text('Nuevo Rol');
    $('#rolModalIcon').removeClass('fa-edit').addClass('fa-user-shield');
    $('#rolModal').modal('show');
    isRolesEditMode = false;
    editRolId = null;
}

function resetearModalRol() {
    // Resetear formulario
    $('#rolForm')[0].reset();

    // Valores por defecto
    $('#rolActivo').prop('checked', true);
    $('#rolNombre').val('');
    $('#rolDescripcion').val('');

    // Limpiar clases de validación
    $('#rolNombre, #rolDescripcion').removeClass('is-invalid is-valid');

    // Resetear variables de control
    isRolesEditMode = false;
    editRolId = null;

    devLog('Modal de rol reseteado');
}

function guardarRol() {
    const nombre = $('#rolNombre').val().trim();
    const descripcion = $('#rolDescripcion').val().trim();
    const activo = $('#rolActivo').is(':checked');

    // ============================================
    // VALIDACIONES MEJORADAS
    // ============================================

    // Validar nombre (requerido)
    if (!nombre) {
        toastr.warning('El nombre del rol es obligatorio', 'Validación');
        $('#rolNombre').focus().addClass('is-invalid');

        // Remover clase después de 3 segundos
        setTimeout(() => {
            $('#rolNombre').removeClass('is-invalid');
        }, 3000);

        return;
    }

    // Validar longitud del nombre
    if (nombre.length < 3) {
        toastr.warning('El nombre debe tener al menos 3 caracteres', 'Validación');
        $('#rolNombre').focus().addClass('is-invalid');

        setTimeout(() => {
            $('#rolNombre').removeClass('is-invalid');
        }, 3000);

        return;
    }

    if (nombre.length > 50) {
        toastr.warning('El nombre no puede exceder 50 caracteres', 'Validación');
        $('#rolNombre').focus().addClass('is-invalid');

        setTimeout(() => {
            $('#rolNombre').removeClass('is-invalid');
        }, 3000);

        return;
    }

    // Validar longitud de descripción
    if (descripcion.length > 255) {
        toastr.warning('La descripción no puede exceder 255 caracteres', 'Validación');
        $('#rolDescripcion').focus().addClass('is-invalid');

        setTimeout(() => {
            $('#rolDescripcion').removeClass('is-invalid');
        }, 3000);

        return;
    }

    // Validar que el ID exista en modo edición
    if (isRolesEditMode && (!editRolId || editRolId <= 0)) {
        toastr.error('Error de configuración: ID de rol inválido', 'Error');
        console.error('ID de rol inválido en modo edición:', editRolId);
        return;
    }

    // ============================================
    // PREPARAR DATOS
    // ============================================

    const url = isRolesEditMode ? '/Roles/ActualizarRol' : '/Roles/CrearRol';
    const data = isRolesEditMode
        ? {
            idRol: editRolId,
            nombre: nombre,
            descripcion: descripcion,
            activo: activo
        }
        : {
            nombre: nombre,
            descripcion: descripcion,
            activo: activo
        };

    const accionTexto = isRolesEditMode ? 'actualizar' : 'crear';
    const accionGerundio = isRolesEditMode ? 'Actualizando' : 'Creando';

    // ============================================
    // DESHABILITAR BOTÓN Y MOSTRAR LOADING
    // ============================================

    const btnSave = $('#btnSaveRol');
    const btnCancel = $('[data-bs-dismiss="modal"]', '#rolModal');

    btnSave.prop('disabled', true)
        .html(`<i class="fas fa-spinner fa-spin me-1"></i>${accionGerundio}...`);

    btnCancel.prop('disabled', true); // Evitar cerrar mientras guarda

    // Logging para debugging
    devLog(`${accionGerundio} rol:`, data);

    // ============================================
    // PETICIÓN AJAX
    // ============================================

    $.ajax({
        url: url,
        type: 'POST',
        data: data,
        timeout: 30000, // 30 segundos de timeout
        success: function (response) {
            if (response.success) {
                // Cerrar modal
                $('#rolModal').modal('hide');

                // Recargar tabla
                cargarRoles().then(() => {
                    // Mostrar mensaje de éxito DESPUÉS de recargar
                    toastr.success(
                        response.message || `Rol ${isRolesEditMode ? 'actualizado' : 'creado'} exitosamente`,
                        'Éxito',
                        {
                            timeOut: 3000,
                            progressBar: true
                        }
                    );

                    // Si es edición, resaltar la fila actualizada
                    if (isRolesEditMode) {
                        setTimeout(() => {
                            const $row = $(`tr:has(button[data-id="${editRolId}"])`);
                            if ($row.length > 0) {
                                $row.addClass('table-success');
                                setTimeout(() => {
                                    $row.removeClass('table-success');
                                }, 2000);
                            }
                        }, 500);
                    }
                });

                // Limpiar formulario
                resetearModalRol();

                devLog('Rol guardado exitosamente:', response);
            } else {
                // Error del servidor (validación o negocio)
                toastr.error(
                    response.message || `Error al ${accionTexto} el rol`,
                    'Error de Validación',
                    {
                        timeOut: 5000,
                        closeButton: true
                    }
                );

                console.error('Error de validación del servidor:', response);
            }
        },
        error: function (xhr, status, error) {
            console.error(`Error al ${accionTexto} rol:`, { xhr, status, error });

            // Mensajes específicos según el código de error
            let errorMessage = `Error al ${accionTexto} el rol`;
            let errorTitle = 'Error';

            if (xhr.status === 400) {
                errorMessage = 'Datos inválidos. Verifique la información ingresada';
                errorTitle = 'Validación';
            } else if (xhr.status === 401) {
                errorMessage = 'Sesión expirada. Inicie sesión nuevamente';
                errorTitle = 'Sesión Expirada';
            } else if (xhr.status === 403) {
                errorMessage = 'No tiene permisos para realizar esta acción';
                errorTitle = 'Acceso Denegado';
            } else if (xhr.status === 404) {
                errorMessage = 'El rol no existe o fue eliminado';
                errorTitle = 'No Encontrado';
            } else if (xhr.status === 409) {
                errorMessage = 'Ya existe un rol con ese nombre';
                errorTitle = 'Duplicado';
            } else if (xhr.status === 500) {
                errorMessage = 'Error interno del servidor. Contacte al administrador';
                errorTitle = 'Error del Servidor';
            } else if (status === 'timeout') {
                errorMessage = 'La operación tardó demasiado. Intente nuevamente';
                errorTitle = 'Timeout';
            } else if (status === 'abort') {
                errorMessage = 'Operación cancelada';
                errorTitle = 'Cancelado';
            }

            toastr.error(errorMessage, errorTitle, {
                timeOut: 7000,
                closeButton: true,
                progressBar: true
            });
        },
        complete: function () {
            // Restaurar botones sin importar el resultado
            btnSave.prop('disabled', false)
                .html('<i class="fas fa-save me-1"></i>Guardar');

            btnCancel.prop('disabled', false);
        }
    });
}

function editarRol(rolId) {
    // Validar ID
    if (!rolId || rolId <= 0) {
        toastr.error('ID de rol inválido', 'Error');
        return;
    }

    // Mostrar loading en el modal antes de abrirlo
    const btnState = showButtonLoading('#btnSaveRol', 'Cargando...');

    $.ajax({
        url: '/Roles/GetRolPorId',
        type: 'GET',
        data: { id: rolId },
        success: function (response) {
            if (response.success && response.data) {
                const rol = response.data;

                // Soporte para ambos formatos de capitalización
                const idRol = rol.idRol || rol.IdRol;
                const nombre = rol.nombre || rol.Nombre;
                const descripcion = rol.descripcion || rol.Descripcion;
                const activo = rol.activo !== undefined ? rol.activo : rol.Activo;

                // Validar que tengamos el nombre al menos
                if (!nombre) {
                    toastr.error('Datos del rol incompletos', 'Error');
                    btnState.restore();
                    return;
                }

                // Llenar formulario
                $('#rolNombre').val(nombre);
                $('#rolDescripcion').val(descripcion || '');
                $('#rolActivo').prop('checked', activo);

                // Configurar modal
                $('#rolModalLabel').text('Editar Rol');
                $('#rolModalIcon').removeClass('fa-user-shield').addClass('fa-edit');

                // Configurar modo edición
                isRolesEditMode = true;
                editRolId = idRol;

                // Restaurar botón y mostrar modal
                btnState.restore();
                $('#rolModal').modal('show');

                // Focus en el nombre después de que el modal se muestre
                $('#rolModal').one('shown.bs.modal', function () {
                    $('#rolNombre').focus().select();
                });

                devLog('Rol cargado para edición:', { idRol, nombre, descripcion, activo });
            } else {
                toastr.error(response.message || 'No se pudo cargar el rol', 'Error');
                btnState.restore();
            }
        },
        error: function (xhr, status, error) {
            console.error('Error al cargar rol para editar:', { xhr, status, error });

            // Mensaje específico según el código de error
            let errorMessage = 'Error al cargar los detalles del rol';

            if (xhr.status === 404) {
                errorMessage = 'El rol no existe o fue eliminado';
            } else if (xhr.status === 403) {
                errorMessage = 'No tiene permisos para editar este rol';
            } else if (xhr.status === 401) {
                errorMessage = 'Sesión expirada. Por favor, inicie sesión nuevamente';
            }

            toastr.error(errorMessage, 'Error');
            btnState.restore();
        }
    });
}

// ============================================
// FUNCIÓN PARA VER DETALLES
// ============================================

function verDetallesRol(rolId) {
    // Cargar información básica y matriz de permisos en paralelo

    debugger;
    Promise.all([
        $.ajax({ url: '/Roles/GetRolPorId', type: 'GET', data: { id: rolId } }),
        $.ajax({ url: '/Roles/GetPermisosMatriz', type: 'GET', data: { idRol: rolId } })
    ]).then(([responseRol, responseMatriz]) => {
        if (responseRol.success && responseMatriz.success) {
            debugger;
            const rol = responseRol.data;
            const matrizData = responseMatriz.data;

            // Soporte para ambos formatos de capitalización
            const idRol = rol.idRol || rol.IdRol;
            const nombre = rol.nombre || rol.Nombre;
            const descripcion = rol.descripcion || rol.Descripcion;
            const activo = rol.activo !== undefined ? rol.activo : rol.Activo;
            const totalUsuarios = rol.totalUsuarios || rol.TotalUsuarios || 0;
            const totalPermisos = matrizData.totalPermisos || 0;
            const fechaCreacion = rol.fechaCreacion || rol.FechaCreacion;
            const usuarioCreacion = rol.usuarioCreacion || rol.UsuarioCreacion;
            const fechaModificacion = rol.fechaModificacion || rol.FechaModificacion;
            const usuarioModificacion = rol.usuarioModificacion || rol.UsuarioModificacion;

            // Información principal
            $('#viewRolId').text(idRol);
            $('#viewRolNombre').text(nombre);
            $('#viewRolDescripcion').text(descripcion || 'Sin descripción disponible');

            // Badge de estado
            const activoElement = $('#viewRolActivo');
            if (activo) {
                activoElement.text('Activo').removeClass('bg-secondary').addClass('bg-success');
            } else {
                activoElement.text('Inactivo').removeClass('bg-success').addClass('bg-secondary');
            }

            // Estadísticas
            $('#viewRolTotalUsuarios').text(totalUsuarios);
            $('#viewRolTotalPermisos').text(totalPermisos);
            $('#permisosCount').text(totalPermisos);

            // NUEVO: Generar MATRIZ DE PERMISOS
            const permisosContainer = $('#viewRolPermisosList');
            permisosContainer.empty();

            if (matrizData.matriz && matrizData.matriz.length > 0) {
                generarMatrizPermisos(matrizData, permisosContainer);
            } else {
                permisosContainer.html(`
                    <div class="permisos-empty-state">
                        <i class="fas fa-shield-alt"></i>
                        <div class="empty-title">Sin permisos asignados</div>
                        <p class="empty-text">Este rol no tiene permisos configurados todavía</p>
                    </div>
                `);
            }

            // Auditoría
            $('#viewRolUsuarioCreacion').text(usuarioCreacion || 'Sistema');
            $('#viewRolFechaCreacion').text(fechaCreacion || '--/--/----');
            $('#viewRolUsuarioModificacion').text(usuarioModificacion || '--');
            $('#viewRolFechaModificacion').text(fechaModificacion || '--/--/----');

            // Mostrar modal
            $('#viewRolModal').modal('show');
        } else {
            debugger;
            toastr.error(responseRol.message || responseMatriz.message, 'Error');
        }
    }).catch(error => {
        console.error('Error al cargar detalles del rol:', error);
        toastr.error('Error al cargar los detalles del rol.', 'Error');
    });
}

// NUEVA FUNCIÓN: Generar matriz de permisos tipo tabla
function generarMatrizPermisos(matrizData, container) {
    const { modulos, acciones, matriz } = matrizData;

    // Crear tabla responsive
    const tablaHtml = `
        <div class="permisos-matriz-container">
            <div class="table-responsive">
                <table class="permisos-matriz-table">
                    <thead>
                        <tr>
                            <th class="modulo-header">Módulo</th>
                            ${acciones.map(accion => `
                                <th class="accion-header">
                                    <span class="accion-icon">${getAccionIcon(accion)}</span>
                                    <span class="accion-text">${accion}</span>
                                </th>
                            `).join('')}
                        </tr>
                    </thead>
                    <tbody>
                        ${matriz.map(fila => {
        const moduloPermisos = fila.permisos.filter(p => p.asignado);
        const tienePermisos = moduloPermisos.length > 0;

        return `
                                <tr class="${tienePermisos ? 'modulo-activo' : 'modulo-inactivo'}">
                                    <td class="modulo-cell">
                                        <div class="modulo-info">
                                            <i class="fas fa-cube modulo-icon"></i>
                                            <span class="modulo-nombre">${fila.modulo}</span>
                                            ${tienePermisos ? `<span class="modulo-badge">${moduloPermisos.length}</span>` : ''}
                                        </div>
                                    </td>
                                    ${fila.permisos.map(permiso => `
                                        <td class="permiso-cell ${permiso.asignado ? 'permiso-asignado' : 'permiso-no-asignado'}">
                                            ${permiso.existe ? `
                                                <div class="permiso-check-container" 
                                                     data-bs-toggle="tooltip" 
                                                     data-bs-placement="top"
                                                     title="${permiso.asignado ? permiso.nombre : 'No asignado'}">
                                                    ${permiso.asignado ?
                    '<i class="fas fa-check-circle permiso-check-icon"></i>' :
                    '<i class="fas fa-circle permiso-empty-icon"></i>'
                }
                                                </div>
                                            ` : `
                                                <span class="permiso-na">—</span>
                                            `}
                                        </td>
                                    `).join('')}
                                </tr>
                            `;
    }).join('')}
                    </tbody>
                </table>
            </div>
            <div class="permisos-matriz-legend">
                <div class="legend-item">
                    <i class="fas fa-check-circle text-success"></i>
                    <span>Permiso asignado</span>
                </div>
                <div class="legend-item">
                    <i class="fas fa-circle text-muted"></i>
                    <span>Permiso disponible</span>
                </div>
                <div class="legend-item">
                    <span class="permiso-na">—</span>
                    <span>No aplicable</span>
                </div>
            </div>
        </div>
    `;

    container.html(tablaHtml);

    // Inicializar tooltips
    initializeLazyTooltips();
}

// HELPER: Obtener icono para cada acción
function getAccionIcon(accion) {
    const iconMap = {
        'LEER': 'fa-eye',
        'CREAR': 'fa-plus',
        'ACTUALIZAR': 'fa-edit',
        'ELIMINAR': 'fa-trash',
        'EXPORTAR': 'fa-download',
        'IMPORTAR': 'fa-upload',
        'CONFIGURAR': 'fa-cog'
    };

    return `<i class="fas ${iconMap[accion] || 'fa-shield-alt'}"></i>`;
}

// ============================================
// ASIGNAR PERMISOS
// ============================================

function abrirModalAsignarPermisos(rolId, rolNombre) {
    $('#asignarPermisosRolId').val(rolId);
    $('#asignarPermisosRolNombre').text(rolNombre);

    // Mostrar loading
    $('#permisosMatrizEditable').html(`
        <div class="text-center py-5">
            <i class="fas fa-spinner fa-spin fa-2x text-muted mb-3"></i>
            <p class="text-muted">Cargando permisos...</p>
        </div>
    `);

    $('#asignarPermisosModal').modal('show');

    // Cargar matriz de permisos para editar
    cargarMatrizPermisosEditable(rolId);
}

function cargarMatrizPermisosEditable(rolId) {
    $.ajax({
        url: '/Roles/GetPermisosMatriz',
        type: 'GET',
        data: { idRol: rolId },
        success: function (response) {
            if (response.success && response.data) {
                const { modulos, acciones, matriz, totalPermisos } = response.data;

                // Actualizar contadores
                actualizarContadoresPermisos(matriz);

                // Generar matriz editable
                generarMatrizPermisosEditable(modulos, acciones, matriz);

                // Inicializar event handlers
                inicializarEventHandlersAsignacion();
            } else {
                mostrarErrorCargaPermisos(response.message);
            }
        },
        error: function (xhr, status, error) {
            console.error('Error al cargar matriz de permisos:', error);
            mostrarErrorCargaPermisos('Error al cargar los permisos');
        }
    });
}

function generarMatrizPermisosEditable(modulos, acciones, matriz) {
    const container = $('#permisosMatrizEditable');

    const tablaHtml = `
        <div class="permisos-matriz-container">
            <div class="table-responsive">
                <table class="permisos-matriz-table">
                    <thead>
                        <tr>
                            <th class="modulo-header">
                                <div class="form-check">
                                    <input type="checkbox" class="form-check-input" id="selectAllModulos">
                                    <label class="form-check-label" for="selectAllModulos">Módulo</label>
                                </div>
                            </th>
                            ${acciones.map(accion => `
                                <th class="accion-header">
                                    <span class="accion-icon">${getAccionIcon(accion)}</span>
                                    <span class="accion-text">${accion}</span>
                                    <div class="form-check mt-1">
                                        <input type="checkbox" class="form-check-input select-accion" data-accion="${accion}" id="selectAll${accion}">
                                    </div>
                                </th>
                            `).join('')}
                        </tr>
                    </thead>
                    <tbody>
                        ${matriz.map(fila => {
        const permisosAsignados = fila.permisos.filter(p => p.asignado).length;
        const tienePermisos = permisosAsignados > 0;

        return `
                                <tr class="${tienePermisos ? 'modulo-activo' : 'modulo-inactivo'}" data-modulo="${fila.modulo}">
                                    <td class="modulo-cell">
                                        <div class="modulo-info">
                                            <div class="form-check">
                                                <input type="checkbox" class="form-check-input select-modulo" data-modulo="${fila.modulo}">
                                                <label class="form-check-label">
                                                    <i class="fas fa-cube modulo-icon"></i>
                                                    <span class="modulo-nombre">${fila.modulo}</span>
                                                </label>
                                            </div>
                                            ${tienePermisos ? `<span class="modulo-badge">${permisosAsignados}</span>` : ''}
                                        </div>
                                    </td>
                                    ${fila.permisos.map(permiso => `
                                        <td class="permiso-cell ${permiso.asignado ? 'permiso-asignado' : 'permiso-no-asignado'}">
                                            ${permiso.existe ? `
                                                <div class="permiso-checkbox-container" 
                                                     data-bs-toggle="tooltip" 
                                                     data-bs-placement="top"
                                                     title="${permiso.nombre || 'Permiso de ' + fila.modulo + ' - ' + permiso.accion}">
                                                    <input type="checkbox" 
                                                           class="permiso-checkbox" 
                                                           data-id-permiso="${permiso.idPermiso}"
                                                           data-modulo="${fila.modulo}"
                                                           data-accion="${permiso.accion}"
                                                           ${permiso.asignado ? 'checked' : ''}>
                                                </div>
                                            ` : `
                                                <span class="permiso-na">—</span>
                                            `}
                                        </td>
                                    `).join('')}
                                </tr>
                            `;
    }).join('')}
                    </tbody>
                </table>
            </div>
            <div class="permisos-matriz-legend">
                <div class="legend-item">
                    <input type="checkbox" checked disabled class="permiso-checkbox me-2" style="width: 20px; height: 20px;">
                    <span>Permiso asignado</span>
                </div>
                <div class="legend-item">
                    <input type="checkbox" disabled class="permiso-checkbox me-2" style="width: 20px; height: 20px;">
                    <span>Permiso disponible</span>
                </div>
                <div class="legend-item">
                    <span class="permiso-na me-2">—</span>
                    <span>No aplicable</span>
                </div>
            </div>
        </div>
    `;

    container.html(tablaHtml);

    // Inicializar tooltips
    initializeLazyTooltips();
}

function inicializarEventHandlersAsignacion() {
    // Evento para checkbox individual
    $(document).off('change', '.permiso-checkbox').on('change', '.permiso-checkbox', function () {
        actualizarContadoresPermisosDesdeCheckboxes();
        actualizarEstadoFila($(this).closest('tr'));
    });

    // Seleccionar todos los permisos
    $('#btnSeleccionarTodos').off('click').on('click', function () {
        $('.permiso-checkbox').prop('checked', true).trigger('change');
        actualizarContadoresPermisosDesdeCheckboxes();
        actualizarTodasLasFilas();
        toastr.success('Todos los permisos seleccionados', 'Selección');
    });

    // Deseleccionar todos los permisos
    $('#btnDeseleccionarTodos').off('click').on('click', function () {
        $('.permiso-checkbox').prop('checked', false).trigger('change');
        actualizarContadoresPermisosDesdeCheckboxes();
        actualizarTodasLasFilas();
        toastr.info('Todos los permisos deseleccionados', 'Selección');
    });

    // Seleccionar todos de un módulo
    $(document).off('change', '.select-modulo').on('change', '.select-modulo', function () {
        const modulo = $(this).data('modulo');
        const checked = $(this).prop('checked');

        $(`tr[data-modulo="${modulo}"] .permiso-checkbox`).prop('checked', checked);
        actualizarContadoresPermisosDesdeCheckboxes();
        actualizarEstadoFila($(`tr[data-modulo="${modulo}"]`));
    });

    // Seleccionar todos de una acción
    $(document).off('change', '.select-accion').on('change', '.select-accion', function () {
        const accion = $(this).data('accion');
        const checked = $(this).prop('checked');

        $(`.permiso-checkbox[data-accion="${accion}"]`).prop('checked', checked);
        actualizarContadoresPermisosDesdeCheckboxes();
        actualizarTodasLasFilas();
    });
}

function actualizarContadoresPermisos(matriz) {
    let asignados = 0;
    let total = 0;

    matriz.forEach(fila => {
        fila.permisos.forEach(permiso => {
            if (permiso.existe) {
                total++;
                if (permiso.asignado) {
                    asignados++;
                }
            }
        });
    });

    $('#permisosAsignadosCount').text(asignados);
    $('#permisosTotalCount').text(total);
}

function actualizarContadoresPermisosDesdeCheckboxes() {
    const total = $('.permiso-checkbox').length;
    const asignados = $('.permiso-checkbox:checked').length;

    $('#permisosAsignadosCount').text(asignados);
    $('#permisosTotalCount').text(total);
}

function actualizarEstadoFila($fila) {
    const totalCheckboxes = $fila.find('.permiso-checkbox').length;
    const checkedCheckboxes = $fila.find('.permiso-checkbox:checked').length;

    // Actualizar clase de fila
    if (checkedCheckboxes > 0) {
        $fila.removeClass('modulo-inactivo').addClass('modulo-activo');
    } else {
        $fila.removeClass('modulo-activo').addClass('modulo-inactivo');
    }

    // Actualizar badge
    const badge = $fila.find('.modulo-badge');
    if (checkedCheckboxes > 0) {
        if (badge.length === 0) {
            $fila.find('.modulo-info').append(`<span class="modulo-badge">${checkedCheckboxes}</span>`);
        } else {
            badge.text(checkedCheckboxes);
        }
    } else {
        badge.remove();
    }

    // Actualizar checkbox de módulo
    const moduloCheckbox = $fila.find('.select-modulo');
    moduloCheckbox.prop('checked', checkedCheckboxes === totalCheckboxes);
    moduloCheckbox.prop('indeterminate', checkedCheckboxes > 0 && checkedCheckboxes < totalCheckboxes);
}

function actualizarTodasLasFilas() {
    $('.permisos-matriz-table tbody tr').each(function () {
        actualizarEstadoFila($(this));
    });
}

function mostrarErrorCargaPermisos(mensaje) {
    $('#permisosMatrizEditable').html(`
        <div class="text-center py-5">
            <i class="fas fa-exclamation-triangle fa-2x text-warning mb-3"></i>
            <p class="text-muted">${mensaje}</p>
            <button class="btn btn-primary btn-sm" onclick="cargarMatrizPermisosEditable($('#asignarPermisosRolId').val())">
                <i class="fas fa-sync-alt me-1"></i>Reintentar
            </button>
        </div>
    `);
}

function guardarPermisosAsignados() {
    const rolId = $('#asignarPermisosRolId').val();
    const permisosIds = [];

    // Obtener todos los checkboxes marcados
    $('.permiso-checkbox:checked').each(function () {
        const idPermiso = $(this).data('id-permiso');
        if (idPermiso > 0) {
            permisosIds.push(idPermiso);
        }
    });

    const btnGuardar = $('#btnGuardarPermisos');
    btnGuardar.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-1"></i>Guardando...');

    $.ajax({
        url: '/Roles/AsignarPermisos',
        type: 'POST',
        data: {
            idRol: rolId,
            permisosIds: permisosIds
        },
        traditional: true, // Para enviar arrays correctamente
        success: function (response) {
            if (response.success) {
                $('#asignarPermisosModal').modal('hide');
                toastr.success(response.message, 'Éxito');

                // Recargar tabla si estaba abierto el modal de detalles
                if ($('#viewRolModal').hasClass('show')) {
                    verDetallesRol(rolId);
                }

                cargarRoles();
            } else {
                toastr.error(response.message, 'Error');
            }
        },
        error: function (xhr, status, error) {
            console.error('Error al asignar permisos:', xhr, status, error);
            toastr.error('Error al asignar permisos.', 'Error');
        },
        complete: function () {
            btnGuardar.prop('disabled', false).html('<i class="fas fa-save me-1"></i>Guardar Permisos');
        }
    });
}

// ============================================
// MEJORAS EN LA FUNCIÓN ELIMINARROL
// ============================================

function eliminarRol(rolId) {
    // Validar ID
    if (!rolId || rolId <= 0) {
        toastr.error('ID de rol inválido', 'Error');
        return;
    }

    // Obtener información del rol antes de eliminar (para mostrar en confirmación)
    const $row = $(`tr:has(button[data-id="${rolId}"])`);
    const rolNombre = $row.find('td:first').text().trim() || 'este rol';
    const totalUsuarios = parseInt($row.find('.badge.bg-primary').text()) || 0;

    // Mensaje de advertencia personalizado
    let mensajeAdvertencia = 'Esta acción desactivará el rol';

    if (totalUsuarios > 0) {
        mensajeAdvertencia += ` y lo removerá de ${totalUsuarios} usuario(s)`;
    }

    mensajeAdvertencia += '.';

    confirmDialog({
        title: `¿Eliminar "${rolNombre}"?`,
        text: mensajeAdvertencia,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#6c757d',
        confirmButtonText: '<i class="fas fa-trash me-1"></i>Sí, eliminar',
        cancelButtonText: '<i class="fas fa-times me-1"></i>Cancelar',
        showLoaderOnConfirm: true,
        preConfirm: () => {
            // Retornar la promesa AJAX
            return $.ajax({
                url: '/Roles/EliminarRol',
                type: 'POST',
                data: { id: rolId },
                timeout: 30000
            }).then(response => {
                if (response.success) {
                    return response;
                } else {
                    throw new Error(response.message || 'Error al eliminar el rol');
                }
            }).catch(error => {
                let errorMessage = 'Error al eliminar el rol';

                if (error.status === 403) {
                    errorMessage = 'No tiene permisos para eliminar este rol';
                } else if (error.status === 404) {
                    errorMessage = 'El rol no existe o ya fue eliminado';
                } else if (error.status === 409) {
                    errorMessage = 'No se puede eliminar el rol porque tiene dependencias';
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
            // Éxito
            const response = result.value;

            // Recargar tabla
            cargarRoles().then(() => {
                toastr.success(
                    response.message || 'Rol eliminado exitosamente',
                    'Éxito',
                    {
                        timeOut: 3000,
                        progressBar: true
                    }
                );
            });

            devLog('Rol eliminado:', { rolId, rolNombre, response });

            // Mostrar notificación adicional si tenía usuarios
            if (totalUsuarios > 0) {
                setTimeout(() => {
                    toastr.info(
                        `El rol fue removido de ${totalUsuarios} usuario(s)`,
                        'Información',
                        {
                            timeOut: 5000
                        }
                    );
                }, 1000);
            }
        }
    });
}

// ============================================
// FUNCIÓN PARA REACTIVAR ROL
// ============================================

function reactivarRol(rolId, rolNombre) {
    // Validar ID
    if (!rolId || rolId <= 0) {
        toastr.error('ID de rol inválido', 'Error');
        return;
    }

    confirmDialog({
        title: `¿Reactivar "${rolNombre}"?`,
        text: 'Esta acción volverá a activar el rol y estará disponible para asignación.',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: '<i class="fas fa-undo me-1"></i>Sí, reactivar',
        cancelButtonText: '<i class="fas fa-times me-1"></i>Cancelar',
        showLoaderOnConfirm: true,
        preConfirm: () => {
            // Retornar la promesa AJAX
            return $.ajax({
                url: '/Roles/ReactivarRol',
                type: 'POST',
                data: { id: rolId },
                timeout: 30000
            }).then(response => {
                if (response.success) {
                    return response;
                } else {
                    throw new Error(response.message || 'Error al reactivar el rol');
                }
            }).catch(error => {
                let errorMessage = 'Error al reactivar el rol';
                
                if (error.status === 403) {
                    errorMessage = 'No tiene permisos para reactivar este rol';
                } else if (error.status === 404) {
                    errorMessage = 'El rol no existe';
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
            // Éxito
            const response = result.value;
            
            // Recargar tabla
            cargarRoles().then(() => {
                toastr.success(
                    response.message || 'Rol reactivado exitosamente',
                    'Éxito',
                    {
                        timeOut: 3000,
                        progressBar: true
                    }
                );
                
                // Si el filtro es "inactivos", al reactivar debería desaparecer de la lista
                // Si es "todos", se debe actualizar el estado visualmente
                if (rolesFilterStatus !== 'inactivos') {
                    setTimeout(() => {
                        const $row = $(`tr:has(button[data-id="${rolId}"])`);
                        if ($row.length > 0) {
                            $row.removeClass('table-secondary').addClass('table-success');
                            setTimeout(() => {
                                $row.removeClass('table-success');
                            }, 2000);
                        }
                    }, 500);
                }
            });

            devLog('Rol reactivado:', { rolId, rolNombre, response });
        }
    });
}

// ============================================
// FUNCIÓN PARA LIMPIAR FILTROS
// ============================================

function limpiarFiltrosRoles() {
    const searchInput = $('#searchRoles');
    const filterStatus = $('#filterRolesStatus');

    // Guardar valores anteriores para comparar
    const hayCambios = rolesSearchTerm !== '' || rolesFilterStatus !== 'activos' || rolesCurrentPage !== 1;

    // Limpiar valores
    if (searchInput.length > 0) {
        searchInput.val('');
    }

    rolesSearchTerm = '';
    rolesFilterStatus = 'activos';
    rolesCurrentPage = 1;

    filterStatus.val('activos');

    // Solo recargar si había filtros aplicados
    if (hayCambios) {
        toastr.info('Filtros restablecidos', 'Información', {
            timeOut: 2000
        });

        cargarRoles();

        devLog('Filtros limpiados');
    } else {
        toastr.info('No hay filtros activos para limpiar', 'Información', {
            timeOut: 2000
        });
    }
}

// ============================================
// UTILIDADES Y MENSAJES DE ERROR
// ============================================

function mostrarErrorAccesoDenegado() {
    $('#rolesBody').html(`
        <tr>
            <td colspan="6" class="text-center py-5">
                <div class="error-container" style="padding: 3rem; background: white; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.1);">
                    <div class="error-icon" style="animation: pulse 2s infinite;">
                        <i class="bi bi-shield-exclamation" style="font-size: 5rem; color: #dc3545;"></i>
                    </div>
                    <h4 class="mt-4">Acceso Denegado</h4>
                    <p class="lead text-muted">No tiene los permisos necesarios para acceder a este recurso.</p>
                    <hr class="my-4">
                    <p class="mb-3"><strong>Solución:</strong> Ejecutar script SQL de configuración</p>
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

    toastr.error('No tiene permisos para ver roles. Ejecute el script de configuración.', 'Acceso Denegado', {
        timeOut: 8000,
        extendedTimeOut: 3000,
        closeButton: true,
        progressBar: true
    });
}

function mostrarMensajeTabla(mensaje, tipo = 'info') {
    const iconMap = {
        'info': 'bi-info-circle',
        'warning': 'bi-exclamation-triangle',
        'error': 'bi-x-circle',
        'success': 'bi-check-circle'
    };

    const icon = iconMap[tipo] || iconMap['info'];

    $('#rolesBody').html(`
        <tr>
            <td colspan="6" class="text-center text-${tipo} py-4">
                <i class="${icon}" style="font-size: 3rem;"></i>
                <p class="mt-3">${mensaje}</p>
            </td>
        </tr>
    `);
}

function manejarErrorAjax(xhr, mensajeBase) {
    let errorMsg = mensajeBase;
    let errorDetail = '';
    let iconClass = 'bi-exclamation-triangle';
    let iconColor = '#ffc107';

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
        errorDetail = `Status: ${xhr.status}`;
    }

    toastr.error(errorDetail, errorMsg);

    $('#rolesBody').html(`
        <tr>
            <td colspan="6" class="text-center py-5">
                <div class="error-container" style="padding: 2rem;">
                    <i class="${iconClass}" style="font-size: 4rem; color: ${iconColor};"></i>
                    <h5 class="mt-3">${errorMsg}</h5>
                    <p class="text-muted">${errorDetail}</p>
                </div>
            </td>
        </tr>
    `);
}

// Exponer funciones globales para debugging
window.cargarRoles = cargarRoles;
window.invalidateRolesCache = function () {
    cachedPermisosDisponibles = null;
    console.log('??? Caché de roles invalidado');
};
