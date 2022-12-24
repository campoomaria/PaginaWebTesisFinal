USE ospes;

-- 2. Creación de tablas
-- 
-- TABLE: Usuarios 
--

CREATE TABLE Usuarios(
    idUsuario          INT             NOT NULL,
    nombres            VARCHAR(50)     NOT NULL,
    apellidos          VARCHAR(50)     NOT NULL,
    dni                VARCHAR(11)     NOT NULL,
    sexo               CHAR(1)         NOT NULL,
    fechaNacimiento    DATE,
    usuario            VARCHAR(30),
    password           CHAR(32),
    domicilio          VARCHAR(120)    NOT NULL,
    fechaAlta          DATE            NOT NULL,
    provincia          CHAR(10),
    departamento       CHAR(10),
    localidad          CHAR(10),
    telefono           VARCHAR(20)     NOT NULL,
    email              VARCHAR(120)    NOT NULL,
    estado             CHAR(1)         NOT NULL,
    PRIMARY KEY (idUsuario)
)ENGINE=INNODB
;



-- 
-- INDEX: UI_DNI 
--

CREATE UNIQUE INDEX UI_DNI ON Usuarios(dni)
;
-- 
-- INDEX: UI_Email 
--

CREATE UNIQUE INDEX UI_Email ON Usuarios(email)
;
-- 
-- INDEX: XI_nombresapellidos 
--

CREATE INDEX XI_nombresapellidos ON Usuarios(nombres, apellidos)
;
-- 
-- INDEX: XI_fechaNacimiento 
--

CREATE INDEX XI_fechaNacimiento ON Usuarios(fechaNacimiento)
;
-- 
-- INDEX: XI_fechaAlta 
--

CREATE INDEX XI_fechaAlta ON Usuarios(fechaAlta)
;
-- 
-- INDEX: UI_Usuario 
--

CREATE UNIQUE INDEX UI_Usuario ON Usuarios(usuario)
;

-- 
-- TABLE: Secretarios 
--

CREATE TABLE Secretarios(
    idUsuario    INT    NOT NULL,
    PRIMARY KEY (idUsuario)
)ENGINE=INNODB
;
-- 
-- INDEX: Ref776 
--

CREATE INDEX Ref776 ON Secretarios(idUsuario)
;
-- 
-- TABLE: Secretarios 
--

ALTER TABLE Secretarios ADD CONSTRAINT RefUsuarios76 
    FOREIGN KEY (idUsuario)
    REFERENCES Usuarios(idUsuario)
;
-- 
-- TABLE: Administradores 
--

CREATE TABLE Administradores(
    idUsuario    INT    NOT NULL,
    PRIMARY KEY (idUsuario)
)ENGINE=INNODB
;



-- 
-- INDEX: Ref774 
--

CREATE INDEX Ref774 ON Administradores(idUsuario)
;
-- 
-- TABLE: Administradores 
--

ALTER TABLE Administradores ADD CONSTRAINT RefUsuarios74 
    FOREIGN KEY (idUsuario)
    REFERENCES Usuarios(idUsuario)
;
-- 
-- TABLE: MedicosExternos 
--

CREATE TABLE MedicosExternos(
    idUsuario               INT            NOT NULL,
    matriculaProfesional    VARCHAR(12)    NOT NULL,
    cargo                   VARCHAR(30)    NOT NULL,
    PRIMARY KEY (idUsuario)
)ENGINE=INNODB
;

-- 
-- INDEX: UI_matriculaProfesional 
--

CREATE UNIQUE INDEX UI_matriculaProfesional ON MedicosExternos(matriculaProfesional)
;
-- 
-- INDEX: Ref775 
--

CREATE INDEX Ref775 ON MedicosExternos(idUsuario)
;
-- 
-- TABLE: MedicosExternos 
--

ALTER TABLE MedicosExternos ADD CONSTRAINT RefUsuarios75 
    FOREIGN KEY (idUsuario)
    REFERENCES Usuarios(idUsuario)
;


-- 
-- TABLE: MedicosInternos 
--

CREATE TABLE MedicosInternos(
    idUsuario               INT            NOT NULL,
    matriculaProfesional    VARCHAR(12)    NOT NULL,
    cargo                   VARCHAR(30)    NOT NULL,
    PRIMARY KEY (idUsuario)
)ENGINE=INNODB
;



