/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2020 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

#if defined(_WIN32)
 #include "stdio.h"
 #define IKI_DLLESPEC __declspec(dllimport)
#else
 #define IKI_DLLESPEC
#endif
#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2020 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

#if defined(_WIN32)
 #include "stdio.h"
 #define IKI_DLLESPEC __declspec(dllimport)
#else
 #define IKI_DLLESPEC
#endif
#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern int main(int, char**);
IKI_DLLESPEC extern void execute_2366(char*, char *);
IKI_DLLESPEC extern void execute_2367(char*, char *);
IKI_DLLESPEC extern void execute_2368(char*, char *);
IKI_DLLESPEC extern void execute_2369(char*, char *);
IKI_DLLESPEC extern void execute_2370(char*, char *);
IKI_DLLESPEC extern void execute_2371(char*, char *);
IKI_DLLESPEC extern void execute_2372(char*, char *);
IKI_DLLESPEC extern void execute_2359(char*, char *);
IKI_DLLESPEC extern void execute_2360(char*, char *);
IKI_DLLESPEC extern void execute_2361(char*, char *);
IKI_DLLESPEC extern void execute_2362(char*, char *);
IKI_DLLESPEC extern void execute_2363(char*, char *);
IKI_DLLESPEC extern void execute_2364(char*, char *);
IKI_DLLESPEC extern void execute_2365(char*, char *);
IKI_DLLESPEC extern void execute_650(char*, char *);
IKI_DLLESPEC extern void execute_51(char*, char *);
IKI_DLLESPEC extern void execute_52(char*, char *);
IKI_DLLESPEC extern void execute_53(char*, char *);
IKI_DLLESPEC extern void execute_54(char*, char *);
IKI_DLLESPEC extern void execute_1468(char*, char *);
IKI_DLLESPEC extern void execute_1469(char*, char *);
IKI_DLLESPEC extern void execute_669(char*, char *);
IKI_DLLESPEC extern void execute_670(char*, char *);
IKI_DLLESPEC extern void execute_671(char*, char *);
IKI_DLLESPEC extern void execute_672(char*, char *);
IKI_DLLESPEC extern void execute_673(char*, char *);
IKI_DLLESPEC extern void execute_674(char*, char *);
IKI_DLLESPEC extern void execute_2272(char*, char *);
IKI_DLLESPEC extern void execute_2273(char*, char *);
IKI_DLLESPEC extern void execute_2356(char*, char *);
IKI_DLLESPEC extern void execute_2357(char*, char *);
IKI_DLLESPEC extern void execute_2358(char*, char *);
IKI_DLLESPEC extern void execute_2277(char*, char *);
IKI_DLLESPEC extern void execute_2278(char*, char *);
IKI_DLLESPEC extern void execute_2279(char*, char *);
IKI_DLLESPEC extern void execute_2280(char*, char *);
IKI_DLLESPEC extern void execute_2281(char*, char *);
IKI_DLLESPEC extern void execute_2282(char*, char *);
IKI_DLLESPEC extern void transaction_0(char*, char*, unsigned, unsigned, unsigned);
IKI_DLLESPEC extern void vhdl_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
funcp funcTab[40] = {(funcp)execute_2366, (funcp)execute_2367, (funcp)execute_2368, (funcp)execute_2369, (funcp)execute_2370, (funcp)execute_2371, (funcp)execute_2372, (funcp)execute_2359, (funcp)execute_2360, (funcp)execute_2361, (funcp)execute_2362, (funcp)execute_2363, (funcp)execute_2364, (funcp)execute_2365, (funcp)execute_650, (funcp)execute_51, (funcp)execute_52, (funcp)execute_53, (funcp)execute_54, (funcp)execute_1468, (funcp)execute_1469, (funcp)execute_669, (funcp)execute_670, (funcp)execute_671, (funcp)execute_672, (funcp)execute_673, (funcp)execute_674, (funcp)execute_2272, (funcp)execute_2273, (funcp)execute_2356, (funcp)execute_2357, (funcp)execute_2358, (funcp)execute_2277, (funcp)execute_2278, (funcp)execute_2279, (funcp)execute_2280, (funcp)execute_2281, (funcp)execute_2282, (funcp)transaction_0, (funcp)vhdl_transfunc_eventcallback};
const int NumRelocateId= 40;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/BNN_testbench_behav/xsim.reloc",  (void **)funcTab, 40);
	iki_vhdl_file_variable_register(dp + 1633104);
	iki_vhdl_file_variable_register(dp + 1633160);
	iki_vhdl_file_variable_register(dp + 1635472);
	iki_vhdl_file_variable_register(dp + 1635512);


	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/BNN_testbench_behav/xsim.reloc");
}

	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net

void simulate(char *dp)
{
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/BNN_testbench_behav/xsim.reloc");

	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/BNN_testbench_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/BNN_testbench_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/BNN_testbench_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, (void*)0, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
