SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';



-- -----------------------------------------------------
-- Table `station`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `station` ;

CREATE  TABLE IF NOT EXISTS `station` (
  `name` VARCHAR(45) NOT NULL ,
  `alias` VARCHAR(5) NOT NULL ,
  `elevation` DOUBLE NOT NULL ,
  `lat` DOUBLE NOT NULL ,
  `lon` DOUBLE NOT NULL ,
  `country` VARCHAR(45) NOT NULL ,
  `state` VARCHAR(45) NOT NULL ,
  `city` VARCHAR(45) NOT NULL ,
  `responsible` VARCHAR(45) NULL ,
  `description` VARCHAR(500) NULL ,
  PRIMARY KEY (`name`) ,
  UNIQUE INDEX `alias_UNIQUE` (`alias` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `camera`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `camera` ;

CREATE  TABLE IF NOT EXISTS `camera` (
  `id` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `reference` VARCHAR(100) NOT NULL ,
  `sizeX` INT NOT NULL ,
  `sizeY` INT NOT NULL ,
  PRIMARY KEY (`id`, `station`) ,
  INDEX `fk_camera_station_idx` (`station` ASC) ,
  CONSTRAINT `fk_camera_station`
    FOREIGN KEY (`station` )
    REFERENCES `station` (`name` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `imagetype`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `imagetype` ;

CREATE  TABLE IF NOT EXISTS `imagetype` (
  `idtype` VARCHAR(10) NOT NULL ,
  `name` VARCHAR(20) NOT NULL ,
  `description` VARCHAR(500) NULL ,
  PRIMARY KEY (`idtype`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `image`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `image` ;

CREATE  TABLE IF NOT EXISTS `image` (
  `filename` VARCHAR(120) NOT NULL ,
  `type` VARCHAR(10) NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  `ismini` TINYINT(1) NOT NULL ,
  `path` VARCHAR(200) NOT NULL ,
  PRIMARY KEY (`filename`) ,
  INDEX `index_filename` USING HASH (`filename` ASC) ,
  INDEX `index_timestamp` USING BTREE (`timestamp` ASC) ,
  INDEX `fk_image_imagetype1_idx` (`type` ASC) ,
  CONSTRAINT `fk_image_imagetype1`
    FOREIGN KEY (`type` )
    REFERENCES `imagetype` (`idtype` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `obliqueimage`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `obliqueimage` ;

CREATE  TABLE IF NOT EXISTS `obliqueimage` (
  `filename` VARCHAR(120) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`filename`) ,
  INDEX `index_filename` USING HASH (`filename` ASC) ,
  CONSTRAINT `fk_obliqueimage_camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_obliqueimage_image1`
    FOREIGN KEY (`filename` )
    REFERENCES `image` (`filename` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `calibration`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `calibration` ;

CREATE  TABLE IF NOT EXISTS `calibration` (
  `idcalibration` VARCHAR(10) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  `resolution` DOUBLE NOT NULL ,
  `EMCuv` DOUBLE NULL ,
  `EMCxy` DOUBLE NULL ,
  `NCE` DOUBLE NULL ,
  PRIMARY KEY (`idcalibration`) ,
  INDEX `fk_calibration_camera1_idx` (`camera` ASC, `station` ASC) ,
  CONSTRAINT `fk_calibration_camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `sensor`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sensor` ;

CREATE  TABLE IF NOT EXISTS `sensor` (
  `name` VARCHAR(45) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `x` DOUBLE NOT NULL ,
  `y` DOUBLE NOT NULL ,
  `z` DOUBLE NOT NULL ,
  `isvirtual` TINYINT(1) NOT NULL ,
  `description` VARCHAR(500) NULL ,
  PRIMARY KEY (`name`, `station`) ,
  INDEX `fk_sensor_station1_idx` (`station` ASC) ,
  CONSTRAINT `fk_sensor_station1`
    FOREIGN KEY (`station` )
    REFERENCES `station` (`name` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `measurementtype`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `measurementtype` ;

CREATE  TABLE IF NOT EXISTS `measurementtype` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `station` VARCHAR(45) NOT NULL ,
  `sensor` VARCHAR(45) NOT NULL ,
  `paramname` VARCHAR(45) NOT NULL ,
  `datatype` VARCHAR(45) NOT NULL ,
  `unitx` VARCHAR(10) NULL ,
  `unity` VARCHAR(10) NULL ,
  `unitz` VARCHAR(10) NULL ,
  `axisnamex` VARCHAR(35) NULL ,
  `axisnamey` VARCHAR(35) NULL ,
  `axisnamez` VARCHAR(60) NULL ,
  `description` VARCHAR(500) NULL ,
  PRIMARY KEY (`id`, `station`) ,
  INDEX `fk_measurementtype_sensor1_idx` (`sensor` ASC, `station` ASC) ,
  CONSTRAINT `fk_measurementtype_sensor1`
    FOREIGN KEY (`sensor` , `station` )
    REFERENCES `sensor` (`name` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `measurement`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `measurement` ;

CREATE  TABLE IF NOT EXISTS `measurement` (
  `idmeasurement` INT NOT NULL AUTO_INCREMENT ,
  `station` VARCHAR(45) NOT NULL ,
  `type` INT NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  PRIMARY KEY (`idmeasurement`, `station`) ,
  INDEX `fk_measurement_measurementtype1_idx` (`type` ASC, `station` ASC) ,
  CONSTRAINT `fk_measurement_measurementtype1`
    FOREIGN KEY (`type` , `station` )
    REFERENCES `measurementtype` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `gcp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `gcp` ;

CREATE  TABLE IF NOT EXISTS `gcp` (
  `idgcp` INT NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `name` VARCHAR(10) NOT NULL ,
  `x` DOUBLE NOT NULL ,
  `y` DOUBLE NOT NULL ,
  `z` DOUBLE NOT NULL ,
  PRIMARY KEY (`idgcp`, `station`) ,
  INDEX `fk_gcp_station1_idx` (`station` ASC) ,
  CONSTRAINT `fk_gcp_station1`
    FOREIGN KEY (`station` )
    REFERENCES `station` (`name` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `pickedgcp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `pickedgcp` ;

CREATE  TABLE IF NOT EXISTS `pickedgcp` (
  `calibration` VARCHAR(10) NOT NULL ,
  `gcp` INT NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `u` DOUBLE NOT NULL ,
  `v` DOUBLE NOT NULL ,
  PRIMARY KEY (`calibration`, `gcp`, `station`) ,
  INDEX `fk_pickedgcp_gcp1_idx` (`gcp` ASC, `station` ASC) ,
  CONSTRAINT `fk_pickedgcp_calibration1`
    FOREIGN KEY (`calibration` )
    REFERENCES `calibration` (`idcalibration` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pickedgcp_gcp1`
    FOREIGN KEY (`gcp` , `station` )
    REFERENCES `gcp` (`idgcp` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `timestack`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `timestack` ;

CREATE  TABLE IF NOT EXISTS `timestack` (
  `filename` VARCHAR(120) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `inittime` DECIMAL(17,10) NOT NULL ,
  `path` VARCHAR(200) NOT NULL ,
  `fps` DOUBLE NOT NULL ,
  `numFrames` INT NOT NULL ,
  INDEX `fk_timestack_camera1_idx` (`camera` ASC, `station` ASC) ,
  PRIMARY KEY (`filename`) ,
  CONSTRAINT `fk_timestack_camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `calibrationparameter`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `calibrationparameter` ;

CREATE  TABLE IF NOT EXISTS `calibrationparameter` (
  `id` VARCHAR(10) NOT NULL ,
  `calibration` VARCHAR(10) NOT NULL ,
  `name` VARCHAR(20) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_GeometryParameter_calibration1_idx` (`calibration` ASC) ,
  CONSTRAINT `fk_GeometryParameter_calibration1`
    FOREIGN KEY (`calibration` )
    REFERENCES `calibration` (`idcalibration` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `calibrationvalue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `calibrationvalue` ;

CREATE  TABLE IF NOT EXISTS `calibrationvalue` (
  `idparam` VARCHAR(10) NOT NULL ,
  `idcol` INT NOT NULL ,
  `idrow` INT NOT NULL ,
  `value` DOUBLE NOT NULL ,
  PRIMARY KEY (`idparam`, `idcol`, `idrow`) ,
  INDEX `fk_ParameterValue_GeometryParameter1_idx` (`idparam` ASC) ,
  CONSTRAINT `fk_ParameterValue_GeometryParameter1`
    FOREIGN KEY (`idparam` )
    REFERENCES `calibrationparameter` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `roi`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `roi` ;

CREATE  TABLE IF NOT EXISTS `roi` (
  `idroi` VARCHAR(10) NOT NULL ,
  `idcalibration` VARCHAR(10) NOT NULL ,
  `type` VARCHAR(45) NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  PRIMARY KEY (`idroi`) ,
  INDEX `fk_roi_calibration1_idx` (`idcalibration` ASC) ,
  CONSTRAINT `fk_roi_calibration1`
    FOREIGN KEY (`idcalibration` )
    REFERENCES `calibration` (`idcalibration` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `fusion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `fusion` ;

CREATE  TABLE IF NOT EXISTS `fusion` (
  `id` VARCHAR(10) NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  `type` VARCHAR(15) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `roicoordinate`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `roicoordinate` ;

CREATE  TABLE IF NOT EXISTS `roicoordinate` (
  `idroi` VARCHAR(10) NOT NULL ,
  `idcoord` INT NOT NULL AUTO_INCREMENT ,
  `u` DOUBLE NOT NULL ,
  `v` DOUBLE NOT NULL ,
  PRIMARY KEY (`idcoord`, `idroi`) ,
  INDEX `fk_roicoordinate_roi1_idx` (`idroi` ASC) ,
  CONSTRAINT `fk_roicoordinate_roi1`
    FOREIGN KEY (`idroi` )
    REFERENCES `roi` (`idroi` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `measurementvalue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `measurementvalue` ;

CREATE  TABLE IF NOT EXISTS `measurementvalue` (
  `idmeasurement` INT NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `idcol` INT NOT NULL ,
  `idrow` INT NOT NULL ,
  `iddepth` INT NOT NULL ,
  `value` DOUBLE NOT NULL ,
  PRIMARY KEY (`idmeasurement`, `station`, `idcol`, `idrow`, `iddepth`) ,
  INDEX `fk_measurementvalue_measurement1_idx` (`idmeasurement` ASC, `station` ASC) ,
  CONSTRAINT `fk_measurementvalue_measurement1`
    FOREIGN KEY (`idmeasurement` , `station` )
    REFERENCES `measurement` (`idmeasurement` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `camerabyfusion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `camerabyfusion` ;

CREATE  TABLE IF NOT EXISTS `camerabyfusion` (
  `idfusion` VARCHAR(10) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `sequence` INT NOT NULL ,
  PRIMARY KEY (`idfusion`, `camera`, `station`) ,
  INDEX `fk_camerabyfusion_camera1_idx` (`camera` ASC, `station` ASC) ,
  CONSTRAINT `fk_camerabyfusion_fusion1`
    FOREIGN KEY (`idfusion` )
    REFERENCES `fusion` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_camerabyfusion_camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `fusionparameter`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `fusionparameter` ;

CREATE  TABLE IF NOT EXISTS `fusionparameter` (
  `id` VARCHAR(10) NOT NULL ,
  `idfusion` VARCHAR(10) NOT NULL ,
  `name` VARCHAR(10) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_fusionMatrix_fusion1_idx` (`idfusion` ASC) ,
  CONSTRAINT `fk_fusionMatrix_fusion1`
    FOREIGN KEY (`idfusion` )
    REFERENCES `fusion` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `fusionvalue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `fusionvalue` ;

CREATE  TABLE IF NOT EXISTS `fusionvalue` (
  `idmatrix` VARCHAR(10) NOT NULL ,
  `idcol` INT NOT NULL ,
  `idrow` INT NOT NULL ,
  `value` DOUBLE NOT NULL ,
  PRIMARY KEY (`idmatrix`, `idcol`, `idrow`) ,
  INDEX `fk_fusionvalue_fusionMatrix1_idx` (`idmatrix` ASC) ,
  CONSTRAINT `fk_fusionvalue_fusionMatrix1`
    FOREIGN KEY (`idmatrix` )
    REFERENCES `fusionparameter` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `rectifiedimage`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rectifiedimage` ;

CREATE  TABLE IF NOT EXISTS `rectifiedimage` (
  `filename` VARCHAR(120) NOT NULL ,
  `calibration` VARCHAR(10) NOT NULL ,
  INDEX `fk_rectifiedimage_calibration1_idx` (`calibration` ASC) ,
  PRIMARY KEY (`filename`) ,
  INDEX `index_filename` USING HASH (`filename` ASC) ,
  CONSTRAINT `fk_rectifiedimage_calibration1`
    FOREIGN KEY (`calibration` )
    REFERENCES `calibration` (`idcalibration` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_rectifiedimage_image1`
    FOREIGN KEY (`filename` )
    REFERENCES `image` (`filename` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `mergedimage`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mergedimage` ;

CREATE  TABLE IF NOT EXISTS `mergedimage` (
  `filename` VARCHAR(120) NOT NULL ,
  `idfusion` VARCHAR(10) NOT NULL ,
  INDEX `fk_fusionimage_fusion1_idx` (`idfusion` ASC) ,
  PRIMARY KEY (`filename`) ,
  INDEX `index_filename` USING HASH (`filename` ASC) ,
  CONSTRAINT `fk_fusionimage_fusion1`
    FOREIGN KEY (`idfusion` )
    REFERENCES `fusion` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_mergedimage_image1`
    FOREIGN KEY (`filename` )
    REFERENCES `image` (`filename` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `automaticparams`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `automaticparams` ;

CREATE  TABLE IF NOT EXISTS `automaticparams` (
  `idauto` INT NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `type` VARCHAR(15) NOT NULL ,
  `start_hour` INT NOT NULL ,
  `start_minute` INT NOT NULL ,
  `end_hour` INT NOT NULL ,
  `end_minute` INT NOT NULL ,
  `step` INT NOT NULL ,
  `duration` INT NULL ,
  `num_images` INT NULL ,
  INDEX `fk_automaticparams_station1_idx` (`station` ASC) ,
  PRIMARY KEY (`idauto`) ,
  CONSTRAINT `fk_automaticparams_station1`
    FOREIGN KEY (`station` )
    REFERENCES `station` (`name` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci
COMMENT = 'El atributo \"type\" puede ser \"image\", \"stack\", \"transfer\", \" /* comment truncated */ /*process".*/';


-- -----------------------------------------------------
-- Table `commonpoint`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `commonpoint` ;

CREATE  TABLE IF NOT EXISTS `commonpoint` (
  `idfusion` VARCHAR(10) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `name` VARCHAR(15) NOT NULL ,
  `u` DOUBLE NOT NULL ,
  `v` DOUBLE NOT NULL ,
  PRIMARY KEY (`idfusion`, `camera`, `station`, `name`) ,
  INDEX `fk_commonpoint_fusion1_idx` (`idfusion` ASC) ,
  INDEX `fk_commonpoint_camera1_idx` (`camera` ASC, `station` ASC) ,
  CONSTRAINT `fk_commonpoint_fusion1`
    FOREIGN KEY (`idfusion` )
    REFERENCES `fusion` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_commonpoint_camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
