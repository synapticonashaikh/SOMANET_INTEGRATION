
#define root locations
ROOTL = ../../

#define the distributed location
MODULEL   = ../pymod/
HEADERSL  = ../pyheader/
HARDWAREL = ../XMOS_HW/
TARGETL	  = ../XMOS_Target/
PYLIBL	  = $(ROOTL)py

#enable/ disable debug message 
ENABLE_DISABLE_DEBUGG_MESSAGE = 0

#enable/ disable our own created modules 
ENABLE_DISABLE_OWN_MODULE = 1

#enable/ disable float functionality
ENABLE_DISABLE_FLOAT_FUNCTIONALITY = 1

#define the code version
#for the terminal interpreter, use DCODE_WITH_PYTHON_INTRACTIVE_TERMINAL
#without terminal use DCODE_WITHOUT_PYTHON_INTRACTIVE_TERMINAL
DEFINE_CODE_VERSION=-DCODE_WITHOUT_PYTHON_INTRACTIVE_TERMINAL

#use the local main for debugging and generating the dependent library
PROCESSING_FLAG = -DUSE_LOCAL_MAIN

# MICROPY_FLOAT_IMPL_NONE MICROPY_FLOAT_IMPL_FLOAT MICROPY_FLOAT_IMPL_DOUBLE 
ifeq ($(ENABLE_DISABLE_FLOAT_FUNCTIONALITY), 1)
FLOAT_FLAG=-DMICROPY_FLOAT_IMPL=MICROPY_FLOAT_IMPL_FLOAT
else
FLOAT_FLAG=-DMICROPY_FLOAT_IMPL=MICROPY_FLOAT_IMPL_NONE
endif

#supoort folder (generated header folder)
BUILD_DIR = build

#target file which has the clock and other definitions
XCTarget = $(TARGETL)C2X.xn

#define the compiler
CMP = xcc -target= $(XCTarget)
#xflash --verbose --target XCORE-200-EXPLORER --boot-partition-size 0x90000  output.xe

#include the all required path
INC += -I.
INC += -I$(ROOTL)
INC += -I$(PYLIBL)
INC += -I$(HEADERSL)
INC += -I$(BUILD_DIR)
INC += -I$(BUILD_DIR)/genhdr/

#remove the unwaned warning of unused variables
FLAG_UNUSED_VAR 	 = -Wno-unused-variable
#remove the unwaned warning of function pointer
FLAG_FUNTION_POINTER = -Wno-xcore-fptrgroup
#remove unwanted warning of unsed parameter
FLAG_UNSED_PARA    	 = -Wno-unused-parameter
#remove the unwanted warning of missing field
FLAG_MISSING_FEILD   = -Wno-missing-field-initializers
#remove the unwanted warning of sign comparison
FLAG_SIGN_COMPARE 	 = -Wno-sign-compare 
#set the optimisation level
FLAG_OPT 		     = -Os
#geneterate the report of the compilation
FLAG_REPORT 		 = -report

#flags with respect to XMOS core
LDFLAGS +=$(INC)
LDFLAGS +=$(FLAG_UNUSED_VAR) 
LDFLAGS +=$(FLAG_UNSED_PARA)
LDFLAGS +=$(FLAG_MISSING_FEILD) 
LDFLAGS +=$(FLAG_SIGN_COMPARE) 
LDFLAGS +=$(FLAG_FUNTION_POINTER)
LDFLAGS +=$(FLAG_OPT)
LDFLAGS +=$(FLAG_REPORT)

LDFLAGS +=$(FLOAT_FLAG)
LDFLAGS +=$(DEFINE_CODE_VERSION)


