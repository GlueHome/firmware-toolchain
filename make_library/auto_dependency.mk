# Adopted from http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
DEPDIR := .d
$(shell mkdir -p $(DEPDIR) >/dev/null)
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td

COMPILE.c = $(CC) $(DEPFLAGS) ${CFLAGS} -c
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

VPATH = ${SRC_PATHS} .
SRC_FILES := $(notdir $(shell find ${VPATH} -type f -name '*.c'))
CFLAGS += $(addprefix -I, ${VPATH})

%.o : %.c
%.o : %.c $(DEPDIR)/%.d
	@echo Compiling $<
	@$(COMPILE.c) $(OUTPUT_OPTION) $<
	@$(POSTCOMPILE)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(SRC_FILES))))
