-- Población de Datos para DB_Zenith_Inventory (idempotente y con lookups para FKs)
-- Ejecutar después de001_Schema.sql

USE [DB_Zenith_Inventory]
GO

--1. Roles
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Roles WHERE Nombre='Administrador')
 INSERT INTO SCH_GENERAL.Roles (Nombre, Descripcion) VALUES('Administrador','Acceso completo al sistema');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Roles WHERE Nombre='Usuario IT')
 INSERT INTO SCH_GENERAL.Roles (Nombre, Descripcion) VALUES('Usuario IT','Acceso limitado a funciones de IT');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Roles WHERE Nombre='Auditor')
 INSERT INTO SCH_GENERAL.Roles (Nombre, Descripcion) VALUES('Auditor','Solo lectura y reportes');

--2. Permisos
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Permisos WHERE Nombre='Crear Equipo')
 INSERT INTO SCH_GENERAL.Permisos (Nombre, Descripcion) VALUES('Crear Equipo','Permiso para crear nuevos equipos');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Permisos WHERE Nombre='Editar Equipo')
 INSERT INTO SCH_GENERAL.Permisos (Nombre, Descripcion) VALUES('Editar Equipo','Permiso para editar equipos existentes');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Permisos WHERE Nombre='Eliminar Equipo')
 INSERT INTO SCH_GENERAL.Permisos (Nombre, Descripcion) VALUES('Eliminar Equipo','Permiso para eliminar equipos');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Permisos WHERE Nombre='Ver Reportes')
 INSERT INTO SCH_GENERAL.Permisos (Nombre, Descripcion) VALUES('Ver Reportes','Permiso para ver reportes');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Permisos WHERE Nombre='Gestionar Usuarios')
 INSERT INTO SCH_GENERAL.Permisos (Nombre, Descripcion) VALUES('Gestionar Usuarios','Permiso para gestionar usuarios');

--3. PermisosRoles (mapear por nombres)
-- Administrador -> todos
DECLARE @rolAdmin INT = (SELECT Id FROM SCH_GENERAL.Roles WHERE Nombre='Administrador');
DECLARE @rolIT INT = (SELECT Id FROM SCH_GENERAL.Roles WHERE Nombre='Usuario IT');
DECLARE @rolAuditor INT = (SELECT Id FROM SCH_GENERAL.Roles WHERE Nombre='Auditor');

DECLARE @permCrear INT = (SELECT Id FROM SCH_GENERAL.Permisos WHERE Nombre='Crear Equipo');
DECLARE @permEditar INT = (SELECT Id FROM SCH_GENERAL.Permisos WHERE Nombre='Editar Equipo');
DECLARE @permEliminar INT = (SELECT Id FROM SCH_GENERAL.Permisos WHERE Nombre='Eliminar Equipo');
DECLARE @permVer INT = (SELECT Id FROM SCH_GENERAL.Permisos WHERE Nombre='Ver Reportes');
DECLARE @permGestion INT = (SELECT Id FROM SCH_GENERAL.Permisos WHERE Nombre='Gestionar Usuarios');

IF @rolAdmin IS NOT NULL AND @permCrear IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.PermisosRoles WHERE RolId=@rolAdmin AND PermisoId=@permCrear)
 INSERT INTO SCH_GENERAL.PermisosRoles (RolId, PermisoId) VALUES(@rolAdmin,@permCrear);
IF @rolAdmin IS NOT NULL AND @permEditar IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.PermisosRoles WHERE RolId=@rolAdmin AND PermisoId=@permEditar)
 INSERT INTO SCH_GENERAL.PermisosRoles (RolId, PermisoId) VALUES(@rolAdmin,@permEditar);
IF @rolAdmin IS NOT NULL AND @permEliminar IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.PermisosRoles WHERE RolId=@rolAdmin AND PermisoId=@permEliminar)
 INSERT INTO SCH_GENERAL.PermisosRoles (RolId, PermisoId) VALUES(@rolAdmin,@permEliminar);
IF @rolAdmin IS NOT NULL AND @permVer IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.PermisosRoles WHERE RolId=@rolAdmin AND PermisoId=@permVer)
 INSERT INTO SCH_GENERAL.PermisosRoles (RolId, PermisoId) VALUES(@rolAdmin,@permVer);
IF @rolAdmin IS NOT NULL AND @permGestion IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.PermisosRoles WHERE RolId=@rolAdmin AND PermisoId=@permGestion)
 INSERT INTO SCH_GENERAL.PermisosRoles (RolId, PermisoId) VALUES(@rolAdmin,@permGestion);

