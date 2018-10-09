CC := gcc

$(call abort_if_exec_not_in_path,${CC})

CFLAGS := -O0 -g -std=c99 -Wall -Werror -DDEBUG

# We need to wrap at least the nrf_log.h in a glue_log.h
# in order to avoid this ugliness
$(call abort_if_env_variable_not_defined,GLUEHOME_C_PROTOCOL_CLIENT)

CFLAGS += -I${GLUEHOME_C_PROTOCOL_CLIENT_PATH}/test/support
