(*
 * File: TempControllerFn_Cyclic.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of TempLib, licensed under the MIT License.
 *
 *)


(****************************************************************************************************)
(* This function implements a temperature controller with autotune using LCRTempPID and LCRTempTune	*)
(****************************************************************************************************)
		

(* Handling TEST interface			DONE and TESTED DFB 20110908 *)
		
(* Map state independent inputs		DONE and TESTED DFB 20110908 *)
	(* CMD.Update					DONE and TESTED DFB 20110908 *)
	(* Others						DONE and TESTED DFB 20110908 *)

(* Main state machine				DONE and TESTED DFB 20110908 *)
	
	(* ST_OFF						DONE and TESTED DFB 20110908 *)
		(* Status					DONE and TESTED DFB 20110908 *)
		(* Enable FUBs				DONE and TESTED DFB 20110908 *)
		(* Check CMD.Enable			DONE and TESTED DFB 20110908 *)
		(* Check CMD.StartAutotune	DONE and TESTED DFB 20110908 *)
			(* Status				DONE and TESTED DFB 20110908 *)
			(* State transition		DONE and TESTED DFB 20110908 *)
		
	(* ST_ON						DONE and TESTED DFB 20110908 *)
		(* Status					DONE and TESTED DFB 20110908 *)
		(* Enable FUBs				DONE and TESTED DFB 20110908 *)
		(* Check CMD.Enable			DONE and TESTED DFB 20110908 *)
			(* State transition		DONE and TESTED DFB 20110908 *)
		(* Check CMD.StartAutotune	DONE and TESTED DFB 20110908 *)
			(* Status				DONE and TESTED DFB 20110908 *)
			(* State transition		DONE and TESTED DFB 20110908 *)
		
	(* ST_TUNE						DONE and TESTED DFB 20110908 *)
		(* Status					DONE and TESTED DFB 20110908 *)
		(* Enable FUBs				DONE and TESTED DFB 20110908 *)
		(* Check CMD.AbortAutotune	DONE and TESTED DFB 20110908 *)
			(* State transition		DONE and TESTED DFB 20110908 *)
		(* Check Tune Done			DONE and TESTED DFB 20110908 *)
			(* Enable FUBs			DONE and TESTED DFB 20110908 *)
			(* Status				DONE and TESTED DFB 20110908 *)
			(* State transition		DONE and TESTED DFB 20110908 *)
		
	(* ST_TUNEDONE					DONE and TESTED DFB 20110908 *)
		(* Status					DONE and TESTED DFB 20110908 *)
		(* Enable FUBs				DONE and TESTED DFB 20110908 *)
		(* Check Tune CMDs			DONE and TESTED DFB 20110908 *)
		
(* Set status outputs				DONE and TESTED DFB 20110908 *)

(* ExtendedTuningStatus handling	DONE and TESTED DFB 20110908 *)
	(* Enabled						DONE and TESTED DFB 20110908 *)
	(* Not enabled					DONE and TESTED DFB 20110908 *)

(* Set percentage outputs			DONE and TESTED DFB 20110908 *)

(* Error handling					DONE and TESTED DFB 20110908 *)
	(* Setting Error, ErrorID		DONE and TESTED DFB 20110908 *)
		(* TempPID enabled			DONE and TESTED DFB 20110908 *)
		(* TempTune enabled			DONE and TESTED DFB 20110908 *)
		(* Neither enabled			DONE and TESTED DFB 20110908 *)
		(* Diff errors				DONE IMPOSSIBLE *)
		(* PT2 errors				DONE IMPOSSIBLE *)
	(* Acknowledging				DONE and TESTED DFB 20110908 *)
	(* Handling TempPID enable		DONE and TESTED DFB 20110908 *)
	

FUNCTION TempControllerFn_Cyclic


(****************************************************)
(* Set return value to get rid of compile warning 	*)
(****************************************************)

TempControllerFn_Cyclic:=	FALSE;


(****************************************************)
(* Handle TEST interface							*)
(****************************************************)

IF( t.TEST.Enable )THEN


	(* Overwrite IN.CMDs and IN.PARs while in TEST mode *)

	t.IN.CMD:=	t.TEST.CMD;
	t.IN.PAR:=	t.TEST.PAR;	