-- Usuario IT: crear, editar, ver reportes
IF @rolIT IS NOT NULL AND @permCrear IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.PermisosRoles WHERE RolId=@rolIT AND PermisoId=@permCrear)
 INSERT INTO SCH_GENERAL.PermisosRoles (RolId, PermisoId) VALUES(@rolIT,@permCrear);
IF @rolIT IS NOT NULL AND @permEditar IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.PermisosRoles WHERE RolId=@rolIT AND PermisoId=@permEditar)
 INSERT INTO SCH_GENERAL.PermisosRoles (RolId, PermisoId) VALUES(@rolIT,@permEditar);
IF @rolIT IS NOT NULL AND @permVer IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.PermisosRoles WHERE RolId=@rolIT AND PermisoId=@permVer)
 INSERT INTO SCH_GENERAL.PermisosRoles (RolId, PermisoId) VALUES(@rolIT,@permVer);

-- Auditor: ver reportes
IF @rolAuditor IS NOT NULL AND @permVer IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.PermisosRoles WHERE RolId=@rolAuditor AND PermisoId=@permVer)
 INSERT INTO SCH_GENERAL.PermisosRoles (RolId, PermisoId) VALUES(@rolAuditor,@permVer);

--4. Agentes (buscar por correo)
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Agentes WHERE Correo='juan.perez@empresa.com')
 INSERT INTO SCH_GENERAL.Agentes (Nombre, Correo, RolId, Estado) VALUES('Juan Pérez','juan.perez@empresa.com',@rolAdmin,1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Agentes WHERE Correo='maria.garcia@empresa.com')
 INSERT INTO SCH_GENERAL.Agentes (Nombre, Correo, RolId, Estado) VALUES('María García','maria.garcia@empresa.com',@rolIT,1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Agentes WHERE Correo='carlos.lopez@empresa.com')
 INSERT INTO SCH_GENERAL.Agentes (Nombre, Correo, RolId, Estado) VALUES('Carlos López','carlos.lopez@empresa.com',@rolAuditor,1);

--5. Usuarios (por Codigo)
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Usuarios WHERE Codigo=1001)
 INSERT INTO SCH_GENERAL.Usuarios (Codigo, Nombre, Correo, Departamento, Puesto, Estado) VALUES(1001,'Ana Rodríguez','ana.rodriguez@empresa.com','Ventas','Gerente',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Usuarios WHERE Codigo=1002)
 INSERT INTO SCH_GENERAL.Usuarios (Codigo, Nombre, Correo, Departamento, Puesto, Estado) VALUES(1002,'Pedro Martínez','pedro.martinez@empresa.com','IT','Desarrollador',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Usuarios WHERE Codigo=1003)
 INSERT INTO SCH_GENERAL.Usuarios (Codigo, Nombre, Correo, Departamento, Puesto, Estado) VALUES(1003,'Laura Sánchez','laura.sanchez@empresa.com','RRHH','Analista',1);

--6. Marcas
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Marcas WHERE Nombre='Dell') INSERT INTO SCH_GENERAL.Marcas (Nombre, Estado) VALUES('Dell',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Marcas WHERE Nombre='HP') INSERT INTO SCH_GENERAL.Marcas (Nombre, Estado) VALUES('HP',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Marcas WHERE Nombre='Lenovo') INSERT INTO SCH_GENERAL.Marcas (Nombre, Estado) VALUES('Lenovo',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Marcas WHERE Nombre='Cisco') INSERT INTO SCH_GENERAL.Marcas (Nombre, Estado) VALUES('Cisco',1);

--7. Categorias
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Categorias WHERE Nombre='Computadoras') INSERT INTO SCH_GENERAL.Categorias (Nombre, Descripcion, Estado) VALUES('Computadoras','Equipos de cómputo',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Categorias WHERE Nombre='Redes') INSERT INTO SCH_GENERAL.Categorias (Nombre, Descripcion, Estado) VALUES('Redes','Equipos de red',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Categorias WHERE Nombre='Impresoras') INSERT INTO SCH_GENERAL.Categorias (Nombre, Descripcion, Estado) VALUES('Impresoras','Dispositivos de impresión',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Categorias WHERE Nombre='Periféricos') INSERT INTO SCH_GENERAL.Categorias (Nombre, Descripcion, Estado) VALUES('Periféricos','Accesorios',1);

