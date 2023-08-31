# This Makefile fragment (since dpkg 1.16.1) defines the following host
# variables:
#
#   ASFLAGS: flags for the host assembler (since 1.21.0).
#   CFLAGS: flags for the host C compiler.
#   CPPFLAGS: flags for the host C preprocessor.
#   CXXFLAGS: flags for the host C++ compiler.
#   OBJCFLAGS: flags for the host Objective C compiler.
#   OBJCXXFLAGS: flags for the host Objective C++ compiler.
#   DFLAGS: flags for the host D compiler.
#   FFLAGS: flags for the host Fortran 77 compiler.
#   FCFLAGS: flags for the host Fortran 9x compiler.
#   LDFLAGS: flags for the host linker.
#
# You can also export them in the environment by setting
# DPKG_EXPORT_BUILDFLAGS to a non-empty value.
#
# This list is kept in sync with the default set of flags returned
# by dpkg-buildflags.

dpkg_lazy_eval ?= $$(or $$(value DPKG_CACHE_$(1)),$$(eval DPKG_CACHE_$(1) := $$(shell $(2)))$$(value DPKG_CACHE_$(1)))

DPKG_BUILDFLAGS_LIST = \
  ASFLAGS \
  CFLAGS \
  CPPFLAGS \
  CXXFLAGS \
  OBJCFLAGS \
  OBJCXXFLAGS \
  DFLAGS \
  FFLAGS \
  FCFLAGS \
  LDFLAGS \
  # EOL

define dpkg_buildflags_export_envvar
  ifdef $(1)
    DPKG_BUILDFLAGS_EXPORT_ENVVAR += $(1)="$$(value $(1))"
  endif
endef

$(eval $(call dpkg_buildflags_export_envvar,DEB_BUILD_OPTIONS))
$(eval $(call dpkg_buildflags_export_envvar,DEB_BUILD_MAINT_OPTIONS))
$(eval $(call dpkg_buildflags_export_envvar,DEB_BUILD_PATH))
$(foreach flag,$(DPKG_BUILDFLAGS_LIST),\
  $(foreach operation,SET STRIP APPEND PREPEND,\
    $(eval $(call dpkg_buildflags_export_envvar,DEB_$(flag)_MAINT_$(operation)))))

dpkg_buildflags_setvar = $(1) = $(call dpkg_lazy_eval,$(1),$(DPKG_BUILDFLAGS_EXPORT_ENVVAR) dpkg-buildflags --get $(1))

$(foreach flag,$(DPKG_BUILDFLAGS_LIST),\
  $(eval $(call dpkg_buildflags_setvar,$(flag))))

ifdef DPKG_EXPORT_BUILDFLAGS
  export $(DPKG_BUILDFLAGS_LIST)
endif
