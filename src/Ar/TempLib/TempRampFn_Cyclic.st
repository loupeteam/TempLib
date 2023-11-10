(*
 * File: TempRampFn_Cyclic.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of TempLib, licensed under the MIT License.
 *
 *)


(********************************************************************)	
(* Cyclic function for controlling temperature setpoint ramping 	*)
(********************************************************************)	


(* State independent input parameter mapping	DONE and TESTED DFB 20110908 *)
(* Error checking								DONE and TESTED DFB 20100726 *)

(* Main state machine							DONE and TESTED DFB 20100726 *)
	(* Disabled									DONE and TESTED DFB 20100726 *)
		(* Setting inputs and outputs			DONE and TESTED DFB 20100726 *)
		(* Transition							DONE and TESTED DFB 20100726 *)
	(* Enabled									DONE and TESTED DFB 20100726 *)
		(* Setting inputs and outputs			DONE and TESTED DFB 20100726 *)
		(* Transition							DONE and TESTED DFB 20100726 *)
	

FUNCTION TempRampFn_Cyclic


(************************************************************)
(* Set return value to get rid of compile warning 			*)
(************************************************************)

TempRampFn_Cyclic:=	FALSE;


(****************************************************************)
(* Map state independent Ramp FUB input values					*)
(****************************************************************)

t.Internal.RampFUB.x:=			t.IN.PAR.SetTemp;
t.Internal.RampFUB.dy_up:=		t.IN.CFG.RampRateUp;
t.Internal.RampFUB.dy_down:=	t.IN.CFG.RampRateDown;
t.Internal.RampFUB.y_max:=		t.IN.CFG.MaxTemp;
t.Internal.RampFUB.y_min:=		t.IN.CFG.MinTemp;


(****************************************************************)
(* Main state machine											*)
(****************************************************************)

CASE t.Internal.State OF


	TEMPRAMP_ST_DISABLED:
	

		(* Disable Ramp FUB *)
		
		t.Internal.RampFUB.enable:=	0;
		t.Internal.RampFUB.y_set:=	0;
		t.Internal.RampFUB.set:=	0;

				
		(* Set disabled outputs *)
		
		t.OUT.RampedSetTemp:=	0;
		
		t.OUT.STAT.Error:=		0;
		t.OUT.STAT.ErrorID:=	0;
	
		
		(* If ramping is enabled, then start ramp from ActTemp and go to SetTemp *)
		
		IF( t.IN.CMD.Enable )THEN
				
			t.Internal.RampFUB.enable:=	1;
			t.Internal.RampFUB.y_set:=	t.IN.PAR.ActTemp;
			t.Internal.RampFUB.set:=	1;
			
			t.Internal.State:=	TEMPRAMP_ST_ENABLED;
    
  		END_IF
		
	
	TEMPRAMP_ST_ENABLED:
	
	
		(* Enable Ramp FUB *)
		
		t.Internal.RampFUB.enable:=	1;
		t.Internal.RampFUB.y_set:=	t.IN.PAR.SetTemp;
		t.Internal.RampFUB.set:=	t.IN.CMD.SetNow;

				
		(* Set enabled outputs *)
		
		t.OUT.RampedSetTemp:=	t.Internal.RampFUB.y;
		
		
		(* If FUB is enabled and there is an error, set Error status output *)
		
		IF( (t.Internal.RampFUB.status < TC_STATUS_FUB_DISABLED)	AND
			(t.Internal.RampFUB.status >= LCR_ERROR)				)THEN
 
		 	t.OUT.STAT.Error:=	1;
	
		ELSE
		
			t.OUT.STAT.Error:=	0;
	
		END_IF
		
		
		(* Map FUB status out through ErrorID status output at all times *)
		
		t.OUT.STAT.ErrorID:=	t.Internal.RampFUB.status;
	
		
		(* If ramping is disabled, then disable ramp FUB *)
		
		IF( NOT(t.IN.CMD.Enable) )THEN
				
			t.Internal.RampFUB.enable:=	0;
			t.Internal.RampFUB.y_set:=	0;
			t.Internal.RampFUB.set:=	0;
			
			t.Internal.State:=	TEMPRAMP_ST_DISABLED;
    
  		END_IF		
	
	
END_CASE


(********************************************************************)
(* Call Ramp FUB 													*)
(********************************************************************)

t.Internal.RampFUB();


END_FUNCTION
