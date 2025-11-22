/*
  Script de creación de base de datos para TechShop
  Este script crea el esquema, tablas, usuarios, y
  carga datos de ejemplo.
*/
-- Sección de administración (ejecutar una vez en un entorno de desarrollo)
drop database if exists techshop;
drop user if exists usuario_prueba;
drop user if exists usuario_reportes;

-- Creación del esquema
CREATE database techshop
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

-- Creación de usuarios con contraseñas seguras (idealmente asignadas fuera del script)
create user 'usuario_prueba'@'%' identified by 'Usuar1o_Clave.';
create user 'usuario_reportes'@'%' identified by 'Usuar1o_Reportes.';

-- Asignación de permisos
-- Se otorgan permisos específicos en lugar de todos los permisos a todas las tablas futuras
grant select, insert, update, delete on techshop.* to 'usuario_prueba'@'%';
grant select on techshop.* to 'usuario_reportes'@'%';
flush privileges;

use techshop;

-- --- Sección de Creación de Tablas ---

-- Tabla de categorías
create table categoria (
  id_categoria INT NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50) NOT NULL,
  ruta_imagen varchar(1024),
  activo boolean,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_categoria),
  unique (descripcion),
  index ndx_descripcion (descripcion))
  ENGINE = InnoDB;

-- Tabla de productos
create table producto (
  id_producto INT NOT NULL AUTO_INCREMENT,
  id_categoria INT NOT NULL,
  descripcion VARCHAR(50) NOT NULL,  
  detalle text, 
  precio decimal(12,2) CHECK (precio >= 0),
  existencias int unsigned CHECK (existencias >= 0),
  ruta_imagen varchar(1024),
  activo boolean,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_producto),
  unique (descripcion),
  index ndx_descripcion (descripcion),
  foreign key fk_producto_categoria (id_categoria) references categoria(id_categoria))
  ENGINE = InnoDB;

-- Tabla de usuarios
CREATE TABLE usuario (
  id_usuario INT NOT NULL AUTO_INCREMENT,
  username varchar(30) NOT NULL UNIQUE,
  password varchar(512) NOT NULL,
  nombre VARCHAR(20) NOT NULL,
  apellidos VARCHAR(30) NOT NULL,
  correo VARCHAR(75) NULL UNIQUE,
  telefono VARCHAR(25) NULL,
  ruta_imagen varchar(1024),
  activo boolean,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  CHECK (correo REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'),
  index ndx_username (username))
  ENGINE = InnoDB;

-- Tabla de facturas
create table factura (
  id_factura INT NOT NULL AUTO_INCREMENT,
  id_usuario INT NOT NULL,
  fecha date,  
  total decimal(12,2) check (total>0),
  estado ENUM('Activa', 'Pagada', 'Anulada') NOT NULL,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_factura),  
  index ndx_id_usuario (id_usuario),
  foreign key fk_factura_usuario (id_usuario) references usuario(id_usuario))
  ENGINE = InnoDB;

-- Tabla de ventas
create table venta (
  id_venta INT NOT NULL AUTO_INCREMENT,
  id_factura INT NOT NULL,
  id_producto INT NOT NULL,
  precio_historico decimal(12,2) check (precio_historico>= 0), 
  cantidad int unsigned check (cantidad> 0),
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_venta),
  index ndx_factura (id_factura),
  index ndx_producto (id_producto),
  UNIQUE (id_factura, id_producto),
  foreign key fk_venta_factura (id_factura) references factura(id_factura),
  foreign key fk_venta_producto (id_producto) references producto(id_producto))
  ENGINE = InnoDB;

-- Tabla de roles
create table rol (
  id_rol INT NOT NULL AUTO_INCREMENT,
  rol varchar(20) unique,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  primary key (id_rol))
  ENGINE = InnoDB;

