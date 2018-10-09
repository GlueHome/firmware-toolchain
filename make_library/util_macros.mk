abort_if_env_variable_not_defined = $(if $(value $1),,$(error Undefined environment: $1))
abort_if_exec_not_in_path = $(if $(shell PATH=${PATH} which $1),,$(error "No $1 in PATH"))
abort_if_option_not_present = $(if $(findstring -$1, $2),,$(error "No -$1 defined in $$2"))
abort_if_not_present = $(if $(findstring $1, $2),,$(error "Not supported $1"))