ELSE


    (* Clear TEST.CMDs and load TEST.PARs from machine while not in TEST mode *)
	
	brsmemset( ADR(t.TEST.CMD), 0, SIZEOF(t.TEST.CMD));
	t.TEST.PAR:=	t.IN.PAR;

END_IF


(****************************************)
(* Map state independent inputs to FUBs *)
(****************************************)


(****************************************)
(* TempPID *)

//t.Internal.FUB.TempPID.enable:=	0;

t.Internal.FUB.TempPID.Temp_set:=	t.IN.PAR.SetTemp;
t.Internal.FUB.TempPID.Temp:=		t.IN.PAR.ActTemp;
t.Internal.FUB.TempPID.Y_man:=		t.IN.PAR.Y_man;
t.Internal.FUB.TempPID.mode:=		t.IN.PAR.Mode;
t.Internal.FUB.TempPID.update:=		t.IN.CMD.Update;
t.Internal.FUB.TempPID.pSettings:=	ADR(t.IN.PAR.Settings);


(* Reset CMD.Update *)

t.IN.CMD.Update:=	0;


(****************************************)
(* TempTune *)

//t.Internal.FUB.TempTune.enable:=		t.IN.PAR.enable;
//t.Internal.FUB.TempTune.start:=		t.IN.PAR.start;

t.Internal.FUB.TempTune.Temp_set:=		t.IN.PAR.SetTemp;
t.Internal.FUB.TempTune.Temp:=			t.IN.PAR.ActTemp;
t.Internal.FUB.TempTune.okToHeat:=		t.IN.CMD.okToHeat;
t.Internal.FUB.TempTune.okToFree:=		t.IN.CMD.okToFree;
t.Internal.FUB.TempTune.okToFreeEnd:=	t.IN.CMD.okToFreeEnd;
t.Internal.FUB.TempTune.okToCool:=		t.IN.CMD.okToCool;
t.Internal.FUB.TempTune.okToCoolEnd:=	t.IN.CMD.okToCoolEnd;
t.Internal.FUB.TempTune.pSettings:=		ADR(t.IN.PAR.Settings);


(****************************************)
(* Check for FUB errors 				*)
(****************************************)
		
		
(****************************************)
(* TempPID, TempTune *)


IF( t.Internal.FUB.TempPID.status < TC_STATUS_FUB_DISABLED) THEN
	

	(* take status if FUB is enabled *)
	(* this will set ErrorID appropriately no matter what the status is 
		(0, error, warning) *)

	t.OUT.STAT.ErrorID:=	t.Internal.FUB.TempPID.status;
	

	(* if an error, trap and go to error state *)

	IF( t.Internal.FUB.TempPID.status >= LCR_ERROR )THEN
		
		t.Internal.TempPIDError:=	1;
		
		t.OUT.STAT.Error:=		1;
		t.OUT.STAT.ErrorState:=	t.Internal.State;
		
	END_IF (* error or warning *)		


ELSIF( t.Internal.FUB.TempTune.status < TC_STATUS_FUB_DISABLED) THEN
	
	
	(* take status if FUB is enabled *)
	(* this will set ErrorID appropriately no matter what the status is 
		(0, error, warning) *)
	
	t.OUT.STAT.ErrorID:=	t.Internal.FUB.TempTune.status;
	
	
	(* if an error, trap and go to error state *)
	
	IF( t.Internal.FUB.TempTune.status >= LCR_ERROR )THEN
	
		t.OUT.STAT.Error:=		1;
		t.OUT.STAT.ErrorState:=	t.Internal.State;
		
	END_IF (* error or warning *)	
	

ELSE		
	
	
	(* Neither TempPID nor TempTune are enabled *)
	(* Reset any warnings *)
	(* Any previous errors will be kept *)
	(* Any errors on Diff or PT2 will overwrite this below *)
	
	IF( NOT(t.OUT.STAT.Error) )THEN
	
		t.OUT.STAT.ErrorID:=	0;
		
	END_IF
	
END_IF
		

(****************************************)
(* Diff *)
		

(* if enabled and error *)

IF( 	(t.Internal.FUB.Diff.status < TC_STATUS_FUB_DISABLED)
	AND	(t.Internal.FUB.Diff.status >= LCR_ERROR)
 	)THEN
	
	t.OUT.STAT.Error:=		1;
	t.OUT.STAT.ErrorID:=	t.Internal.FUB.Diff.status;
	
