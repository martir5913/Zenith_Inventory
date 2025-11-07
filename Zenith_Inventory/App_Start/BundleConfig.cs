using System.Web.Optimization;

namespace Zenith_Inventory
{
    /// <summary>
    /// Configuración de Bundle y Minificación de archivos JavaScript y CSS
    /// </summary>
    /// <remarks>
    /// COMPORTAMIENTO: DEBUG (archivos separados) | RELEASE (minificados y combinados)
    /// </remarks>
    public class BundleConfig
    {
        /// <summary>
        /// Registra todos los bundles de la aplicación
        /// </summary>
        public static void RegisterBundles(BundleCollection bundles)
        {


            // Configuracion ejemplo
            // RUTA VIRTUAL: ~/Content/catalogos/categorias (usada en @Styles.Render())
            // RUTA FÍSICA: ~/Content/css/Catalogos/categorias.css (ubicación real del archivo)


            // ============================================================
            // LIBRERÍAS EXTERNAS
            // ============================================================

            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                        "~/Scripts/bootstrap.js"));

            // ============================================================
            // MÓDULOS - JAVASCRIPT
            // ============================================================

            // Catálogos
            bundles.Add(new ScriptBundle("~/bundles/catalogos/categorias").Include(
                        "~/Scripts/Catalogos/categorias.js"));

            bundles.Add(new ScriptBundle("~/bundles/catalogos/subcategorias").Include(
                        "~/Scripts/Catalogos/subcategorias.js"));

            // Principales
            bundles.Add(new ScriptBundle("~/bundles/login").Include(
                        "~/Scripts/login.js"));

            bundles.Add(new ScriptBundle("~/bundles/dashboard").Include(
                        "~/Scripts/dashboard.js"));

            bundles.Add(new ScriptBundle("~/bundles/equipos").Include(
                        "~/Scripts/equipos.js"));

            // ============================================================
            // MÓDULOS - CSS
            // ============================================================

            // Base
            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/bootstrap.css",
                      "~/Content/site.css"));

            // Páginas principales
            bundles.Add(new StyleBundle("~/Content/login").Include(
                      "~/Content/css/login.css"));

            bundles.Add(new StyleBundle("~/Content/dashboard").Include(
                      "~/Content/css/dashboard.css"));

            bundles.Add(new StyleBundle("~/Content/equipos").Include(
                      "~/Content/css/equipos.css"));

            // Catálogos
            bundles.Add(new StyleBundle("~/Content/catalogos/categorias").Include(
                      "~/Content/css/Catalogos/categorias.css"));

            bundles.Add(new StyleBundle("~/Content/catalogos/subcategorias").Include(
                      "~/Content/css/Catalogos/subcategorias.css"));

            // ============================================================
            // OPTIMIZACIÓN
            // ============================================================

            // Habilita minificación solo en modo RELEASE
#if !DEBUG
            BundleTable.EnableOptimizations = true;
#endif
        }
    }
}
