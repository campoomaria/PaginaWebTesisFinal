-- Scritp de creación de base de datos y de sus objetos
-- 1. reación de BD
CREATE SCHEMA ospes;
USE ospes;

-- 2. Creación de tablas

-- TABLE: RubrosDeProductos 
CREATE TABLE RubrosDeProductos(
    idRubro    TINYINT        NOT NULL,
    rubro      VARCHAR(25)    NOT NULL,
    estado     CHAR(1)        NOT NULL,
    PRIMARY KEY (idRubro)
)ENGINE=INNODB
COMMENT='Tabla que almacena los rubros de productos de farmacia';

CREATE UNIQUE INDEX UI_rubro ON RubrosDeProductos(rubro);


-- 3. Stored Procedures
DROP procedure IF EXISTS `osp_buscar_rubrosdeproductos`;
DELIMITER $$

CREATE PROCEDURE `osp_buscar_rubrosdeproductos` (pCadena varchar(25), pIncluyeBajas char(1))
BEGIN
	/*
    Procedimiento que sirve para buscar los rubros de productos mediante una cadena que debe coincidir con parte del nombre, y la opción
    si incluye o no los rubros dadfos de baja (S: Si, N:No).
    */
    SELECT		*
    FROM		RubrosDeProductos
    WHERE		rubro LIKE CONCAT('%', pCadena, '%') AND
				(pIncluyeBajas = 'S' OR  Estado = 'A')
	ORDER BY	rubro;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_alta_rubrodeproducto`;
DELIMITER $$

CREATE PROCEDURE `osp_alta_rubrodeproducto`(pRubro varchar(25))
SALIR:BEGIN
	/*
    Permite dar de alta un rubro controlando que el nombre no sea vacío y no exista ya un rubro con ese nombre.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pidRubro tinyint;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que el rubro no sea vacío ni nulo
    IF pRubro = '' OR pRubro IS NULL THEN
		SELECT 'El nombre del rubro es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
	-- Controlo que el rubro no exista ya
    IF EXISTS(SELECT rubro FROM RubrosDeProductos WHERE rubro = pRubro) THEN
		SELECT 'Ya existe un rubro con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		-- Calcula el próximo ID
		SET pidRubro = 1 + COALESCE((SELECT MAX(idRubro) FROM RubrosDeProductos),0);
		-- Inserta
        INSERT INTO RubrosDeProductos VALUES(pidRubro, pRubro, 'A');
		
        SELECT CONCAT('OK',pidRubro) AS Mensaje;
	COMMIT;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_modifica_rubrodeproducto`;
DELIMITER $$

CREATE PROCEDURE `osp_modifica_rubrodeproducto`(pidRubro tinyint, pRubro varchar(25))
SALIR:BEGIN
	/*
    Permite modificar un rubro existente controlando que el nombre no sea vacío y no exista ya un rubro con ese nombre.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que el rubro no sea vacío ni nulo
    IF pRubro = '' OR pRubro IS NULL THEN
		SELECT 'El nombre del rubro es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
	-- Controlo que el rubro exista
    IF NOT EXISTS(SELECT idRubro FROM RubrosDeProductos WHERE idRubro = pidRubro) THEN
		SELECT 'No existe ese rubro.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el rubro no exista ya
    IF EXISTS(SELECT rubro FROM RubrosDeProductos WHERE rubro = pRubro AND idRubro != pidRubro) THEN
		SELECT 'Ya existe un rubro con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE RubrosDeProductos SET rubro = pRubro WHERE idRubro = pidRubro;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_borra_rubrodeproducto`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_rubrodeproducto`(pidRubro tinyint)
SALIR:BEGIN
	/*
    Permite borrar un rubro existente controlando que no existan productos en ese rubro
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el rubro exista
    IF NOT EXISTS(SELECT idRubro FROM RubrosDeProductos WHERE idRubro = pidRubro) THEN
		SELECT 'No existe ese rubro.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el rubro no exista ya
    IF EXISTS(SELECT idRubro FROM Productos WHERE idRubro = pidRubro) THEN
		SELECT 'No puede borrar el rubro porque tiene productos asociados.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra
	DELETE FROM RubrosDeProductos WHERE idRubro = pidRubro;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_dame_rubrodeproducto`;
DELIMITER $$

CREATE PROCEDURE `osp_dame_rubrodeproducto` (pidRubro tinyint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un rubro de productos en memoria, desde la base de datos.
    */
    SELECT * FROM RubrosDeProductos WHERE idRubro = pidRubro;
    END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_darbaja_rubrodeproducto`;
DELIMITER $$

CREATE PROCEDURE `osp_darbaja_rubrodeproducto`(pidRubro tinyint)
SALIR:BEGIN
	/*
    Permite dar de baja un rubro siempre y cuando exista y esté activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el rubro exista
    IF NOT EXISTS(SELECT idRubro FROM RubrosDeProductos WHERE idRubro = pidRubro) THEN
		SELECT 'No existe ese rubro.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el rubro esté activo
    IF NOT EXISTS(SELECT idRubro FROM RubrosDeProductos WHERE idRubro = pidRubro AND Estado = 'A') THEN
		SELECT 'El rubro ya está dado de baja.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE RubrosDeProductos SET Estado = 'B' WHERE idRubro = pidRubro;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_activar_rubrodeproducto`;
DELIMITER $$

CREATE PROCEDURE `osp_activar_rubrodeproducto`(pidRubro tinyint)
SALIR:BEGIN
	/*
    Permite activar un rubro siempre y cuando exista y esté activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el rubro exista
    IF NOT EXISTS(SELECT idRubro FROM RubrosDeProductos WHERE idRubro = pidRubro) THEN
		SELECT 'No existe ese rubro.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que rubro esté dado de baja
    IF NOT EXISTS(SELECT idRubro FROM RubrosDeProductos WHERE idRubro = pidRubro AND Estado = 'B') THEN
		SELECT 'El rubro ya está activo.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE RubrosDeProductos SET Estado = 'A' WHERE idRubro = pidRubro;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;