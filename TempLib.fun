(********************************************************************
 * COPYRIGHT --  Automation Resources Group
 ********************************************************************
 * Library: TempLib
 * File: TempLib.fun
 * Author: Administrator
 * Created: July 16, 2010
 ********************************************************************
 * Functions and function blocks of library TempLib
 ********************************************************************)

FUNCTION TempSensorFn_Cyclic : BOOL (*Handles analog temperature sensors*)
	VAR_IN_OUT
		t : TempSensor_typ; (*TempSensor control structure*)
	END_VAR
END_FUNCTION

FUNCTION TempRampFn_Cyclic : BOOL (*Cyclic function for controlling temperature setpoint ramping*)
	VAR_IN_OUT
		t : TempRamp_typ; (*TempRamp control object*)
	END_VAR
END_FUNCTION

FUNCTION TempControllerFn_Init : BOOL (*This function calls the internal TempTune FUB once with enable=1 to allocate internal dynamic memory.*)
	VAR_IN_OUT
		t : TempController_typ; (*Variable of TempZone_typ which represents the temperature zone to be initialized.*)
	END_VAR
END_FUNCTION

FUNCTION TempControllerFn_Cyclic : BOOL (*This function implements a temperature controller with autotune using LCRTempPID and LCRTempTune.*)
	VAR_IN_OUT
		t : TempController_typ; (*Variable of TempZone_typ which represents the temperature zone to be controlled.*)
	END_VAR
END_FUNCTION
