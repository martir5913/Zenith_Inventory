/**
 * Gestión de Categorías - JavaScript con AJAX
 * Sistema ultra-simple para SPA
 */

const CategoriasApp = {
    estado: {
        currentPage: 1,
        pageSize: 10,
        searchTerm: '',
        categorias: [],
        totalRecords: 0,
        totalPages: 0,
        isLoading: false,
        modoEdicion: false,
        categoriaEditando: null
    },

    init() {
        console.log('?? CATEGORIAS: Iniciando CategoriasApp...');

        // Bind events inmediatamente
        this.bindEvents();

        // Cargar datos
        this.cargarCategorias();

        console.log('? CATEGORIAS: Inicialización completa');
    },

    bindEvents() {
        console.log('?? CATEGORIAS: Configurando eventos...');

        // Limpiar eventos anteriores
        $(document).off('.categorias');

        // Configurar eventos con delegation
        $(document).on('input.categorias', '#txtBuscar', (e) => {
            clearTimeout(this.searchTimeout);
            this.searchTimeout = setTimeout(() => {
                this.estado.searchTerm = $(e.target).val();
                this.estado.currentPage = 1;
                this.cargarCategorias();
            }, 150);
        });

        $(document).on('change.categorias', '#selectPageSize', (e) => {
            this.estado.pageSize = parseInt($(e.target).val());
            this.estado.currentPage = 1;
            this.cargarCategorias();
        });

        $(document).on('click.categorias', '#btnLimpiar', () => {
            this.limpiarFiltros();
        });

        $(document).on('click.categorias', '#btnNuevaCategoria', () => {
            this.abrirModalNuevo();
        });

        $(document).on('click.categorias', '#btnGuardar', () => {
            this.guardarCategoria();
        });

        $(document).on('submit.categorias', '#formCategoria', (e) => {
            e.preventDefault();
            this.guardarCategoria();
        });

        console.log('? CATEGORIAS: Eventos configurados');
    },

    cargarCategorias() {
        console.log('?? CATEGORIAS: Iniciando carga de categorías...');
        console.log('?? CATEGORIAS: Estado actual:', {
            currentPage: this.estado.currentPage,
            pageSize: this.estado.pageSize,
            searchTerm: this.estado.searchTerm
        });

        this.mostrarLoading(true);

        const url = `/Equipos/GetCategorias?page=${this.estado.currentPage}&pageSize=${this.estado.pageSize}&search=${encodeURIComponent(this.estado.searchTerm || '')}`;
        console.log('?? CATEGORIAS: URL de petición:', url);

        $.ajax({
            url: url,
            type: 'GET',
            dataType: 'json',
            success: (result) => {
                console.log('?? CATEGORIAS: Respuesta recibida:', result);

                if (result.success) {
                    this.estado.categorias = result.data.items || [];
                    this.estado.totalRecords = result.data.pagination?.totalRecords || 0;
                    this.estado.totalPages = result.data.pagination?.totalPages || 0;
                    this.estado.currentPage = result.data.pagination?.currentPage || 1;

                    console.log('?? CATEGORIAS: Datos procesados:', {
                        categoriasCount: this.estado.categorias.length,
                        totalRecords: this.estado.totalRecords,
                        totalPages: this.estado.totalPages
                    });

                    // Render content
                    this.renderCategorias();
                    this.renderPaginacion();
                    this.renderInfoRegistros();
                    this.updateVisibility();
                } else {
                    console.error('? CATEGORIAS: Error en respuesta:', result.message);
                    this.mostrarError(result.message);
                }
            },
            error: (xhr, status, error) => {
                console.error('? CATEGORIAS: Error en petición AJAX:', {
                    status: xhr.status,
                    statusText: xhr.statusText,
                    responseText: xhr.responseText,
                    error: error
                });
                this.mostrarError('Error al cargar las categorías. Por favor, intente nuevamente.');
            },
            complete: () => {
                this.mostrarLoading(false);
                console.log('?? CATEGORIAS: Petición completada');
            }
        });
    },

    renderInfoRegistros() {
        const inicio = (this.estado.currentPage - 1) * this.estado.pageSize + 1;
        const fin = Math.min(this.estado.currentPage * this.estado.pageSize, this.state.totalRecords);

        $('#infoRegistros').text(`Mostrando ${inicio} - ${fin} de ${this.estado.totalRecords} registros`);
    },

    irAPagina(page) {
        if (page < 1 || page > this.estado.totalPages || page === this.estado.currentPage) {
            return;
        }
        this.estado.currentPage = page;
        this.cargarCategorias();
    },

    limpiarFiltros() {
        $('#txtBuscar').val('');
        $('#selectPageSize').val('10');
        this.estado.searchTerm = '';
        this.estado.pageSize = 10;
        this.estado.currentPage = 1;
        this.cargarCategorias();
    },

    abrirModalNuevo() {
        this.estado.modoEdicion = false;
        this.estado.categoriaEditando = null;

        $('#modalTitulo').text('Nueva Categoría');
        $('#idCategoria').val('0');
        $('#nombre').val('');
        $('#descripcion').val('');
        $('#activo').prop('checked', true);

        this.limpiarErrores();
        $('#modalCategoria').modal('show');
    },

    editar(id) {
        const categoria = this.estado.categorias.find(c => c.IdCategoria === id);

        if (!categoria) {
            this.mostrarError('Categoría no encontrada');
            return;
        }

        this.estado.modoEdicion = true;
        this.estado.categoriaEditando = categoria;

        $('#modalTitulo').text('Editar Categoría');
        $('#idCategoria').val(categoria.IdCategoria);
        $('#nombre').val(categoria.Nombre);
        $('#descripcion').val(categoria.Descripcion);
        $('#activo').prop('checked', categoria.Activo);

        this.limpiarErrores();
        $('#modalCategoria').modal('show');
    },

    guardarCategoria() {
        if (!this.validarFormulario()) {
            return;
        }

        const categoria = {
            nombre: $('#nombre').val().trim(),
            descripcion: $('#descripcion').val().trim(),
            activo: $('#activo').prop('checked')
        };

        const url = this.estado.modoEdicion ? '/Equipos/UpdateCategoria' : '/Equipos/CreateCategoria';
        const token = $('input[name="__RequestVerificationToken"]').val();

        // Agregar ID si es edición
        if (this.estado.modoEdicion) {
            categoria.id = parseInt($('#idCategoria').val());
        }

        $.ajax({
            url: url,
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(categoria),
            headers: {
                'RequestVerificationToken': token
            },
            success: (result) => {
                if (result.success) {
                    this.mostrarExito(result.message);
                    $('#modalCategoria').modal('hide');
                    this.cargarCategorias();
                } else {
                    this.mostrarError(result.message);
                }
            },
            error: (xhr, status, error) => {
                console.error('Error al guardar categoría:', error);
                this.mostrarError('Error al guardar la categoría. Por favor, intente nuevamente.');
            }
        });
    },

    eliminar(id) {
        const categoria = this.estado.categorias.find(c => c.IdCategoria === id);

        if (!categoria) {
            this.mostrarError('Categoría no encontrada');
            return;
        }

        Swal.fire({
            title: '¿Está seguro?',
            text: `¿Desea eliminar la categoría "${categoria.Nombre}"?`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Sí, eliminar',
            cancelButtonText: 'Cancelar'
        }).then((result) => {
            if (result.isConfirmed) {
                const token = $('input[name="__RequestVerificationToken"]').val();

                $.ajax({
                    url: `/Equipos/DeleteCategoria/${id}`,
                    type: 'POST',
                    contentType: 'application/json',
                    headers: {
                        'RequestVerificationToken': token
                    },
                    success: (result) => {
                        if (result.success) {
                            this.mostrarExito(result.message);
                            this.cargarCategorias();
                        } else {
                            this.mostrarError(result.message);
                        }
                    },
                    error: (xhr, status, error) => {
                        console.error('Error al eliminar categoría:', error);
                        this.mostrarError('Error al eliminar la categoría. Por favor, intente nuevamente.');
                    }
                });
            }
        });
    },

    cambiarEstado(id, nuevoEstado) {
        const categoria = this.estado.categorias.find(c => c.IdCategoria === id);

        if (!categoria) {
            this.mostrarError('Categoría no encontrada');
            return;
        }

        const accion = nuevoEstado ? 'activar' : 'desactivar';
        const token = $('input[name="__RequestVerificationToken"]').val();

        $.ajax({
            url: `/Equipos/UpdateCategoria`,
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                id: id,
                nombre: categoria.Nombre,
                descripcion: categoria.Descripcion,
                activo: nuevoEstado
            }),
            headers: {
                'RequestVerificationToken': token
            },
            success: (result) => {
                if (result.success) {
                    this.mostrarExito(result.message);
                    this.cargarCategorias();
                } else {
                    this.mostrarError(result.message);
                }
            },
            error: (xhr, status, error) => {
                console.error(`Error al ${accion} categoría:`, error);
                this.mostrarError(`Error al ${accion} la categoría. Por favor, intente nuevamente.`);
            }
        });
    },

    validarFormulario() {
        this.limpiarErrores();
        let valido = true;

        const nombre = $('#nombre').val().trim();

        if (!nombre) {
            $('#errorNombre').text('El nombre es requerido').show();
            valido = false;
        } else if (nombre.length > 100) {
            $('#errorNombre').text('El nombre no puede exceder 100 caracteres').show();
            valido = false;
        }

        return valido;
    },

    limpiarErrores() {
        $('#errorNombre').hide();
    },

    mostrarLoading(mostrar) {
        this.estado.isLoading = mostrar;

        if (mostrar) {
            $('#loadingSpinner').show();
            $('#tablaContainer').hide();
            $('#sinResultados').hide();
        } else {
            $('#loadingSpinner').hide();
        }
    },

    mostrarExito(mensaje) {
        toastr.success(mensaje, 'Éxito', {
            closeButton: true,
            progressBar: true,
            timeOut: 3000
        });
    },

    mostrarError(mensaje) {
        toastr.error(mensaje, 'Error', {
            closeButton: true,
            progressBar: true,
            timeOut: 5000
        });
    },

    renderCategorias() {
        const tbody = $('#tablaCuerpo');
        const sinResultados = $('#sinResultados');
        const tablaContainer = $('#tablaContainer');

        tbody.empty();

        if (this.estado.categorias.length === 0) {
            tablaContainer.hide();
            sinResultados.show();
            return;
        }

        tablaContainer.show();
        sinResultados.hide();

        this.estado.categorias.forEach(cat => {
            const estadoBadge = cat.Activo
                ? '<span class="badge badge-success"><i class="fas fa-check"></i> Activo</span>'
                : '<span class="badge badge-secondary"><i class="fas fa-times"></i> Inactivo</span>';

            const row = `
                <tr>
                    <td>${cat.IdCategoria}</td>
                    <td><strong>${this.escapeHtml(cat.Nombre)}</strong></td>
                    <td>${this.escapeHtml(cat.Descripcion || '-')}</td>
                    <td class="text-center">
                        <span class="badge badge-info">${cat.TotalSubcategorias}</span>
                    </td>
                    <td class="text-center">${estadoBadge}</td>
                    <td class="text-center">
                        <div class="btn-group" role="group">
                            <button type="button" 
                            class="btn btn-sm btn-info" 
                            onclick="CategoriasApp.editar(${cat.IdCategoria})"
                            title="Editar">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button type="button" 
                            class="btn btn-sm ${cat.Activo ? 'btn-warning' : 'btn-success'}" 
                            onclick="CategoriasApp.cambiarEstado(${cat.IdCategoria}, ${!cat.Activo})"
                            title="${cat.Activo ? 'Desactivar' : 'Activar'}">
                                <i class="fas fa-${cat.Activo ? 'ban' : 'check'}"></i>
                            </button>
                            <button type="button" 
                            class="btn btn-sm btn-danger" 
                            onclick="CategoriasApp.eliminar(${cat.IdCategoria})"
                            title="Eliminar">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `;
            tbody.append(row);
        });
    },

    renderPaginacion() {
        const paginacion = $('#paginacion');
        paginacion.empty();

        if (this.estado.totalPages <= 1) {
            return;
        }

        const disabledPrev = this.estado.currentPage === 1 ? 'disabled' : '';
        paginacion.append(`
            <li class="page-item ${disabledPrev}">
                <a class="page-link" href="#" onclick="CategoriasApp.irAPagina(${this.estado.currentPage - 1}); return false;">
                    <i class="fas fa-chevron-left"></i>
                </a>
            </li>
        `);

        const startPage = Math.max(1, this.estado.currentPage - 2);
        const endPage = Math.min(this.estado.totalPages, this.estado.currentPage + 2);

        if (startPage > 1) {
            paginacion.append(`
                <li class="page-item">
                    <a class="page-link" href="#" onclick="CategoriasApp.irAPagina(1); return false;">1</a>
                </li>
            `);

            if (startPage > 2) {
                paginacion.append('<li class="page-item disabled"><span class="page-link">...</span></li>');
            }
        }

        for (let i = startPage; i <= endPage; i++) {
            const active = i === this.estado.currentPage ? 'active' : '';
            paginacion.append(`
                <li class="page-item ${active}">
                    <a class="page-link" href="#" onclick="CategoriasApp.irAPagina(${i}); return false;">${i}</a>
                </li>
            `);
        }

        if (endPage < this.estado.totalPages) {
            if (endPage < this.estado.totalPages - 1) {
                paginacion.append('<li class="page-item disabled"><span class="page-link">...</span></li>');
            }
            paginacion.append(`
                <li class="page-item">
                    <a class="page-link" href="#" onclick="CategoriasApp.irAPagina(${this.estado.totalPages}); return false;">${this.estado.totalPages}</a>
                </li>
            `);
        }

        const disabledNext = this.estado.currentPage === this.estado.totalPages ? 'disabled' : '';
        paginacion.append(`
            <li class="page-item ${disabledNext}">
                <a class="page-link" href="#" onclick="CategoriasApp.irAPagina(${this.estado.currentPage + 1}); return false;">
                    <i class="fas fa-chevron-right"></i>
                </a>
            </li>
        `);
    },

    updateVisibility() {
        if (this.estado.categorias.length === 0) {
            $('#tablaContainer').hide();
            $('#sinResultados').show();
        } else {
            $('#tablaContainer').show();
            $('#sinResultados').hide();
        }
    },

    /**
   * Escapa HTML para prevenir XSS
     */
    escapeHtml(text) {
        if (!text) return '';
        const map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return text.replace(/[&<>"']/g, m => map[m]);
    }
};

// ========================================
// INICIALIZACIÓN AUTOMÁTICA
// ========================================

// Inicialización automática cuando el DOM está listo
$(document).ready(function() {
    console.log('?? CATEGORIAS: Document ready ejecutado');

    // Verificar si estamos en la página de categorías
    const hasSearchBox = $('#txtBuscar').length > 0;
    const hasNewButton = $('#btnNuevaCategoria').length > 0;

    console.log('?? CATEGORIAS: Verificación de elementos:', {
        hasSearchBox,
        hasNewButton,
        searchBoxExists: $('#txtBuscar').length,
        newButtonExists: $('#btnNuevaCategoria').length
    });

    if (hasSearchBox && hasNewButton) {
        console.log('? CATEGORIAS: Elementos encontrados, inicializando...');
        CategoriasApp.init();
    } else {
        console.log('?? CATEGORIAS: No estamos en página de categorías, omitiendo inicialización');
    }
});

// ========================================
// DIAGNÓSTICO DEL SISTEMA SPA
// ========================================

window.diagnosticarSPA = function() {
    console.log('?? === DIAGNÓSTICO DEL SISTEMA SPA ===');

    // Verificar elementos del DOM
    console.log('?? Elementos del DOM:');
    console.log('  - #txtBuscar:', $('#txtBuscar').length > 0 ? '? Existe' : '? No existe');
    console.log('  - #btnNuevaCategoria:', $('#btnNuevaCategoria').length > 0 ? '? Existe' : '? No existe');
    console.log('  - .content .container-fluid:', $('.content .container-fluid').length > 0 ? '? Existe' : '? No existe');

    // Verificar scripts cargados
    console.log('?? Scripts cargados:');
    const categoriasScript = document.querySelector('script[src*="categorias.js"]');
    console.log('  - categorias.js:', categoriasScript ? '? Cargado' : '? No cargado');

    // Verificar estado del SPA
    console.log('?? Estado del SPA:');
    if (typeof ZenithSPA !== 'undefined') {
        console.log('  - ZenithSPA:', '? Definido');
        console.log('  - Controlador actual:', ZenithSPA.estado.currentController);
        console.log('  - Acción actual:', ZenithSPA.estado.currentAction);
        console.log('  - Scripts cargados:', ZenithSPA.estado.loadedScripts);
    } else {
        console.log('  - ZenithSPA:', '? No definido');
    }

    // Verificar estado de categorías
    console.log('?? Estado de Categorías:');
    if (typeof CategoriasApp !== 'undefined') {
        console.log('  - CategoriasApp:', '? Definido');
        console.log('  - Estado:', CategoriasApp.estado);
    } else {
        console.log('  - CategoriasApp:', '? No definido');
    }

    // Verificar eventos
    console.log('?? Eventos configurados:');
    const hasSearchEvents = $._data(document, 'events')?.input?.some(e => e.namespace === 'categorias');
    const hasClickEvents = $._data(document, 'events')?.click?.some(e => e.namespace === 'categorias');
    console.log('  - Eventos input.categorias:', hasSearchEvents ? '? Configurados' : '? No configurados');
    console.log('  - Eventos click.categorias:', hasClickEvents ? '? Configurados' : '? No configurados');

    console.log('?? === FIN DEL DIAGNÓSTICO ===');
};

// Función para probar la funcionalidad manualmente
window.probarCategorias = function() {
    console.log('?? Probando funcionalidad de categorías...');

    if (typeof CategoriasApp === 'undefined') {
        console.error('? CategoriasApp no está definido');
        return;
    }

    // Probar carga de datos
    console.log('?? Probando carga de categorías...');
    CategoriasApp.cargarCategorias();

    // Probar apertura de modal
    console.log('?? Probando apertura de modal...');
    setTimeout(() => {
        CategoriasApp.abrirModalNuevo();
    }, 1000);
};

console.log('?? Herramientas de diagnóstico disponibles:');
console.log('  - diagnosticarSPA(): Ejecuta diagnóstico completo');
console.log('  - probarCategorias(): Prueba funcionalidad manualmente');

// Exponer globalmente
window.CategoriasApp = CategoriasApp;
console.log('?? CATEGORIAS: Script cargado, CategoriasApp expuesto globalmente');
