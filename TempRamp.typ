(********************************************************************
 * COPYRIGHT --  Automation Resources Group
 ********************************************************************
 * Library: Temp_Lib
 * File: TempRamp.typ
 * Author: David
 * Created: July 21, 2010
 ********************************************************************
 * Data types of library Temp_Lib
 ********************************************************************)

TYPE
	TempRamp_ST_enum : 
		(
		TEMPRAMP_ST_DISABLED,
		TEMPRAMP_ST_ENABLED
		);
	TempRamp_Internal_typ : 	STRUCT 
		RampFUB : LCRRamp;
		State : DINT;
	END_STRUCT;
	TempRamp_OUT_STAT_typ : 	STRUCT 
		Error : BOOL;
		ErrorID : UINT;
	END_STRUCT;
	TempRamp_OUT_typ : 	STRUCT 
		STAT : TempRamp_OUT_STAT_typ;
		RampedSetTemp : REAL; (*Ramped set temperature [°C]*)
	END_STRUCT;
	TempRamp_IN_CFG_typ : 	STRUCT 
		RampRateUp : REAL; (*Temperature ramp rate for increasing temperature [°C/s]*)
		RampRateDown : REAL; (*Temperature ramp rate for decreasing temperature [°C/s]*)
		MinTemp : REAL; (*Minimum output temperature [°C]*)
		MaxTemp : REAL; (*Maximum output temperature [°C]*)
	END_STRUCT;
	TempRamp_IN_PAR_typ : 	STRUCT 
		SetTemp : REAL; (*Set temperature [°C]*)
		ActTemp : REAL; (*Actual temperature (this will serve as the starting point for the ramp upon enable) [°C]*)
	END_STRUCT;
	TempRamp_IN_CMD_typ : 	STRUCT 
		Enable : BOOL; (*Enable temperature setpoint ramping*)
		SetNow : BOOL; (*Pass the set temperature through immediately with no ramping (enable must also be set)*)
	END_STRUCT;
	TempRamp_IN_typ : 	STRUCT 
		CMD : TempRamp_IN_CMD_typ;
		PAR : TempRamp_IN_PAR_typ;
		CFG : TempRamp_IN_CFG_typ;
	END_STRUCT;
	TempRamp_typ : 	STRUCT 
		IN : TempRamp_IN_typ;
		OUT : TempRamp_OUT_typ;
		Internal : TempRamp_Internal_typ;
	END_STRUCT;
END_TYPE
