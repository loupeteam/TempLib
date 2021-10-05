(********************************************************************
 * COPYRIGHT -- Automation Resources Group
 ********************************************************************
 * Library: TempLib
 * File: TempController.typ
 * Author: David Blackburn
 * Created: December 21, 2011
 ********************************************************************
 * Data types of library TempLib
 ********************************************************************)

TYPE
	TempController_Int_FUB_typ : 	STRUCT  (*Temperature control FUBs*)
		TempPID : LCRTempPID;
		TempTune : LCRTempTune;
		Diff : LCRDifferentiate;
		PT2 : LCRPT2o;
	END_STRUCT;
	TempController_Internal_typ : 	STRUCT 
		FUB : TempController_Int_FUB_typ; (*FUBs for Temperature control*)
		State : UINT; (*State variable for temperature control*)
		TempPIDError : BOOL; (*An error was seen with the TempPID block. This will reset TempPID.enable until cleared by CMD.AcknowledgeError.*)
	END_STRUCT;
	TempController_TEST_typ : 	STRUCT 
		Enable : BOOL; (*Enable Test mode (Use Values from TEST.CMD and TEST.PAR)*)
		CMD : TempController_IN_CMD_typ;
		PAR : TempController_IN_PAR_typ;
	END_STRUCT;
	TempCont_OUT_STAT_Tuning_typ : 	STRUCT 
		Active : BOOL; (*Zone is currently performing an autotune*)
		Done : BOOL; (*Autotune successfully completed*)
		rdyToHeat : BOOL; (*TempTune rdyToHeat*)
		rdyToFree : BOOL; (*TempTune rdyToFree*)
		rdyToFreeEnd : BOOL; (*TempTune rdyToFreeEnd*)
		rdyToCool : BOOL; (*TempTune rdyToCool*)
		rdyToCoolEnd : BOOL; (*TempTune rdyToCoolEnd*)
		State : DINT; (*Tuning state. See TempTune FUB help for details.*)
		FilteredTempGradient : REAL; (*Filtered actual temperature gradient [°C/s]. Only available when IN.PAR.EnableExtendedTuneStatus is TRUE.*)
		FilteredActTemp : REAL; (*Filtered actual temperature [°C]. Only available when IN.PAR.EnableExtendedTuneStatus is TRUE.*)
	END_STRUCT;
	TempController_OUT_STAT_typ : 	STRUCT 
		ActTemp : REAL; (*Actual temperature [°C]*)
		SetTemp : REAL; (*Set temperature [°C]*)
		TempDeviation : REAL; (*Temperature deviation from setpoint*)
		Tuning : TempCont_OUT_STAT_Tuning_typ;
		Error : BOOL; (*There is an error with the temperature controller*)
		ErrorID : UINT; (*Error number from internal FUBs*)
		ErrorState : UINT; (*State in which error occurred*)
	END_STRUCT;
	TempController_OUT_typ : 	STRUCT 
		PercentHeat : REAL; (*Heating output effort [%]*)
		PercentCool : REAL; (*Cooling output effort [%]*)
		STAT : TempController_OUT_STAT_typ; (*Status*)
	END_STRUCT;
	TempController_IN_PAR_typ : 	STRUCT 
		SetTemp : REAL; (*Set temperature [°C]*)
		ActTemp : REAL; (*Actual temperature [°C]*)
		Y_man : REAL; (*Manual output percentage value*)
		Mode : UDINT; (*Controller mode (LCRTEMPPID_MODE_AUTO or LCRTEMPPID_MODE_MAN)*)
		Settings : lcrtemp_set_typ; (*Control settings.  See LoopConR library help for additional information.*)
		EnableExtendedTuningStatus : BOOL; (*When set, the TempGradient and FilteredActTemp variables will be updated. This increases the function's CPU load.*)
	END_STRUCT;
	TempController_IN_CMD_typ : 	STRUCT 
		EnableControl : BOOL; (*Enable temperature control*)
		StartAutotune : BOOL; (*Request an autotune.  Zone does not need to be enabled to tune.*)
		AbortAutotune : BOOL; (*Abort an autotune procedure. If StartAutotune is high when AbortAutotune is recognized, StartAutotune is RESET INTERNALLY.*)
		Update : BOOL; (*Update settings to LCRTempPID FUB.*)
		AcknowledgeError : BOOL; (*Acknowledge errors*)
		okToHeat : BOOL; (*TempTune okToHeat*)
		okToFree : BOOL; (*TempTune okToFree*)
		okToFreeEnd : BOOL; (*TempTune okToFreeEnd*)
		okToCool : BOOL; (*TempTune okToCool*)
		okToCoolEnd : BOOL; (*TempTune okToCoolEnd*)
	END_STRUCT;
	TempController_IN_typ : 	STRUCT 
		CMD : TempController_IN_CMD_typ; (*Commands*)
		PAR : TempController_IN_PAR_typ; (*Parameters*)
	END_STRUCT;
	TempController_typ : 	STRUCT  (*Generic Temperature PID zone*)
		IN : TempController_IN_typ; (*Inputs*)
		OUT : TempController_OUT_typ; (*Outputs*)
		TEST : TempController_TEST_typ;
		Internal : TempController_Internal_typ; (*Internal variables*)
	END_STRUCT;
END_TYPE
