#==============================================================================
# Makefile template for small / medium sized C projects.
# Author: Raphael CAUSSE
#==============================================================================

# Define target name
TARGET_NAME :=

# Define build mode (debug or release)
BUILD_MODE := debug

# Define source files to compile
SOURCE_FILES :=


#==============================================================================
# DIRECTORIES AND FILES
#==============================================================================

### Predefined directories
DIR_BIN   := bin
DIR_BUILD := build
DIR_SRC   := src

### Target
TARGET := $(DIR_BIN)/$(TARGET_NAME)

### Source files
SOURCES := $(addprefix $(DIR_SRC)/,$(filter-out \,$(SOURCE_FILES)))

### Object files
OBJECTS := $(subst $(DIR_SRC),$(DIR_BUILD),$(addsuffix .o,$(basename $(SOURCES))))


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

### Extra flags to give to compiler when it invokes the linker (e.g. -L ...)
LDFLAGS := 

### Library names given to compiler when it invokes the linker (e.g. -l ...)
LDLIBS := 

### Build mode specific flags
DEBUG_FLAGS   := -O0 -g3 -DDEBUG
RELEASE_FLAGS := -O2 -g0 -DNDEBUG


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
ifeq ($(VERBOSE),)
    Q := @
else
    Q :=
endif


#==============================================================================
# RULES
#==============================================================================

default: build

#-------------------------------------------------
# (Internal rule) Check directories
#-------------------------------------------------
.PHONY: __checkdirs
__checkdirs:
	@$(MKDIR) $(DIR_BIN)
	@$(MKDIR) $(DIR_BUILD)

#-------------------------------------------------
# (Internal rule) Pre build operations
#-------------------------------------------------
.PHONY: __prebuild
__prebuild: __checkdirs
ifeq ($(TARGET_NAME),)
	$(error TARGET_NAME is required. Must provide a target name)
endif
ifeq ($(filter $(BUILD_MODE),debug release),)
	$(error BUILD_MODE is invalid. Must provide a valid mode (debug or release))
endif
ifeq ($(SOURCE_FILES),)
	$(error SOURCE_FILES is required. Must provide sources files to compile)
endif
ifeq ($(BUILD_MODE),debug)
	$(eval CFLAGS += $(DEBUG_FLAGS))
else ifeq ($(BUILD_MODE),release)
	$(eval CFLAGS += $(RELEASE_FLAGS))
endif
	@echo "===== Building $(TARGET) ($(BUILD_MODE)) ====="

#-------------------------------------------------
# Build operations
#-------------------------------------------------
.PHONY: build
build: __prebuild $(TARGET)
	@echo "===== Build done ($(BUILD_MODE)) ====="

#-------------------------------------------------
# Rebuild operations
#-------------------------------------------------
.PHONY: rebuild
rebuild: clean build
	
#-------------------------------------------------
# Link object files into target
#-------------------------------------------------
$(TARGET): $(OBJECTS)
	@echo "LD    $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

#-------------------------------------------------
# Compile C source files
#-------------------------------------------------
%.o: %.c
	@echo "CC    $@"
	@$(MKDIR) $(dir $@)
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

#-------------------------------------------------
# Clean generated files
#-------------------------------------------------
.PHONY: clean
clean:
	@echo "===== Cleaning generated files ====="
ifneq ($(wildcard $(TARGET)),)
	@echo " RM    $(TARGET)"
	@$(RM) $(TARGET)
endif
ifneq ($(wildcard $(OBJECTS)),)
	@echo "RM    $(OBJECTS)"
	@$(RM) $(OBJECTS)
endif
	@echo "===== Clean done ====="

#-------------------------------------------------
# Clean entire project
#-------------------------------------------------
.PHONY: cleanall
cleanall:
	@echo "===== Cleaning entire project ====="
ifneq ($(wildcard $(DIR_BIN)),)
	@echo "RM    $(DIR_BIN)"
	@$(RMDIR) $(DIR_BIN)
endif
ifneq ($(wildcard $(DIR_BUILD)),)
	@echo "RM    $(DIR_BUILD)"
	@$(RMDIR) $(DIR_BUILD)
endif
	@echo "===== Clean done ====="

#-------------------------------------------------
# Project informations
#-------------------------------------------------
.PHONY: info
info:
	@echo "===== Build configurations ====="
	@echo "CC        $(CC)"
	@echo "CFLAGS    $(CFLAGS)"
	@echo "CPPFLAGS  $(CPPFLAGS)"
	@echo "LDFLAGS   $(LDFLAGS)"
	@echo "LDLIBS    $(LDLIBS)"
	@echo "===== Files ====="
	@echo "TARGET    $(TARGET)"
	@echo "SOURCES   $(SOURCES)"
	@echo "OBJECTS   $(OBJECTS)"
