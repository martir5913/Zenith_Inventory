# ?? Guía de Implementación de Optimizaciones de Rendimiento

## Zenith Inventory - Módulos de Categorías y Subcategorías

---

## ?? Tabla de Contenidos

1. [Resumen de Optimizaciones](#resumen-de-optimizaciones)
2. [Instrucciones de Implementación](#instrucciones-de-implementación)
3. [Pruebas de Rendimiento](#pruebas-de-rendimiento)
4. [Resultados Esperados](#resultados-esperados)
5. [Troubleshooting](#troubleshooting)
6. [Mantenimiento](#mantenimiento)

---

## ?? Resumen de Optimizaciones

### ? **Optimizaciones JavaScript Implementadas**

| Optimización | Archivo | Estado | Impacto |
|--------------|---------|--------|---------|
| Carga paralela de AJAX | `subcategorias.js` | ? Implementado | ALTO (40-60%) |
| Eliminación de duplicación | `subcategorias.js` | ? Implementado | MEDIO (20-30%) |
| Caché localStorage | `subcategorias.js` | ? Implementado | MEDIO-ALTO (70-90% subsecuente) |
| Select2 centralizado | `subcategorias.js` | ? Implementado | BAJO-MEDIO (5-10%) |
| Lazy loading tooltips | `subcategorias.js` & `categorias.js` | ? Implementado | BAJO (2-5%) |
| Medición de tiempos | Ambos archivos | ? Implementado | Diagnóstico |

### ?? **Optimizaciones SQL Pendientes**

| Optimización | Archivo | Estado | Impacto |
|--------------|---------|--------|---------|
| Índices optimizados | `Optimization_Indexes_Catalogos.sql` | ?? Pendiente | ALTO (50-80%) |
| Actualizar estadísticas | Script incluido | ?? Pendiente | MEDIO |
| Verificar fragmentación | Script incluido | ?? Pendiente | Diagnóstico |

---

## ?? Instrucciones de Implementación

### **Paso 1: Verificar Archivos Modificados**

Los siguientes archivos han sido actualizados:

```
? Zenith_Inventory\Scripts\Catalogos\subcategorias.js
? Zenith_Inventory\Scripts\Catalogos\categorias.js
?? Docs\Performance_Optimization_Analysis.md (nuevo)
?? Database\Scripts\Optimization_Indexes_Catalogos.sql (nuevo)
```

### **Paso 2: Compilar y Publicar**

```bash
# 1. Compilar el proyecto
dotnet build

# 2. Verificar que no hay errores
# Los archivos JavaScript se copiarán automáticamente al publicar
```

### **Paso 3: Ejecutar Optimizaciones SQL**

?? **IMPORTANTE:** Realizar en horario de bajo tráfico

```sql
-- 1. Conectarse a la base de datos
USE [Zenith_Inventory];
GO

-- 2. Ejecutar el script de índices
-- Abrir y ejecutar: Database\Scripts\Optimization_Indexes_Catalogos.sql

-- 3. Verificar que los índices se crearon correctamente
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    name AS IndexName,
    type_desc AS IndexType
FROM sys.indexes
WHERE OBJECT_NAME(object_id) IN ('ZI_CATEGORIAS', 'ZI_SUBCATEGORIAS')
ORDER BY TableName, IndexName;
```

### **Paso 4: Limpiar Caché del Navegador**

Para que los usuarios obtengan los archivos JavaScript actualizados:

**Opción 1: Agregar versión a los scripts (Recomendado)**

En `Views\SubCategorias\Index.cshtml` y `Views\Categorias\Index.cshtml`:

```html
@section Scripts {
    <script src="~/Scripts/Catalogos/subcategorias.js?v=2.0" defer></script>
}
```

**Opción 2: Usuarios finales**

Presionar `Ctrl + F5` para forzar recarga completa.

---

## ?? Pruebas de Rendimiento

### **Test 1: Medición de Tiempos con Chrome DevTools**

1. Abrir Chrome DevTools (`F12`)
2. Ir a la pestaña **Console**
3. Navegar a la página de Subcategorías
4. Observar los logs de tiempo:

```javascript
// Deberías ver algo como:
? Usando categorías desde caché
loadCategoriesOnce: 2.5ms  // Muy rápido con caché
loadSubcategories: 150ms    // Depende del servidor
Carga Inicial Total: 152ms  // Total
```

### **Test 2: Comparación Antes/Después**

| Métrica | Antes (Estimado) | Después (Esperado) | Mejora |
|---------|------------------|-------------------|---------|
| Primera carga | 800-1200ms | 300-500ms | ~60% |
| Carga subsecuente | 800-1200ms | 50-150ms | ~90% |
| Llamadas AJAX | 3 | 2 | -33% |
| Datos duplicados | Sí | No | 100% |

### **Test 3: Network Profiling**

1. DevTools ? **Network** tab
2. Recargar página (`Ctrl + F5`)
3. Verificar:
   - ? Solo 2 llamadas AJAX (no 3)
   - ? `/Categorias/GetCategorias` se llama 1 vez
   - ? `/SubCategorias/GetSubcategorias` se llama 1 vez

### **Test 4: Performance Profiling**

```javascript
// En la consola de Chrome:
performance.mark('start');

// Navegar a la página

performance.mark('end');
performance.measure('page-load', 'start', 'end');
console.table(performance.getEntriesByType('measure'));
```

### **Test 5: Verificar Caché localStorage**

```javascript
// En la consola de Chrome:
const cache = localStorage.getItem('zenith_categories');
const parsed = JSON.parse(cache);

console.log('Categorías en caché:', parsed.data.length);
console.log('Timestamp:', new Date(parsed.timestamp));
console.log('Expira en:', Math.round((300000 - (Date.now() - parsed.timestamp)) / 1000), 'segundos');
```

### **Test 6: SQL Performance Testing**

```sql
-- Habilitar estadísticas
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Ejecutar query de subcategorías
EXEC ZI_GENERAL.SP_SUBCATEGORIAS_LISTAR_PAGINADO
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = NULL,
    @IncluirInactivos = 0,
    @IdCategoria = NULL;

-- Observar:
-- CPU time: debería ser < 50ms
-- Logical reads: debería ser < 100
```

---

## ?? Resultados Esperados

### **Métricas de Éxito**

#### ? **Métricas Cliente (JavaScript)**

- ? Primera carga: **< 500ms** (antes: ~1000ms)
- ? Carga subsecuente: **< 200ms** (antes: ~1000ms)
- ? Llamadas AJAX: **2** (antes: 3)
- ? Uso de caché: **> 80%** de las visitas
- ? Tiempo de render tabla: **< 100ms**

#### ? **Métricas Servidor (SQL)**

- ? Tiempo de query: **< 50ms** (antes: ~100-200ms)
- ? Logical reads: **< 100** (antes: ~200-500)
- ? CPU time: **< 30ms** (antes: ~50-100ms)

### **Gráfica Comparativa Esperada**

```
Tiempo de Carga (ms)
???????????????????????????????????????????
?                                         ?
?  Antes:  ???????????? 1000ms            ?
?                                         ?
?  Después: ???? 400ms                    ?
?                                         ?
?  Mejora: 60% ?                          ?
?                                         ?
???????????????????????????????????????????

Carga Subsecuente (ms)
???????????????????????????????????????????
?                                         ?
?  Antes:  ???????????? 1000ms            ?
?                                         ?
?  Después: ? 100ms                       ?
?                                         ?
?  Mejora: 90% ???                       ?
?                                         ?
???????????????????????????????????????????
```

---

## ?? Troubleshooting

### **Problema: No veo mejoras en el rendimiento**

**Solución 1:** Verificar que los archivos JS se actualizaron
```javascript
// En consola del navegador:
console.log('Versión subcategorias:', typeof loadCategoriesOnce !== 'undefined' ? 'v2.0' : 'v1.0');
```

**Solución 2:** Limpiar caché del navegador
```
Ctrl + Shift + Delete ? Borrar caché
```

**Solución 3:** Verificar que los índices SQL se crearon
```sql
SELECT name FROM sys.indexes 
WHERE object_id = OBJECT_ID('ZI_GENERAL.ZI_SUBCATEGORIAS');
```

### **Problema: Error "loadCategoriesOnce is not a function"**

**Causa:** Archivo JS antiguo en caché del navegador

**Solución:** 
1. Limpiar caché (`Ctrl + F5`)
2. Verificar que el archivo en el servidor está actualizado
3. Agregar parámetro de versión al script

### **Problema: Caché localStorage no funciona**

**Verificar:**
```javascript
// En consola:
try {
    localStorage.setItem('test', 'test');
    localStorage.removeItem('test');
    console.log('? localStorage habilitado');
} catch(e) {
    console.error('? localStorage bloqueado:', e);
}
```

**Solución:** Verificar configuración del navegador (modo incógnito puede bloquear localStorage)

### **Problema: Queries SQL lentas después de crear índices**

**Causa posible:** Estadísticas desactualizadas

**Solución:**
```sql
UPDATE STATISTICS ZI_GENERAL.ZI_CATEGORIAS WITH FULLSCAN;
UPDATE STATISTICS ZI_GENERAL.ZI_SUBCATEGORIAS WITH FULLSCAN;
```

### **Problema: Índices fragmentados**

**Verificar fragmentación:**
```sql
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    name AS IndexName,
    avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE avg_fragmentation_in_percent > 10;
```

**Solución si fragmentación > 30%:**
```sql
ALTER INDEX ALL ON ZI_GENERAL.ZI_CATEGORIAS REBUILD;
ALTER INDEX ALL ON ZI_GENERAL.ZI_SUBCATEGORIAS REBUILD;
```

---

## ?? Mantenimiento

### **Tareas Semanales**

```sql
-- 1. Actualizar estadísticas (Sábados 2:00 AM)
UPDATE STATISTICS ZI_GENERAL.ZI_CATEGORIAS WITH FULLSCAN;
UPDATE STATISTICS ZI_GENERAL.ZI_SUBCATEGORIAS WITH FULLSCAN;
```

### **Tareas Mensuales**

```sql
-- 1. Verificar fragmentación de índices
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    name AS IndexName,
    avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id;

-- 2. Reorganizar índices si fragmentación > 10%
ALTER INDEX ALL ON ZI_GENERAL.ZI_CATEGORIAS REORGANIZE;
ALTER INDEX ALL ON ZI_GENERAL.ZI_SUBCATEGORIAS REORGANIZE;

-- 3. Si fragmentación > 30%, reconstruir
ALTER INDEX ALL ON ZI_GENERAL.ZI_CATEGORIAS REBUILD;
ALTER INDEX ALL ON ZI_GENERAL.ZI_SUBCATEGORIAS REBUILD;
```

### **Monitoreo Continuo**

**Chrome DevTools - Agregar a favoritos:**

```javascript
// Snippet para medir rendimiento
console.clear();
console.log('?? Métricas de Rendimiento:');
console.log('----------------------------');

const perfData = performance.getEntriesByType("navigation")[0];
console.log('DOM Content Loaded:', Math.round(perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart), 'ms');
console.log('Load Complete:', Math.round(perfData.loadEventEnd - perfData.loadEventStart), 'ms');

// Verificar caché
const cache = localStorage.getItem('zenith_categories');
if (cache) {
    const {data, timestamp} = JSON.parse(cache);
    const age = Date.now() - timestamp;
    console.log('Caché:', age < 300000 ? '? Válido' : '? Expirado');
    console.log('Categorías en caché:', data.length);
}
```

### **Dashboard de Métricas (Opcional)**

Considerar implementar Application Insights o similar para tracking automático:

```csharp
// En el futuro, agregar a controllers:
telemetry.TrackMetric("LoadSubcategories.Duration", stopwatch.ElapsedMilliseconds);
telemetry.TrackMetric("LoadSubcategories.Count", resultado.TotalRecords);
```

---

## ?? Soporte

Si encuentras problemas:

1. Revisar esta guía de troubleshooting
2. Verificar logs en Chrome DevTools (F12 ? Console)
3. Verificar logs de SQL Server
4. Contactar al equipo de desarrollo

---

## ?? Referencias

- [Documentación completa de análisis](./Docs/Performance_Optimization_Analysis.md)
- [Script de índices SQL](./Database/Scripts/Optimization_Indexes_Catalogos.sql)
- [Chrome DevTools Performance](https://developer.chrome.com/docs/devtools/performance/)
- [SQL Server Index Optimization](https://docs.microsoft.com/en-us/sql/relational-databases/indexes/)

---

**Última actualización:** 2024  
**Versión:** 2.0  
**Equipo:** Desarrollo Zenith Inventory