-- Tabla de relación entre usuarios y roles
create table usuario_rol (
  id_usuario int not null,
  id_rol INT NOT NULL,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usuario,id_rol),
  foreign key fk_usuarioRol_usuario (id_usuario) references usuario(id_usuario),
  foreign key fk_usuarioRol_rol (id_rol) references rol(id_rol))
  ENGINE = InnoDB;

-- Tabla de rutas
CREATE TABLE ruta (
    id_ruta INT AUTO_INCREMENT NOT NULL,
    ruta VARCHAR(255) NOT NULL,
    id_rol INT NULL,
    requiere_rol boolean NOT NULL DEFAULT TRUE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    check (id_rol IS NOT NULL OR requiere_rol = FALSE),
    PRIMARY KEY (id_ruta),
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol))
    ENGINE = InnoDB;

-- Tabla de constantes de la aplicación
CREATE TABLE constante (
    id_constante INT AUTO_INCREMENT NOT NULL,
    atributo VARCHAR(25) NOT NULL,
    valor VARCHAR(150) NOT NULL,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_constante),
    UNIQUE (atributo))
    ENGINE = InnoDB;

-- --- Sección de Inserción de Datos ---
-- Inserción de usuarios
INSERT INTO usuario (username,password,nombre, apellidos, correo, telefono,ruta_imagen,activo) VALUES 
('juan','$2a$10$P1.w58XvnaYQUQgZUCk4aO/RTRl8EValluCqB3S2VMLTbRt.tlre.','Juan', 'Castro Mora',    'jcastro@gmail.com',    '4556-8978', 'https://img2.rtve.es/i/?w=1600&i=1677587980597.jpg',true),
('rebeca','$2a$10$GkEj.ZzmQa/aEfDmtLIh3udIH5fMphx/35d0EYeqZL5uzgCJ0lQRi','Rebeca',  'Contreras Mora', 'acontreras@gmail.com', '5456-8789','https://media.licdn.com/dms/image/v2/C5603AQGwjJ5ht4bWXQ/profile-displayphoto-shrink_200_200/profile-displayphoto-shrink_200_200/0/1661476259292?e=2147483647&v=beta&t=9_i5zTdqHRMSXlb9H4TuWkWeRGQXmaZLjxkBlWsg2lg',true),
('pedro','$2a$10$koGR7eS22Pv5KdaVJKDcge04ZB53iMiw76.UjHPY.XyVYlYqXnPbO','Pedro', 'Mena Loria',     'lmena@gmail.com',      '7898-8936','https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Eduardo_de_Pedro_2019.jpg/480px-Eduardo_de_Pedro_2019.jpg?20200109230854',true);

-- Inserción de categorias
INSERT INTO categoria (descripcion,ruta_imagen,activo) VALUES 
('Monitores', 'https://image.benq.com/is/image/benqco/monitor-all-series-kv-m?$ResponsivePreset$&fmt=png-alpha',   true), 
('Teclados',  'https://cnnespanol.cnn.com/wp-content/uploads/2022/04/teclado-mecanico.jpg',   true),
('Tarjeta Madre','https://static-geektopia.com/storage/thumbs/784x311/788/7884251b/98c0f4a5.webp',true),
('Celulares','https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyVjIkJkEs1CqujaBs6G0PUxGJJ4vlCTFxsQ&s',    false);

