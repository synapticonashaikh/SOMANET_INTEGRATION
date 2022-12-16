#
# SOMANET Motion Drive
#

# The location of this Makefile, regardless of from where it's called.
MAKEFILE_DIR = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
# Build and packaging tools
XCC_VERSION = $(shell xcc --version)

ifneq ($(findstring 15.1.4,$(XCC_VERSION)),15.1.4)
  $(info $(XCC_VERSION))
  $(error the XTC tool is not a compatible version.)
endif

ZIPTOOL = zip
# Generate the version via git describe or an SDK pre-generated file if git isn't used.
# The call to sed converts git describe into a semantic version format. It assumes the tag is already semantic and strips down the git additives.
APPVERSION := upy1

# Source folder of the library sources
SC_LIBRARIES_SRC := $(MAKEFILE_DIR)/../../sc_somanet_ip

# Set the name of the app being built
APP_DEVICENAME := Motion Drive
APP_FILE_NAME := motion-drive

# Default BSP files (no full path necessary on the command line)
CONFIG ?= Release

# Default files required for the OBLAC Drives package
ESIFILE := $(MAKEFILE_DIR)/../SOMANET_CiA_402.xml
NODEIMAGE ?= $(MAKEFILE_DIR)/../../sc_configuration/module_board-support/images/Node-rev-default.svg
ifeq ($(findstring integro, $(NODE_CONFIGURATION)), integro)
  NETX_BINARY_FILE=$(MAKEFILE_DIR)/../../../arm_application/build/release/Targets/com_motion_drive_fw.bin
endif

TMP_CERT_CHECK := certisign.txt

#
# File output names
#
# Version information is generated into this file.
VERSION_FILE = src/version.h
# The app_ prefix is required by the bootloader.
TARGETBIN := app_$(APP_FILE_NAME)-$(APPVERSION).bin
NETXBIN := com_$(APP_FILE_NAME)-$(APPVERSION).bin
# Doesn't matter.
ESIZIP = SOMANET_CiA_402.xml.zip
# Required by OBLAC Drives for display of the node connectors
TARGETNODEIMAGE = stack_image.svg
NODEIMAGEZIP = $(TARGETNODEIMAGE).zip

# OPTIONAL:
# Specify a pre-defined set of compilation parameters that modify the above
# defaults.

PREDEFINED_BUILD = False

ifdef NODE_CONFIGURATION
  NODE_CONFIGURATION_PATH := $(shell find $(MAKEFILE_DIR)/../.. -regex '.*node_configuration.*' -type d -name "$(NODE_CONFIGURATION)" )
  include $(NODE_CONFIGURATION_PATH)/build_configuration.mk
  APP_NODE_CONFIGURATION = $(NODE_CONFIGURATION)
else
  APP_NODE_CONFIGURATION = "Unknown"
endif

SUPPORT_MODULES ?= ""

# Get version of the certified safety module
ifneq ($(findstring NoSafetyModule.bsp, $(SAFETY_BOARD)), NoSafetyModule.bsp)
#  SAFETY_MODULE_VERSION := $(shell git describe --abbrev=0 --match "certified/module_safety/v*")
endif

# The version of the XTC that bootloader has been compiled with.
# Products earlier than integro (i.e circulo, Node) use boot loader built with XTC 14.3
ifeq ($(findstring Integro, $(CORE_BOARD)), Integro)
  BOOTLOADER_XTC_VERSION = "15.1"
else
  BOOTLOADER_XTC_VERSION = "14.3"
endif

# Set to 0 for minimal output, 1 for verbose output.
VERBOSE=0
TARGET = XCORE-200-EXPLORER

.PHONY: upy version check_certified_modules clean distclean binary release package debug help xmake $(TARGETBIN)

all: upy

xmake:
	xmake -f Makefile.xmos APP_NAME=app_$(APP_FILE_NAME) CONFIG=$(CONFIG) PREDEFINED_BUILD=$(PREDEFINED_BUILD) SUPPORT_MODULES="$(SUPPORT_MODULES)" GENERATED_MODULE=$(MODULE_GENERATED_FILES) \
				DRIVE_BOARD=$(DRIVE_BOARD) CORE_BOARD=$(CORE_BOARD) COM_BOARD=$(COM_BOARD) SAFETY_BOARD=$(SAFETY_BOARD)

upy:
	xmake -f Makefile.xmos APP_NAME=app_$(APP_FILE_NAME) CONFIG=$(CONFIG)
# PREDEFINED_BUILD=$(PREDEFINED_BUILD) SUPPORT_MODULES="$(SUPPORT_MODULES)" GENERATED_MODULE=$(MODULE_GENERATED_FILES) \



release: CONFIG=Release
release: version xmake

debug: CONFIG=Debug
debug: version xmake

binary: $(TARGETBIN)

$(TARGETBIN):
	@echo "$(TARGETBIN): creating binary from the .xe firmware..."
	@xflash --upgrade 1 bin/Release/app_$(APP_FILE_NAME).xe --factory-version $(BOOTLOADER_XTC_VERSION) --noinq -o $(TARGETBIN)
	@shasum -a 1 $(TARGETBIN)

