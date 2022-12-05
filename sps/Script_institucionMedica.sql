USE ospes;

-- 2. Creación de tablas
-- 
-- TABLE: InstitucionesMedicas 
--

CREATE TABLE InstitucionesMedicas(
    idInstitucionMedica    INT             NOT NULL,
    institucionMedica      VARCHAR(120)    NOT NULL,
    direccion              VARCHAR(140)    NOT NULL,
    cuil                   VARCHAR(11)     NOT NULL,
    telefono               VARCHAR(20)     NOT NULL,
    estado                 CHAR(1)         NOT NULL,
    PRIMARY KEY (idInstitucionMedica)
)ENGINE=INNODB
COMMENT='Tabla que almacena las instituciones medicas';
-- 
-- INDEX: UI_institucionMedica 
--

CREATE UNIQUE INDEX UI_institucionMedica ON InstitucionesMedicas(institucionMedica);
-- 
-- INDEX: UI_cuil 
--

CREATE UNIQUE INDEX UI_cuil ON InstitucionesMedicas(cuil);

-- 3. Stored Procedures
DROP procedure IF EXISTS `osp_buscar_institucionmedica`;
DELIMITER $$

CREATE PROCEDURE `osp_buscar_institucionmedica` (pCadena varchar(25))
BEGIN
	/*
    Procedimiento que sirve para buscar una institución medica mediante una cadena que debe coincidir con parte del nombre.
    */
    SELECT		*
    FROM		InstitucionesMedicas
    WHERE		institucionMedica LIKE CONCAT('%', pCadena, '%') 
	ORDER BY	institucionMedica;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_alta_institucionmedica`;
DELIMITER $$

CREATE PROCEDURE `osp_alta_institucionmedica`(pinstitucionMedica varchar(120),pdireccion varchar(140), pcuil varchar(11), ptelefono varchar(20))
SALIR:BEGIN
	/*
    Permite dar de alta una institución médica controlando que el nombre no sea vacío y no exista ya una institución médica con ese nombre.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pidInstitucionMedica int;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que institucion medica no sea vacío ni nulo
    IF pinstitucionMedica = '' OR pdireccion='' OR pcuil= '' OR ptelefono=''
    OR pinstitucionMedica IS NULL OR pdireccion IS NULL OR pcuil IS NULL OR ptelefono IS NULL THEN
		SELECT 'El nombre, direccion, cuil y telefono de la institución médica es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
	-- Controlo que la institucion medica no exista ya
    IF EXISTS(SELECT institucionMedica FROM InstitucionesMedicas WHERE institucionMedica = pinstitucionMedica) THEN
		SELECT 'Ya existe una institución médica  con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
		-- Calcula el próximo ID
		SET pidInstitucionMedica = 1 + COALESCE((SELECT MAX(idInstitucionMedica) FROM InstitucionesMedicas),0);
		-- Inserta
        INSERT INTO InstitucionesMedicas VALUES(pinstitucionMedica, pdireccion, pcuil, ptelefono);
		
        SELECT CONCAT('OK',pidInstitucionMedica) AS Mensaje;
	COMMIT;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_modifica_institucionmedica`;
DELIMITER $$

CREATE PROCEDURE `osp_modifica_institucionmedica`(pidInstitucionMedica int, pinstitucionMedica varchar(120),pdireccion varchar(140), pcuil varchar(11), ptelefono varchar(20))
SALIR:BEGIN
	/*
    Permite modificar una institucion medica existente controlando que el nombre no sea vacío y no exista ya una institucion medica con ese nombre.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
    -- Controla que la institución médica no sea vacío ni nulo
    IF pinstitucionMedica = '' OR pdireccion='' OR pcuil= '' OR ptelefono=''
    OR pinstitucionMedica IS NULL OR pdireccion IS NULL OR pcuil IS NULL OR ptelefono IS NULL THEN
		SELECT 'El nombre, direccion, cuil y telefono de la institución médica es obligatorio.' AS Mensaje;
	LEAVE SALIR;
	END IF;
	-- Controlo que la institucion medica exista
    IF NOT EXISTS(SELECT idInstitucionMedica FROM InstitucionesMedicas WHERE idInstitucionesMedicas = pidInstitucionesMedicas) THEN
		SELECT 'No existe esa institución Médica.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que la institución médica y su cuil no exista ya
    IF EXISTS(SELECT institucionMedica, cuil FROM InstitucionesMedicas WHERE institucionMedica = pinstitucionesMedicas AND idInstitucionMedica != pidInstitucionMedica AND pcuil = cuil) THEN
		SELECT 'Ya existe una institución médica o un cuil con ese nombre y numero.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE InstitucionesMedicas SET institucionMedica = pinstitucionMedica,direccion =pdireccion , cuil=pcuil , telefono=ptelefono
    WHERE idInstitucionesMedicas = pidInstitucionesMedicas;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_borra_institucionmedica`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_institucionmedica`(pidInstitucionMedica int)
SALIR:BEGIN
	/*
    Permite borrar una institución médica existente controlando que no exista liquidacion pendiente
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que la institución médica exista
    IF NOT EXISTS(SELECT idInstitucionMedica FROM InstitucionesMedicas WHERE idInstitucionMedica = pidInstitucionMedica) THEN
		SELECT 'No existe esa institucion medica.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que la institucion medica no tenga asociado una liquidacion 
    IF EXISTS(SELECT idInstitucionMedica FROM Liquidaciones WHERE idInstitucionMedica = pidInstitucionMedica) THEN
		SELECT 'No puede borrar la liquidacion porque tiene una liquidacion.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra
	DELETE FROM InstitucionesMedicas WHERE idInstitucionMedica = pidInstitucionMedica;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_dame_institucionesmedicas`;
DELIMITER $$

CREATE PROCEDURE `osp_dame_institucionesmedicas` (pidInstitucionMedica int)
BEGIN
	/*
    Procedimiento que sirve para instanciar una institucion medica en memoria, desde la base de datos.
    */
    SELECT * FROM InstitucionesMedicas WHERE idInstitucionMedica = pidInstitucionMedica;
    END$$

DELIMITER ;