-- 
-- INDEX: UI_matriculaProfesional 
--

CREATE UNIQUE INDEX UI_matriculaProfesional ON MedicosInternos(matriculaProfesional)
;
-- 
-- INDEX: Ref777 
--

CREATE INDEX Ref777 ON MedicosInternos(idUsuario)
;
-- 
-- TABLE: MedicosInternos 
--

ALTER TABLE MedicosInternos ADD CONSTRAINT RefUsuarios77 
    FOREIGN KEY (idUsuario)
    REFERENCES Usuarios(idUsuario)
;

-- 
-- TABLE: Afiliados 
--

CREATE TABLE Afiliados(
    idUsuario             INT            NOT NULL,
    tipoAfiliado          CHAR(1)        NOT NULL,
    fechaBaja             DATE,
    empleador             VARCHAR(50)    NOT NULL,
    maxPrestacionesMes    INT            DEFAULT 5 NOT NULL,
    PRIMARY KEY (idUsuario)
)ENGINE=INNODB
;



-- 
-- INDEX: UI_tipoAfiliado 
--

CREATE UNIQUE INDEX UI_tipoAfiliado ON Afiliados(tipoAfiliado)
;
-- 
-- INDEX: XI_fechaBaja 
--

CREATE INDEX XI_fechaBaja ON Afiliados(fechaBaja)
;
-- 
-- INDEX: Ref765 
--

CREATE INDEX Ref765 ON Afiliados(idUsuario)
;
-- 
-- TABLE: Afiliados 
--

ALTER TABLE Afiliados ADD CONSTRAINT RefUsuarios65 
    FOREIGN KEY (idUsuario)
    REFERENCES Usuarios(idUsuario)
;











-- 3. Stored Procedures
DROP procedure IF EXISTS `osp_buscar_usuarios`;
DELIMITER $$

CREATE PROCEDURE `osp_buscar_usuarios` (pCadena varchar(30), pIncluyeBajas char(1))
BEGIN
	/*
    Procedimiento que sirve para buscar los usuarios mediante una cadena que debe coincidir con parte del nombre de usuario, y la opción
    si incluye los usuarios de baja (S: Si, N:No).
    */
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SELECT		*
    FROM		USUARIOS
    WHERE		usuario LIKE CONCAT('%', pCadena, '%') AND
				(pIncluyeBajas = 'S' OR  Estado = 'A' OR Estado = 'P')
	ORDER BY	usuario;
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_alta_usuario`;
DELIMITER $$

CREATE PROCEDURE `osp_alta_usuario`(ptipo CHAR(1), pnombres VARCHAR(50), papellidos VARCHAR(50), pdni VARCHAR(11), 
psexo CHAR(1),pfechaNacimiento DATE, pusuario VARCHAR(30), ppassword CHAR(32), pdomicilio VARCHAR(120), pfechaAlta DATE, pprovincia VARCHAR(50),
pdepartamento VARCHAR(50),plocalidad  VARCHAR(50), ptelefono VARCHAR(20), pemail VARCHAR(120))
SALIR:BEGIN
	/*
    Permite dar de alta un usuario (ptipo = A para administrador; ptipo= S para secretario) controlando que el nombre, apellido, dni,sexo, 
    domicilio, fechaAlta,telefono,email no sea vacío y no exista ya un usuario con ese nombre de usuario, dni o email repetido.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pidUsuario int;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;

    -- Controla que los datos correspondientes no esten vacios ni nulos
    IF pnombres = '' OR pnombres IS NULL OR papellidos = '' OR papellidos IS NULL OR pdni = '' OR pdni IS NULL 
    OR psexo = '' OR psexo IS NULL OR pdomicilio = '' OR pdomicilio IS NULL OR ptelefono = '' OR ptelefono IS NULL 
    OR pemail = '' OR pemail IS NULL THEN
		SELECT 'El nombre, apellido, dni, sexo, domicilio, telefono y email del usuario es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- select 1;
	-- Controlo que el usuario no exista ya
    IF EXISTS(SELECT usuario FROM usuarios WHERE usuario = pusuario) THEN
		SELECT 'Ya existe un usuario con ese nombre de usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- select 2;
    IF EXISTS(SELECT dni FROM Usuarios WHERE dni = pdni) THEN
		SELECT 'Ya existe un usuario con ese DNI.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT email FROM Usuarios WHERE email = pemail) THEN
		SELECT 'Ya existe un usuario con ese email.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		-- Calcula el próximo ID
		SET pidUsuario = 1 + COALESCE((SELECT MAX(idUsuario) FROM usuarios),0);
		-- Inserta
        INSERT INTO usuarios VALUES(pidUsuario,pnombres, papellidos, pdni, psexo,
    pfechaNacimiento, pusuario, ppassword, pdomicilio, pfechaAlta, pprovincia,
    pdepartamento,plocalidad, ptelefono, pemail, 'A');
    CASE ptipo
    WHEN 'A' THEN 
		INSERT INTO administradores VALUES(pidUsuario);
	WHEN 'S' THEN 
		INSERT INTO secretarios VALUES(pidUsuario);    
	END CASE;
        SELECT CONCAT('OK',pidUsuario) AS Mensaje;
	COMMIT;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_alta_usuariomedicos`;