-- Inserción de productos
INSERT INTO producto (id_categoria,descripcion,detalle,precio,existencias,ruta_imagen,activo) VALUES
(1,'Monitor AOC 19','Lorem ipsum dolor sit amet consectetur adipiscing elit iaculis, ullamcorper in fringilla eu cras tempor mi. Luctus blandit sapien mauris vestibulum consequat mattis taciti aliquam ullamcorper, sagittis suscipit etiam urna convallis interdum tempor bibendum, ultricies habitant viverra natoque dictum posuere senectus volutpat. Cum ad vehicula condimentum nunc lacus nec tellus eleifend, a platea curae nullam sollicitudin nibh class cursus taciti, posuere purus inceptos facilisis cubilia suspendisse ut.',23000,5,'https://c.pxhere.com/images/ec/fd/d67b367ed6467eb826842ac81d3b-1453591.jpg!d',true),
(1,'Monitor MAC','Quisque in ridiculus scelerisque platea accumsan libero sem vel, mi cras metus cubilia tempor conubia fermentum volutpat gravida, maecenas semper sodales potenti turpis enim dapibus. Volutpat accumsan vivamus dignissim blandit vel eget posuere donec id, tempus sagittis aliquam erat luctus ornare aptent cubilia aliquet proin, ultrices ante pretium gravida sed vitae vestibulum aenean. Eleifend nascetur conubia ornare purus a eget at metus est risus natoque, elementum dis vulputate sociosqu integer ut ad nisl dui molestie.',27000,2,'https://c.pxhere.com/photos/17/77/Art_Calendar_Cc0_Creative_Design_High_Resolution_Mac_Stock-1622403.jpg!d',true),
(1,'Monitor Flex 21','Natoque lacinia accumsan hendrerit pretium sociis imperdiet a, nullam ornare erat suspendisse praesent porta, euismod in augue tempus aliquet habitasse. Non accumsan nostra cras vestibulum augue facilisi auctor scelerisque suscipit, iaculis maecenas varius sollicitudin lacus netus et ultricies tincidunt, tortor curabitur tempor diam aliquet dis platea integer. Potenti aliquet erat neque vitae et sociis pretium, viverra euismod vivamus scelerisque metus est feugiat curae, parturient auctor aliquam pharetra nam congue.',24000,5,'https://www.trustedreviews.com/wp-content/uploads/sites/54/2022/09/LG-OLED-Flex-7-scaled.jpg',true),
(1,'Monitor Flex 36','Elementum sagittis dictumst leo curabitur porta, pellentesque interdum mauris class augue, penatibus vulputate dignissim lobortis, risus euismod ullamcorper ultrices. Hac suspendisse id odio tempus eleifend a malesuada, conubia gravida turpis auctor eget quam eu, fusce taciti lobortis sem netus cum. Etiam lacinia non nibh taciti vulputate ut nullam, curae mollis penatibus facilisi maecenas urna aptent, metus fusce felis magna ullamcorper aenean.',27600,2,'https://www.lg.com/us/images/tvs/md08003300/gallery/D-01.jpg',true),
(2,'Teclado español everex','Aenean senectus diam vitae curae habitant risus a et netus ante, sociis metus quisque euismod aptent etiam platea fringilla class vestibulum, dis habitasse facilisis fusce varius nam arcu blandit congue. Rutrum placerat congue etiam senectus tincidunt fringilla consequat dignissim sollicitudin, vulputate curae accumsan tempor nunc vel eros mus. Mauris donec urna ante proin duis nullam purus maecenas gravida curae iaculis, tempor quam massa cursus mollis per sodales eros diam leo.',45000,5,'https://http2.mlstatic.com/D_NQ_NP_984317-MLA43206062255_082020-O.webp',true),
(2,'Teclado fisico gamer','Auctor id morbi tempor litora fusce potenti, ornare integer imperdiet turpis accumsan enim, sagittis suscipit purus lacus nunc. Posuere tellus elementum imperdiet sollicitudin consequat torquent urna risus, pulvinar ac per quis egestas tristique ultricies, bibendum dignissim congue eu litora malesuada montes. Nisl arcu mi purus auctor nulla sodales torquent facilisis imperdiet, dignissim bibendum justo dictum in congue integer scelerisque sagittis, accumsan laoreet nam augue felis massa varius nostra.',57000,2,'https://cyberteamcr.com/wp-content/uploads/2024/02/16064_11399.webp',true),
(2,'Teclado usb compacto','Cum placerat etiam lobortis curabitur fames class facilisi hac duis, congue vulputate mus feugiat nostra imperdiet neque vehicula. Mi mollis ridiculus montes aenean sagittis vitae metus, netus massa ligula sociis magnis porttitor, torquent nisl eleifend lobortis dignissim at. Eget nostra tellus sagittis condimentum nec felis curabitur dis ad purus, montes dapibus ullamcorper cras vivamus facilisis nascetur lectus porttitor, dictum vulputate luctus pretium ligula eu posuere rhoncus molestie. Nibh platea odio at mollis est, turpis enim felis pharetra tellus placerat, facilisis praesent massa nulla. Accumsan curabitur cras mus turpis malesuada arcu aptent, volutpat praesent habitant senectus quis mollis sed, viverra nec proin nostra cubilia hendrerit.',25000,5,'https://live.staticflickr.com/7010/26783973491_3e2043edda_b.jpg',true),
(2,'Teclado Monitor Flex','Purus dictumst scelerisque mollis platea malesuada per vehicula lectus blandit sed, vulputate morbi imperdiet duis dapibus congue class accumsan nullam, ligula eleifend tincidunt urna mi condimentum dis posuere tellus. Sem rutrum erat mauris justo nunc odio condimentum in dictumst, cum porttitor lectus dignissim velit nulla gravida lobortis tempus vehicula, pharetra urna ullamcorper metus semper volutpat proin senectus. Aliquam donec cras ante hendrerit enim vitae nostra consequat scelerisque a habitant dictum congue ornare potenti, sodales velit litora suspendisse nullam neque pellentesque dui etiam platea imperdiet pretium luctus.',27600,2,'https://hardzone.es/app/uploads-hardzone.es/2020/10/Mejores-KVM.jpg',true),
(3,'CPU Intel 7i','Morbi egestas sociis magnis curabitur suscipit nostra blandit magna torquent convallis, enim parturient feugiat fringilla litora aliquam turpis nisl at velit, fames aenean dui viverra arcu habitasse nascetur platea ac. Lectus nibh imperdiet nascetur proin potenti nisl mattis fringilla urna consequat diam, pellentesque vulputate magnis ridiculus dignissim nec venenatis primis ut bibendum, penatibus himenaeos mus sapien magna etiam velit justo vivamus metus. Tellus volutpat hendrerit vehicula lacinia aliquam euismod lectus erat posuere, arcu nec morbi dui placerat quisque semper tempor vulputate est, turpis ac dis nostra congue odio per mattis.',15780,5,'https://live.staticflickr.com/7391/9662276651_f4aa27d5ca_b.jpg',true),
(3,'CPU Intel Core 5i','Rhoncus ante magna cursus consequat proin senectus ridiculus, varius maecenas tellus justo facilisi ligula eros dapibus, taciti sollicitudin vulputate vivamus lacus fusce. Lacus aptent facilisi urna volutpat vestibulum nunc sociis viverra habitasse egestas, vivamus blandit ultricies neque netus pulvinar elementum ac per iaculis, donec euismod porttitor velit diam ullamcorper congue phasellus nam. Feugiat senectus parturient tristique enim ac integer torquent rutrum imperdiet, nec dapibus nam vestibulum sodales phasellus dis egestas urna, donec interdum id dictumst mollis nostra felis euismod. Ornare proin diam lobortis enim maecenas tempus scelerisque nascetur, id quam magna fames vitae posuere luctus tempor, interdum mattis et ac sapien imperdiet ante.',15000,2,'https://live.staticflickr.com/1473/24714440462_31a0fcdfba_b.jpg',true),
(3,'AMD 7500','Primis quis sollicitudin ac himenaeos dui metus ridiculus, viverra vitae erat litora mauris eget, ut nisl platea feugiat inceptos cum. Diam vitae sem nulla commodo hendrerit duis dictum, tristique senectus maecenas eu augue dignissim lectus, eros cursus felis ornare nisl primis. Tempor facilisi ad scelerisque himenaeos nec ultrices interdum praesent, tincidunt mauris morbi nostra et parturient vivamus odio viverra, eget eu fermentum conubia vestibulum sagittis feugiat. Nulla mus dis rutrum feugiat imperdiet sociosqu non augue tempor sem, arcu natoque ridiculus odio dapibus quis ligula sagittis dui.',25400,5,'https://upload.wikimedia.org/wikipedia/commons/0/0c/AMD_Ryzen_9_3900X_-_ISO.jpg',true),
(3,'AMD 670','Risus tristique donec faucibus cursus dictumst vestibulum maecenas, ac scelerisque luctus purus senectus quisque pellentesque, dictum commodo accumsan himenaeos placerat suscipit. Pharetra erat cubilia sapien feugiat aenean molestie vulputate ac, lectus phasellus rutrum pretium interdum a natoque varius parturient, pulvinar condimentum praesent mollis ante nulla inceptos. Curabitur vestibulum malesuada justo non nostra nam donec dictum platea, commodo dictumst natoque bibendum leo nibh cras habitant primis, quisque augue eget ultrices pulvinar sodales odio rhoncus. Diam condimentum id pellentesque imperdiet porttitor vestibulum himenaeos iaculis, natoque ornare scelerisque nam nostra taciti tortor malesuada, sapien lacus cubilia suspendisse eros rutrum conubia.',45000,3,'https://upload.wikimedia.org/wikipedia/commons/a/a0/AMD_Duron_850_MHz_D850AUT1B.jpg',true),
(4,'Samsung S22','Nam ad hac curae mollis dui scelerisque convallis eros, dignissim faucibus velit nostra dapibus cursus vehicula habitasse facilisi, mi conubia pellentesque quisque cras justo inceptos. Integer varius consequat volutpat at dui scelerisque dapibus magnis platea quis, purus mi nibh tempor inceptos litora hac himenaeos ultrices. Convallis orci dictumst tincidunt phasellus facilisis ullamcorper montes vestibulum, leo cubilia tempus fringilla sodales per lacus viverra pretium, potenti id sociis fames curae nam etiam.',285000,0,'https://www.trustedreviews.com/wp-content/uploads/sites/54/2022/08/S22-app-drawer-scaled.jpg',true),
(4,'Motorola X23','Luctus lacus montes vulputate libero purus est litora, risus magnis quisque ac urna magna sollicitudin, suspendisse mauris massa euismod quam placerat. Facilisis congue id posuere tortor et porttitor curabitur pulvinar sapien, cubilia tempus pharetra facilisi fringilla dapibus lectus non hendrerit, pellentesque dictumst vulputate natoque molestie aptent nascetur ante. Laoreet etiam taciti integer at metus facilisis, pellentesque tortor leo enim felis turpis bibendum, neque curabitur himenaeos hac torquent.',154000,0,'https://www.trustedreviews.com/wp-content/uploads/sites/54/2021/10/motorola-2.jpg',true),
(4,'Nokia 5430','Nullam porttitor vivamus phasellus tempus in morbi aliquet platea duis, nulla tristique inceptos pellentesque pulvinar congue sagittis euismod vitae lacinia, scelerisque mus orci sociosqu libero proin sed felis. Pretium tincidunt ultrices eu vel nam massa morbi diam sem, neque aliquet vehicula penatibus odio phasellus curabitur. Conubia natoque quis tellus scelerisque sociis facilisi nisi suspendisse, id interdum ornare vivamus proin himenaeos class sed in, suscipit torquent est aliquam orci nunc etiam. Congue et nisl magna cum id sociis enim suscipit integer, nisi egestas est porttitor sollicitudin commodo natoque pharetra torquent, aliquam euismod nam porta rhoncus non ante habitasse.',330000,0,'https://www.trustedreviews.com/wp-content/uploads/sites/54/2021/08/nokia-xr20-1.jpg',true),
(4,'Xiami x45','Litora metus senectus mattis egestas mus fames tempus suscipit, inceptos luctus hendrerit congue quis sem. Potenti quis conubia fermentum non dictum nibh, viverra neque sed pretium eros aptent, metus hac at imperdiet est. Accumsan donec sociosqu etiam venenatis felis aenean suspendisse facilisi dignissim conubia non, molestie est ultrices neque id diam pellentesque quis quisque in odio, per nulla aptent arcu vehicula lobortis aliquet tempor cum platea.',273000,0,'https://www.trustedreviews.com/wp-content/uploads/sites/54/2022/03/20220315_104812-1-scaled.jpg',true);