--8. Subcategorias (usar lookup de categoria)
DECLARE @catComputadoras INT = (SELECT Id FROM SCH_GENERAL.Categorias WHERE Nombre='Computadoras');
DECLARE @catRedes INT = (SELECT Id FROM SCH_GENERAL.Categorias WHERE Nombre='Redes');
DECLARE @catImpresoras INT = (SELECT Id FROM SCH_GENERAL.Categorias WHERE Nombre='Impresoras');
DECLARE @catPerifericos INT = (SELECT Id FROM SCH_GENERAL.Categorias WHERE Nombre='Periféricos');

IF @catComputadoras IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Subcategorias WHERE Nombre='Laptops' AND CategoriaId=@catComputadoras)
 INSERT INTO SCH_GENERAL.Subcategorias (Nombre, CategoriaId, Descripcion, Estado) VALUES('Laptops',@catComputadoras,'Computadoras portátiles',1);
IF @catComputadoras IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Subcategorias WHERE Nombre='Escritorios' AND CategoriaId=@catComputadoras)
 INSERT INTO SCH_GENERAL.Subcategorias (Nombre, CategoriaId, Descripcion, Estado) VALUES('Escritorios',@catComputadoras,'Computadoras de escritorio',1);
IF @catComputadoras IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Subcategorias WHERE Nombre='Servidores' AND CategoriaId=@catComputadoras)
 INSERT INTO SCH_GENERAL.Subcategorias (Nombre, CategoriaId, Descripcion, Estado) VALUES('Servidores',@catComputadoras,'Servidores',1);
IF @catRedes IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Subcategorias WHERE Nombre='Routers' AND CategoriaId=@catRedes)
 INSERT INTO SCH_GENERAL.Subcategorias (Nombre, CategoriaId, Descripcion, Estado) VALUES('Routers',@catRedes,'Dispositivos de enrutamiento',1);
IF @catRedes IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Subcategorias WHERE Nombre='Switches' AND CategoriaId=@catRedes)
 INSERT INTO SCH_GENERAL.Subcategorias (Nombre, CategoriaId, Descripcion, Estado) VALUES('Switches',@catRedes,'Dispositivos de conmutación',1);
IF @catImpresoras IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Subcategorias WHERE Nombre='Impresoras Laser' AND CategoriaId=@catImpresoras)
 INSERT INTO SCH_GENERAL.Subcategorias (Nombre, CategoriaId, Descripcion, Estado) VALUES('Impresoras Laser',@catImpresoras,'Impresoras láser',1);
IF @catPerifericos IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Subcategorias WHERE Nombre='Monitores' AND CategoriaId=@catPerifericos)
 INSERT INTO SCH_GENERAL.Subcategorias (Nombre, CategoriaId, Descripcion, Estado) VALUES('Monitores',@catPerifericos,'Pantallas',1);
IF @catPerifericos IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Subcategorias WHERE Nombre='Teclados' AND CategoriaId=@catPerifericos)
 INSERT INTO SCH_GENERAL.Subcategorias (Nombre, CategoriaId, Descripcion, Estado) VALUES('Teclados',@catPerifericos,'Dispositivos de entrada',1);

--9. Modelos (usar lookups de marca y subcategoria)
DECLARE @idDell INT = (SELECT Id FROM SCH_GENERAL.Marcas WHERE Nombre='Dell');
DECLARE @idHP INT = (SELECT Id FROM SCH_GENERAL.Marcas WHERE Nombre='HP');
DECLARE @idLenovo INT = (SELECT Id FROM SCH_GENERAL.Marcas WHERE Nombre='Lenovo');
DECLARE @idCisco INT = (SELECT Id FROM SCH_GENERAL.Marcas WHERE Nombre='Cisco');

DECLARE @subLaptops INT = (SELECT Id FROM SCH_GENERAL.Subcategorias WHERE Nombre='Laptops' AND CategoriaId=@catComputadoras);
DECLARE @subEscritorios INT = (SELECT Id FROM SCH_GENERAL.Subcategorias WHERE Nombre='Escritorios' AND CategoriaId=@catComputadoras);
DECLARE @subServidores INT = (SELECT Id FROM SCH_GENERAL.Subcategorias WHERE Nombre='Servidores' AND CategoriaId=@catComputadoras);
DECLARE @subSwitches INT = (SELECT Id FROM SCH_GENERAL.Subcategorias WHERE Nombre='Switches' AND CategoriaId=@catRedes);
DECLARE @subImpresorasLaser INT = (SELECT Id FROM SCH_GENERAL.Subcategorias WHERE Nombre='Impresoras Laser' AND CategoriaId=@catImpresoras);
DECLARE @subMonitores INT = (SELECT Id FROM SCH_GENERAL.Subcategorias WHERE Nombre='Monitores' AND CategoriaId=@catPerifericos);
DECLARE @subTeclados INT = (SELECT Id FROM SCH_GENERAL.Subcategorias WHERE Nombre='Teclados' AND CategoriaId=@catPerifericos);

