(*
 * File: TempSensor.typ
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of TempLib, licensed under the MIT License.
 *
 *)

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