END_IF


(****************************************)
(* PT2 *)
		

(* if enabled and error *)

IF( 	(t.Internal.FUB.PT2.status < TC_STATUS_FUB_DISABLED)
	AND	(t.Internal.FUB.PT2.status >= LCR_ERROR)
 	)THEN
	
	t.OUT.STAT.Error:=		1;
	t.OUT.STAT.ErrorID:=	t.Internal.FUB.PT2.status;
	
END_IF


(****************************************)
(* Main State Machine					*)
(****************************************)

CASE t.Internal.State OF

	
	TC_ST_OFF:
		
		
		(* Set Status appropriately *)
		
		t.OUT.STAT.Tuning.Active:=	0;
		t.OUT.STAT.Tuning.Done:=	0;
		
		
		(* Enable inputs *)
		
		t.Internal.FUB.TempPID.enable:=		0;
		
		t.Internal.FUB.TempTune.enable:=	0;
		t.Internal.FUB.TempTune.start:=		0;

		
		(****************************************)
		(* External EnableControl input			*)
		(****************************************)
				
		
		(* if you are enabled go to TC_ST_ON *)
		
		IF( t.IN.CMD.EnableControl )THEN
	
			t.Internal.State:=	TC_ST_ON;
	
		END_IF			
		

		(****************************************)
		(* Check for Tune CMD *)
		
		IF( t.IN.CMD.StartAutotune ) THEN
  			
			
			(* switch to TempTune and give a start command *)
			
			t.Internal.FUB.TempPID.enable:=		0;
			
			t.Internal.FUB.TempTune.enable:=	1;
			t.Internal.FUB.TempTune.start:=		1;
			
			
			(* update tuning status *)
			
			t.OUT.STAT.Tuning.Active:=	1;
			t.OUT.STAT.Tuning.Done:=	0;
			
			t.Internal.State:=			TC_ST_TUNE;
			
			
		END_IF
		
	
	TC_ST_ON:

		
		(* set Status appropriately *)
		
		t.OUT.STAT.Tuning.Active:=	0;
		t.OUT.STAT.Tuning.Done:=	0;
		
		
		(* enable TempPID, but not TempTune *)
		
		t.Internal.FUB.TempPID.enable:=		1;
		
		t.Internal.FUB.TempTune.enable:=	0;
		t.Internal.FUB.TempTune.start:=		0;
	
	
		(****************************************)
		(* External EnableControl input			*)
		(****************************************)
		
		(* if not enabled, go to TC_ST_OFF *)
		
		IF( NOT(t.IN.CMD.EnableControl) ) THEN

			t.Internal.State:=	TC_ST_OFF;

		END_IF		
		
		
		(****************************************)
		(* Check for Tune CMD *)
		
		IF( t.IN.CMD.StartAutotune ) THEN
  			
			
			(* switch to TempTune and give a start command *)
			
			t.Internal.FUB.TempPID.enable:=		0;
			
			t.Internal.FUB.TempTune.enable:=	1;
			t.Internal.FUB.TempTune.start:=		1;
			
			
			(* update tuning status *)
			
			t.OUT.STAT.Tuning.Active:=	1;
			t.OUT.STAT.Tuning.Done:=	0;
			
			t.Internal.State:=			TC_ST_TUNE;
			
			
		END_IF
		
	
	TC_ST_TUNE:

		
		(* set Status appropriately *)
		
		t.OUT.STAT.Tuning.Active:=	1;
		t.OUT.STAT.Tuning.Done:=	0;
	
		
		(* enable TempTune, but not TempPID *)
		
		t.Internal.FUB.TempPID.enable:=	0;
		
		t.Internal.FUB.TempTune.enable:=	1;
		t.Internal.FUB.TempTune.start:=		1;
	
		
		(****************************************)
		(* External EnableControl input			*)
		(****************************************)

		(* EnableControl not monitored while tuning *)


		(****************************************)
		(* watch for AbortAutotune command *)
		
		IF( t.IN.CMD.AbortAutotune ) THEN
			
		
			t.IN.CMD.StartAutotune:=	0;
			t.IN.CMD.AbortAutotune:=	0;	
  			
		
			(* if enabled, then go to TC_ST_ON, if not enabled, go to TC_ST_OFF *)		
		
			IF( t.IN.CMD.EnableControl ) THEN
   				t.Internal.State:=	TC_ST_ON;
			ELSE
				t.Internal.State:=	TC_ST_OFF;
			END_IF
		
			
		END_IF (* AbortAutotune *)
		
		
		(****************************************)
		(* watch for tune done *)
		
		(* if done, then switch back to TempPID, update tuning status and go to tune done state *)
		(* This means that if the StartAutoTune cmd is high and EnableControl is low, you will still 
			control until StartAutoTune goes low.  I am okay with that *)
		
		IF( t.Internal.FUB.TempTune.done ) THEN
  			
			t.Internal.FUB.TempPID.enable:=		1;
			
			t.Internal.FUB.TempTune.enable:=	0;
			t.Internal.FUB.TempTune.start:=		0;
			
			t.OUT.STAT.Tuning.Active:=			0;
			t.OUT.STAT.Tuning.Done:=			1;
			
			t.Internal.State:=	TC_ST_TUNEDONE;
			
		END_IF	
		
	
	TC_ST_TUNEDONE:

		
		(* set Status appropriately *)
		
		t.OUT.STAT.Tuning.Active:=	0;
		t.OUT.STAT.Tuning.Done:=	1;
	
		
		(* enable TempPID, but not TempTune *)
		
		t.Internal.FUB.TempPID.enable:=	1;
		
		t.Internal.FUB.TempTune.enable:=	0;
		t.Internal.FUB.TempTune.start:=		0;
	
		
		(****************************************)
		(* External EnableControl input			*)
		(****************************************)
		
		(* EnableControl not monitored while tuning *)

		
		(****************************************)		
		(* watch for tune cmd to go away or AbortAutoTune command *)
			
		IF( NOT(t.IN.CMD.StartAutotune) OR t.IN.CMD.AbortAutotune ) THEN
  			
		
			t.IN.CMD.StartAutotune:=	0;
			t.IN.CMD.AbortAutotune:=	0;	
  			
		
			(* if enabled, then go to TC_ST_ON, if not enabled, go to TC_ST_OFF *)		
		
			IF( t.IN.CMD.EnableControl ) THEN
   				t.Internal.State:=	TC_ST_ON;
			ELSE
				t.Internal.State:=	TC_ST_OFF;
			END_IF
		
			
		END_IF
		
		