$(ESIZIP): $(ESIFILE)
	@echo "zipping the $(ESIFILE) file..."
	@zip -j $@ $(ESIFILE)

$(TARGETNODEIMAGE):
	@echo "$(NODEIMAGE): copying to $(TARGETNODEIMAGE) for compression...."
	@cp -f $(NODEIMAGE) $(TARGETNODEIMAGE)

$(NODEIMAGEZIP): $(TARGETNODEIMAGE)
	@echo "zipping the $(TARGETNODEIMAGE) file..."
	@zip -j $@ $(TARGETNODEIMAGE)
	@rm -f $(TARGETNODEIMAGE)

$(NETXBIN):
ifneq ("$(wildcard $(NETX_BINARY_FILE))","")
	@echo "Copying netx update package from arm_application."
	@cp -f $(NETX_BINARY_FILE) ./$(NETXBIN)
else
	@$(eval NETXBIN=)
	@echo "Netx update package Not included."
endif

package: $(TARGETPACKAGE)

$(TARGETPACKAGE): $(TARGETBIN) $(ESIZIP) $(NODEIMAGEZIP) $(NETXBIN)
	@echo "Creating package file..."
	@$(ZIPTOOL) -j $(TARGETPACKAGE) $(ESIZIP) $(SIIFILE) $(TARGETBIN) $(NODEIMAGEZIP) $(NETXBIN)
	@echo "Done. See $(TARGETPACKAGE)"

check_certified_modules:
ifneq ($(findstring NoSafetyModule.bsp, $(SAFETY_BOARD)), NoSafetyModule.bsp)
	@echo "Check if module safety is valid"
#	@git tag -v $(SAFETY_MODULE_VERSION) > $(TMP_CERT_CHECK)
	@echo "Tagger for $(SAFETY_MODULE_VERSION): `grep "tagger" $(TMP_CERT_CHECK) | cut -f 2-4 -d ' '`"
	@rm -f $(TMP_CERT_CHECK)
	@$(GIT_BASE_DIR)/tools/check_certified_module.sh $(SAFETY_MODULE_VERSION) sc_certified/module_safety
else
	@echo "No safety module present. Continue..."
endif

# Targets for libraries expoect to be in sc_libraries

.PHONY: libraries libraries_clean libraries_reset

libraries:
	@echo "Prepare libraries for sc_libraries"
	@make -C $(SC_LIBRARIES_SRC) lib

libraries_clean:
	@make -C $(SC_LIBRARIES_SRC) clean

libraries_reset:
	@make -C $(SC_LIBRARIES_SRC) reset

version:
	@echo "/* Autogenerated file DO NOT EDIT! */" >  $(VERSION_FILE)
	@echo ""  >>  $(VERSION_FILE)
	@echo "#pragma once" >>  $(VERSION_FILE)
	@echo ""  >>  $(VERSION_FILE)
	@echo "#define APP_VERSION    \"$(APPVERSION)\"" >>  $(VERSION_FILE)
	@echo "#define APP_DEVICENAME    \"$(APP_DEVICENAME)\"" >> $(VERSION_FILE)
	@echo "#define APP_NODE_CONFIGURATION    \"$(APP_NODE_CONFIGURATION)\"" >> $(VERSION_FILE)

print_version:
	@echo ${APPVERSION}

clean:
	@rm -f $(VERSION_FILE)
	@rm -f $(TARGETNODEIMAGE)
	@rm -f $(NODEIMAGEZIP)
	@rm -f $(ESIZIP)
	xmake -f Makefile.xmos clean

distclean: clean
	@rm -f $(TARGETBIN)
	@rm -f $(TARGETPACKAGE)

help:
	@echo "Available targets: all help develop release binary package clean libraries libraries_clean"
	@echo ""
	@echo "To build only debug or release use the variable 'CONFIG' on the command line."
	@echo "  e.g. make CONFIG=Release"
	@echo "       make debug"
	@echo "To choose the drive board to build for, use the 'DRIVE_BOARD' parameter."
	@echo "  e.g. make CONFIG=Debug DRIVE_BOARD=drive1000-rev-d.bsp"
	@echo "       will build the Debug binary for the Node 1000 revision D."
	@echo "To choose the image bundled with the package, use the NODEIMAGE parameter."
	@echo "  e.g. make package NODEIMAGE=/full/path/my_node_image.svg"
	@echo "       will bundle a package file with the specified image included."
	@echo ""
	@echo "To ignore all of that and select a fully defined node configuration, use NODE_CONFIGURATION."
	@echo "  e.g. make release package NODE_CONFIGURATION=MySpecialConfig"
	@echo "       will go find the build_configuration for the specified node."
	@echo ""
	@echo "With 'make binary' a upgrade image of the release build is generated."
	@echo "For creating a update package used by OBLAC Drives use: make release package"
	@echo ""
	@echo "To build the libraries for sc_libraries/ use 'make libraries'. In the future the use of"
	@echo "USE_BUILD_MODULES is discouraged and may not work in the future."
