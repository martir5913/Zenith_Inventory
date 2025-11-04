-- Script para agregar permisos de Categorías
USE [DB_Zenith_Inventory]
GO

-- Insertar permisos de CATEGORIAS
INSERT INTO ZI_GENERAL.ZI_PERMISOS (PER_Nombre, PER_Descripcion, PER_Modulo, PER_Accion, PER_UsuarioCreacion) 
VALUES 
('CATEGORIAS_CREAR', 'Crear categorías', 'CATEGORIAS', 'CREAR', 'SYSTEM'),
('CATEGORIAS_LEER', 'Consultar categorías', 'CATEGORIAS', 'LEER', 'SYSTEM'),
('CATEGORIAS_ACTUALIZAR', 'Actualizar categorías', 'CATEGORIAS', 'ACTUALIZAR', 'SYSTEM'),
('CATEGORIAS_ELIMINAR', 'Eliminar categorías', 'CATEGORIAS', 'ELIMINAR', 'SYSTEM');

-- Asignar permisos de CATEGORIAS al rol Administrador (ROL_Id = 1)
DECLARE @PermisoCategoriaCrear INT, @PermisoCategoriaLeer INT, @PermisoCategoriaActualizar INT, @PermisoCategoriaEliminar INT;

SELECT @PermisoCategoriaCrear = PER_Id FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Nombre = 'CATEGORIAS_CREAR';
SELECT @PermisoCategoriaLeer = PER_Id FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Nombre = 'CATEGORIAS_LEER';
SELECT @PermisoCategoriaActualizar = PER_Id FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Nombre = 'CATEGORIAS_ACTUALIZAR';
SELECT @PermisoCategoriaEliminar = PER_Id FROM ZI_GENERAL.ZI_PERMISOS WHERE PER_Nombre = 'CATEGORIAS_ELIMINAR';

-- Asignar al rol Administrador
INSERT INTO ZI_GENERAL.ZI_PERMISOSROLES (PRO_RolId, PRO_PermisoId) 
VALUES 
(1, @PermisoCategoriaCrear),
(1, @PermisoCategoriaLeer),
(1, @PermisoCategoriaActualizar),
(1, @PermisoCategoriaEliminar);

-- Asignar permiso de LEER al rol Usuario (ROL_Id = 2)
INSERT INTO ZI_GENERAL.ZI_PERMISOSROLES (PRO_RolId, PRO_PermisoId) 
VALUES (2, @PermisoCategoriaLeer);

-- Asignar permiso de LEER al rol Consulta (ROL_Id = 3)
INSERT INTO ZI_GENERAL.ZI_PERMISOSROLES (PRO_RolId, PRO_PermisoId) 
VALUES (3, @PermisoCategoriaLeer);

GO
