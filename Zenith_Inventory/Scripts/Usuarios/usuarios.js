// Zenith Inventory - Users Management Script

let currentPage = 1;
const pageSize = 10;
let currentFilter = 'activos';
let searchTerm = '';
let currentUserId = null;
let availableRoles = [];

// ========================================
// TABS MANAGEMENT
// ========================================

// Initialize tabs on document ready
$(document).ready(function () {
    initializeTabs();
    initializeEventHandlers();

    // Load initial data only for active tab
    loadUsers();
    loadRoles();
});

function initializeTabs() {
    // Ensure first tab is active
    const firstTab = document.querySelector('#usuarios-tab');
    const firstTabPane = document.querySelector('#usuarios-content');

    if (firstTab && firstTabPane) {
        firstTab.classList.add('active');
        firstTab.setAttribute('aria-selected', 'true');
        firstTabPane.classList.add('show', 'active');
    }

    // Handle tab change events
    const tabButtons = document.querySelectorAll('[data-bs-toggle="tab"]');
    tabButtons.forEach(button => {
        button.addEventListener('shown.bs.tab', function (event) {
            // Hide all tab panes first
            document.querySelectorAll('.tab-pane').forEach(pane => {
                pane.classList.remove('show', 'active');
            });

            // Show the selected tab pane
            const targetId = this.getAttribute('data-bs-target');
            const targetPane = document.querySelector(targetId);
            if (targetPane) {
                targetPane.classList.add('show', 'active');
            }

            // Trigger specific actions based on tab
            const tabId = this.getAttribute('id');
            handleTabSwitch(tabId);
        });
    });
}

function handleTabSwitch(tabId) {
    // Clear any previous content issues
    document.querySelectorAll('.tab-pane').forEach(pane => {
        pane.style.display = 'none';
    });

    // Show only the active pane
    const activePane = document.querySelector('.tab-pane.active');
    if (activePane) {
        activePane.style.display = 'block';
    }

    // Load data if needed
    switch (tabId) {
        case 'usuarios-tab':
            // Already loaded on init
            break;
        case 'roles-tab':
            // Trigger roles load from roles.js
            if (typeof loadRoles === 'function' && $('#rolesBody').children().length === 0) {
                loadRoles();
            }
            break;
        case 'permisos-tab':
            // Nothing to load yet
            break;
    }
}

// ========================================
// INITIALIZATION
// ========================================

function initializeEventHandlers() {
    // Search
    $('#searchInput').on('keyup', debounce(function () {
        searchTerm = $(this).val();
        currentPage = 1;
        loadUsers();
    }, 500));

    // Filter
    $('#filterStatus').on('change', function () {
        currentFilter = $(this).val();
        currentPage = 1;
        loadUsers();
    });

    // Buttons
    $('#btnAddUser').on('click', openAddUserModal);
    $('#btnSaveUser').on('click', saveUser);
    $('#btnEditUserFromView').on('click', editUserFromView);

    // Password actions
    $('#btnGeneratePassword').on('click', generatePassword);
    $('#togglePassword').on('click', togglePasswordVisibility);
    $('#btnConfirmReset').on('click', resetPassword);
    $('#btnCopyPassword').on('click', copyPassword);

    // Modal events
    $('#userModal').on('hidden.bs.modal', resetUserForm);
    $('#resetPasswordModal').on('hidden.bs.modal', resetResetForm);
}

// ========================================
// LOAD DATA
// ========================================

