// ============================================
// ERROR HANDLER CENTRALIZADO
// Zenith Inventory - Sistema de Gestión de Inventario
// ============================================

(function () {
    'use strict';

    // Configuración global de Toastr
    if (typeof toastr !== 'undefined') {
        toastr.options = {
            closeButton: true,
            debug: false,
            newestOnTop: true,
            progressBar: true,
            positionClass: "toast-top-right",
            preventDuplicates: true,
            onclick: null,
            showDuration: "300",
            hideDuration: "1000",
            timeOut: "5000",
            extendedTimeOut: "1000",
            showEasing: "swing",
            hideEasing: "linear",
            showMethod: "fadeIn",
            hideMethod: "fadeOut"
        };
    }

    // Manejador global de errores de AJAX
    $(document).ajaxError(function (event, jqxhr, settings, thrownError) {
        console.error('Error AJAX:', {
            url: settings.url,
            status: jqxhr.status,
            error: thrownError,
            response: jqxhr.responseText
        });

        // No mostrar error si es una llamada cancelada
        if (jqxhr.status === 0 && jqxhr.statusText === 'abort') {
            return;
        }

        // Manejar diferentes tipos de errores
        let errorMessage = 'Ha ocurrido un error inesperado';
        let errorTitle = 'Error';

        switch (jqxhr.status) {
            case 401:
                errorTitle = 'Sesión Expirada';
                errorMessage = 'Su sesión ha expirado. Por favor, inicie sesión nuevamente.';
                // Redirigir al login después de 2 segundos
                setTimeout(function () {
                    window.location.href = '/Account/Login';
                }, 2000);
                break;
            case 403:
                errorTitle = 'Acceso Denegado';
                errorMessage = 'No tiene permisos para realizar esta acción.';
                break;
            case 404:
                errorTitle = 'No Encontrado';
                errorMessage = 'El recurso solicitado no fue encontrado.';
                break;
            case 500:
                errorTitle = 'Error del Servidor';
                errorMessage = 'Ha ocurrido un error en el servidor. Por favor, contacte al administrador.';
                break;
            case 503:
                errorTitle = 'Servicio No Disponible';
                errorMessage = 'El servicio no está disponible en este momento. Intente nuevamente más tarde.';
                break;
            default:
                if (thrownError) {
                    errorMessage = thrownError;
                }
        }

        // Mostrar error solo si Toastr está disponible
        if (typeof toastr !== 'undefined') {
            toastr.error(errorMessage, errorTitle);
        } else {
            console.error(errorTitle + ': ' + errorMessage);
        }
    });

    // Manejador global de errores de JavaScript
    window.onerror = function (message, source, lineno, colno, error) {
        console.error('Error de JavaScript:', {
            message: message,
            source: source,
            lineno: lineno,
            colno: colno,
            error: error
        });

        // No mostrar errores de scripts externos
        if (source && (source.includes('jquery') || source.includes('bootstrap'))) {
            return false;
        }

        // Mostrar error en desarrollo (puedes comentar en producción)
        if (typeof toastr !== 'undefined' && window.location.hostname === 'localhost') {
            toastr.warning('Error de JavaScript: ' + message, 'Error de Desarrollo');
        }

        return false; // Permite que el error se registre en la consola
    };

    // Manejador de promesas rechazadas
    window.addEventListener('unhandledrejection', function (event) {
        console.error('Promesa rechazada:', event.reason);

        if (typeof toastr !== 'undefined' && window.location.hostname === 'localhost') {
            toastr.warning('Error en promesa: ' + event.reason, 'Error de Desarrollo');
        }
    });

    console.log('? Error Handler inicializado correctamente');

})();
