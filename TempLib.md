![Automation Resources Group](http://automationresourcesgroup.com/images/arglogo254x54.png)

#TempLib Library
The TempLib library provides functionality related to temperature systems, including temperature sensor scaling, set point ramping, and closed loop control with autotuning.

Nearly every manufacturing process has some dependence on temperature. Whether it is a chemical process that needs to take place at a certain temperature or a pot of glue that needs to be kept hot, maintaining a steady temperature is crucial to success.

The TempLib library provides an easy to use interface for all of the most common tasks associated with temperature control systems, from set point generation to sensor monitoring and control.

#Usage
The TempLib functionality can be integrated into any project using data structures and function calls. For an example of how to use this in a project, please see the ARG Automation Studio Starter Project at [https://github.com/autresgrp/StarterProject](https://github.com/autresgrp/StarterProject).

##Temperature Sensors
The **TempSensorFn_Cyclic** function scales temperature sensor inputs from their default analog input scaling of 0.1 degrees Celsius to degrees Celsius and Fahrenheit. A variable should be declared of type **TempSensor_typ**, and the **TempSensor.IN.TempInput** element should be mapped to an analog input channel. After calling the **TempSensorFn_Cyclic** function, the actual temperatures will be available in the **TempSensor.OUT** structure.

	TempSensorFn_Cyclic( TempSensor );

##Set Point Ramping
The **TempRampFn_Cyclic** function ramps from one set point to another at a set ramp rate. The actual temperature is used as the initial value when enabling the ramp, preventing discontinuities in the downstream temperature control variables. It is possible to set minimum and maximum limits on the ramped set point, and different ramp rates are available for increasing and decreasing the set temperature. To use the **TempRampFn_Cyclic** function, a variable must be declared of type **TempRamp_typ**.

	TempRamp.IN.CMD.Enable:=	EnableTempRamp;
	
	TempRamp.IN.PAR.SetTemp:=	RecipeSetTemp;
	TempRamp.IN.PAR.ActTemp:=	TempSensor.OUT.ActTempC;
	
	TempRamp.IN.CFG.RampRateUp:=	TempRampRate;
	TempRamp.IN.CFG.RampRateDown:=	TempRampRate;
	TempRamp.IN.CFG.MinTemp:=		MinSetTemp;
	TempRamp.IN.CFG.MaxTemp:=		MaxSetTemp;
	
	TempRampFn_Cyclic( TempRamp );

##Temperature Control

###Initialization
To use the TempLib closed loop temperature control functionality, a variable must be declared of type **TempController_typ**. This variable must then be initialized in the INIT routine of your program by populating the **TempController.IN.PAR.Settings** structure and calling the **TempControllerFn_Init()** function. The **Settings** structure should typically be loaded from a file or data object on startup. Alternatively, the values can be set directly in the INIT routine of your program.

	(* Load Settings structure from file... *)
	
	TempControllerFn_Init( TempController );

###Cyclic Operation
The **TempControllerFn_Cyclic** function performs closed loop temperature control with autotuning. It should be noted that this function is tailored to temperature control, and it is not intended for performing other forms of closed loop control (pressure, speed, etc.). To use the **TempControllerFn_Cyclic** function, a variable must be declared of type **TempController_typ**, and that variable should be initialized using the **TempControllerFn_Init** function. The **TempControllerFn_Cyclic** function should be called in the CYCLIC routine of your program, once every scan, unconditionally.

	TempController.IN.CMD.EnableControl:=	EnableTempControl;
	
	TempController.IN.PAR.SetTemp:=	RecipeSetTemp;
	TempController.IN.PAR.ActTemp:=	TempSensor.OUT.ActTempC;

	TempControllerFn_Cyclic( TempController );

#Reference

##Temperature Sensor Data Structure

###Inputs
* **TempInput** - Input temperature in 0.1℃. This should typically be mapped to a thermocouple or RTD input module.

###Outputs
* **ActTempC** - Actual temperature scaled to degrees Celsius.
* **ActTempF** - Actual temperature scaled to degrees Fahrenheit.

##Set Point Ramping Data Structure
The TempRamp data structure provides the interface to higher level programs and also stores all necessary internal information for temperature set point ramping. It is divided into inputs (TempRamp.IN), outputs (TempRamp.OUT), and internals (TempRamp.Internal).

###Inputs
TempRamp inputs are divided into commands (IN.CMD), parameters (IN.PAR), and configuration settings (IN.CFG). Commands are used to initiate operations, and parameters and configuration settings determine how the commands will be processed. The difference between parameters and configuration settings is that configuration settings are generally set only once, while parameters might be set any time a command is issued.

####Commands
* **Enable** - Enable set point ramping. On a rising edge of **Enable**, **OUT.RampedSetTemp** is initialized to **IN.PAR.ActTemp**.
* **SetNow** - Set **OUT.RampedSetTemp** to **IN.PAR.SetTemp** immediately, with no ramping. **Enable** must be TRUE for this to have an effect.

####Parameters
* **SetTemp** - Final target temperature for set point ramping [℃].
* **ActTemp** - Current actual temperature [℃]. This is only used to initialize **OUT.RampedSetTemp** on a rising edge of **IN.CMD.Enable**.

####Configuration Settings
* **RampRateUp** - Ramp rate for ramping away from 0℃ [℃/s].
* **RampRateDown** - Ramp rate for ramping towards 0℃ [℃/s].
* **MinTemp** - Minimum value of **OUT.RampedSetTemp** while ramping is enabled [℃].
* **MaxTemp** - Maximum value of **OUT.RampedSetTemp** while ramping is enabled [℃].

###Outputs
TempRamp outputs contain the ramped set temperature and status information (OUT.STAT).

* **RampedSetTemp** - Ramped set temperature [℃]. If **IN.CMD.Enable** is FALSE, then **RampedSetTemp** is set to 0℃.

####Status Outputs
* **Error** - An error exists with the TempRamp. Check **IN.CFG** settings.
* **ErrorID** - Current ramp status. This is passed directly from the internal LCRRamp function block. If **Error** is FALSE, then **ErrorID** represents a function block warning. For details, please see the LoopConR library documenation in the Automation Studio Online Help.

##Temperature Controller Data Structure
The TempController data structure provides the interface to higher level programs and also stores all necessary internal information for closed loop temperature control with autotuning. It is divided into inputs (TempController.IN), outputs (TempController.OUT), and internals (TempController.Internal).

###Inputs
TempController inputs are divided into commands (IN.CMD) and parameters (IN.PAR). Commands are used to initiate operations, and parameters determine how the commands will be processed.

####Commands
* **EnableControl** - Enable temperature control.
* **StartAutotune** - Start an autotune procedure, regardless of the status of **EnableControl**. After the tuning is finished, the control will stay active as long as **StartAutotune** (or **EnableControl**) is TRUE.
* **AbortAutotune** - Abort an autotune procedure before it finishes. Setting **AbortAutotune** to TRUE will automatically reset the **StartAutotune** command.
* **Update** - Update the controller settings while control is active. Settings are captured on a rising edge of **EnableControl**. While control is active, changes to settings can only be applied by using the **Update** command. This command is automatically reset by the controller.
* **AcknowledgeError** - Acknowledge temperature controller errors.
* **okToHeat**, **okToFree**, **okToFreeEnd**, **okToCool**, **okToCoolEnd** - The **okTo** inputs are used for synchronizing autotuning across multiple temperature zones. For details on how best to use these inputs, please see the AS Online Help for the LCRTempTune function block.

####Parameters
* **SetTemp** - Set temperature [℃].
* **ActTemp** - Actual temperature [℃].
* **Y_man** - Controller output during manual control [%]. If the **Mode** input is set to **LCRTEMPPID_MODE_MAN**, then **Y_man** is passed directly to the **PercentHeat** and **PercentCool** outputs. Values greater than 0 are passed to **PercentHeat** and values less than 0 are passed to **PercentCool**.
* **Mode** - Controller mode. Valid settings are **LCRTEMPPID_MODE_AUTO** and **LCRTEMPPID_MODE_MAN**.
* **Settings** - Controller settings (lcrtemp_set_typ structure). This structure contains all of the settings for closed loop control and autotuning. For details, please see the LoopConR library documentation in the AS Online Help.
* **EnableExtendedTuningStatus** - When set to TRUE, the **FilteredTempGradient** and **FilteredActTemp** status outputs will be calculated. This can be useful for determining tuning settings, but it uses significant CPU resources. This should be enabled during commissioning to find appropriate tuning settings but disabled during normal machine operation.

###Outputs
TempController outputs contain the control effort and status information (OUT.STAT).

* **PercentHeat** - Heating control effort [%].
* **PercentCool** - Cooling control effort [%].

####Status Outputs
* **ActTemp** - Actual temperature [℃]. This is passed directly from **IN.PAR.ActTemp**.
* **SetTemp** - Set temperature [℃]. This is passed directly from **IN.PAR.SetTemp**.
* **TempDeviation** - Deviation from set temperature [℃].
* **Tuning** - Status information for autotuning operations.
* **Error** - An error exists with the TempController.
* **ErrorID** - Current controller status. This is passed directly from the internal LoopConR function blocks. If **Error** is FALSE, then **ErrorID** represents a function block warning. For details, please see the LoopConR library documentation in the AS Online Help.
* **ErrorState** - TempController state in which the error occurred.

####Tuning Status
* **Active** - The autotune procedure is currently active.
* **Done** - The autotune procedure finished successfully. Controller settings are updated and applied automatically.
* **rdyToHeat**, **rdyToFree**, **rdyToFreeEnd**, **rdyToCool**, **rdyToCoolEnd** - The **rdyTo** outputs are used for synchronizing autotuning across multiple temperature zones. For details on how best to use these inputs, please see the AS Online Help for the LCRTempTune function block.
* **State** - Tuning state passed directly from the internal LCRTempTune function block. For details, please see the AS Online Help for the LCRTempTune function block.
* **FilteredTempGradient** - Temperature gradient measured by the autotune procedure, filtered using the **filter_base_T** setting [℃/s]. If this curve appears too noisy during an autotune, increase **filter_base_T** gradually. If the curve does not accurately reflect the temperature gradient, reduce **filter_base_T**.
* **FilteredActTemp** - Actual temperature filtered using the **filter_base_T** setting [℃]. If this curve appears too noisy during an autotune, increase **filter_base_T** gradually. If the curve does not accurately reflect the actual temperature, reduce **filter_base_T**.

##Error ID Numbers
All errors are passed directly from function blocks contained in the LoopConR library. For details on these, please see the AS Online Help for the LoopConR library.