//	TC_ST_ERROR:
//
//		
//		(* set Status appropriately *)
//		
//		t.OUT.STAT.Tuning.Active:=	0;
//		t.OUT.STAT.Tuning.Done:=	0;
//		
//		
//		(* turn off internal FUBs *)
//		
//		t.Internal.FUB.TempPID.enable:=		0;
//		
//		t.Internal.FUB.TempTune.enable:=	0;
//		t.Internal.FUB.TempTune.start:=		0;
//		
//		
//		(* only way to recover from errors is to cycle enable input *)
//		(* This might not be a good idea, but it will stay for now *)
//		(* other solutions would be more complex *)
//		
//		
//		(****************************************)
//		(* External EnableControl input			*)
//		(****************************************)
//		
//		
//		(* if not enabled, go to TC_ST_OFF *)
//		
//		IF( NOT(t.IN.CMD.EnableControl) AND NOT(t.IN.CMD.StartAutotune) ) THEN
//
//			t.Internal.State:=	TC_ST_OFF;
//
//		END_IF		
	
END_CASE


(****************************************)
(* Call FUBs							*)
(****************************************)


(* Disable TempPID if TempPIDError is TRUE *)

IF( t.Internal.TempPIDError )THEN

	t.Internal.FUB.TempPID.enable:=	0;
	
END_IF


t.Internal.FUB.TempPID();
t.Internal.FUB.TempTune();
t.Internal.FUB.Diff();
t.Internal.FUB.PT2();


(****************************************)
(* Handle AcknowledgeError CMD			*)
(****************************************)

IF( t.IN.CMD.AcknowledgeError )THEN
	
	t.Internal.TempPIDError:=	0;
	
	t.OUT.STAT.Error:=		0;
	t.OUT.STAT.ErrorID:=	0;
	t.OUT.STAT.ErrorState:=	0;
	
END_IF


