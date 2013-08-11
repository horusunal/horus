SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';



-- -----------------------------------------------------
-- Table `Station`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Station` ;

CREATE  TABLE IF NOT EXISTS `Station` (
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
-- Table `Camera`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Camera` ;

CREATE  TABLE IF NOT EXISTS `Camera` (
  `id` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `reference` VARCHAR(100) NOT NULL ,
  `sizeX` INT NOT NULL ,
  `sizeY` INT NOT NULL ,
  PRIMARY KEY (`id`, `station`) ,
  INDEX `fk_Camera_Station_idx` (`station` ASC) ,
  CONSTRAINT `fk_Camera_Station`
    FOREIGN KEY (`station` )
    REFERENCES `Station` (`name` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `ImageType`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ImageType` ;

CREATE  TABLE IF NOT EXISTS `ImageType` (
  `idtype` VARCHAR(10) NOT NULL ,
  `name` VARCHAR(20) NOT NULL ,
  `description` VARCHAR(500) NULL ,
  PRIMARY KEY (`idtype`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `Image`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Image` ;

CREATE  TABLE IF NOT EXISTS `Image` (
  `filename` VARCHAR(120) NOT NULL ,
  `type` VARCHAR(10) NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  `ismini` TINYINT(1) NOT NULL ,
  `path` VARCHAR(200) NOT NULL ,
  PRIMARY KEY (`filename`) ,
  INDEX `index_filename` USING HASH (`filename` ASC) ,
  INDEX `index_timestamp` USING BTREE (`timestamp` ASC) ,
  INDEX `fk_Image_ImageType1_idx` (`type` ASC) ,
  CONSTRAINT `fk_Image_ImageType1`
    FOREIGN KEY (`type` )
    REFERENCES `ImageType` (`idtype` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `ObliqueImage`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ObliqueImage` ;

CREATE  TABLE IF NOT EXISTS `ObliqueImage` (
  `filename` VARCHAR(120) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`filename`) ,
  INDEX `index_filename` USING HASH (`filename` ASC) ,
  CONSTRAINT `fk_ObliqueImage_Camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `Camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_ObliqueImage_Image1`
    FOREIGN KEY (`filename` )
    REFERENCES `Image` (`filename` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `Calibration`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Calibration` ;

CREATE  TABLE IF NOT EXISTS `Calibration` (
  `idcalibration` VARCHAR(10) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  `resolution` DOUBLE NOT NULL ,
  `EMCuv` DOUBLE NULL ,
  `EMCxy` DOUBLE NULL ,
  `NCE` DOUBLE NULL ,
  PRIMARY KEY (`idcalibration`) ,
  INDEX `fk_Calibration_Camera1_idx` (`camera` ASC, `station` ASC) ,
  CONSTRAINT `fk_Calibration_Camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `Camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `Sensor`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Sensor` ;

CREATE  TABLE IF NOT EXISTS `Sensor` (
  `name` VARCHAR(45) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `x` DOUBLE NOT NULL ,
  `y` DOUBLE NOT NULL ,
  `z` DOUBLE NOT NULL ,
  `isvirtual` TINYINT(1) NOT NULL ,
  `description` VARCHAR(500) NULL ,
  PRIMARY KEY (`name`, `station`) ,
  INDEX `fk_Sensor_Station1_idx` (`station` ASC) ,
  CONSTRAINT `fk_Sensor_Station1`
    FOREIGN KEY (`station` )
    REFERENCES `Station` (`name` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `MeasurementType`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `MeasurementType` ;

CREATE  TABLE IF NOT EXISTS `MeasurementType` (
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
  INDEX `fk_MeasurementType_Sensor1_idx` (`sensor` ASC, `station` ASC) ,
  CONSTRAINT `fk_MeasurementType_Sensor1`
    FOREIGN KEY (`sensor` , `station` )
    REFERENCES `Sensor` (`name` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `Measurement`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Measurement` ;

CREATE  TABLE IF NOT EXISTS `Measurement` (
  `idmeasurement` INT NOT NULL AUTO_INCREMENT ,
  `station` VARCHAR(45) NOT NULL ,
  `type` INT NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  PRIMARY KEY (`idmeasurement`, `station`) ,
  INDEX `fk_Measurement_MeasurementType1_idx` (`type` ASC, `station` ASC) ,
  CONSTRAINT `fk_Measurement_MeasurementType1`
    FOREIGN KEY (`type` , `station` )
    REFERENCES `MeasurementType` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `GCP`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `GCP` ;

CREATE  TABLE IF NOT EXISTS `GCP` (
  `idgcp` INT NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `name` VARCHAR(10) NOT NULL ,
  `x` DOUBLE NOT NULL ,
  `y` DOUBLE NOT NULL ,
  `z` DOUBLE NOT NULL ,
  PRIMARY KEY (`idgcp`, `station`) ,
  INDEX `fk_GCP_Station1_idx` (`station` ASC) ,
  CONSTRAINT `fk_GCP_Station1`
    FOREIGN KEY (`station` )
    REFERENCES `Station` (`name` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `PickedGCP`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PickedGCP` ;

CREATE  TABLE IF NOT EXISTS `PickedGCP` (
  `calibration` VARCHAR(10) NOT NULL ,
  `gcp` INT NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `u` DOUBLE NOT NULL ,
  `v` DOUBLE NOT NULL ,
  PRIMARY KEY (`calibration`, `gcp`, `station`) ,
  INDEX `fk_PickedGCP_GCP1_idx` (`gcp` ASC, `station` ASC) ,
  CONSTRAINT `fk_PickedGCP_Calibration1`
    FOREIGN KEY (`calibration` )
    REFERENCES `Calibration` (`idcalibration` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_PickedGCP_GCP1`
    FOREIGN KEY (`gcp` , `station` )
    REFERENCES `GCP` (`idgcp` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `TimeStack`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `TimeStack` ;

CREATE  TABLE IF NOT EXISTS `TimeStack` (
  `filename` VARCHAR(120) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `inittime` DECIMAL(17,10) NOT NULL ,
  `path` VARCHAR(200) NOT NULL ,
  `fps` DOUBLE NOT NULL ,
  `numFrames` INT NOT NULL ,
  INDEX `fk_TimeStack_Camera1_idx` (`camera` ASC, `station` ASC) ,
  PRIMARY KEY (`filename`) ,
  CONSTRAINT `fk_TimeStack_Camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `Camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `CalibrationParameter`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CalibrationParameter` ;

CREATE  TABLE IF NOT EXISTS `CalibrationParameter` (
  `id` VARCHAR(10) NOT NULL ,
  `calibration` VARCHAR(10) NOT NULL ,
  `name` VARCHAR(20) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_GeometryParameter_Calibration1_idx` (`calibration` ASC) ,
  CONSTRAINT `fk_GeometryParameter_Calibration1`
    FOREIGN KEY (`calibration` )
    REFERENCES `Calibration` (`idcalibration` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `CalibrationValue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CalibrationValue` ;

CREATE  TABLE IF NOT EXISTS `CalibrationValue` (
  `idparam` VARCHAR(10) NOT NULL ,
  `idcol` INT NOT NULL ,
  `idrow` INT NOT NULL ,
  `value` DOUBLE NOT NULL ,
  PRIMARY KEY (`idparam`, `idcol`, `idrow`) ,
  INDEX `fk_ParameterValue_GeometryParameter1_idx` (`idparam` ASC) ,
  CONSTRAINT `fk_ParameterValue_GeometryParameter1`
    FOREIGN KEY (`idparam` )
    REFERENCES `CalibrationParameter` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `ROI`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ROI` ;

CREATE  TABLE IF NOT EXISTS `ROI` (
  `idroi` VARCHAR(10) NOT NULL ,
  `idcalibration` VARCHAR(10) NOT NULL ,
  `type` VARCHAR(45) NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  PRIMARY KEY (`idroi`) ,
  INDEX `fk_ROI_Calibration1_idx` (`idcalibration` ASC) ,
  CONSTRAINT `fk_ROI_Calibration1`
    FOREIGN KEY (`idcalibration` )
    REFERENCES `Calibration` (`idcalibration` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `Fusion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Fusion` ;

CREATE  TABLE IF NOT EXISTS `Fusion` (
  `id` VARCHAR(10) NOT NULL ,
  `timestamp` DECIMAL(17,10) NOT NULL ,
  `type` VARCHAR(15) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `ROICoordinate`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ROICoordinate` ;

CREATE  TABLE IF NOT EXISTS `ROICoordinate` (
  `idroi` VARCHAR(10) NOT NULL ,
  `idcoord` INT NOT NULL AUTO_INCREMENT ,
  `u` DOUBLE NOT NULL ,
  `v` DOUBLE NOT NULL ,
  PRIMARY KEY (`idcoord`, `idroi`) ,
  INDEX `fk_ROICoordinate_ROI1_idx` (`idroi` ASC) ,
  CONSTRAINT `fk_ROICoordinate_ROI1`
    FOREIGN KEY (`idroi` )
    REFERENCES `ROI` (`idroi` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `MeasurementValue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `MeasurementValue` ;

CREATE  TABLE IF NOT EXISTS `MeasurementValue` (
  `idmeasurement` INT NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `idcol` INT NOT NULL ,
  `idrow` INT NOT NULL ,
  `iddepth` INT NOT NULL ,
  `value` DOUBLE NOT NULL ,
  PRIMARY KEY (`idmeasurement`, `station`, `idcol`, `idrow`, `iddepth`) ,
  INDEX `fk_MeasurementValue_Measurement1_idx` (`idmeasurement` ASC, `station` ASC) ,
  CONSTRAINT `fk_MeasurementValue_Measurement1`
    FOREIGN KEY (`idmeasurement` , `station` )
    REFERENCES `Measurement` (`idmeasurement` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `CameraByFusion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CameraByFusion` ;

CREATE  TABLE IF NOT EXISTS `CameraByFusion` (
  `idfusion` VARCHAR(10) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `sequence` INT NOT NULL ,
  PRIMARY KEY (`idfusion`, `camera`, `station`) ,
  INDEX `fk_CameraByFusion_Camera1_idx` (`camera` ASC, `station` ASC) ,
  CONSTRAINT `fk_CameraByFusion_Fusion1`
    FOREIGN KEY (`idfusion` )
    REFERENCES `Fusion` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_CameraByFusion_Camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `Camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `FusionParameter`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `FusionParameter` ;

CREATE  TABLE IF NOT EXISTS `FusionParameter` (
  `id` VARCHAR(10) NOT NULL ,
  `idfusion` VARCHAR(10) NOT NULL ,
  `name` VARCHAR(10) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_FusionMatrix_Fusion1_idx` (`idfusion` ASC) ,
  CONSTRAINT `fk_FusionMatrix_Fusion1`
    FOREIGN KEY (`idfusion` )
    REFERENCES `Fusion` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `FusionValue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `FusionValue` ;

CREATE  TABLE IF NOT EXISTS `FusionValue` (
  `idmatrix` VARCHAR(10) NOT NULL ,
  `idcol` INT NOT NULL ,
  `idrow` INT NOT NULL ,
  `value` DOUBLE NOT NULL ,
  PRIMARY KEY (`idmatrix`, `idcol`, `idrow`) ,
  INDEX `fk_FusionValue_FusionMatrix1_idx` (`idmatrix` ASC) ,
  CONSTRAINT `fk_FusionValue_FusionMatrix1`
    FOREIGN KEY (`idmatrix` )
    REFERENCES `FusionParameter` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `RectifiedImage`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `RectifiedImage` ;

CREATE  TABLE IF NOT EXISTS `RectifiedImage` (
  `filename` VARCHAR(120) NOT NULL ,
  `calibration` VARCHAR(10) NOT NULL ,
  INDEX `fk_RectifiedImage_Calibration1_idx` (`calibration` ASC) ,
  PRIMARY KEY (`filename`) ,
  INDEX `index_filename` USING HASH (`filename` ASC) ,
  CONSTRAINT `fk_RectifiedImage_Calibration1`
    FOREIGN KEY (`calibration` )
    REFERENCES `Calibration` (`idcalibration` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_RectifiedImage_Image1`
    FOREIGN KEY (`filename` )
    REFERENCES `Image` (`filename` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `MergedImage`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `MergedImage` ;

CREATE  TABLE IF NOT EXISTS `MergedImage` (
  `filename` VARCHAR(120) NOT NULL ,
  `idfusion` VARCHAR(10) NOT NULL ,
  INDEX `fk_FusionImage_Fusion1_idx` (`idfusion` ASC) ,
  PRIMARY KEY (`filename`) ,
  INDEX `index_filename` USING HASH (`filename` ASC) ,
  CONSTRAINT `fk_FusionImage_Fusion1`
    FOREIGN KEY (`idfusion` )
    REFERENCES `Fusion` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_MergedImage_Image1`
    FOREIGN KEY (`filename` )
    REFERENCES `Image` (`filename` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;


-- -----------------------------------------------------
-- Table `AutomaticParams`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `AutomaticParams` ;

CREATE  TABLE IF NOT EXISTS `AutomaticParams` (
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
  INDEX `fk_AutomaticParams_Station1_idx` (`station` ASC) ,
  PRIMARY KEY (`idauto`) ,
  CONSTRAINT `fk_AutomaticParams_Station1`
    FOREIGN KEY (`station` )
    REFERENCES `Station` (`name` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci
COMMENT = 'El atributo \"type\" puede ser \"image\", \"stack\", \"transfer\", \" /* comment truncated */ /*process".*/';


-- -----------------------------------------------------
-- Table `CommonPoint`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CommonPoint` ;

CREATE  TABLE IF NOT EXISTS `CommonPoint` (
  `idfusion` VARCHAR(10) NOT NULL ,
  `camera` VARCHAR(10) NOT NULL ,
  `station` VARCHAR(45) NOT NULL ,
  `name` VARCHAR(15) NOT NULL ,
  `u` DOUBLE NOT NULL ,
  `v` DOUBLE NOT NULL ,
  PRIMARY KEY (`idfusion`, `camera`, `station`, `name`) ,
  INDEX `fk_CommonPoint_Fusion1_idx` (`idfusion` ASC) ,
  INDEX `fk_CommonPoint_Camera1_idx` (`camera` ASC, `station` ASC) ,
  CONSTRAINT `fk_CommonPoint_Fusion1`
    FOREIGN KEY (`idfusion` )
    REFERENCES `Fusion` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_CommonPoint_Camera1`
    FOREIGN KEY (`camera` , `station` )
    REFERENCES `Camera` (`id` , `station` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_spanish_ci;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