-- Inserción de facturas
INSERT INTO factura (id_usuario,fecha,total,estado) VALUES
(1,'2025-06-05',211560,'Pagada'),
(2,'2025-06-07',554340,'Pagada'),
(3,'2025-07-07',871000,'Pagada'),
(1,'2025-07-15',244140,'Pagada'),
(2,'2025-07-17',414800,'Pagada'),
(3,'2025-07-21',420000,'Pagada');

-- Inserción de ventas
INSERT INTO venta (id_factura,id_producto,precio_historico,cantidad) values
(1,5,45000,3),
(1,9,15780,2),
(1,10,15000,3),
(2,5,45000,1),
(2,14,154000,3),
(2,9,15780,3),
(3,14,154000,1),
(3,6,57000,1),
(3,15,330000,2),
(4,6,57000,2),
(4,8,27600,3),
(4,9,15780,3),
(5,8,27600,3),
(5,14,154000,2),
(5,3,24000,1),
(6,15,330000,1),
(6,12,45000,1),
(6,10,15000,3);

-- Inserción de roles
insert into rol (rol) values ('ADMIN'), ('VENDEDOR'), ('USER');

-- ASignación de roles a usuarios
insert into usuario_rol (id_usuario, id_rol) values
 (1,1), (1,2), (1,3),(2,2),(2,3),(3,3);

