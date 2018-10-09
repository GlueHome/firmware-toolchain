# Adopted from http://make.mad-scientist.net/papers/multi-architecture-builds
# meant to be used as: FLAVOR=debug make all
include ${MAKE_LIBRARY_PATH}/util_macros.mk

SUPPORTED_FLAVORS := debug release

ifndef FLAVOR
FLAVOR := release
export FLAVOR
endif

$(call abort_if_not_present,${FLAVOR},${SUPPORTED_FLAVORS})

BUILD_PATH := _${FLAVOR}

MAKETARGET = ${MAKE} --no-print-directory -C $@ -f ${CURDIR}/Makefile ${MAKECMDGOALS}

.PHONY: ${BUILD_PATH}
${BUILD_PATH}:
	+@[ -d $@ ] || mkdir -p $@
	+@${MAKETARGET}

Makefile : ;
%.mk :: ;

# This why just typing make does not do the full job, you need to specify target all
% :: ${BUILD_PATH} ; @:

ALL_FLAVOR_BUILD_PATHS := $(foreach supported_flavor,${SUPPORTED_FLAVORS},_${supported_flavor})

.PHONY: clean
clean:
	rm -rf ${ALL_FLAVOR_BUILD_PATHS}

.SUFFIXES:
