#==============================================================================
# Makefile template for small / medium sized C projects.
# Author: Raphael CAUSSE
#==============================================================================

# Define target name
TARGET_NAME := 

# Define source files to compile
SOURCE_FILES := 


#==============================================================================
# DIRECTORIES AND FILES
#==============================================================================

### Base directories
DIR_BIN   := bin
DIR_BUILD := build
DIR_SRC   := src

### Generation directories
DIR_BIN_DEBUG     := $(DIR_BIN)/debug
DIR_BUILD_DEBUG   := $(DIR_BUILD)/debug
DIR_BIN_RELEASE   := $(DIR_BIN)/release
DIR_BUILD_RELEASE := $(DIR_BUILD)/release

### Target
TARGET_DEBUG := $(DIR_BIN_DEBUG)/$(TARGET_NAME)
TARGET_RELEASE := $(DIR_BIN_RELEASE)/$(TARGET_NAME)

### Source files
SOURCES := $(addprefix $(DIR_SRC)/, $(filter-out \, $(SOURCE_FILES)))

### Object files
OBJECTS_DEBUG := $(patsubst $(DIR_SRC)/%.c, $(DIR_BUILD_DEBUG)/%.o, $(SOURCES))
OBJECTS_RELEASE := $(patsubst $(DIR_SRC)/%.c, $(DIR_BUILD_RELEASE)/%.o, $(SOURCES))

### Dependency files
DEPENDENCIES_DEBUG := $(OBJECTS_DEBUG:.o=.d)
DEPENDENCIES_RELEASE := $(OBJECTS_RELEASE:.o=.d)


#==============================================================================
# COMPILER AND LINKER
#==============================================================================

### C Compiler
CC := gcc

### C standard
CSTD := -std=c99

### Extra flags to give to the C compiler
CFLAGS := $(CSTD) -Wall -Wextra -pedantic

### Extra flags to give to the C preprocessor (e.g. -I, -D, -U ...)
CPPFLAGS := 

### Dependency flags
DEPFLAGS := -MMD -MP

### Extra flags to give to compiler when it invokes the linker (e.g. -L ...)
LDFLAGS := 

### Library names given to compiler when it invokes the linker (e.g. -l ...)
LDLIBS := 

### Build mode specific flags
FLAGS_DEBUG   := -O0 -g3 -DDEBUG
FLAGS_RELEASE := -O2 -g0 -DNDEBUG


#==============================================================================
# SHELL
#==============================================================================

### Commands
MKDIR := mkdir -p
RM    := rm -f
RMDIR := rm -rf
CP    := cp -rf
MV    := mv


#==============================================================================
# VERBOSITY
#==============================================================================

VERBOSE := $(or $(v), $(verbose))
ifeq ($(VERBOSE), )
    Q := @
else
    Q :=
endif


#==============================================================================
# RULES
#==============================================================================

all: default

default: debug

### Internal rules protection
$(if $(filter __%, $(MAKECMDGOALS)), $(error Rules prefixed with "__" are only for internal use))

#-------------------------------------------------
# (Internal) Check configuration
#-------------------------------------------------
.PHONY: __check_conf
__check_conf:
ifeq ($(TARGET_NAME), )
	$(error TARGET_NAME is required. Must provide a target name)
endif
ifeq ($(SOURCE_FILES), )
	$(error SOURCE_FILES is required. Must provide sources files to compile)
endif

#-------------------------------------------------
# (Internal) Pre build debug
#-------------------------------------------------
.PHONY: __pre_debug
__pre_debug:
	@$(MKDIR) $(DIR_BIN_DEBUG)
	@$(MKDIR) $(DIR_BUILD_DEBUG)

#-------------------------------------------------
# (Internal) Pre build release
#-------------------------------------------------
.PHONY: __pre_release
__pre_release:
	@$(MKDIR) $(DIR_BIN_RELEASE)
	@$(MKDIR) $(DIR_BUILD_RELEASE)