IF @idDell IS NOT NULL AND @subLaptops IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='Latitude5420' AND MarcaId=@idDell AND SubcategoriaId=@subLaptops)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('Latitude5420',@idDell,@subLaptops,1);
IF @idHP IS NOT NULL AND @subLaptops IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='ProBook450' AND MarcaId=@idHP AND SubcategoriaId=@subLaptops)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('ProBook450',@idHP,@subLaptops,1);
IF @idLenovo IS NOT NULL AND @subLaptops IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='ThinkPad X1' AND MarcaId=@idLenovo AND SubcategoriaId=@subLaptops)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('ThinkPad X1',@idLenovo,@subLaptops,1);
IF @idDell IS NOT NULL AND @subEscritorios IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='OptiPlex7090' AND MarcaId=@idDell AND SubcategoriaId=@subEscritorios)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('OptiPlex7090',@idDell,@subEscritorios,1);
IF @idHP IS NOT NULL AND @subEscritorios IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='ProDesk400' AND MarcaId=@idHP AND SubcategoriaId=@subEscritorios)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('ProDesk400',@idHP,@subEscritorios,1);
IF @idDell IS NOT NULL AND @subServidores IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='PowerEdge R750' AND MarcaId=@idDell AND SubcategoriaId=@subServidores)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('PowerEdge R750',@idDell,@subServidores,1);
IF @idHP IS NOT NULL AND @subServidores IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='ProLiant DL380' AND MarcaId=@idHP AND SubcategoriaId=@subServidores)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('ProLiant DL380',@idHP,@subServidores,1);
IF @idCisco IS NOT NULL AND @subSwitches IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='Catalyst2960' AND MarcaId=@idCisco AND SubcategoriaId=@subSwitches)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('Catalyst2960',@idCisco,@subSwitches,1);
IF @idHP IS NOT NULL AND @subImpresorasLaser IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='LaserJet Pro M182nw' AND MarcaId=@idHP AND SubcategoriaId=@subImpresorasLaser)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('LaserJet Pro M182nw',@idHP,@subImpresorasLaser,1);
IF @idDell IS NOT NULL AND @subMonitores IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='UltraSharp U2720Q' AND MarcaId=@idDell AND SubcategoriaId=@subMonitores)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('UltraSharp U2720Q',@idDell,@subMonitores,1);
IF @idLenovo IS NOT NULL AND @subTeclados IS NOT NULL AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Modelos WHERE Nombre='K380' AND MarcaId=@idLenovo AND SubcategoriaId=@subTeclados)
 INSERT INTO SCH_GENERAL.Modelos (Nombre, MarcaId, SubcategoriaId, Estado) VALUES('K380',@idLenovo,@subTeclados,1);

--10. Contratos
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato A') INSERT INTO SCH_GENERAL.Contratos (Nombre, Descripcion, Estado) VALUES('Contrato A','Contrato estándar para equipos',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato B') INSERT INTO SCH_GENERAL.Contratos (Nombre, Descripcion, Estado) VALUES('Contrato B','Contrato premium',1);

--11. Bodegas
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal') INSERT INTO SCH_GENERAL.Bodegas (Nombre, Ubicacion, Estado) VALUES('Bodega Principal','Edificio A, Piso1',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Secundaria') INSERT INTO SCH_GENERAL.Bodegas (Nombre, Ubicacion, Estado) VALUES('Bodega Secundaria','Edificio B, Piso2',1);

--12. Estados
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Estados WHERE Nombre='Asignado') INSERT INTO SCH_GENERAL.Estados (Nombre) VALUES('Asignado');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Estados WHERE Nombre='No Asignado') INSERT INTO SCH_GENERAL.Estados (Nombre) VALUES('No Asignado');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Estados WHERE Nombre='Transferido') INSERT INTO SCH_GENERAL.Estados (Nombre) VALUES('Transferido');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Estados WHERE Nombre='Leasing') INSERT INTO SCH_GENERAL.Estados (Nombre) VALUES('Leasing');
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Estados WHERE Nombre='En Reparación') INSERT INTO SCH_GENERAL.Estados (Nombre) VALUES('En Reparación');

