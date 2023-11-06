(*
 * File: TempSensorFn_Cyclic.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of TempLib, licensed under the MIT License.
 *
 *)


(********************************************************************)
(* Handles analog temperature sensors		 						*)
(********************************************************************)


(* Functionality			DONE and TESTED DFB 20110908 *)


FUNCTION TempSensorFn_Cyclic


(************************************************************)
(* Set return value to get rid of compile warning 			*)
(************************************************************)

TempSensorFn_Cyclic:=	FALSE;


(************************************************************)
(* Convert input to output						 			*)
(************************************************************)

t.OUT.ActTempC:=	INT_TO_REAL(t.IN.TempInput) / 10.0;

t.OUT.ActTempF:=	C_to_F( t.OUT.ActTempC );


END_FUNCTION