#-------------------------------------------------
# Build operations (debug)
#-------------------------------------------------
.PHONY: debug
debug: CFLAGS += $(FLAGS_DEBUG)
debug: __check_conf __pre_debug $(TARGET_DEBUG)

#-------------------------------------------------
# Build operations (release)
#-------------------------------------------------
.PHONY: release
release: CFLAGS += $(FLAGS_RELEASE)
release: __check_conf __pre_release $(TARGET_RELEASE)
	
#-------------------------------------------------
# Link objects into target (debug)
#-------------------------------------------------
$(TARGET_DEBUG): $(OBJECTS_DEBUG)
	@echo " LD    $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

#-------------------------------------------------
# Link objects into target (release)
#-------------------------------------------------
$(TARGET_RELEASE): $(OBJECTS_RELEASE)
	@echo " LD    $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

#-------------------------------------------------
# Compile C source files (debug)
#-------------------------------------------------
$(DIR_BUILD_DEBUG)/%.o: $(DIR_SRC)/%.c
	@echo " CC    $@"
	@$(MKDIR) $(dir $@)
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

#-------------------------------------------------
# Compile C source files (release)
#-------------------------------------------------
$(DIR_BUILD_RELEASE)/%.o: $(DIR_SRC)/%.c
	@echo " CC    $@"
	@$(MKDIR) $(dir $@)
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

#-------------------------------------------------
# Clean generated files
#-------------------------------------------------
.PHONY: clean
clean:
ifneq ($(wildcard $(TARGET_DEBUG)), )
	@echo " RM    $(TARGET_DEBUG)"
	@$(RM) $(TARGET_DEBUG)
endif
ifneq ($(wildcard $(OBJECTS_DEBUG)), )
	@for obj in $(OBJECTS_DEBUG); do echo " RM    $$obj"; done
	@$(RM) $(OBJECTS_DEBUG)
	@for dep in $(DEPENDENCIES_DEBUG); do echo " RM    $$dep"; done
	@$(RM) $(DEPENDENCIES_DEBUG)
endif
ifneq ($(wildcard $(TARGET_RELEASE)), )
	@echo " RM    $(TARGET_RELEASE)"
	@$(RM) $(TARGET_RELEASE)
endif
ifneq ($(wildcard $(OBJECTS_RELEASE)), )
	@for obj in $(OBJECTS_RELEASE); do echo " RM    $$obj"; done
	@$(RM) $(OBJECTS_RELEASE)
	@for dep in $(DEPENDENCIES_RELEASE); do echo " RM    $$dep"; done
	@$(RM) $(DEPENDENCIES_RELEASE)
endif

#-------------------------------------------------
# Clean generated files and directories
#-------------------------------------------------
.PHONY: cleanall
cleanall:
ifneq ($(wildcard $(DIR_BIN)), )
	@echo " RM    $(DIR_BIN)/"
	@$(RMDIR) $(DIR_BIN)
endif
ifneq ($(wildcard $(DIR_BUILD)), )
	@echo " RM    $(DIR_BUILD)/"
	@$(RMDIR) $(DIR_BUILD)
endif

#-------------------------------------------------
# Project informations
#-------------------------------------------------
.PHONY: info
info:
	@echo " CC        $(CC)"
	@echo " CFLAGS    $(CFLAGS)"
	@echo " CPPFLAGS  $(CPPFLAGS)"
	@echo " LDFLAGS   $(LDFLAGS)"
	@echo " LDLIBS    $(LDLIBS)"
	@echo " SOURCES   $(SOURCES)"

#-------------------------------------------------
# Makefile help
#-------------------------------------------------
.PHONY: help
help:
	@echo "debug      Build target in debug mode"
	@echo "release    Build target in release mode"
	@echo "clean      Clean generated files"
	@echo "cleanall   Clean generated files and directories"
	@echo "info       Display project informations"

#-------------------------------------------------
# Load dependency files
#-------------------------------------------------
-include $(DEPENDENCIES)
