-- Scritp de creación de base de datos y de sus objetos
-- 1. creación de BD
USE ospes;

-- 2. Creación de tablas
-- 
-- TABLE: TiposPrestaciones 
--

CREATE TABLE TiposPrestaciones(
    idTipoPrestacion      TINYINT           NOT NULL,
    tipoPrestacion        VARCHAR(120)      NOT NULL,
    precioConDescuento    DECIMAL(10, 2)    NOT NULL,
    estado                CHAR(1)           NOT NULL,
    observaciones         VARCHAR(255),
    PRIMARY KEY (IdTipoPrestacion)
)ENGINE=INNODB;

CREATE UNIQUE INDEX UI_tipoPrestacion ON TiposPrestaciones(tipoPrestacion);

-- 3. Stored Procedures
DROP procedure IF EXISTS `osp_buscar_tiposdepretaciones`;
DELIMITER $$

CREATE PROCEDURE `osp_buscar_tiposdepretaciones` (pCadena varchar(120), pIncluyeBajas char(1))
BEGIN
	/*
    Procedimiento que sirve para buscar los tipos de prestaciones  mediante una cadena que debe coincidir con parte del nombre, y la opción
    si incluye o no los rubros dadfos de baja (S: Si, N:No).
    */
    SELECT		*
    FROM		TiposPrestaciones
    WHERE		tipoPrestacion LIKE CONCAT('%', pCadena, '%') AND
				(pIncluyeBajas = 'S' OR  estado = 'A')
	ORDER BY	rubro;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_alta_tiposdepretaciones`;
DELIMITER $$

CREATE PROCEDURE `osp_alta_tiposdeprestaciones`(ptipoPrestacion varchar(120),pprecioConDescuento Decimal(10,2))
SALIR:BEGIN
	/*
    Permite dar de alta una tipo de prestacion controlando que el nombre no sea vacío y no exista ya un tipo deprestacion con ese nombre.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pidTipoPrestacion tinyint;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que la tipo de prestacion no sea vacío ni nulo
    IF ptipoPrestacion = '' OR ptipoPrestacion IS NULL OR pprecioConDescuento= '' OR pprecioConDescuento IS NULL THEN
		SELECT 'El nombre  y el precio con descuento del tipo de prestación es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
	-- Controlo que el tipo de prestación no exista ya
    IF EXISTS(SELECT tipoPrestacion FROM TiposPrestaciones WHERE tipoPrestacion = ptipoPrestacion) THEN
		SELECT 'Ya existe un tipo de prestación con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		-- Calcula el próximo ID
		SET pidTipoPrestacion = 1 + COALESCE((SELECT MAX(idTipoPrestacion) FROM TiposPrestaciones),0);
		-- Inserta
        INSERT INTO TiposPrestaciones VALUES(pidTipoPrestacion, ptipoPrestacion, 'A');
		
        SELECT CONCAT('OK',pidTipoPrestacion) AS Mensaje;
	COMMIT;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_modifica_tipodeprestacion`;
DELIMITER $$

CREATE PROCEDURE `osp_modifica_tipodeprestacion`(pidTipoPrestacion tinyint, ptipoPrestacion varchar(120), pprecioConDescuento Decimal(10,2))
SALIR:BEGIN
	/*
    Permite modificar un tipo de prestacion existente controlando que el nombre no sea vacío y no exista ya un tipo de prestacion con ese nombre.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que el tipo de prestación no sea vacío ni nulo
    IF ptipoPrestacion = '' OR ptipoPrestacion IS NULL OR pprecioConDescuento= '' OR pprecioConDescuento IS NULL THEN
		SELECT 'El nombre del tipo de Prestación y precio son obligatorios.' AS Mensaje;
        LEAVE SALIR;
	END IF;
	-- Controlo que el tipo de prestacion exista
    IF NOT EXISTS(SELECT idTipoPrestacion FROM TiposPrestaciones WHERE idTipoPrestacion = pidTipoPrestacion) THEN
		SELECT 'No existe ese tipo de prestación.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el tipo de prestación no exista ya
    IF EXISTS(SELECT tipoPrestacion FROM TiposPrestaciones WHERE tipoPrestacion = ptipoPrestacion AND idTipoPrestacion != pidTipoPrestacion) THEN
		SELECT 'Ya existe una tipo de prestación con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE TiposPrestaciones SET tipoPrestacion = ptipoPrestacion WHERE idTipoPrestacion = pidTipoPrestacion;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_borra_tipoprestacion`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_tipoprestacion`(pidTipoPrestacion tinyint)
SALIR:BEGIN
	/*
    Permite borrar una tipo de prestacion existente controlando que no existan prestaiones con este tipo de prestacion 
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el tipo de prestacion exista
    IF NOT EXISTS(SELECT idTipoPrestacion FROM TiposPrestaciones WHERE idTipoPrestacion = pidTipoPrestacion) THEN
		SELECT 'No existe ese tipo de prestación.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el tipo de prestacion no exista ya
    IF EXISTS(SELECT idTipoPrestacion FROM PrestacionesMedicas WHERE idTipoPrestacion = pidTipoPrestacion) THEN
		SELECT 'No puede borrar el tipo de prestacion porque tiene prestacionmedica asociados.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra
	DELETE FROM Tiposprestaciones WHERE idTipoPrestacion = pidTipoPrestacion;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_dame_tipoprestaciones`;
DELIMITER $$

CREATE PROCEDURE `osp_dame_tipoprestaciones` (pidTipoPrestacion tinyint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un tipo de prestacion en memoria, desde la base de datos.
    */
    SELECT * FROM TiposPrestaciones WHERE idTipoPrestacion = pidTipoPrestacion;
    END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_darbaja_tipoprestacion`;
DELIMITER $$

CREATE PROCEDURE `osp_darbaja_tipoprestacion`(pidTipoPrestacion tinyint)
SALIR:BEGIN
	/*
    Permite dar de baja una tipo de prestacion siempre y cuando exista y esté activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el rubro exista
    IF NOT EXISTS(SELECT idTipoPrestacion FROM TiposPrestaciones WHERE idTipoPrestacion = pidTipoPrestacion) THEN
		SELECT 'No existe esa tipo de prestación.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que la tipo de prestación esté activo
    IF NOT EXISTS(SELECT idTipoPrestacion FROM TiposPrestaciones WHERE idTipoPrestacion = pidTipoPrestacion AND estado = 'A') THEN
		SELECT 'La tipo de prestación ya está dado de baja.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE TiposPrestaciones SET estado = 'B' WHERE idTipoPrestacion = pidTipoPrestacion;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_activar_tipoprestacion`;
DELIMITER $$

CREATE PROCEDURE `osp_activar_tipoprestacion`(pidTipoPrestacion tinyint)
SALIR:BEGIN
	/*
    Permite activar una tipo de prestacion siempre y cuando exista y esté activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que la tipo de prestación exista
    IF NOT EXISTS(SELECT idTipoPrestacion FROM TiposPrestaciones WHERE idTiposPrestacion = pidTiposPrestacion) THEN
		SELECT 'No existe esa tipo de prestación.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que la prestación esté dado de baja
    IF NOT EXISTS(SELECT idTipoPrestacion FROM TiposPrestaciones WHERE idTiposPrestacion = pidTiposPrestacion AND estado = 'B') THEN
		SELECT 'La tipo de prestación ya está activo.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE TiposPrestaciones SET estado = 'A' WHERE idTiposPrestacion = pidTiposPrestacion;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;