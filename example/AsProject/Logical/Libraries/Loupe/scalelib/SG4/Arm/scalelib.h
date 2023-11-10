/* Automation Studio generated header file */
/* Do not edit ! */
/* scalelib 0.01.0 */

#ifndef _SCALELIB_
#define _SCALELIB_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _scalelib_VERSION
#define _scalelib_VERSION 0.01.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
/* Datatypes and datatypes of function blocks */
typedef struct Scale_OUT_STAT_typ
{	plcbit Error;
} Scale_OUT_STAT_typ;

typedef struct Scale_OUT_typ
{	float OutputValue;
	struct Scale_OUT_STAT_typ STAT;
} Scale_OUT_typ;

typedef struct Scale_IN_CFG_Point_typ
{	float Input;
	float Output;
} Scale_IN_CFG_Point_typ;

typedef struct Scale_IN_CFG_typ
{	struct Scale_IN_CFG_Point_typ Point[2];
} Scale_IN_CFG_typ;

typedef struct Scale_IN_typ
{	float InputValue;
	struct Scale_IN_CFG_typ CFG;
} Scale_IN_typ;

typedef struct Scale_typ
{	struct Scale_IN_typ IN;
	struct Scale_OUT_typ OUT;
} Scale_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC plcbit ScaleFnCyclic(struct Scale_typ* t);
_BUR_PUBLIC float F_to_C(float F);
_BUR_PUBLIC float C_to_F(float C);


#ifdef __cplusplus
};
#endif
#endif /* _SCALELIB_ */

