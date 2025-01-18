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

### Dependency files
DEPENDENCIES := $(OBJECTS:.o=.d)


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
	@echo "BUILD    $(TARGET) ($(BUILD_MODE))"

#-------------------------------------------------
# Build operations
#-------------------------------------------------
.PHONY: build
build: __prebuild $(TARGET)

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
$(DIR_BUILD)/%.o: $(DIR_SRC)/%.c
	@echo "CC    $@"
	@$(MKDIR) $(dir $@)
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

#-------------------------------------------------
# Clean generated files
#-------------------------------------------------
.PHONY: clean
clean:
ifneq ($(wildcard $(TARGET)),)
	@echo "RM    $(TARGET)"
	@$(RM) $(TARGET)
endif
ifneq ($(wildcard $(OBJECTS)),)
	@for obj in $(OBJECTS); do echo "RM    $$obj"; done
	@$(RM) $(OBJECTS)
	@for dep in $(DEPENDENCIES); do echo "RM    $$dep"; done
	@$(RM) $(DEPENDENCIES)
endif

#-------------------------------------------------
# Clean entire project
#-------------------------------------------------
.PHONY: cleanall
cleanall:
ifneq ($(wildcard $(DIR_BIN)),)
	@echo "RM    $(DIR_BIN)/"
	@$(RMDIR) $(DIR_BIN)
endif
ifneq ($(wildcard $(DIR_BUILD)),)
	@echo "RM    $(DIR_BUILD)/"
	@$(RMDIR) $(DIR_BUILD)
endif

#-------------------------------------------------
# Project informations
#-------------------------------------------------
.PHONY: info
info:
	@echo "INFO    CC        $(CC)"
	@echo "INFO    CFLAGS    $(CFLAGS)"
	@echo "INFO    CPPFLAGS  $(CPPFLAGS)"
	@echo "INFO    LDFLAGS   $(LDFLAGS)"
	@echo "INFO    LDLIBS    $(LDLIBS)"
	@echo
	@echo "INFO    TARGET    $(TARGET)"
	@echo "INFO    SOURCES   $(SOURCES)"
	@echo "INFO    OBJECTS   $(OBJECTS)"

#-------------------------------------------------
# Load dependency files
#-------------------------------------------------
-include $(DEPENDENCIES)
