(********************************************************************
 * COPYRIGHT --  Automation Resources Group
 ********************************************************************
 * Library: TempLib
 * File: TempSensor.typ
 * Author: David
 * Created: January 13, 2011
 ********************************************************************
 * Data types of library TempLib
 ********************************************************************)

TYPE
	TempSensor_OUT_typ : 	STRUCT 
		ActTempC : REAL;
		ActTempF : REAL;
	END_STRUCT;
	TempSensor_IN_typ : 	STRUCT 
		TempInput : INT;
	END_STRUCT;
	TempSensor_typ : 	STRUCT 
		IN : TempSensor_IN_typ;
		OUT : TempSensor_OUT_typ;
	END_STRUCT;
END_TYPE