--13. TiposSalida
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.TiposSalida WHERE Nombre='Asignación') INSERT INTO SCH_GENERAL.TiposSalida (Nombre, Descripcion, Estado) VALUES('Asignación','Salida por asignación a usuario',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.TiposSalida WHERE Nombre='Transferencia') INSERT INTO SCH_GENERAL.TiposSalida (Nombre, Descripcion, Estado) VALUES('Transferencia','Salida por transferencia entre bodegas',1);
IF NOT EXISTS(SELECT 1 FROM SCH_GENERAL.TiposSalida WHERE Nombre='Devolución') INSERT INTO SCH_GENERAL.TiposSalida (Nombre, Descripcion, Estado) VALUES('Devolución','Salida por devolución',1);

--14. Equipos (usar lookups para FKs: Modelo, Contrato, Bodega)
INSERT INTO SCH_GENERAL.Equipos (Serie, ModeloId, ContratoId, BodegaId, TipoSalidaId, EstadoEquipo, Descripcion, Estado)
SELECT 'DELL001', M.Id, C.Id, B.Id, NULL,2, 'Laptop Dell nueva',1
FROM SCH_GENERAL.Modelos M
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato A') C
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal') B
WHERE M.Nombre='Latitude 5420' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Equipos E WHERE E.Serie='DELL001');

INSERT INTO SCH_GENERAL.Equipos (Serie, ModeloId, ContratoId, BodegaId, TipoSalidaId, EstadoEquipo, Descripcion, Estado)
SELECT 'HP001', M.Id, C.Id, B.Id, NULL,2, 'Laptop HP',1
FROM SCH_GENERAL.Modelos M
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato A') C
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal') B
WHERE M.Nombre='ProBook 450' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Equipos E WHERE E.Serie='HP001');

INSERT INTO SCH_GENERAL.Equipos (Serie, ModeloId, ContratoId, BodegaId, TipoSalidaId, EstadoEquipo, Descripcion, Estado)
SELECT 'LEN001', M.Id, C.Id, B.Id, NULL,1, 'Laptop Lenovo asignada',1
FROM SCH_GENERAL.Modelos M
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato B') C
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal') B
WHERE M.Nombre='ThinkPad X1' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Equipos E WHERE E.Serie='LEN001');

-- Otros equipos
INSERT INTO SCH_GENERAL.Equipos (Serie, ModeloId, ContratoId, BodegaId, TipoSalidaId, EstadoEquipo, Descripcion, Estado)
SELECT 'DESK001', M.Id, C.Id, B.Id, NULL,2, 'Desktop Dell',1
FROM SCH_GENERAL.Modelos M
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato A') C
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Secundaria') B
WHERE M.Nombre='OptiPlex 7090' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Equipos E WHERE E.Serie='DESK001');

INSERT INTO SCH_GENERAL.Equipos (Serie, ModeloId, ContratoId, BodegaId, TipoSalidaId, EstadoEquipo, Descripcion, Estado)
SELECT 'SERV001', M.Id, C.Id, B.Id, NULL,2, 'Servidor Dell',1
FROM SCH_GENERAL.Modelos M
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato B') C
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal') B
WHERE M.Nombre='PowerEdge R750' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Equipos E WHERE E.Serie='SERV001');

INSERT INTO SCH_GENERAL.Equipos (Serie, ModeloId, ContratoId, BodegaId, TipoSalidaId, EstadoEquipo, Descripcion, Estado)
SELECT 'SWITCH001', M.Id, C.Id, B.Id, NULL,2, 'Switch Cisco',1
FROM SCH_GENERAL.Modelos M
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato A') C
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal') B
WHERE M.Nombre='Catalyst 2960' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Equipos E WHERE E.Serie='SWITCH001');

INSERT INTO SCH_GENERAL.Equipos (Serie, ModeloId, ContratoId, BodegaId, TipoSalidaId, EstadoEquipo, Descripcion, Estado)
SELECT 'PRINT001', M.Id, C.Id, B.Id, NULL,2, 'Impresora HP',1
FROM SCH_GENERAL.Modelos M
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato A') C
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Secundaria') B
WHERE M.Nombre='LaserJet Pro M182nw' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Equipos E WHERE E.Serie='PRINT001');

INSERT INTO SCH_GENERAL.Equipos (Serie, ModeloId, ContratoId, BodegaId, TipoSalidaId, EstadoEquipo, Descripcion, Estado)
SELECT 'MON001', M.Id, C.Id, B.Id, NULL,2, 'Monitor Dell',1
FROM SCH_GENERAL.Modelos M
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Contratos WHERE Nombre='Contrato A') C
CROSS JOIN (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal') B
WHERE M.Nombre='UltraSharp U2720Q' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Equipos E WHERE E.Serie='MON001');

