// ============================================
// UTILITIES.JS - Funciones Helper Globales
// Zenith Inventory - Sistema de Gestión de Inventario
// ============================================

/**
 * IMPORTANTE: Este archivo debe cargarse ANTES que cualquier script específico
 * que use estas utilidades (categorias.js, subcategorias.js, roles.js, etc.)
 */

(function (window) {
    'use strict';

    // ============================================
    // SEGURIDAD - Escape HTML para prevenir XSS
    // ============================================

    /**
     * Escapa caracteres especiales HTML para prevenir ataques XSS
     * @param {string|number|null|undefined} text - Texto a escapar
     * @returns {string} Texto escapado seguro para HTML
     */
    window.escapeHtml = function (text) {
        if (text === null || text === undefined) {
            return '';
        }

        const str = String(text);
        const map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;',
            '/': '&#x2F;'
        };

        return str.replace(/[&<>"'/]/g, function (m) { return map[m]; });
    };

    // ============================================
    // PERFORMANCE - Debounce y Throttle
    // ============================================

    /**
     * Crea una función debounced que retrasa la ejecución hasta que
     * hayan pasado X milisegundos desde la última invocación
     * @param {Function} func - Función a ejecutar
     * @param {number} wait - Milisegundos de espera
     * @param {boolean} immediate - Si debe ejecutarse inmediatamente la primera vez
     * @returns {Function} Función debounced
     * 
     * @example
     * const searchDebounced = debounce(function(query) {
     *     console.log('Buscando:', query);
     * }, 500);
     * 
     * $('#search').on('input', function() {
     *     searchDebounced($(this).val());
     * });
     */
    window.debounce = function (func, wait, immediate) {
        let timeout;
        return function executedFunction(...args) {
            const context = this;
            const later = function () {
                timeout = null;
                if (!immediate) func.apply(context, args);
            };
            const callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func.apply(context, args);
        };
    };

    /**
     * Crea una función throttled que solo ejecuta la función una vez
     * cada X milisegundos, sin importar cuántas veces se llame
     * @param {Function} func - Función a ejecutar
     * @param {number} limit - Milisegundos entre ejecuciones
     * @returns {Function} Función throttled
     * 
     * @example
     * const handleScroll = throttle(function() {
     *     console.log('Scroll detectado');
     * }, 1000);
     * 
     * $(window).on('scroll', handleScroll);
     */
    window.throttle = function (func, limit) {
        let inThrottle;
        return function (...args) {
            const context = this;
            if (!inThrottle) {
                func.apply(context, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    };

    // ============================================
    // TOOLTIPS - Inicialización Lazy
    // ============================================

    /**
     * Inicializa tooltips de Bootstrap solo cuando se necesitan (lazy loading)
     * Mejora el rendimiento al no inicializar todos los tooltips de inmediato
     * 
     * @example
     * // Llamar después de agregar elementos dinámicos a la tabla
     * poblarTabla(datos);
     * initializeLazyTooltips();
     */
    window.initializeLazyTooltips = function () {
        $('[data-bs-toggle="tooltip"]').off('mouseenter.tooltip').on('mouseenter.tooltip', function () {
            const $this = $(this);
            if (!$this.data('bs.tooltip')) {
                $this.tooltip({
                    trigger: 'hover',
                    boundary: 'window'
                });
                $this.tooltip('show');
            }
        });
    };

    /**
     * Destruye todos los tooltips activos
     * Útil antes de recargar una tabla o modal
     */
    window.destroyAllTooltips = function () {
        $('[data-bs-toggle="tooltip"]').each(function () {
            const $this = $(this);
            if ($this.data('bs.tooltip')) {
                $this.tooltip('dispose');
            }
        });
    };

    // ============================================
    // FORMATEO DE DATOS
    // ============================================

    /**
     * Formatea una fecha en formato dd/MM/yyyy
     * @param {string|Date} dateString - Fecha a formatear
     * @returns {string} Fecha formateada o '--/--/----' si es inválida
     */
    window.formatDate = function (dateString) {
        if (!dateString) return '--/--/----';

        try {
            let date;
            
            // Manejar formato de fecha de .NET (/Date(timestamp)/)
            if (typeof dateString === 'string' && dateString.startsWith('/Date(')) {
                const timestamp = parseInt(dateString.match(/\d+/)[0]);
                date = new Date(timestamp);
            } else {
                date = new Date(dateString);
            }

            if (isNaN(date.getTime())) {
                return '--/--/----';
            }

            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const year = date.getFullYear();

            return `${day}/${month}/${year}`;
        } catch (e) {
            console.error('Error al formatear fecha:', e);
            return '--/--/----';
        }
    };

    /**
     * Formatea una fecha y hora en formato dd/MM/yyyy HH:mm
     * @param {string|Date} dateString - Fecha a formatear
     * @returns {string} Fecha y hora formateada
     */
    window.formatDateTime = function (dateString) {
        if (!dateString) return '--/--/---- --:--';

        try {
            let date;
            
            if (typeof dateString === 'string' && dateString.startsWith('/Date(')) {
                const timestamp = parseInt(dateString.match(/\d+/)[0]);
                date = new Date(timestamp);
            } else {
                date = new Date(dateString);
            }

            if (isNaN(date.getTime())) {
                return '--/--/---- --:--';
            }

            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const year = date.getFullYear();
            const hours = String(date.getHours()).padStart(2, '0');
            const minutes = String(date.getMinutes()).padStart(2, '0');

            return `${day}/${month}/${year} ${hours}:${minutes}`;
        } catch (e) {
            console.error('Error al formatear fecha y hora:', e);
            return '--/--/---- --:--';
        }
    };

    /**
     * Formatea un número con separadores de miles
     * @param {number|string} number - Número a formatear
     * @param {number} decimals - Cantidad de decimales (default: 0)
     * @returns {string} Número formateado
     */
    window.formatNumber = function (number, decimals = 0) {
        if (number === null || number === undefined || number === '') {
            return '0';
        }

        const num = parseFloat(number);
        if (isNaN(num)) {
            return '0';
        }

        return num.toLocaleString('es-GT', {
            minimumFractionDigits: decimals,
            maximumFractionDigits: decimals
        });
    };

    /**
     * Formatea un número como moneda (Quetzales)
     * @param {number|string} amount - Monto a formatear
     * @returns {string} Monto formateado con símbolo Q
     */
    window.formatCurrency = function (amount) {
        if (amount === null || amount === undefined || amount === '') {
            return 'Q 0.00';
        }

        const num = parseFloat(amount);
        if (isNaN(num)) {
            return 'Q 0.00';
        }

        return 'Q ' + num.toLocaleString('es-GT', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    };

    // ============================================
    // VALIDACIONES
    // ============================================

    /**
     * Valida si un string es un email válido
     * @param {string} email - Email a validar
     * @returns {boolean} True si es válido
     */
    window.isValidEmail = function (email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(String(email).toLowerCase());
    };

    /**
     * Valida si un string es un número de teléfono guatemalteco válido
     * @param {string} phone - Teléfono a validar
     * @returns {boolean} True si es válido
     */
    window.isValidPhone = function (phone) {
        // Acepta formatos: 12345678, 1234-5678, +502 1234-5678
        const re = /^(\+502\s?)?[2-7]\d{3}-?\d{4}$/;
        return re.test(String(phone).replace(/\s/g, ''));
    };

    /**
     * Valida si un string no está vacío (después de trim)
     * @param {string} str - String a validar
     * @returns {boolean} True si no está vacío
     */
    window.isNotEmpty = function (str) {
        return str !== null && str !== undefined && String(str).trim().length > 0;
    };

    // ============================================
    // MANEJO DE ARRAYS
    // ============================================

    /**
     * Agrupa un array de objetos por una propiedad
     * @param {Array} array - Array a agrupar
     * @param {string} key - Propiedad por la cual agrupar
     * @returns {Object} Objeto con grupos
     * 
     * @example
     * const permisos = [
     *     {modulo: 'USUARIOS', nombre: 'Ver'},
     *     {modulo: 'USUARIOS', nombre: 'Crear'},
     *     {modulo: 'ROLES', nombre: 'Ver'}
     * ];
     * const grouped = groupBy(permisos, 'modulo');
     * // Result: { USUARIOS: [...], ROLES: [...] }
     */
    window.groupBy = function (array, key) {
        return array.reduce(function (result, currentValue) {
            const groupKey = currentValue[key];
            if (!result[groupKey]) {
                result[groupKey] = [];
            }
            result[groupKey].push(currentValue);
            return result;
        }, {});
    };

    /**
     * Obtiene valores únicos de un array
     * @param {Array} array - Array de entrada
     * @returns {Array} Array con valores únicos
     */
    window.unique = function (array) {
        return [...new Set(array)];
    };

    // ============================================
    // MANEJO DE STRINGS
    // ============================================

    /**
     * Trunca un texto a cierta longitud y agrega "..."
     * @param {string} text - Texto a truncar
     * @param {number} maxLength - Longitud máxima
     * @returns {string} Texto truncado
     */
    window.truncateText = function (text, maxLength) {
        if (!text || text.length <= maxLength) {
            return text || '';
        }
        return text.substring(0, maxLength) + '...';
    };

    /**
     * Capitaliza la primera letra de cada palabra
     * @param {string} str - String a capitalizar
     * @returns {string} String capitalizado
     */
    window.capitalize = function (str) {
        if (!str) return '';
        return str.toLowerCase().replace(/\b\w/g, function (char) {
            return char.toUpperCase();
        });
    };

    // ============================================
    // LOADING STATES
    // ============================================

    /**
     * Muestra un estado de loading en un botón
     * @param {jQuery|string} button - Selector o elemento jQuery del botón
     * @param {string} loadingText - Texto a mostrar (default: "Cargando...")
     * @returns {Object} Objeto con método restore() para restaurar el botón
     * 
     * @example
     * const btnState = showButtonLoading('#btnGuardar', 'Guardando...');
     * // ... hacer operación async
     * btnState.restore();
     */
    window.showButtonLoading = function (button, loadingText = 'Cargando...') {
        const $btn = $(button);
        const originalHtml = $btn.html();
        const originalDisabled = $btn.prop('disabled');

        $btn.prop('disabled', true)
            .html(`<i class="fas fa-spinner fa-spin me-1"></i>${loadingText}`);

        return {
            restore: function () {
                $btn.prop('disabled', originalDisabled)
                    .html(originalHtml);
            }
        };
    };

    /**
     * Muestra un mensaje de loading en un contenedor
     * @param {jQuery|string} container - Selector o elemento jQuery del contenedor
     * @param {string} message - Mensaje a mostrar
     */
    window.showLoadingMessage = function (container, message = 'Cargando...') {
        $(container).html(`
            <div class="text-center py-5">
                <i class="fas fa-spinner fa-spin fa-2x text-muted mb-3"></i>
                <p class="text-muted">${message}</p>
            </div>
        `);
    };

    /**
     * Muestra un mensaje de error en un contenedor
     * @param {jQuery|string} container - Selector o elemento jQuery del contenedor
     * @param {string} message - Mensaje de error
     * @param {Function} retryCallback - Función a ejecutar al hacer clic en "Reintentar"
     */
    window.showErrorMessage = function (container, message = 'Ha ocurrido un error', retryCallback = null) {
        let retryButton = '';
        if (retryCallback && typeof retryCallback === 'function') {
            const retryId = 'retry_' + Math.random().toString(36).substr(2, 9);
            retryButton = `
                <button class="btn btn-primary btn-sm mt-3" id="${retryId}">
                    <i class="fas fa-sync-alt me-1"></i>Reintentar
                </button>
            `;
            
            // Asignar callback
            setTimeout(function () {
                $(`#${retryId}`).on('click', retryCallback);
            }, 100);
        }

        $(container).html(`
            <div class="text-center py-5">
                <i class="fas fa-exclamation-triangle fa-2x text-warning mb-3"></i>
                <p class="text-muted">${message}</p>
                ${retryButton}
            </div>
        `);
    };

    /**
     * Muestra un mensaje de "sin datos" en un contenedor
     * @param {jQuery|string} container - Selector o elemento jQuery del contenedor
     * @param {string} message - Mensaje a mostrar
     */
    window.showEmptyMessage = function (container, message = 'No hay datos disponibles') {
        $(container).html(`
            <div class="text-center py-5">
                <i class="fas fa-inbox fa-2x text-muted mb-3"></i>
                <p class="text-muted">${message}</p>
            </div>
        `);
    };

    // ============================================
    // HELPERS DE CONFIRMACIÓN
    // ============================================

    /**
     * Muestra un diálogo de confirmación usando SweetAlert2
     * @param {Object} options - Opciones del diálogo
     * @returns {Promise} Promesa que resuelve con el resultado
     * 
     * @example
     * confirmDialog({
     *     title: '¿Eliminar usuario?',
     *     text: 'Esta acción no se puede deshacer',
     *     confirmButtonText: 'Sí, eliminar'
     * }).then(result => {
     *     if (result.isConfirmed) {
     *         // Ejecutar eliminación
     *     }
     * });
     */
    window.confirmDialog = function (options) {
        const defaults = {
            title: '¿Está seguro?',
            text: 'Esta acción no se puede deshacer',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: '<i class="fas fa-check me-1"></i>Sí, continuar',
            cancelButtonText: '<i class="fas fa-times me-1"></i>Cancelar',
            customClass: {
                confirmButton: 'btn btn-danger',
                cancelButton: 'btn btn-secondary'
            },
            buttonsStyling: false
        };

        return Swal.fire({ ...defaults, ...options });
    };

    // ============================================
    // LOG Y DEBUG
    // ============================================

    /**
     * Log condicional (solo en desarrollo)
     * @param {...any} args - Argumentos a loggear
     */
    window.devLog = function (...args) {
        if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
            console.log('[DEV]', ...args);
        }
    };

    /**
     * Mide el tiempo de ejecución de una función
     * @param {Function} func - Función a medir
     * @param {string} label - Etiqueta para el log
     * @returns {any} Resultado de la función
     */
    window.measureTime = function (func, label = 'Función') {
        console.time(label);
        const result = func();
        console.timeEnd(label);
        return result;
    };

    // ============================================
    // INFORMACIÓN DEL SISTEMA
    // ============================================

    console.log('? Utilities.js cargado correctamente');
    console.log('?? Funciones disponibles globalmente:');
    console.log('   - escapeHtml(text)');
    console.log('   - debounce(func, wait)');
    console.log('   - throttle(func, limit)');
    console.log('   - initializeLazyTooltips()');
    console.log('   - formatDate(date)');
    console.log('   - formatDateTime(date)');
    console.log('   - formatNumber(number, decimals)');
    console.log('   - formatCurrency(amount)');
    console.log('   - isValidEmail(email)');
    console.log('   - isValidPhone(phone)');
    console.log('   - groupBy(array, key)');
    console.log('   - truncateText(text, maxLength)');
    console.log('   - showButtonLoading(button, text)');
    console.log('   - confirmDialog(options)');
    console.log('   - y más...');

})(window);