t.IN.CMD.AcknowledgeError:=	0;


(****************************************)
(* Set outputs							*)
(****************************************)

(****************************************)
(* Status outputs *)

t.OUT.STAT.ActTemp:=		t.IN.PAR.ActTemp;
t.OUT.STAT.SetTemp:=		t.IN.PAR.SetTemp;
t.OUT.STAT.TempDeviation:=	t.IN.PAR.ActTemp - t.IN.PAR.SetTemp;


t.OUT.STAT.Tuning.rdyToHeat:=		t.Internal.FUB.TempTune.rdyToHeat;
t.OUT.STAT.Tuning.rdyToFree:=		t.Internal.FUB.TempTune.rdyToFree;
t.OUT.STAT.Tuning.rdyToFreeEnd:=	t.Internal.FUB.TempTune.rdyToFreeEnd;
t.OUT.STAT.Tuning.rdyToCool:=		t.Internal.FUB.TempTune.rdyToCool;
t.OUT.STAT.Tuning.rdyToCoolEnd:=	t.Internal.FUB.TempTune.rdyToCoolEnd;

t.OUT.STAT.Tuning.State:=	t.Internal.FUB.TempTune.step;


(* Extended tuning status *)

IF( t.IN.PAR.EnableExtendedTuningStatus )THEN


	(* TempGradient *)
	
	t.Internal.FUB.Diff.enable:=	1;
	t.Internal.FUB.Diff.x:=			t.IN.PAR.ActTemp;
	t.Internal.FUB.Diff.tv:=		1.0;
	
	(* If no filter time is set, default to 25s, like TempTune *)
	
	IF( t.IN.PAR.Settings.TuneSet.filter_base_T = 0 )THEN
 		
		t.Internal.FUB.Diff.tf:=	25.0;
		
	ELSE
		
		t.Internal.FUB.Diff.tf:=	t.IN.PAR.Settings.TuneSet.filter_base_T;
		
	END_IF
	
	
	(* Set TempGradient regardless of status *)
	(* If no error, then gradient will update properly *)
	(* If error, then gradient will be 0 *)
	
	t.OUT.STAT.Tuning.FilteredTempGradient:=	t.Internal.FUB.Diff.y;
	
	
	(* FilteredActTemp *)
	
	t.Internal.FUB.PT2.enable:=	1;
	t.Internal.FUB.PT2.V:=		1.0;
	t.Internal.FUB.PT2.D:=		0.875;
	
	
	(* If no filter time is set, default to 25s, like TempTune *)
	
	IF( t.IN.PAR.Settings.TuneSet.filter_base_T = 0 )THEN
 		
		t.Internal.FUB.PT2.Tf:=	25.0;
		
	ELSE
		
		t.Internal.FUB.PT2.Tf:=	t.IN.PAR.Settings.TuneSet.filter_base_T;
		
	END_IF
	
	t.Internal.FUB.PT2.u:=		t.IN.PAR.ActTemp;
	t.Internal.FUB.PT2.Set_y:=	0;
	t.Internal.FUB.PT2.y_set:=	0;
	
	
	(* Set FilteredActTemp regardless of status *)
	(* Filtered temp will be updated even with errors *)
	
	t.OUT.STAT.Tuning.FilteredActTemp:=	t.Internal.FUB.PT2.y;
	
	
ELSE
	
	t.Internal.FUB.Diff.enable:=	0;
	t.Internal.FUB.PT2.enable:=		0;
	
	t.OUT.STAT.Tuning.FilteredTempGradient:=	0;
	t.OUT.STAT.Tuning.FilteredActTemp:=			0;
	
END_IF


(****************************************)
(* Percentage outputs *)

IF( t.Internal.FUB.TempPID.enable ) THEN

	t.OUT.PercentCool:=	t.Internal.FUB.TempPID.y_cool;
	t.OUT.PercentHeat:=	t.Internal.FUB.TempPID.y_heat;

ELSIF( t.Internal.FUB.TempTune.enable ) THEN

	t.OUT.PercentCool:=	t.Internal.FUB.TempTune.y_cool;
	t.OUT.PercentHeat:=	t.Internal.FUB.TempTune.y_heat;

ELSE

	t.OUT.PercentCool:=	0;
	t.OUT.PercentHeat:=	0;

END_IF


END_FUNCTION
