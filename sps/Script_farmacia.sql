
USE ospes;

-- 2. Creación de tablas
-- 
-- TABLE: Farmacias 
--

CREATE TABLE Farmacias(
    idFarmacia           INT             NOT NULL,
    farmacia             VARCHAR(60)     NOT NULL,
    cuil                 VARCHAR(11)     NOT NULL,
    domicilio            VARCHAR(250)    NOT NULL,
    provincia            VARCHAR(20)     NOT NULL,
    localidad            VARCHAR(30)     NOT NULL,
    telefono             INT             NOT NULL,
    correoElectronico    VARCHAR(150)    NOT NULL,	
    estado               CHAR(1) NOT NULL,
    PRIMARY KEY (idFarmacia)
)ENGINE=INNODB;

-- 
-- INDEX: UI_farmacia 
--

CREATE UNIQUE INDEX UI_farmacia ON Farmacias(farmacia);
-- 
-- INDEX: UI_cuil 
--

CREATE UNIQUE INDEX UI_cuil ON Farmacias(cuil);
-- 
-- INDEX: UI_correoElectronico 
--

CREATE UNIQUE INDEX UI_correoElectronico ON Farmacias(correoElectronico);

-- 3. Stored Procedures
DROP procedure IF EXISTS `osp_buscar_farmacias`;
DELIMITER $$

CREATE PROCEDURE `osp_buscar_farmacias` (pCadena varchar(60), pIncluyeBajas char(1))
BEGIN
	/*
    Procedimiento que sirve para buscar las farmacias mediante una cadena que debe coincidir con parte del nombre, y la opción
    si incluye o no los rubros dados de baja (S: Si, N:No).
    */
    SELECT		*
    FROM		Farmacias
    WHERE		farmacia LIKE CONCAT('%', pCadena, '%') AND
				(pIncluyeBajas = 'S' OR  Estado = 'A')
	ORDER BY	farmacia;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_alta_farmacia`;
DELIMITER $$

CREATE PROCEDURE `osp_alta_farmacia`(pfarmacia varchar(60),pcuil varchar(11), pdomicilio varchar(250), pprovincia varchar(20), plocalidad varchar(30), ptelefono int, pcorreoElectronico varchar(150))
SALIR:BEGIN
	/*
    Permite dar de alta una farmacia controlando que el nombre no sea vacío y no exista ya una farmacia con ese nombre.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pidFarmacia int;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que los datos de farmacia no sea vacío ni null
    IF pfarmacia = ''  OR pfarmacia IS NULL THEN
		SELECT 'El nombre de la farmacia es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        IF pcuil = ''  OR pcuil IS NULL THEN
		SELECT 'El  cuil de la farmacia es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        IF pdomicilio = ''  OR pdomicilio IS NULL THEN
		SELECT 'El domicilio de la farmacia es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        IF pprovincia = ''  OR pprovincia IS NULL THEN
		SELECT 'La provincia de la farmacia es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        IF plocalidad = ''  OR plocalidad IS NULL THEN
		SELECT 'La localidad de la farmacia es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        IF ptelefono = ''  OR pfarmacia IS NULL THEN
		SELECT 'El telefono de la farmacia es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF pcorreoElectronico = ''  OR pcorreoElectronico IS NULL THEN
		SELECT 'El correo electronico de la farmacia es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    
	-- Controlo que la farmacia no exista ya
    IF EXISTS(SELECT farmacia FROM Farmacias WHERE farmacia = pfarmacia AND cuil = pcuil AND correoElectronico=pcorreoElectronico) THEN
		SELECT 'Ya existe una farmacia con ese nombre, cuil o correoelectronico.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		-- Calcula el próximo ID
		SET pidFarmacia = 1 + COALESCE((SELECT MAX(idFarmacia) FROM Farmacias),0);
		-- Inserta
        INSERT INTO Farmacias VALUES(pidFarmacia, pfarmacia, pcuil, pdomicilio, pprovincia, plocalidad, ptelefono, pcorreoElectronico, 'P');
		
        SELECT CONCAT('OK',pidFarmacia) AS Mensaje;
	COMMIT;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_modifica_farmacia`;
