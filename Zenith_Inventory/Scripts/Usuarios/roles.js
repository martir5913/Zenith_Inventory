// Zenith Inventory - Roles Management Script

let currentRolesPage = 1;
const rolesPageSize = 10;
let rolesSearchTerm = '';
let rolesFilter = 'activos';
let rolesTabInitialized = false;

// ========================================
// ROLES TAB INITIALIZATION
// ========================================

// Initialize when roles tab is shown
$(document).on('shown.bs.tab', '#roles-tab', function () {
    if (!rolesTabInitialized) {
        loadRoles();
        rolesTabInitialized = true;
    }
});

// Event handlers - Use event delegation
$(document).on('keyup', '#searchRoles', debounce(function () {
    rolesSearchTerm = $(this).val();
    currentRolesPage = 1;
    loadRoles();
}, 500));

$(document).on('change', '#filterRolesStatus', function () {
    rolesFilter = $(this).val();
    currentRolesPage = 1;
    loadRoles();
});

// ========================================
// LOAD ROLES
// ========================================

function loadRoles() {
    console.time('loadRoles');
    showLoading();
    
    const incluirInactivos = rolesFilter === 'todos' || rolesFilter === 'inactivos';

    $.ajax({
        url: '/Usuarios/GetRolesPaginados',
        type: 'GET',
        data: {
            page: currentRolesPage,
            pageSize: rolesPageSize,
            search: rolesSearchTerm,
            incluirInactivos: incluirInactivos
        },
        success: function (response) {
            console.timeEnd('loadRoles');
            console.log('Response de GetRolesPaginados:', response); // Debug
            hideLoading();
            
            // Detectar si la respuesta es HTML (página de error)
            if (typeof response === 'string' && (response.includes('<!DOCTYPE') || response.includes('<html') || response.includes('Acceso Denegado'))) {
                console.error('❌ Respuesta HTML detectada (posible error de permisos o autenticación)');
                
                // Usar el mismo diseño que AccessDenied.cshtml (sin instrucciones técnicas)
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
                                <p class="mb-0 text-muted">
                                    <i class="bi bi-info-circle me-1"></i>
                                    Si cree que esto es un error, por favor contacte al administrador del sistema.
                                </p>
                            </div>
                        </td>
                    </tr>
                `);
                
                toastr.error('No tiene permisos para ver roles.', 'Acceso Denegado', {
                    timeOut: 5000,
                    closeButton: true,
                    progressBar: true
                });
                
                return;
            }
            
            if (response.success) {
                renderRoles(response.data.items);
                renderRolesPagination(response.data.pagination);
            } else {
                showError('Error al cargar roles', response.message);
            }
        },
        error: function (xhr, status, error) {
            console.timeEnd('loadRoles');
            console.error('Error AJAX al cargar roles:', {xhr, status, error});
            hideLoading();
            
            let errorMsg = 'Error al cargar los roles';
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
                errorDetail = 'Error de conexión al servidor';
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
    });
}

// ========================================
// RENDER ROLES
// ========================================

function renderRoles(roles) {
    const tbody = $('#rolesBody');
    tbody.empty();

    if (roles.length === 0) {
        tbody.append(`
            <tr>
                <td colspan="6" class="text-center py-4 text-muted">
                    <i class="fas fa-user-shield fa-3x mb-3 d-block"></i>
                    No se encontraron roles
                </td>
            </tr>
        `);
        return;
    }

    roles.forEach(rol => {
        const estadoBadge = rol.activo ? 
            '<span class="badge badge-success">Activo</span>' : 
            '<span class="badge badge-secondary">Inactivo</span>';

        const nombreTooltip = rol.nombre.length > 35 ? `title="${escapeHtml(rol.nombre)}"` : '';
        const descripcionTooltip = rol.descripcion && rol.descripcion.length > 50 ? `title="${escapeHtml(rol.descripcion)}"` : '';

        tbody.append(`
            <tr>
                <td ${nombreTooltip}>
                    <i class="fas fa-shield-alt text-primary me-2"></i>
                    <strong>${escapeHtml(rol.nombre)}</strong>
                </td>
                <td ${descripcionTooltip}>
                    ${escapeHtml(rol.descripcion) || '<span class="text-muted">Sin descripción</span>'}
                </td>
                <td class="text-center">
                    <span class="counter-badge sm">${rol.totalUsuarios || 0}</span>
                </td>
                <td class="text-center">
                    <span class="counter-badge sm bg-success">${rol.totalPermisos || 0}</span>
                </td>
                <td class="text-center">${estadoBadge}</td>
                <td class="text-center">
                    <div class="action-buttons">
                        <button class="btn btn-action btn-info" onclick="viewRolPermisos(${rol.idRol})" title="Ver permisos">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `);
    });

    if (typeof bootstrap !== 'undefined' && bootstrap.Tooltip) {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[title]'));
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl, {
                placement: 'top',
                trigger: 'hover'
            });
        });
    }
}

function renderRolesPagination(pagination) {
    const container = $('#paginationRolesContainer');
    container.empty();

    if (pagination.totalPages <= 1) return;

    let html = '<ul class="pagination">';

    html += `
        <li class="page-item ${!pagination.hasPreviousPage ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changeRolesPage(${currentRolesPage - 1}); return false;">
                <i class="fas fa-chevron-left"></i>
            </a>
        </li>
    `;

    const startPage = Math.max(1, currentRolesPage - 2);
    const endPage = Math.min(pagination.totalPages, currentRolesPage + 2);

    for (let i = startPage; i <= endPage; i++) {
        html += `
            <li class="page-item ${i === currentRolesPage ? 'active' : ''}">
                <a class="page-link" href="#" onclick="changeRolesPage(${i}); return false;">${i}</a>
            </li>
        `;
    }

    html += `
        <li class="page-item ${!pagination.hasNextPage ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changeRolesPage(${currentRolesPage + 1}); return false;">
                <i class="fas fa-chevron-right"></i>
            </a>
        </li>
    `;

    html += '</ul>';
    
    html += `<p class="text-muted small mt-2 text-center">
                Mostrando ${pagination.pageSize * (currentRolesPage - 1) + 1} - ${Math.min(pagination.pageSize * currentRolesPage, pagination.totalRecords)} de ${pagination.totalRecords} roles
             </p>`;
    
    container.html(html);
}

// ========================================
// VIEW ROL PERMISSIONS
// ========================================

function viewRolPermisos(rolId) {
    showLoading();
    
    $.ajax({
        url: '/Usuarios/GetPermisosRol',
        type: 'GET',
        data: { idRol: rolId },
        success: function (response) {
            hideLoading();
            
            if (typeof response === 'string' && (response.includes('<!DOCTYPE') || response.includes('<html') || response.includes('Acceso Denegado'))) {
                console.error('❌ Respuesta HTML detectada al cargar permisos del rol');
                
                Swal.fire({
                    icon: 'error',
                    title: 'Acceso Denegado',
                    text: 'No tiene permisos para ver los permisos de este rol.',
                    confirmButtonColor: '#dc3545',
                    confirmButtonText: '<i class="bi bi-x-circle me-2"></i>Cerrar'
                });
                
                return;
            }
            
            if (response.success) {
                const permisos = response.data.items;
                
                let html = '<div class="permisos-list p-3" style="max-height: 500px; overflow-y: auto;">';
                
                if (permisos.length === 0) {
                    html += '<p class="text-muted text-center">Este rol no tiene permisos asignados</p>';
                } else {
                    const permisosPorModulo = {};
                    permisos.forEach(p => {
                        if (!permisosPorModulo[p.modulo]) {
                            permisosPorModulo[p.modulo] = [];
                        }
                        permisosPorModulo[p.modulo].push(p);
                    });

                    Object.keys(permisosPorModulo).forEach(modulo => {
                        html += `<div class="mb-3">`;
                        html += `<h6 class="text-primary border-bottom pb-2">
                                    <i class="fas fa-cube me-2"></i>${escapeHtml(modulo)}
                                 </h6>`;
                        html += `<ul class="list-unstyled ps-4">`;
                        
                        permisosPorModulo[modulo].forEach(p => {
                            const badgeClass = getAccionBadgeClass(p.accion);
                            html += `<li class="mb-2">
                                        <i class="fas fa-shield-alt me-2 text-success"></i>
                                        ${escapeHtml(p.nombre)} 
                                        <span class="badge ${badgeClass} ms-2">${escapeHtml(p.accion)}</span>
                                     </li>`;
                        });
                        
                        html += '</ul>';
                        html += '</div>';
                    });
                }
                
                html += '</div>';
                
                Swal.fire({
                    title: '<i class="fas fa-user-shield me-2"></i>Permisos del Rol',
                    html: html,
                    width: 700,
                    showCloseButton: true,
                    confirmButtonText: '<i class="fas fa-times me-2"></i>Cerrar',
                    confirmButtonColor: '#6c757d',
                    customClass: {
                        popup: 'swal-wide',
                        htmlContainer: 'swal-html-container-scroll'
                    }
                });
            } else {
                showError('Error', response.message);
            }
        },
        error: function (xhr, status, error) {
            hideLoading();
            
            let errorMsg = 'Error al cargar permisos';
            let errorDetail = 'No se pudieron cargar los permisos del rol';
            
            if (xhr.status === 403) {
                errorMsg = 'Acceso Denegado';
                errorDetail = 'No tiene permisos para ver los permisos de este rol.';
            } else if (xhr.status === 401) {
                errorMsg = 'Sesión Expirada';
                errorDetail = 'Por favor, inicie sesión nuevamente.';
            } else if (xhr.status === 404) {
                errorMsg = 'Rol No Encontrado';
                errorDetail = 'El rol solicitado no existe.';
            }
            
            Swal.fire({
                icon: 'error',
                title: errorMsg,
                text: errorDetail,
                confirmButtonColor: '#dc3545',
                confirmButtonText: '<i class="bi bi-x-circle me-2"></i>Cerrar'
            });
        }
    });
}

// ========================================
// UTILITY FUNCTIONS
// ========================================

function changeRolesPage(page) {
    currentRolesPage = page;
    loadRoles();
    
    const rolesContent = document.getElementById('roles-content');
    if (rolesContent) {
        rolesContent.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

function getAccionBadgeClass(accion) {
    const badges = {
        'LEER': 'badge-info',
        'CREAR': 'badge-success',
        'ACTUALIZAR': 'badge-warning',
        'ELIMINAR': 'badge-danger'
    };
    return badges[accion] || 'badge-secondary';
}

function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.toString().replace(/[&<>"']/g, function(m) { return map[m]; });
}

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
