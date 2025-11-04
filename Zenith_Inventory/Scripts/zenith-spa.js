/**
 * Sistema de Navegación SPA para Zenith Inventory
 * Previene recargas completas del Layout
 */

const ZenithSPA = {
    estado: {
        currentController: window.zenithContext?.controller || 'Home',
        currentAction: window.zenithContext?.action || 'Index',
        isLoading: false,
        navigationHistory: [],
        loadedScripts: [],
        contentCache: {},
        maxCacheSize: 10
    },

    init() {
        console.log('Inicializando Zenith SPA...');
        this.interceptarNavegacion();
        this.configurarHistorial();
        this.marcarMenuActivo();
        this.monitorearSesion();
        console.log('Zenith SPA inicializado correctamente');
    },

    interceptarNavegacion() {
        $(document).on('click', '.nav-link, .submenu-link', (e) => {
            const link = $(e.currentTarget);
            const href = link.attr('href');

            if (href && href.startsWith('#')) {
                return true;
            }

            if (!href || href.startsWith('http') || href === '#') {
                return true;
            }

            e.preventDefault();

            const controller = link.data('controller');
            const action = link.data('action') || 'Index';

            this.navegarA(controller, action, href);
        });
    },

    async navegarA(controller, action, url) {
        try {
            if (!controller) {
                console.warn('No se especificó controller, usando URL completa');
                if (!url) {
                    console.error('No se puede navegar sin controller o URL');
                    return;
                }
            }

            if (controller === this.estado.currentController &&
                action === this.estado.currentAction) {
                console.log('Ya estás en esta página');
                return;
            }

            if (!url) {
                url = `/${controller}/${action}`;
            }

            const cleanUrl = url.replace('?ajax=true', '');

            if (this.estado.contentCache[cleanUrl]) {
                console.log('Cargando desde caché:', cleanUrl);
                this.mostrarContenidoCacheado(cleanUrl, controller, action);
                return;
            }

            this.mostrarLoading(true);

            const response = await fetch(`${url}?ajax=true`, {
                method: 'GET',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                },
                credentials: 'same-origin'
            });

            if (response.status === 401 || response.status === 403) {
                console.warn('Sesión expirada o sin permisos');
                window.location.href = '/Account/Login';
                return;
            }

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const html = await response.text();

            this.agregarAlCache(cleanUrl, html);
            this.mostrarContenido(html, cleanUrl, controller, action);

        } catch (error) {
            console.error('Error en navegación SPA:', error);
            toastr.error('Error al cargar la página. Por favor, intente nuevamente.');

            if (error.message.includes('Failed to fetch') || error.message.includes('NetworkError')) {
                console.log('Recurriendo a navegación tradicional...');
                window.location.href = url || `/${controller}/${action}`;
            }
        } finally {
            this.mostrarLoading(false);
        }
    },

    mostrarContenidoCacheado(url, controller, action) {
        const html = this.estado.contentCache[url];
        this.mostrarContenido(html, url, controller, action, true);
    },

    mostrarContenido(html, url, controller, action, fromCache = false) {
        if (!fromCache) {
            this.limpiarScriptsAnteriores();
        }

        $('.content .container-fluid').html(html);

        const match = html.match(/<title>(.*?)<\/title>/i);
        if (match && match[1]) {
            document.title = match[1];
            $('.page-title').text(match[1].replace(' - Zenith Inventory', ''));
        }

        window.history.pushState(
            { controller, action },
            '',
            url
        );

        this.estado.currentController = controller;
        this.estado.currentAction = action;
        this.estado.navigationHistory.push({ controller, action, url });

        this.marcarMenuActivo();

        if (!fromCache) {
            this.ejecutarScripts(html);
        }

        window.scrollTo({ top: 0, behavior: 'smooth' });

        console.log(`Navegación exitosa a ${controller}/${action}${fromCache ? ' (caché)' : ''}`);
    },

    agregarAlCache(url, html) {
        if (html.includes('error') || html.includes('Error') || html.length < 100) {
            return;
        }

     this.estado.contentCache[url] = html;

        const cacheKeys = Object.keys(this.estado.contentCache);
      if (cacheKeys.length > this.estado.maxCacheSize) {
      const oldestKey = cacheKeys[0];
            delete this.estado.contentCache[oldestKey];
        console.log('Contenido removido del caché:', oldestKey);
        }

        console.log('Contenido agregado al caché:', url);
    },

    limpiarCache() {
        this.estado.contentCache = {};
        console.log('Caché limpiado');
    },

    configurarHistorial() {
        window.addEventListener('popstate', (e) => {
            if (e.state) {
                console.log('Navegación con historial:', e.state);
                this.navegarA(e.state.controller, e.state.action, window.location.pathname);
            }
        });

        window.history.replaceState(
            {
                controller: this.estado.currentController,
                action: this.estado.currentAction
            },
            '',
            window.location.pathname
        );
    },

    marcarMenuActivo() {
        $('.nav-link, .submenu-link').removeClass('active');

        const controller = this.estado.currentController;
        const action = this.estado.currentAction;

        $(`.nav-link[data-controller="${controller}"][data-action="${action}"]`).addClass('active');
        $(`.submenu-link[data-controller="${controller}"][data-action="${action}"]`).addClass('active');

        const submenuLink = $(`.submenu-link[data-controller="${controller}"][data-action="${action}"]`);
        if (submenuLink.length > 0) {
            const submenu = submenuLink.closest('.submenu');
            submenu.addClass('show');

            const parentLink = submenu.prev('.nav-link');
            parentLink.addClass('active');
        }
    },

    limpiarScriptsAnteriores() {
        this.estado.loadedScripts.forEach(scriptSrc => {
            const scriptElement = document.querySelector(`script[src="${scriptSrc}"]`);
            if (scriptElement && scriptElement.dataset.dynamic === 'true') {
                scriptElement.remove();
                console.log(`Script removido: ${scriptSrc}`);
            }
        });

        this.estado.loadedScripts = [];
    },

    ejecutarScripts(html) {
        const scriptRegex = /<script[^>]*>([\s\S]*?)<\/script>/gi;
        let match;

        while ((match = scriptRegex.exec(html)) !== null) {
            try {
                if (!match[0].includes('src=')) {
                    const scriptCode = match[1];
                    eval(scriptCode);
                    console.log('Script inline ejecutado');
                }
            } catch (error) {
                console.error('Error ejecutando script inline:', error);
            }
        }

        const scriptSrcRegex = /<script[^>]*src="([^"]+)"[^>]*><\/script>/gi;
        while ((match = scriptSrcRegex.exec(html)) !== null) {
            const scriptSrc = match[1];

            const existingScript = document.querySelector(`script[src="${scriptSrc}"]`);

            if (!existingScript) {
                const script = document.createElement('script');
                script.src = scriptSrc;
                script.dataset.dynamic = 'true';
                script.async = false;

                script.onload = () => {
                    console.log(`Script externo cargado: ${scriptSrc}`);
                };

                script.onerror = () => {
                    console.error(`Error cargando script: ${scriptSrc}`);
                };

                document.body.appendChild(script);

                this.estado.loadedScripts.push(scriptSrc);
                console.log(`Cargando script: ${scriptSrc}`);
            } else {
                console.log(`Script ya cargado: ${scriptSrc}`);
            }
        }
    },

    mostrarLoading(mostrar) {
        this.estado.isLoading = mostrar;

        if (mostrar) {
            if (!$('#spaLoadingBar').length) {
                $('body').append(`
                <div id="spaLoadingBar" style="
    position: fixed;
             top: 0;
      left: 0;
             width: 100%;
          height: 3px;
      background: #e0e0e0;
             z-index: 10000;
    overflow: hidden;
 ">
<div class="loading-progress" style="
     height: 100%;
   background: linear-gradient(90deg, #4e73df, #36b9cc);
                 width: 0%;
 animation: loadingAnimation 1s ease-in-out infinite;
          "></div>
 </div>
        <style>
            @keyframes loadingAnimation {
         0% { width: 0%; margin-left: 0%; }
       50% { width: 50%; margin-left: 25%; }
     100% { width: 0%; margin-left: 100%; }
       }
       </style>
          `);
            }
            $('#spaLoadingBar').fadeIn(100);
        } else {
            $('#spaLoadingBar').fadeOut(300, function() {
                $(this).remove();
         });
        }
    },

    /**
     * Monitorea la sesión del usuario para detectar expiraciones
     */
    monitorearSesion() {
        setInterval(async () => {
try {
             const response = await fetch('/Account/VerificarSesion', {
           method: 'POST',
   credentials: 'same-origin'
   });

         if (response.ok) {
         const data = await response.json();
     if (!data.authenticated) {
      console.warn('Sesión expirada');
         toastr.warning('Su sesión ha expirado. Redirigiendo al login...');
       setTimeout(() => {
         window.location.href = '/Account/Login';
        }, 2000);
           }
 }
            } catch (error) {
      console.error('Error verificando sesión:', error);
            }
  }, 5 * 60 * 1000);
    },

    getCurrentRoute() {
        return {
            controller: this.estado.currentController,
            action: this.estado.currentAction
        };
    },

    recargarPaginaActual() {
        const currentUrl = window.location.pathname;
        if (this.estado.contentCache[currentUrl]) {
            delete this.estado.contentCache[currentUrl];
      console.log('Caché de página actual limpiado');
     }

        this.navegarA(
    this.estado.currentController,
          this.estado.currentAction,
        currentUrl
  );
    },

    /**
     * Pre-carga una página en segundo plano para mejorar rendimiento
     */
    async precargarPagina(controller, action) {
        const url = `/${controller}/${action}`;

        try {
 const response = await fetch(`${url}?ajax=true`, {
     method: 'GET',
                headers: {
              'X-Requested-With': 'XMLHttpRequest'
      },
       credentials: 'same-origin'
            });

         if (response.ok) {
    const html = await response.text();
 this.agregarAlCache(url, html);
    console.log('Página precargada:', url);
          }
        } catch (error) {
    console.error('Error precargando página:', error);
        }
    }
};

function initZenithSPA() {
    if (typeof $ === 'undefined' || typeof jQuery === 'undefined') {
        console.warn('jQuery no está disponible aún, reintentando...');
      setTimeout(initZenithSPA, 50);
        return;
    }
    
    $(document).ready(() => {
        ZenithSPA.init();
    });
}

initZenithSPA();

window.ZenithSPA = ZenithSPA;