DELIMITER $$

CREATE PROCEDURE `osp_modifica_farmacia`(pidFarmacia int, pfarmacia varchar(60),pcuil varchar(11), pdomicilio varchar(250), pprovincia varchar(20), plocalidad varchar(30), ptelefono int, pcorreoElectronico varchar(150))
SALIR:BEGIN
	/*
    Permite modificar una farmacia existente controlando que el nombre no sea vacío y no exista ya una farmacia con ese nombre.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que la farmacia no sea vacío ni nulo
    IF pfarmacia = '' OR pfarmacia IS NULL THEN
		SELECT 'El nombre de la farmacia es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
	-- Controlo que la  farmacia exista
    IF NOT EXISTS(SELECT idFarmacia FROM Farmacias WHERE idFarmacia = pidFarmacia) THEN
		SELECT 'No existe esa farmacia.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que la farmacia no exista ya
    IF EXISTS(SELECT farmacia FROM Farmacias WHERE farmacia = pfarmacia AND idFarmacia != pidFarmacia) THEN
		SELECT 'Ya existe una farmacia con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE Farmacias SET farmacia = pfarmacia, cuil = pcuil, domicilio = pdomicilio , provincia = pprovincia,  localidad = plocalidad, telefono = ptelefono, 
    correoElectronico = pcorreoElectronico, estado = 'A' 
    WHERE idFarmacia = pidFarmacia;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_borra_farmacia`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_farmacia`(pidFarmacia int)
SALIR:BEGIN
	/*
    Permite borrar una farmacia existente controlando que no existan salidas con esa farmacia 
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
	-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que la farmacia exista
    IF NOT EXISTS(SELECT idFarmacia FROM Farmacias WHERE idFarmacia = pidFarmacia) THEN
		SELECT 'No existe esa farmacia.' AS Mensaje;
        LEAVE SALIR;
	END IF;

    -- Controlo que la farmacia no exista ya
    IF EXISTS(SELECT idFarmacia FROM Salidas WHERE idFarmacia = pidFarmacia) THEN
		SELECT 'No puede borrar la farmacia porque tiene una salida asociados.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra
	DELETE FROM Farmacias WHERE idFarmacia = pidFarmacia;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_dame_farmacia`;
DELIMITER $$

CREATE PROCEDURE `osp_dame_farmacia` (pidFarmacia int)
BEGIN
	/*
    Procedimiento que sirve para instanciar una farmacia en memoria, desde la base de datos.
    */
    SELECT * FROM Farmacias WHERE idFarmacia = pidFarmacia;
    END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_darbaja_farmacia`;
DELIMITER $$

CREATE PROCEDURE `osp_darbaja_farmacia`(pidFarmacia int)
SALIR:BEGIN
	/*
    Permite dar de baja una farmacia siempre y cuando exista y esté activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que la farmacia exista
    IF NOT EXISTS(SELECT idFarmacia FROM Farmacias WHERE idFarmacia = pidFarmacia) THEN
		SELECT 'No existe esa farmacia.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que la farmacia esté activa
    IF NOT EXISTS(SELECT idFarmacia FROM Farmacias WHERE idFarmacia = pidFarmacia AND estado = 'A') THEN
		SELECT 'La farmacia ya está dado de baja.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE Farmacias SET estado = 'B' WHERE idFarmacia = pidFarmacia;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_activar_farmacia`;
DELIMITER $$

CREATE PROCEDURE `osp_activar_farmacia`(pidFarmacia int)
SALIR:BEGIN
	/*
    Permite activar una farmacia siempre y cuando exista y esté dado de baja .
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el rubro exista
    IF NOT EXISTS(SELECT idFarmacia FROM Farmacias WHERE idFarmacia = pidFarmacia) THEN
		SELECT 'No existe ese farmacia.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que farmacia esté dado de baja o pendiente 
    IF NOT EXISTS(SELECT idFarmacia FROM Farmacias WHERE idFarmacia = pidFarmacia AND estado = 'B' OR estado = 'P') THEN
		SELECT 'La farmacia ya está activa.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE Farmacias SET estado = 'A' WHERE idFarmacia = pidFarmacia;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