--15. Ingresos (usar bodega lookup)
INSERT INTO SCH_GENERAL.Ingresos (Usuario, Host, Dominio, BodegaId, Fecha, Hora, Descripcion, Estado, TipoIngreso)
SELECT 'admin','PC001','empresa.com', (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal'), '2023-10-01','09:00','Ingreso inicial de equipos',1,'Compra'
WHERE NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Ingresos WHERE Usuario='admin' AND Fecha='2023-10-01' AND TipoIngreso='Compra');

INSERT INTO SCH_GENERAL.Ingresos (Usuario, Host, Dominio, BodegaId, Fecha, Hora, Descripcion, Estado, TipoIngreso)
SELECT 'admin','PC002','empresa.com', (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Secundaria'), '2023-10-02','10:00','Ingreso adicional',1,'Donación'
WHERE NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Ingresos WHERE Usuario='admin' AND Fecha='2023-10-02' AND TipoIngreso='Donación');

--16. Egresos (usar lookup de usuario por Codigo)
INSERT INTO SCH_GENERAL.Egresos (UsuarioId, ViceId, BodegaId, TipoSalidaId, Usuario, Host, Fecha, Hora, Path, Adjunto, Descripcion, Estado)
SELECT U.Id,1, (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal'), (SELECT Id FROM SCH_GENERAL.TiposSalida WHERE Nombre='Asignación'), 'admin','PC001','2023-10-03','11:00', NULL,0, 'Asignación a usuario',1
FROM SCH_GENERAL.Usuarios U
WHERE U.Codigo=1001 AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Egresos WHERE UsuarioId=U.Id AND Fecha='2023-10-03' AND Descripcion='Asignación a usuario');

INSERT INTO SCH_GENERAL.Egresos (UsuarioId, ViceId, BodegaId, TipoSalidaId, Usuario, Host, Fecha, Hora, Path, Adjunto, Descripcion, Estado)
SELECT U.Id,1, (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal'), (SELECT Id FROM SCH_GENERAL.TiposSalida WHERE Nombre='Asignación'), 'admin','PC001','2023-10-04','12:00', NULL,0, 'Asignación a desarrollador',1
FROM SCH_GENERAL.Usuarios U
WHERE U.Codigo=1002 AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Egresos WHERE UsuarioId=U.Id AND Fecha='2023-10-04' AND Descripcion='Asignación a desarrollador');

--17. DetalleEgreso (referenciar Equipos por Serie y Egresos por Fecha+Descripcion)
INSERT INTO SCH_GENERAL.DetalleEgreso (EgresoId, EquipoId, Estado)
SELECT E.Id, EQ.Id,1
FROM SCH_GENERAL.Egresos E
INNER JOIN SCH_GENERAL.Usuarios U ON E.UsuarioId = U.Id
INNER JOIN SCH_GENERAL.Equipos EQ ON EQ.Serie='LEN001'
WHERE U.Codigo=1001 AND E.Fecha='2023-10-03' AND E.Descripcion='Asignación a usuario' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.DetalleEgreso DE WHERE DE.EgresoId=E.Id AND DE.EquipoId=EQ.Id);

INSERT INTO SCH_GENERAL.DetalleEgreso (EgresoId, EquipoId, Estado)
SELECT E.Id, EQ.Id,1
FROM SCH_GENERAL.Egresos E
INNER JOIN SCH_GENERAL.Usuarios U ON E.UsuarioId = U.Id
INNER JOIN SCH_GENERAL.Equipos EQ ON EQ.Serie='DELL001'
WHERE U.Codigo=1002 AND E.Fecha='2023-10-04' AND E.Descripcion='Asignación a desarrollador' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.DetalleEgreso DE WHERE DE.EgresoId=E.Id AND DE.EquipoId=EQ.Id);

--18. Devoluciones
INSERT INTO SCH_GENERAL.Devoluciones (EgresoId, Fecha, Hora, Path, EstadoEquipo, Agente, Descripcion, Adjunto, Estado, BodegaId)
SELECT E.Id, '2023-10-05','13:00', NULL,2, A.Nombre, 'Devolución por cambio de puesto',0,1, (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal')
FROM SCH_GENERAL.Egresos E
INNER JOIN SCH_GENERAL.Agentes A ON A.Correo='juan.perez@empresa.com'
WHERE E.Fecha='2023-10-03' AND E.Descripcion='Asignación a usuario' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.Devoluciones D WHERE D.EgresoId=E.Id AND D.Fecha='2023-10-05');

