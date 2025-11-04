/**
 * Gestión de Categorías - JavaScript con AJAX
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
        this.bindEvents();
        this.cargarCategorias();
    },

    bindEvents() {
        let searchTimeout;
        $('#txtBuscar').on('input', () => {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                this.estado.searchTerm = $('#txtBuscar').val();
                this.estado.currentPage = 1;
                this.cargarCategorias();
            }, 150);
        });

        $('#selectPageSize').on('change', () => {
            this.estado.pageSize = parseInt($('#selectPageSize').val());
            this.estado.currentPage = 1;
            this.cargarCategorias();
        });

        $('#btnLimpiar').on('click', () => {
            this.limpiarFiltros();
        });

        $('#btnNuevaCategoria').on('click', () => {
            this.abrirModalNuevo();
        });

        $('#btnGuardar').on('click', () => {
            this.guardarCategoria();
        });

        $('#formCategoria').on('submit', (e) => {
            e.preventDefault();
            this.guardarCategoria();
        });
    },

    cargarCategorias() {
        this.mostrarLoading(true);

        const url = `/Categorias/Listar?pageNumber=${this.estado.currentPage}&pageSize=${this.estado.pageSize}&searchTerm=${encodeURIComponent(this.estado.searchTerm || '')}`;

        $.ajax({
            url: url,
            type: 'GET',
            dataType: 'json',
            success: (result) => {
                if (result.success) {
                    this.estado.categorias = result.data;
                    this.estado.totalRecords = result.pagination.totalRecords;
                    this.estado.totalPages = result.pagination.totalPages;
                    this.estado.currentPage = result.pagination.currentPage;

                    this.renderCategorias();
                    this.renderPaginacion();
                    this.renderInfoRegistros();
                } else {
                    this.mostrarError(result.message);

                    if (result.accessDenied) {
                        setTimeout(() => {
                            window.location.href = '/Account/Login';
                        }, 500);
                    }
                }
            },
            error: (xhr, status, error) => {
                console.error('Error al cargar categorías:', error);
                this.mostrarError('Error al cargar las categorías. Por favor, intente nuevamente.');
            },
            complete: () => {
                this.mostrarLoading(false);
            }
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

    renderInfoRegistros() {
        const inicio = (this.estado.currentPage - 1) * this.estado.pageSize + 1;
        const fin = Math.min(this.estado.currentPage * this.estado.pageSize, this.estado.totalRecords);

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
            IdCategoria: parseInt($('#idCategoria').val()) || 0,
            Nombre: $('#nombre').val().trim(),
            Descripcion: $('#descripcion').val().trim(),
            Activo: $('#activo').prop('checked')
        };

        const url = this.estado.modoEdicion ? '/Categorias/Actualizar' : '/Categorias/Crear';
        const token = $('input[name="__RequestVerificationToken"]').val();

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
                    url: `/Categorias/Eliminar/${id}`,
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
            url: `/Categorias/CambiarEstado/${id}?activo=${nuevoEstado}`,
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

$(document).ready(function () {
    CategoriasApp.init();
});