DELIMITER $$

CREATE PROCEDURE `osp_alta_usuariomedicos`(ptipo CHAR(1), pnombres VARCHAR(50), papellidos VARCHAR(50), pdni VARCHAR(11), psexo CHAR(1),
    pfechaNacimiento DATE, pusuario VARCHAR(30), ppassword CHAR(32), pdomicilio VARCHAR(120), pfechaAlta DATE, pprovincia VARCHAR(50),
    pdepartamento CHAR(10),plocalidad  CHAR(10), ptelefono VARCHAR(20), pemail VARCHAR(120),pmatriculaProfesional VARCHAR(12), 
    pcargo VARCHAR(30))
SALIR:BEGIN
	/*
    Permite dar de alta un usuario (ptipo = A para administrador; ptipo= S para secretario) controlando que el nombre, apellido, dni,sexo, domicilio, fechaAlta,telefono,email
    no sea vacío y no exista ya un usuario con ese nombre de usuario, dni o email repetido.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pidUsuario int;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
	-- 	SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;

    -- Controla que los datos correspondientes no esten vacios ni nulos
    IF pnombres = '' OR pnombres IS NULL OR papellidos = '' OR papellidos IS NULL OR pdni = '' OR pdni IS NULL 
    OR psexo = '' OR psexo IS NULL OR pdomicilio = '' OR pdomicilio IS NULL OR ptelefono = '' OR ptelefono IS NULL 
    OR pemail = '' OR pemail IS NULL OR pmatriculaProfesional='' OR pcargo ='' OR pcargo IS NULL THEN
		SELECT 'El nombre, apellido, dni, sexo, domicilio, telefono y email del usuario es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
	-- Controlo que el usuario no exista ya
    IF EXISTS(SELECT usuario FROM usuarios WHERE usuario = pusuario) THEN
		SELECT 'Ya existe un usuario con ese nombre de usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT dni FROM usuarios WHERE dni = pdni) THEN
		SELECT 'Ya existe un usuario con ese DNI.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT email FROM usuarios WHERE email = pemail) THEN
		SELECT 'Ya existe un usuario con ese email.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		-- Calcula el próximo ID
		SET pidUsuario = 1 + COALESCE((SELECT MAX(idUsuario) FROM usuarios),0);
		-- Inserta
        INSERT INTO usuarios VALUES(pidUsuario,pnombres, papellidos, pdni, psexo,
    pfechaNacimiento, pusuario, ppassword, pdomicilio, pfechaAlta, pprovincia,
    pdepartamento,plocalidad, ptelefono, pemail, 'A');
    
    CASE ptipo
    WHEN 'E' THEN  
        INSERT INTO medicosexternos VALUES(pidUsuario,pmatriculaProfesional, pcargo);
	WHEN 'I' THEN 
		INSERT INTO medicosinternos VALUES(pidUsuario,pmatriculaProfesional, pcargo);    
	END CASE;
	
        SELECT CONCAT('OK',pidUsuario) AS Mensaje;
	COMMIT;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_alta_usuarioafiliado`;
DELIMITER $$

CREATE PROCEDURE `osp_alta_usuarioafiliado`(ptipo CHAR(2), pnombres VARCHAR(50), papellidos VARCHAR(50), pdni VARCHAR(11), psexo CHAR(1),
    pfechaNacimiento DATE, pusuario VARCHAR(30), ppassword CHAR(32), pdomicilio VARCHAR(120), pprovincia VARCHAR(50),
    pdepartamento VARCHAR(50),plocalidad  VARCHAR(50), ptelefono VARCHAR(20), pemail VARCHAR(120),ptipoAfiliado CHAR(1),
    pempleador VARCHAR(50),pmaxPrestacionesMes INT)

SALIR:BEGIN
	/*
    Permite dar de alta un usuario (ptipo = AF para afiliado) controlando que el nombre, apellido, dni,sexo, domicilio, fechaAlta,telefono,email
    no sea vacío y no exista ya un usuario con ese nombre de usuario, dni o email repetido.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pidUsuario int;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;

    -- Controla que los datos correspondientes no esten vacios ni nulos
    IF pnombres = '' OR pnombres IS NULL OR papellidos = '' OR papellidos IS NULL OR pdni = '' OR pdni IS NULL 
    OR psexo = '' OR psexo IS NULL OR pdomicilio = '' OR pdomicilio IS NULL OR ptelefono = '' OR ptelefono IS NULL 
    OR pemail = '' OR pemail IS NULL THEN
		SELECT 'El nombre, apellido, dni, sexo, domicilio, telefono y email del usuario es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    
	-- Controlo que el usuario no exista ya
    IF EXISTS(SELECT usuario FROM usuarios WHERE usuario = pusuario) THEN
		SELECT 'Ya existe un usuario con ese nombre de usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT dni FROM usuarios WHERE dni = pdni) THEN
		SELECT 'Ya existe un usuario con ese DNI.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT email FROM usuarios WHERE email = pemail) THEN
		SELECT 'Ya existe un usuario con ese email.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		-- Calcula el próximo ID
		SET pidUsuario = 1 + COALESCE((SELECT MAX(idUsuario) FROM usuarios),0);
		-- Inserta
--        select 1;
        INSERT INTO usuarios VALUES(pidUsuario,pnombres, papellidos, pdni, psexo,
    pfechaNacimiento, pusuario, ppassword, pdomicilio, now(), pprovincia,
    pdepartamento,plocalidad, ptelefono, pemail, 'A');
-- select 2;
    CASE ptipo
    WHEN 'F' THEN 
		INSERT INTO afiliados VALUES(pidUsuario,ptipoAfiliado,null,pempleador,pmaxPrestacionesMes);
	END CASE;
	
        SELECT CONCAT('OK',pidUsuario) AS Mensaje;
	COMMIT;
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_modifica_usuario`;
DELIMITER $$

CREATE PROCEDURE `osp_modifica_usuario`(pidUsuario int, pnombres VARCHAR(50), papellidos VARCHAR(50), pdni VARCHAR(11), psexo CHAR(1), 
    pfechaNacimiento DATE, pusuario VARCHAR(30), ppassword CHAR(32), pdomicilio VARCHAR(120), pprovincia CHAR(10),
    pdepartamento CHAR(10),plocalidad  CHAR(10), ptelefono VARCHAR(20), pemail VARCHAR(120))
SALIR:BEGIN
	/*
    Permite modificar un usuario existente controlando que el nombre de usuario no sea vacío y no exista ya un usuario con ese nombre.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
	-- 	 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;

    -- Controla que el rubro no sea vacío ni nulo
    IF pnombres = '' OR pnombres IS NULL OR papellidos = '' OR papellidos IS NULL OR pdni = '' OR pdni IS NULL 
    OR psexo = '' OR psexo IS NULL OR pdomicilio = '' OR pdomicilio IS NULL OR ptelefono = '' OR ptelefono IS NULL 
    OR pemail = '' OR pemail IS NULL THEN
		SELECT 'El nombre, apellido, dni, sexo, domicilio, telefono y email del usuario es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;

    -- Controlo que el usuario no exista ya
    IF EXISTS(SELECT usuario FROM usuarios WHERE usuario = pusuario AND idUsuario != pidUsuario) THEN
		SELECT 'Ya existe un usuario con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT dni FROM usuarios WHERE dni = pdni AND idUsuario != pidUsuario) THEN
		SELECT 'Ya existe un usuario con ese DNI.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT email FROM usuarios WHERE email = pemail AND idUsuario != pidUsuario) THEN
		SELECT 'Ya existe un usuario con ese email.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    
	-- Modifica
	UPDATE usuarios SET nombres = pnombres, apellidos = papellidos, dni = pdni,sexo = psexo, fechaNacimiento = pfechaNacimiento, 
    usuario = pusuario,password = ppassword, domicilio = pdomicilio,provincia = pprovincia,
    departamento = pdepartamento, localidad = plocalidad, telefono = ptelefono,email = pemail, estado ='A' 
    WHERE idUsuario = pidUsuario;
		
	SELECT 'OK' AS Mensaje;
    
END$$
DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_modifica_usuariosMedicos`;
DELIMITER $$

CREATE PROCEDURE `osp_modifica_usuariosMedicos`(ptipo char(1),pidUsuario int, pnombres VARCHAR(50), papellidos VARCHAR(50), pdni VARCHAR(11), psexo CHAR(1), 
    pfechaNacimiento DATE, pusuario VARCHAR(30), ppassword CHAR(32), pdomicilio VARCHAR(120), pprovincia CHAR(10),
    pdepartamento CHAR(10),plocalidad  CHAR(10), ptelefono VARCHAR(20), pemail VARCHAR(120),pmatriculaProfesional VARCHAR(12), 
    pcargo VARCHAR(30))
SALIR:BEGIN
	/*
    Permite modificar un usuario existente controlando que el nombre de usuario no sea vacío y no exista ya un usuario con ese nombre.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;

    -- Controla que el rubro no sea vacío ni nulo
    IF pnombres = '' OR pnombres IS NULL OR papellidos = '' OR papellidos IS NULL OR pdni = '' OR pdni IS NULL 
    OR psexo = '' OR psexo IS NULL OR pdomicilio = '' OR pdomicilio IS NULL OR ptelefono = '' OR ptelefono IS NULL 
    OR pemail = '' OR pemail IS NULL THEN
		SELECT 'El nombre, apellido, dni, sexo, domicilio, telefono y email del usuario es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;

    -- Controlo que el usuario no exista ya
    IF EXISTS(SELECT usuario FROM usuarios WHERE usuario = pusuario AND idUsuario != pidUsuario) THEN
		SELECT 'Ya existe un usuario con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT dni FROM usuarios WHERE dni = pdni AND idUsuario != pidUsuario) THEN
		SELECT 'Ya existe un usuario con ese DNI.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT email FROM usuarios WHERE email = pemail AND idUsuario != pidUsuario) THEN
		SELECT 'Ya existe un usuario con ese email.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		-- Modifica primero al usuario
		UPDATE usuarios SET nombres = pnombres, apellidos = papellidos, dni = pdni,sexo = psexo, fechaNacimiento = pfechaNacimiento, 
		usuario = pusuario,password = ppassword, domicilio = pdomicilio,provincia = pprovincia,
		departamento = pdepartamento, localidad = plocalidad, telefono = ptelefono,email = pemail, estado ='A' 
		WHERE idUsuario = pidUsuario;
			
		CASE ptipo
		WHEN 'E' THEN  
			UPDATE medicosexternos SET matriculaProfesional = pmatriculaProfesional, cargo = pcargo
			WHERE idUsuario = pidUsuario;
		WHEN 'I' THEN 
			UPDATE medicosinternos SET matriculaProfesional = pmatriculaProfesional, cargo = pcargo
			WHERE idUsuario = pidUsuario;    
		END CASE;
    COMMIT;
	SELECT 'OK' AS Mensaje;
    
END$$
DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_modifica_usuarioafiliado`;
DELIMITER $$

CREATE PROCEDURE `osp_modifica_usuarioafiliado`(ptipo char(1),pidUsuario int, pnombres VARCHAR(50), papellidos VARCHAR(50), pdni VARCHAR(11), psexo CHAR(1), 
    pfechaNacimiento DATE, pusuario VARCHAR(30), ppassword CHAR(32), pdomicilio VARCHAR(120), pprovincia CHAR(10),
    pdepartamento CHAR(10),plocalidad  CHAR(10), ptelefono VARCHAR(20), pemail VARCHAR(120),ptipoAfiliado CHAR(1),
    pempleador VARCHAR(50),pmaxPrestacionesMes INT)
SALIR:BEGIN
	/*
    Permite modificar un usuario existente controlando que el nombre de usuario no sea vacío y no exista ya un usuario con ese nombre.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;

    -- Controla que el rubro no sea vacío ni nulo
    IF pnombres = '' OR pnombres IS NULL OR papellidos = '' OR papellidos IS NULL OR pdni = '' OR pdni IS NULL 
    OR psexo = '' OR psexo IS NULL OR pdomicilio = '' OR pdomicilio IS NULL OR ptelefono = '' OR ptelefono IS NULL 
    OR pemail = '' OR pemail IS NULL THEN
		SELECT 'El nombre, apellido, dni, sexo, domicilio, telefono y email del usuario es obligatorio.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;

    -- Controlo que el usuario no exista ya
    IF EXISTS(SELECT usuario FROM usuarios WHERE usuario = pusuario AND idUsuario != pidUsuario) THEN
		SELECT 'Ya existe un usuario con ese nombre.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT dni FROM usuarios WHERE dni = pdni AND idUsuario != pidUsuario) THEN
		SELECT 'Ya existe un usuario con ese DNI.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT email FROM usuarios WHERE email = pemail AND idUsuario != pidUsuario) THEN
		SELECT 'Ya existe un usuario con ese email.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    
	-- Modifica primero al usuario
	START TRANSACTION;
		UPDATE usuarios SET nombres = pnombres, apellidos = papellidos, dni = pdni,sexo = psexo, fechaNacimiento = pfechaNacimiento, 
		usuario = pusuario,password = ppassword, domicilio = pdomicilio,provincia = pprovincia,
		departamento = pdepartamento, localidad = plocalidad, telefono = ptelefono,email = pemail, estado ='A' 
		WHERE idUsuario = pidUsuario;
			
		CASE ptipo
		WHEN 'F' THEN 
		UPDATE afiliados SET tipoAfiliado= ptipoAfiliado, empleador = pempleador, maxPrestacionesMes = pmaxPrestacionesMes
		WHERE idUsuario = pidUsuario;
		END CASE;
    COMMIT;
	SELECT 'OK' AS Mensaje;
    
END$$
DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------

DROP procedure IF EXISTS `osp_borra_usuario`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_usuario`(ptipo char(1),pidUsuario int)
SALIR:BEGIN
	/*
    Permite borrar un usuario existente controlando que no existan afiliados,secretarios,medicos con ese usuario     
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el usuario no exista como afiliado
    IF EXISTS(SELECT idUsuario FROM afiliados WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un afiliado asociado.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT idUsuario FROM administradores WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un administrador asociado.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT idUsuario FROM secretarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un secretario asociado.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        IF EXISTS(SELECT idUsuario FROM medicosexternos WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un médico externo asociados.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        IF EXISTS(SELECT idUsuario FROM medicosinternos WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un médico interno asociados.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra
	DELETE FROM usuarios WHERE idUsuario = pidUsuario;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------

DROP procedure IF EXISTS `osp_borra_usuario`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_usuariomedico`(pidUsuario int)
SALIR:BEGIN
	/*
    Permite borrar un usuario existente controlando que no existan afiliados,secretarios,medicos con ese usuario     
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el usuario no exista como afiliado
    IF EXISTS(SELECT idUsuario FROM afiliado WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un afiliado asociado.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT idUsuario FROM administradores WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un administrador asociado.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT idUsuario FROM secretarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un secretario asociado.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        IF EXISTS(SELECT idUsuario FROM medicosexternos WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un médico externo asociados.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        IF EXISTS(SELECT idUsuario FROM medicosinternos WHERE idUsuario = pidUsuario) THEN
		SELECT 'No puede borrar el usuario porque tiene un médico interno asociados.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra

		DELETE FROM usuarios WHERE idUsuario = pidUsuario;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_borra_secretarioadministrador`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_secretarioadministrador`(ptipo char(1),pidUsuario int)
SALIR:BEGIN
	/*
    Permite borrar un usuario existente controlando que no existan afiliados,secretarios,medicos con ese usuario     
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
	-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra
		CASE ptipo
		WHEN 'A' THEN  
			DELETE FROM administradores WHERE idUsuario = pidUsuario;
			DELETE FROM usuarios WHERE idUsuario = pidUsuario;

		WHEN 'S' THEN 
			DELETE FROM secretarios WHERE idUsuario = pidUsuario;
			DELETE FROM usuarios WHERE idUsuario = pidUsuario;

		END CASE;

		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_borra_medicos`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_medicos`(ptipo char(1),pidUsuario int)
SALIR:BEGIN
	/*
    Permite borrar un usuario existente controlando que no existan afiliados,secretarios,medicos con ese usuario     
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra
		CASE ptipo
		WHEN 'E' THEN  
			DELETE FROM medicosexternos WHERE idUsuario = pidUsuario;
			DELETE FROM usuarios WHERE idUsuario = pidUsuario;
		
        WHEN 'I' THEN 
			DELETE FROM medicosinternos WHERE idUsuario = pidUsuario;
			DELETE FROM usuarios WHERE idUsuario = pidUsuario;
		
        END CASE;

		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------------------------------

DROP procedure IF EXISTS `osp_borra_usuarioafiliado`;
DELIMITER $$

CREATE PROCEDURE `osp_borra_usuarioafiliado`(ptipo char(1),pidUsuario int)
SALIR:BEGIN
	/*
    Permite borrar un usuario existente controlando que no existan afiliados,secretarios,medicos con ese usuario     
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Borra
	CASE ptipo
	WHEN 'F' THEN 
		DELETE FROM afiliados WHERE idUsuario = pidUsuario;
		DELETE FROM usuarios WHERE idUsuario = pidUsuario;
	
    END CASE;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_dame_usuario`;
DELIMITER $$

CREATE PROCEDURE `osp_dame_usuario` (pidUsuario int)
BEGIN
	/*
    Procedimiento que sirve para instanciar un usuario  en memoria, desde la base de datos.
    */
    SELECT * FROM usuarios WHERE idUsuario = pidUsuario;
    END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_darbaja_usuario`;
DELIMITER $$

CREATE PROCEDURE `osp_darbaja_usuario`(pidUsuario int)
SALIR:BEGIN
	/*
    Permite dar de baja un usuario siempre y cuando exista y esté activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el usuario esté activo
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario AND estado = 'A') THEN
		SELECT 'El usuario ya está dado de baja.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	
    UPDATE usuarios SET estado = 'B' WHERE idUsuario = pidUsuario;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_activar_usuario`;
