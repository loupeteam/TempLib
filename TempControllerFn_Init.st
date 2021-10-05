(********************************************************************
 * COPYRIGHT --  Automation Resources Group
 ********************************************************************
 * Library: Temp_Lib
 * File: TempControllerFn_Init.st
 * Author: blackburnd
 * Created: April 02, 2009
 *******************************************************************)


(****************************************************************************)
(* Function to initialize a temperature control zone						*)
(****************************************************************************)


FUNCTION TempControllerFn_Init


(************************************************************)
(* Set return value to get rid of compile warning 			*)
(************************************************************)

TempControllerFn_Init:=	FALSE;


(********************************************************************)
(* Call TempTune with enable = 1 once to initialize internal memory	*)
(********************************************************************)

t.Internal.FUB.TempTune.enable:=		1;
t.Internal.FUB.TempTune.start:=			0;
t.Internal.FUB.TempTune.pSettings:=		ADR(t.IN.PAR.Settings);

t.Internal.FUB.TempTune();

t.Internal.FUB.TempTune.enable:=	0;


END_FUNCTION
