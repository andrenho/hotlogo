#
# compilation options
#

# default compilation options
CFLAGS += -std=gnu11
CPPFLAGS += -fdiagnostics-color=always -pipe -fPIC -rdynamic -D_FILE_OFFSET_BITS=64
CXXFLAGS += -std=c++14
LDFLAGS += -Wl,--no-as-needed

# add libraries
CPPFLAGS += `pkg-config --cflags lua`
LDFLAGS += `pkg-config --libs lua`

# add debugging
ifeq (${DEBUG},1)
  CPPFLAGS += -g3 -ggdb -DDEBUG
endif

# add optimization
ifeq (${OPTIMIZE},1)
  CPPFLAGS += -Ofast -fomit-frame-pointer -ffast-math -mfpmath=sse -msse -msse2 -msse3 -mssse3 -msse4
  ifneq (${DEBUG},1)
    CPPFLAGS += -s
  endif
endif

# add warnings
ifeq (${WARNINGS},1)
  WARNING_FLAGS += \
      -Wextra  -Wall -Wcast-align -Wcast-qual  -Wchar-subscripts  -Wcomment \
      -Wdisabled-optimization -Wfloat-equal  -Wformat  -Wformat=2 \
      -Wformat-nonliteral -Wformat-security -Wformat-y2k -Wimport  -Winit-self \
      -Winvalid-pch -Wmissing-braces -Wmissing-field-initializers -Wmissing-format-attribute   \
      -Wmissing-include-dirs -Wmissing-noreturn -Wpacked -Wparentheses  -Wpointer-arith \
      -Wredundant-decls -Wreturn-type -Wsequence-point  -Wsign-compare  -Wstack-protector \
      -Wstrict-aliasing -Wstrict-aliasing=2 -Wswitch -Wuninitialized \
      -Wunknown-pragmas  -Wunreachable-code -Wunused -Wunused-function  -Wunused-label \
      -Wunused-parameter -Wunused-value  -Wunused-variable  -Wvariadic-macros \
      -Wvolatile-register-var  -Wwrite-strings -Wfatal-errors -Winvalid-pch \
      -Winline -Wswitch-enum -Wfatal-errors
endif

# debug Makefile
Q := @
ifeq (${DEBUG_MAKE},1)
  Q =
endif


#
# constants
#

ifneq (${OS},Windows_NT)
  red =\033[0;31m
  green =\033[0;32m
  magenta =\033[0;35m
  done =\033[0m
else
  red =
  green =
  magenta =
  done =
endif

# 
# print Makefile information
# 

$(info DEBUG    = $(if ${DEBUG},yes,no))
$(info OPTIMIZE = $(if ${OPTIMIZE},yes,no))
$(info WARNINGS = $(if ${WARNINGS},yes,no))
$(info CXX       = ${CXX})
$(info LDLFLAGS = ${LDFLAGS})
$(info CPPFLAGS = ${CPPFLAGS} $(if $WARNINGS,...WARNINGS...))
$(info ----------------)

CPPFLAGS += ${WARNING_FLAGS}

#
# rules
#

all: lang

logo.o: logo.cc logo.h

lang: scanner.o parser.o logo.o
ifneq (${DEBUG_MAKE},1)
	@echo -e '${green}${CXX} -o lang${done}'
endif
	${Q} ${CXX} -o lang $^ ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}

#
# compile C sources
#

scanner.o: scanner.yy.c parser.cc
ifneq (${DEBUG_MAKE},1)	
	@echo ${CC} -c $<
endif
	${Q} ${CC} -c ${CFLAGS} ${CPPFLAGS} $< -o $@

%.o : %.cc
ifneq (${DEBUG_MAKE},1)	
	@echo ${CXX} -c $<
endif
	${Q} ${CXX} -c ${CXXFLAGS} ${CPPFLAGS} $< -o $@

%.yy.c: %.l
ifneq (${DEBUG_MAKE},1)	
	@echo flex $<
endif
	${Q} flex -o $@ $<

%.cc: %.y
ifneq (${DEBUG_MAKE},1)	
	@echo bison $<
endif
	${Q} bison --verbose --debug -d $< -o $@
	

clean:
ifneq (${DEBUG_MAKE},1)	
	@echo -e '${red}cleaning${done}'
endif
	${Q} rm -f *.o parser.cc parser.hh parser.output scanner.yy.c lang

cloc:
	cloc *.c

help:
	@echo 'Variables that will influence this make:'
	@echo '  CXX          choose a different compiler'
	@echo '  OPTIMIZE     turn on all optimizations'
	@echo '  WARNINGS     turn on all warnings'
	@echo '  DEBUG        create debug symbols'
	@echo '  DEBUG_MAKE   debug this Makefile'

.PHONY: all clean help checkleaks doc