function loadUsers() {
    console.time('loadUsers');
    showLoading();

    const incluirInactivos = currentFilter === 'todos' || currentFilter === 'inactivos';
    const soloBloqueados = currentFilter === 'bloqueados';

    $.ajax({
        url: '/Usuarios/GetUsuarios',
        type: 'GET',
        data: {
            page: currentPage,
            pageSize: pageSize,
            search: searchTerm,
            incluirInactivos: incluirInactivos,
            soloBloqueados: soloBloqueados
        },
        success: function (response) {
            console.timeEnd('loadUsers');
            console.log('Response de GetUsuarios:', response); // Debug
            hideLoading();

            // Detectar si la respuesta es HTML (página de error)
            if (typeof response === 'string' && (response.includes('<!DOCTYPE') || response.includes('<html') || response.includes('Acceso Denegado'))) {
                console.error('? Respuesta HTML detectada (posible error de permisos o autenticación)');

                // Usar el mismo diseño que AccessDenied.cshtml (sin instrucciones técnicas)
                $('#usersBody').html(`
                    <tr>
                        <td colspan="8" class="text-center py-5">
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

                toastr.error('No tiene permisos para ver usuarios.', 'Acceso Denegado', {
                    timeOut: 5000,
                    closeButton: true,
                    progressBar: true
                });

                return;
            }

            if (response.success) {
                renderUsers(response.data.items);
                renderPagination(response.data.pagination);
            } else {
                showError('Error al cargar usuarios', response.message);
            }
        },
        error: function (xhr, status, error) {
            console.timeEnd('loadUsers');
            console.error('Error AJAX al cargar usuarios:', { xhr, status, error });
            hideLoading();

            let errorMsg = 'Error al cargar los usuarios';
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
                errorDetail = 'No se pudo conectar con el servidor';
            }

            toastr.error(errorDetail, errorMsg);

            $('#usersBody').html(`
                <tr>
                    <td colspan="8" class="text-center py-5">
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

function loadRoles() {
    $.ajax({
        url: '/Usuarios/GetRolesDisponibles',
        type: 'GET',
        success: function (response) {
            if (response.success) {
                availableRoles = response.data.items;
            }
        }
    });
}

// ========================================
// RENDER FUNCTIONS
// ========================================

function renderUsers(users) {
    const tbody = $('#usersBody');
    tbody.empty();

    if (users.length === 0) {
        tbody.append(`
            <tr>
                <td colspan="8" class="text-center py-4 text-muted">
                    <i class="fas fa-users fa-3x mb-3 d-block"></i>
                    No se encontraron usuarios
                </td>
            </tr>
        `);
        return;
    }

    users.forEach(user => {
        const estadoBadge = getEstadoBadge(user.estadoTexto);
        const rolesDisplay = user.rolesAsignados || '<span class="text-muted">Sin roles</span>';

        tbody.append(`
            <tr>
                <td><strong>${user.codigo}</strong></td>
                <td>
                    <i class="fas fa-user text-primary me-2"></i>
                    <strong>${user.username}</strong>
                </td>
                <td>${user.nombreCompleto}</td>
                <td>
                    <i class="fas fa-envelope text-muted me-1"></i>
                    ${user.correo}
                </td>
                <td>
                    <span class="text-muted">${user.departamento || '--'}</span>
                </td>
                <td class="text-center">${estadoBadge}</td>
                <td>
                    <small>${rolesDisplay}</small>
                </td>
                <td class="text-center">
                    <div class="action-buttons">
                        <button class="btn btn-action btn-info" onclick="viewUser(${user.idUsuario})" title="Ver detalle">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-action btn-primary" onclick="editUser(${user.idUsuario})" title="Editar">
                            <i class="fas fa-edit"></i>
                        </button>
                        ${user.bloqueado ? `
                            <button class="btn btn-action btn-success" onclick="unlockUser(${user.idUsuario})" title="Desbloquear">
                                <i class="fas fa-unlock"></i>
                            </button>
                        ` : ''}
                        <button class="btn btn-action btn-warning" onclick="openResetPasswordModal(${user.idUsuario})" title="Resetear contraseña">
                            <i class="fas fa-key"></i>
                        </button>
                        <button class="btn btn-action btn-danger" onclick="deleteUser(${user.idUsuario}, '${user.username}')" title="Eliminar">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `);
    });
}

function renderPagination(pagination) {
    const container = $('#paginationContainer');
    container.empty();

    if (pagination.totalPages <= 1) return;

    let html = '<ul class="pagination">';

    // Previous
    html += `
        <li class="page-item ${!pagination.hasPreviousPage ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changePage(${currentPage - 1}); return false;">
                <i class="fas fa-chevron-left"></i>
            </a>
        </li>
    `;

    // Pages
    const startPage = Math.max(1, currentPage - 2);
    const endPage = Math.min(pagination.totalPages, currentPage + 2);

    for (let i = startPage; i <= endPage; i++) {
        html += `
            <li class="page-item ${i === currentPage ? 'active' : ''}">
                <a class="page-link" href="#" onclick="changePage(${i}); return false;">${i}</a>
            </li>
        `;
    }

    // Next
    html += `
        <li class="page-item ${!pagination.hasNextPage ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changePage(${currentPage + 1}); return false;">
                <i class="fas fa-chevron-right"></i>
            </a>
        </li>
    `;

    html += '</ul>';

    html += `<p class="text-muted small mt-2 text-center">
                Mostrando ${pagination.pageSize * (currentPage - 1) + 1} - ${Math.min(pagination.pageSize * currentPage, pagination.totalRecords)} de ${pagination.totalRecords} usuarios
             </p>`;

    container.html(html);
}

function renderRolesCheckboxes(selectedRoles = []) {
    const container = $('#rolesContainer');
    container.empty();

    if (availableRoles.length === 0) {
        container.append('<p class="text-muted">No hay roles disponibles</p>');
        return;
    }

    availableRoles.forEach(rol => {
        const isChecked = selectedRoles.includes(rol.idRol);
        container.append(`
            <div class="role-checkbox-item">
                <div class="form-check">
                    <input type="checkbox" 
                           class="form-check-input" 
                           id="rol_${rol.idRol}" 
                           value="${rol.idRol}" 
                           ${isChecked ? 'checked' : ''}>
                    <label class="form-check-label" for="rol_${rol.idRol}">
                        <strong>${rol.nombre}</strong>
                        <div class="role-description">${rol.descripcion || ''}</div>
                    </label>
                </div>
            </div>
        `);
    });
}

// ========================================
// MODAL OPERATIONS
// ========================================

function openAddUserModal() {
    resetUserForm();
    $('#userModalLabel').text('Nuevo Usuario');
    $('#userModalIcon').removeClass().addClass('fas fa-user-plus');
    $('#passwordSection').show();
    $('#userPassword').prop('required', true);
    renderRolesCheckboxes();
    $('#userModal').modal('show');
}

function editUser(userId) {
    showLoading();

    $.ajax({
        url: '/Usuarios/GetUsuarioDetalle',
        type: 'GET',
        data: { id: userId },
        success: function (response) {
            hideLoading();

            if (response.success) {
                const user = response.data;
                currentUserId = userId;

                $('#userId').val(userId);
                $('#userCodigo').val(user.codigo).prop('disabled', true);
                $('#userUsername').val(user.username).prop('disabled', true);
                $('#userNombre').val(user.nombre);
                $('#userApellido').val(user.apellido);
                $('#userCorreo').val(user.correo);
                $('#userTelefono').val(user.telefono);
                $('#userDepartamento').val(user.departamento);
                $('#userPuesto').val(user.puesto);
                $('#userActivo').prop('checked', user.activo);

                $('#passwordSection').hide();
                $('#userPassword').prop('required', false);

                const selectedRoles = user.roles.map(r => r.idRol);
                renderRolesCheckboxes(selectedRoles);

                $('#userModalLabel').text('Editar Usuario');
                $('#userModalIcon').removeClass().addClass('fas fa-user-edit');
                $('#userModal').modal('show');
            }
        },
        error: function () {
            hideLoading();
            showError('Error', 'No se pudo cargar el usuario');
        }
    });
}

function viewUser(userId) {
    showLoading();

    $.ajax({
        url: '/Usuarios/GetUsuarioDetalle',
        type: 'GET',
        data: { id: userId },
        success: function (response) {
            hideLoading();

            if (response.success) {
                currentUserId = userId;
                const user = response.data;

                // Información básica
                $('#viewUserUsername').text(user.username);
                $('#viewUserNombre').text(user.nombreCompleto);
                $('#viewUserCodigo').text(user.codigo);
                $('#viewUserCorreo').text(user.correo);
                $('#viewUserTelefono').text(user.telefono || '--');
                $('#viewUserDepartamento').text(user.departamento || '--');
                $('#viewUserPuesto').text(user.puesto || '--');

                // Estado
                const estadoBadge = $('#viewUserEstado');
                estadoBadge.attr('data-estado', user.estadoTexto);
                estadoBadge.text(user.estadoTexto);

                // Roles
                const rolesContainer = $('#viewUserRoles');
                rolesContainer.empty();

                if (user.roles && user.roles.length > 0) {
                    user.roles.forEach(rol => {
                        rolesContainer.append(`
                            <span class="role-badge">
                                <i class="fas fa-shield-alt"></i>
                                ${rol.nombre}
                            </span>
                        `);
                    });
                } else {
                    rolesContainer.append('<p class="no-roles">Sin roles asignados</p>');
                }

                // Estadísticas
                $('#viewUserUltimoLogin').text(user.ultimoLogin || 'Nunca');
                $('#viewUserIntentos').text(user.intentosFallidos);
                $('#viewUserPassTemp').text(user.requiereCambioPassword ? 'Sí' : 'No');

                // Auditoría
                $('#viewUserCreador').text(user.usuarioCreacion);
                $('#viewUserFechaCreacion').text(user.fechaCreacion);
                $('#viewUserModificador').text(user.usuarioModificacion || '--');
                $('#viewUserFechaModificacion').text(user.fechaModificacion || '--');

                $('#viewUserModal').modal('show');
            }
        },
        error: function () {
            hideLoading();
            showError('Error', 'No se pudo cargar el usuario');
        }
    });
}

function editUserFromView() {
    $('#viewUserModal').modal('hide');
    setTimeout(() => editUser(currentUserId), 500);
}

function saveUser() {
    if (!validateUserForm()) return;

    const isEdit = $('#userId').val() !== '';
    const userData = collectUserData();

    showLoading();

    const url = isEdit ? '/Usuarios/UpdateUsuario' : '/Usuarios/CreateUsuario';

    $.ajax({
        url: url,
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(userData),
        success: function (response) {
            hideLoading();

            if (response.success) {
                showSuccess(
                    isEdit ? 'Usuario actualizado' : 'Usuario creado',
                    response.message
                );
                $('#userModal').modal('hide');
                loadUsers();
            } else {
                showError('Error', response.message);
            }
        },
        error: function (xhr) {
            hideLoading();
            let errorMessage = 'No se pudo guardar el usuario';

            // Manejo de errores específicos
            if (xhr.status === 400) {
                errorMessage = 'Datos inválidos. Por favor, verifique la información ingresada.';
            } else if (xhr.status === 409) {
                errorMessage = 'Conflicto al guardar. Es posible que el usuario ya exista.';
            } else if (xhr.status === 500) {
                errorMessage = 'Error interno del servidor. Por favor, intente nuevamente más tarde.';
            }

            showError('Error', errorMessage);
        }
    });
}

function deleteUser(userId, username) {
    Swal.fire({
        title: '¿Eliminar usuario?',
        text: `Se desactivará el usuario "${username}". Esta acción no elimina los registros, solo desactiva el usuario.`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            showLoading();

            $.ajax({
                url: '/Usuarios/DeleteUsuario',
                type: 'POST',
                data: { id: userId },
                success: function (response) {
                    hideLoading();

                    if (response.success) {
                        showSuccess('Usuario eliminado', response.message);
                        loadUsers();
                    } else {
                        showError('Error', response.message);
                    }
                },
                error: function () {
                    hideLoading();
                    showError('Error', 'No se pudo eliminar el usuario');
                }
            });
        }
    });
}

// ========================================
// PASSWORD OPERATIONS
// ========================================

function openResetPasswordModal(userId) {
    $('#resetUserId').val(userId);
    $('#newPasswordDisplay').addClass('d-none');
    $('#btnConfirmReset').show();
    $('#resetPasswordModal').modal('show');
}

function resetPassword() {
    const userId = $('#resetUserId').val();

    showLoading();

    $.ajax({
        url: '/Usuarios/ResetearPassword',
        type: 'POST',
        data: { id: userId },
        success: function (response) {
            hideLoading();

            if (response.success) {
                $('#newPasswordValue').val(response.data.passwordTemporal);
                $('#newPasswordDisplay').removeClass('d-none');
                $('#btnConfirmReset').hide();

                showSuccess('Contraseña reseteada', response.message);
            } else {
                showError('Error', response.message);
            }
        },
        error: function () {
            hideLoading();
            showError('Error', 'No se pudo resetear la contraseña');
        }
    });
}

function unlockUser(userId) {
    Swal.fire({
        title: '¿Desbloquear usuario?',
        text: 'Se desbloqueará el usuario y se resetearán los intentos fallidos.',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, desbloquear',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            showLoading();

            $.ajax({
                url: '/Usuarios/DesbloquearUsuario',
                type: 'POST',
                data: { id: userId },
                success: function (response) {
                    hideLoading();

                    if (response.success) {
                        showSuccess('Usuario desbloqueado', response.message);
                        loadUsers();
                    } else {
                        showError('Error', response.message);
                    }
                },
                error: function () {
                    hideLoading();
                    showError('Error', 'No se pudo desbloquear el usuario');
                }
            });
        }
    });
}

function generatePassword() {
    $.ajax({
        url: '/Usuarios/GenerarPasswordTemporal',
        type: 'GET',
        success: function (response) {
            if (response.success) {
                $('#userPassword').val(response.data.passwordTemporal);
                $('#userPassword').attr('type', 'text');

                Swal.fire({
                    icon: 'success',
                    title: 'Contraseña generada',
                    text: response.data.passwordTemporal,
                    timer: 3000
                });
            }
        }
    });
}

function togglePasswordVisibility() {
    const passwordInput = $('#userPassword');
    const icon = $('#togglePassword i');

    if (passwordInput.attr('type') === 'password') {
        passwordInput.attr('type', 'text');
        icon.removeClass('fa-eye').addClass('fa-eye-slash');
    } else {
        passwordInput.attr('type', 'password');
        icon.removeClass('fa-eye-slash').addClass('fa-eye');
    }
}

function copyPassword() {
    const password = $('#newPasswordValue').val();
    navigator.clipboard.writeText(password).then(() => {
        showSuccess('Copiado', 'Contraseña copiada al portapapeles');
    });
}

// ========================================
// FORM VALIDATION & DATA COLLECTION
// ========================================

function validateUserForm() {
    const codigo = $('#userCodigo').val();
    const username = $('#userUsername').val();
    const password = $('#userPassword').val();
    const nombre = $('#userNombre').val();
    const correo = $('#userCorreo').val();
    const isEdit = $('#userId').val() !== '';

    if (!codigo || codigo <= 0) {
        showError('Error de validación', 'El código es requerido y debe ser mayor a 0');
        return false;
    }

    if (!username || username.length < 3) {
        showError('Error de validación', 'El nombre de usuario debe tener al menos 3 caracteres');
        return false;
    }

    if (!isEdit && (!password || password.length < 6)) {
        showError('Error de validación', 'La contraseña debe tener al menos 6 caracteres');
        return false;
    }

    if (!nombre || nombre.length < 2) {
        showError('Error de validación', 'El nombre es requerido');
        return false;
    }

    if (!correo || !validateEmail(correo)) {
        showError('Error de validación', 'El correo electrónico no es válido');
        return false;
    }

    return true;
}

function collectUserData() {
    const isEdit = $('#userId').val() !== '';
    const selectedRoles = [];

    $('#rolesContainer input[type="checkbox"]:checked').each(function () {
        selectedRoles.push(parseInt($(this).val()));
    });

    const data = {
        Nombre: $('#userNombre').val(),
        Apellido: $('#userApellido').val(),
        Correo: $('#userCorreo').val(),
        Telefono: $('#userTelefono').val(),
        Departamento: $('#userDepartamento').val(),
        Puesto: $('#userPuesto').val(),
        Activo: $('#userActivo').is(':checked')
    };

    if (isEdit) {
        data.IdUsuario = parseInt($('#userId').val());
    } else {
        data.Codigo = parseInt($('#userCodigo').val());
        data.Username = $('#userUsername').val();
        data.Password = $('#userPassword').val();
        data.PasswordTemporal = $('#userPasswordTemporal').is(':checked');
        data.RolesIds = selectedRoles;
    }

    return data;
}

function resetUserForm() {
    $('#userForm')[0].reset();
    $('#userId').val('');
    $('#userCodigo').prop('disabled', false);
    $('#userUsername').prop('disabled', false);
    $('#userActivo').prop('checked', true);
    $('#userPasswordTemporal').prop('checked', true);
    $('#passwordSection').show();
    $('#userPassword').prop('required', true).attr('type', 'password');
    currentUserId = null;
    renderRolesCheckboxes();
}

function resetResetForm() {
    $('#resetUserId').val('');
    $('#newPasswordDisplay').addClass('d-none');
    $('#newPasswordValue').val('');
    $('#btnConfirmReset').show();
}

// ========================================
// UTILITY FUNCTIONS
// ========================================

function changePage(page) {
    currentPage = page;
    loadUsers();
    window.scrollTo(0, 0);
}

function getEstadoBadge(estado) {
    const badges = {
        'Activo': '<span class="badge-estado activo">Activo</span>',
        'Bloqueado': '<span class="badge-estado bloqueado">Bloqueado</span>',
        'Inactivo': '<span class="badge-estado inactivo">Inactivo</span>'
    };
    return badges[estado] || '<span class="badge-estado inactivo">--</span>';
}

function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
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

function showLoading() {
    if ($('.loading-overlay').length === 0) {
        $('body').append(`
            <div class="loading-overlay">
                <div class="loading-spinner"></div>
            </div>
        `);
    }
}

function hideLoading() {
    $('.loading-overlay').remove();
}

function showSuccess(title, message) {
    Swal.fire({
        icon: 'success',
        title: title,
        text: message,
        timer: 3000,
        showConfirmButton: false
    });
}

function showError(title, message) {
    Swal.fire({
        icon: 'error',
        title: title,
        text: message
    });
}
