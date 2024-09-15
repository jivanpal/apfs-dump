### Directory definitions ###
SRCDIR=src
OUTDIR=out
INCDIR=include

### Compiler definition ###
CC := gcc

override CFLAGS += \
-std=c99 \
-D _GNU_SOURCE \
-Werror \
-Wall \
-Wextra \
-Wno-incompatible-pointer-types \
-Wno-unused-variable \
-Wno-unused-but-set-variable \
-Wno-deprecated-non-prototype \
-Wno-multichar \
-Wno-unused-parameter \
-Wno-missing-field-initializers \
-I./$(INCDIR)

### Linker definition ###
LD := gcc
override LDFLAGS += # Nothing

### On macOS, include <argp.h> from Homebrew package `argp-standalone`
ifneq ($(OS),Windows_NT)
	ifeq ($(shell uname -s),Darwin)
                override CFLAGS  += -I/opt/homebrew/Cellar/argp-standalone/1.5.0/include/
                override LDFLAGS += -L/opt/homebrew/Cellar/argp-standalone/1.5.0/lib/ -largp
	endif
endif

### Source paths ###
HEADERS		:= $(shell find $(SRCDIR) $(INCDIR) -name '*.h')
SOURCES		:= $(shell find $(SRCDIR) $(INCDIR) -name '*.c')
CMD_SRCS	:= $(wildcard $(SRCDIR)/commands/*.c)
BIN_SRCS	:= $(wildcard $(SRCDIR)/*.c)

### Target paths ###
GCHS		:= $(HEADERS:%.h=$(OUTDIR)/%.gch)
OBJECTS		:= $(SOURCES:%.c=$(OUTDIR)/%.o)
COMMANDS	:= $(CMD_SRCS:$(SRCDIR)/commands/%.c=%)
BINARIES	:= $(BIN_SRCS:$(SRCDIR)/%.c=%)

### Targets ###

.DEFAULT_GOAL := all

$(GCHS): $(OUTDIR)/%.gch: %.h
	@echo "GCHS +++ $< +++ $@"
	@[ -d $(@D) ] || (mkdir -p $(@D) && echo "Created directory \`$(@D)\`.")
	$(CC) $(CFLAGS) -c "$<" -o "$@"
	@echo

$(OBJECTS): $(OUTDIR)/%.o: %.c $(HEADERS)
	@echo "OBJECTS +++ $< +++ $@"
	@[ -d $(@D) ] || (mkdir -p $(@D) && echo "Created directory \`$(@D)\`.")
	$(CC) $(CFLAGS) -c "$<" -o "$@"
	@echo

# Make `<command_name>` an alias of `out/commands/<command_name>.o`
.PHONY: $(COMMANDS)
$(COMMANDS): %: $(OUTDIR)/$(SRCDIR)/commands/%.o

$(BINARIES): %: $(OUTDIR)/$(SRCDIR)/%.o $(OBJECTS)
	@echo "BINARIES +++ $< +++ $@"
	$(LD) $^ $(LDFLAGS) -o $@
	@echo

### Meta-targets ###

.PHONY: headers
headers: $(GCHS)

.PHONY: commands
commands: $(COMMANDS)

.PHONY: binaries
binaries: $(BINARIES)

.PHONY: clean
clean:
	rm -rf $(BINARIES) $(OUTDIR)

.PHONY: all
all: headers commands binaries

##

.PHONY: docs
docs:
	(cd docs && make html)

.PHONY: clean-docs
clean-docs:
	(cd docs && make clean)