--19. DetalleDevolucion
INSERT INTO SCH_GENERAL.DetalleDevolucion (DevolucionId, EquipoId, EstadoEquipo, Estado)
SELECT D.Id, EQ.Id,2,1
FROM SCH_GENERAL.Devoluciones D
INNER JOIN SCH_GENERAL.Egresos E ON D.EgresoId = E.Id
INNER JOIN SCH_GENERAL.Equipos EQ ON EQ.Serie='LEN001'
WHERE E.Fecha='2023-10-03' AND D.Fecha='2023-10-05' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.DetalleDevolucion DD WHERE DD.DevolucionId=D.Id AND DD.EquipoId=EQ.Id);

--20. KardexEquipo (usar MovId como Id de Ingresos/Egresos según corresponda)
INSERT INTO SCH_GENERAL.KardexEquipo (MovId, Serie, TipoMov, BodegaId, Estado)
SELECT I.Id, 'DELL001',1, (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal'),1 FROM SCH_GENERAL.Ingresos I WHERE I.Fecha='2023-10-01' AND I.TipoIngreso='Compra' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.KardexEquipo K WHERE K.MovId=I.Id AND K.Serie='DELL001');

INSERT INTO SCH_GENERAL.KardexEquipo (MovId, Serie, TipoMov, BodegaId, Estado)
SELECT I.Id, 'HP001',1, (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal'),1 FROM SCH_GENERAL.Ingresos I WHERE I.Fecha='2023-10-01' AND I.TipoIngreso='Compra' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.KardexEquipo K WHERE K.MovId=I.Id AND K.Serie='HP001');

-- Egresos -> TipoMov2
INSERT INTO SCH_GENERAL.KardexEquipo (MovId, Serie, TipoMov, BodegaId, Estado)
SELECT E.Id, 'LEN001',2, (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal'),1 FROM SCH_GENERAL.Egresos E WHERE E.Fecha='2023-10-03' AND E.Descripcion='Asignación a usuario' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.KardexEquipo K WHERE K.MovId=E.Id AND K.Serie='LEN001');

INSERT INTO SCH_GENERAL.KardexEquipo (MovId, Serie, TipoMov, BodegaId, Estado)
SELECT E.Id, 'DELL001',2, (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal'),1 FROM SCH_GENERAL.Egresos E WHERE E.Fecha='2023-10-04' AND E.Descripcion='Asignación a desarrollador' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.KardexEquipo K WHERE K.MovId=E.Id AND K.Serie='DELL001');

--21. KardexUsuarios
INSERT INTO SCH_GENERAL.KardexUsuarios (MovId, UsuarioId, TipoMov, BodegaId, Estado)
SELECT E.Id, U.Id,2, (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal'),1
FROM SCH_GENERAL.Egresos E
INNER JOIN SCH_GENERAL.Usuarios U ON U.Id=E.UsuarioId
WHERE E.Fecha='2023-10-03' AND E.Descripcion='Asignación a usuario' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.KardexUsuarios K WHERE K.MovId=E.Id AND K.UsuarioId=U.Id);

INSERT INTO SCH_GENERAL.KardexUsuarios (MovId, UsuarioId, TipoMov, BodegaId, Estado)
SELECT E.Id, U.Id,2, (SELECT Id FROM SCH_GENERAL.Bodegas WHERE Nombre='Bodega Principal'),1
FROM SCH_GENERAL.Egresos E
INNER JOIN SCH_GENERAL.Usuarios U ON U.Id=E.UsuarioId
WHERE E.Fecha='2023-10-04' AND E.Descripcion='Asignación a desarrollador' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.KardexUsuarios K WHERE K.MovId=E.Id AND K.UsuarioId=U.Id);

--22. BitacoraAuditoria
INSERT INTO SCH_GENERAL.BitacoraAuditoria (AgenteId, Accion, Entidad, EntidadId, Detalles, ValoresAntiguos, ValoresNuevos)
SELECT A.Id,'Crear Equipo','Equipos',EQ.Id,'Equipo creado',NULL,'Serie: DELL001'
FROM SCH_GENERAL.Agentes A
INNER JOIN SCH_GENERAL.Equipos EQ ON EQ.Serie='DELL001'
WHERE A.Correo='juan.perez@empresa.com' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.BitacoraAuditoria B WHERE B.AgenteId=A.Id AND B.Accion='Crear Equipo' AND B.Entidad='Equipos' AND B.EntidadId=EQ.Id);

INSERT INTO SCH_GENERAL.BitacoraAuditoria (AgenteId, Accion, Entidad, EntidadId, Detalles, ValoresAntiguos, ValoresNuevos)
SELECT A.Id,'Asignar Equipo','Equipos',EQ.Id,'Equipo asignado a usuario','Estado: No Asignado','Estado: Asignado'
FROM SCH_GENERAL.Agentes A
INNER JOIN SCH_GENERAL.Equipos EQ ON EQ.Serie='LEN001'
WHERE A.Correo='maria.garcia@empresa.com' AND NOT EXISTS(SELECT 1 FROM SCH_GENERAL.BitacoraAuditoria B WHERE B.AgenteId=A.Id AND B.Accion='Asignar Equipo' AND B.Entidad='Equipos' AND B.EntidadId=EQ.Id);

-- Reiniciar secuencias al valor calculado (cursor dinámico)
DECLARE @seq nvarchar(200), @tbl nvarchar(200), @sql nvarchar(max), @maxid bigint;

DECLARE seq_cursor CURSOR FOR
SELECT 'SCH_GENERAL.Seq_Roles','SCH_GENERAL.Roles' UNION ALL
SELECT 'SCH_GENERAL.Seq_Permisos','SCH_GENERAL.Permisos' UNION ALL
SELECT 'SCH_GENERAL.Seq_Agentes','SCH_GENERAL.Agentes' UNION ALL
SELECT 'SCH_GENERAL.Seq_Usuarios','SCH_GENERAL.Usuarios' UNION ALL
SELECT 'SCH_GENERAL.Seq_Marcas','SCH_GENERAL.Marcas' UNION ALL
SELECT 'SCH_GENERAL.Seq_Categorias','SCH_GENERAL.Categorias' UNION ALL
SELECT 'SCH_GENERAL.Seq_Subcategorias','SCH_GENERAL.Subcategorias' UNION ALL
SELECT 'SCH_GENERAL.Seq_Modelos','SCH_GENERAL.Modelos' UNION ALL
SELECT 'SCH_GENERAL.Seq_Contratos','SCH_GENERAL.Contratos' UNION ALL
SELECT 'SCH_GENERAL.Seq_Bodegas','SCH_GENERAL.Bodegas' UNION ALL
SELECT 'SCH_GENERAL.Seq_Estados','SCH_GENERAL.Estados' UNION ALL
SELECT 'SCH_GENERAL.Seq_TiposSalida','SCH_GENERAL.TiposSalida' UNION ALL
SELECT 'SCH_GENERAL.Seq_Equipos','SCH_GENERAL.Equipos' UNION ALL
SELECT 'SCH_GENERAL.Seq_Ingresos','SCH_GENERAL.Ingresos' UNION ALL
SELECT 'SCH_GENERAL.Seq_Egresos','SCH_GENERAL.Egresos' UNION ALL
SELECT 'SCH_GENERAL.Seq_DetalleEgreso','SCH_GENERAL.DetalleEgreso' UNION ALL
SELECT 'SCH_GENERAL.Seq_Devoluciones','SCH_GENERAL.Devoluciones' UNION ALL
SELECT 'SCH_GENERAL.Seq_DetalleDevolucion','SCH_GENERAL.DetalleDevolucion' UNION ALL
SELECT 'SCH_GENERAL.Seq_KardexEquipo','SCH_GENERAL.KardexEquipo' UNION ALL
SELECT 'SCH_GENERAL.Seq_KardexUsuarios','SCH_GENERAL.KardexUsuarios' UNION ALL
SELECT 'SCH_GENERAL.Seq_BitacoraAuditoria','SCH_GENERAL.BitacoraAuditoria';

OPEN seq_cursor;
FETCH NEXT FROM seq_cursor INTO @seq, @tbl;
WHILE @@FETCH_STATUS =0
BEGIN
 SET @sql = N'SELECT @m = ISNULL(MAX(Id),0) +1 FROM ' + @tbl + N';';
 EXEC sp_executesql @sql, N'@m bigint OUTPUT', @m = @maxid OUTPUT;

 SET @sql = N'ALTER SEQUENCE ' + @seq + N' RESTART WITH ' + CAST(@maxid AS nvarchar(20)) + N';';
 EXEC(@sql);

 FETCH NEXT FROM seq_cursor INTO @seq, @tbl;
END

CLOSE seq_cursor;
DEALLOCATE seq_cursor;

GO