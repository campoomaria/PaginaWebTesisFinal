-- Scritp de creación de base de datos y de sus objetos

USE ospes;

-- 2. Creación de tablas
-- 
-- TABLE: Productos 
--

CREATE TABLE Productos(
    idProducto          INT              NOT NULL,
    idRubro             TINYINT          NOT NULL,
    producto            VARCHAR(120)     NOT NULL,
    fechaVencimiento    DATE             NOT NULL,
    descuento           DECIMAL(5, 2)    NOT NULL,
    marca               VARCHAR(20)      NOT NULL,
    descripcion         VARCHAR(300),
    estado              CHAR(1)          NOT NULL,
    PRIMARY KEY (idProducto)
)ENGINE=INNODB;


-- 
-- INDEX: UI_producto 
--

CREATE UNIQUE INDEX UI_producto ON Productos(producto);
-- 
-- INDEX: XI_fechaVencimiento 
--

CREATE INDEX XI_fechaVencimiento ON Productos(fechaVencimiento);

-- 
-- INDEX: Ref2770 
--
CREATE INDEX Ref2770 ON Productos(idRubro);

ALTER TABLE Productos ADD CONSTRAINT RefRubrosDeProductos70 
    FOREIGN KEY (idRubro)
    REFERENCES RubrosDeProductos(idRubro);

-- 3. Stored Procedures
DROP procedure IF EXISTS `osp_buscar_productos`;
DELIMITER $$

CREATE PROCEDURE `osp_buscar_productos` (pCadena VARCHAR(120), pIncluyeBajas char(1))
BEGIN
	/*
    Procedimiento que sirve para buscar los productos mediante una cadena que debe coincidir con parte del nombre
    */
    SELECT		*
    FROM		Productos
    WHERE		producto LIKE CONCAT('%', pCadena, '%') AND
				(pIncluyeBajas = 'S' OR  Estado = 'A')
	ORDER BY	producto;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_alta_producto`;
DELIMITER $$

CREATE PROCEDURE `osp_alta_producto`(pidRubro tinyint, pproducto VARCHAR(120),pfechaVencimiento DATE,pdescuento DECIMAL(5, 2), pmarca VARCHAR(20))
SALIR:BEGIN
	/*
    Permite dar de alta un producto controlando que el nombre no sea vacío, fecha de vencimiento, descuento y marca no sean null
    y no exista ya un producto con ese nombre.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pidproducto int;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que el nombre del producto, fecha vencimiento,descuento y marca no sea vacío ni nulo
   	IF (COALESCE(pproducto, '') = ''  OR COALESCE(pmarca, '') = '') THEN
        SELECT 'Faltan completar campos' Mensaje;
        LEAVE SALIR;
	END IF;  
 
	-- Controlo que el producto no exista ya
    IF EXISTS(SELECT producto FROM Productos WHERE producto = pproducto) THEN
		SELECT 'Ya existe un producto con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		-- Calcula el próximo ID
		SET pidProducto = 1 + COALESCE((SELECT MAX(idProducto) FROM Productos),0);
		-- Inserta
        INSERT INTO Productos VALUES(pidProducto,pidRubro, pproducto, pfechaVencimiento,pdescuento, pmarca,null, 'A');
		
        SELECT CONCAT('OK',pidProducto) AS Mensaje;
	COMMIT;
END$$
productos
DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_modifica_producto`;
DELIMITER $$

CREATE PROCEDURE `osp_modifica_producto`(pidRubro tinyint, pidProducto int, pproducto varchar(120),pfechaVencimiento DATE,pdescuento DECIMAL(5, 2), pmarca VARCHAR(20))
SALIR:BEGIN
	/*
    Permite modificar un producto existente controlando que el nombre no sea vacío y no exista ya un producto con ese nombre.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que el nombre del producto, fecha vencimiento,descuento y marca no sea vacío ni nulo
    IF pproducto = '' OR pproducto OR pmarca = '' OR pmarca IS NULL THEN
		SELECT 'El nombre del producto, fecha de vencimiento, descuento y marca es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Controlo que el producto exista
    IF NOT EXISTS(SELECT idProducto FROM Productos WHERE idProducto = pidProducto) THEN
		SELECT 'No existe ese producto.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el producto no exista ya para que no se repita
    IF EXISTS(SELECT producto FROM Productos WHERE producto = pproducto AND idProducto != pidProducto) THEN
		SELECT 'Ya existe un producto con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE Productos SET idRubro=pidRubro, producto = pproducto, fechaVencimiento=pfechaVencimiento, descuento=pdescuento ,  marca=pmarca,descripcion=null, estado='A'  
    WHERE idProducto = pidProducto;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_borra_producto`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_producto`(pidProducto int)
SALIR:BEGIN
	/*
    Permite borrar un producto existente controlando que no existan una linea de salida en ese producto
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el producto exista
    IF NOT EXISTS(SELECT idProducto FROM Productos WHERE idProducto = pidProducto) THEN
		SELECT 'No existe ese producto.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el producto no tenga asociado 
    IF EXISTS(SELECT idProducto FROM LineasSalidas WHERE idProducto = pidProducto) THEN
		SELECT 'No puede borrar el producto porque tiene una linea de asociados.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra
	DELETE FROM Productos WHERE idProducto = pidProducto;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_dame_producto`;
DELIMITER $$

CREATE PROCEDURE `osp_dame_producto` (pidProducto int)
BEGIN
	/*
    Procedimiento que sirve para instanciar un  productos en memoria, desde la base de datos.
    */
    SELECT * FROM Productos WHERE idProducto = pidProducto;
    END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_darbaja_producto`;
DELIMITER $$

CREATE PROCEDURE `osp_darbaja_producto`(pidProducto tinyint)
SALIR:BEGIN
	/*
    Permite dar de baja un producto siempre y cuando exista y esté activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el producto exista
    IF NOT EXISTS(SELECT idProducto FROM Productos WHERE idProducto = pidProducto) THEN
		SELECT 'No existe ese producto.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el producto esté activo
    IF NOT EXISTS(SELECT idProducto FROM Productos WHERE idProducto = pidProducto AND estado = 'A') THEN
		SELECT 'El producto ya está dado de baja.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE Productos SET estado = 'B' WHERE idProducto = pidProducto;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_activar_producto`;
DELIMITER $$

CREATE PROCEDURE `osp_activar_producto`(pidProducto tinyint)
SALIR:BEGIN
	/*
    Permite activar un producto siempre y cuando exista y no este activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el producto exista
    IF NOT EXISTS(SELECT idProducto FROM Productos WHERE idProducto = pidProducto) THEN
		SELECT 'No existe ese producto.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el producto esté dado de baja
    IF NOT EXISTS(SELECT idProducto FROM Productos WHERE idProducto = pidProducto AND estado = 'B') THEN
		SELECT 'El producto ya está activo.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE Productos SET estado = 'A' WHERE idProducto = pidProducto;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;