DELIMITER $$

CREATE PROCEDURE `osp_activar_usuario`(pidUsuario int)
SALIR:BEGIN
	/*
    Permite activar un usuario siempre y cuando exista y esté activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el usuario esté dado de baja
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario AND estado = 'B') THEN
		SELECT 'El usuario ya está activo.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el usuario esté suspendido
/*    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario AND estado = 'S') THEN
		SELECT 'El usuario ya está activo.' AS Mensaje;
        LEAVE SALIR;
	END IF;
        -- Controlo que el usuario esté pendiente
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario AND estado = 'P') THEN
		SELECT 'El usuario ya está activo.' AS Mensaje;
        LEAVE SALIR;
	END IF;
*/
	-- Modifica
	UPDATE usuarios SET estado = 'A' WHERE idUsuario = pidUsuario;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------------------------------
DROP procedure IF EXISTS `osp_suspender_usuario`;
DELIMITER $$

CREATE PROCEDURE `osp_suspender_usuario`(pidUsuario int)
SALIR:BEGIN
	/*
    Permite suspender un usuario siempre y cuando exista y esté activo.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' AS Mensaje;
        ROLLBACK;
    END;
	-- Controlo que el usuario exista
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario) THEN
		SELECT 'No existe ese usuario.' AS Mensaje;
        LEAVE SALIR;
	END IF;
    -- Controlo que el usuario esté activo
    IF NOT EXISTS(SELECT idUsuario FROM usuarios WHERE idUsuario = pidUsuario AND estado = 'S') THEN
		SELECT 'El usuario ya está Activo.' AS Mensaje;
        LEAVE SALIR;
	END IF;

	-- Modifica
	UPDATE usuarios SET estado = 'S' WHERE idUsuario = pidUsuario;
		
	SELECT 'OK' AS Mensaje;
    
END$$

DELIMITER ;