-- Inserción de rutas con roles específicos
INSERT INTO ruta (ruta, id_rol) VALUES 
('/producto/nuevo', 1),
('/producto/guardar', 1),
('/producto/modificar/**', 1),
('/producto/eliminar/**', 1),
('/categoria/nuevo', 1),
('/categoria/guardar', 1),
('/categoria/modificar/**', 1),
('/categoria/eliminar/**', 1),
('/usuario/**', 1),
('/constante/**', 1),
('/role/**', 1),
('/usuario_role/**', 1),
('/ruta/**', 1),
('/producto/listado', 2),
('/categoria/listado', 2),
('/pruebas/**', 2),
('/reportes/**', 2),
('/facturar/carrito', 3),
('/payment/**', 3);

-- Inserción de rutas que no requieren rol
INSERT INTO ruta (ruta,requiere_rol) VALUES 
('/',false),
('/index',false),
('/errores/**',false),
('/carrito/**',false),
('/registro/**',false),
('/403',false),
('/fav/**',false),
('/js/**',false),
('/webjars/**',false);

-- Inserción de constantes de la aplicación
INSERT INTO constante (atributo,valor) VALUES 
('dominio','localhost'),
('dolar','520.75'),
('url_paypal_cancel','http://localhost/payment/cancel'),
('url_paypal_success','http://localhost/payment/success');


/* estos valores por seguridad deben quedar como variables de entorno 
('paypal.client-id','AaDNEUcELb-wQi6_MOboN0a1Ug4BnD4Z2T2-_KIoDjIb8Rif6525nvRhDu-MS-YdKQ8PJqZi7R6T6e_k'),
('paypal.client-secret','EKBpJ1oXlwfcp60KyF9ednFM4i9G_RkzgPCpDXo_NbQbaO_bICxhs_a_mnepi7524BQeK_qdNPRmLt71'),
('paypal.mode','sandbox'),
('currency','USD'),
('method','sale'),
('descripcion','Facturación en TechShop'); */