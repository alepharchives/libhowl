APP_NAME=libhowl
APP_DIR=.
OBJ=$(shell ls $(APP_DIR)/src/*.erl | sed -e 's/\.erl$$/.beam/' | sed -e 's;^$(APP_DIR)/src;$(APP_DIR)/ebin;g') $(shell ls $(APP_DIR)/src/*.app.src | sed -e 's/\.src$$//g' | sed -e 's;^$(APP_DIR)/src;$(APP_DIR)/ebin;g')
DEPS=$(shell cat rebar.config  |sed -e 's/%.*//'| sed -e '/{\(\w\+\), [^,]\+, {\w\+, [^,]\+, {[^,]\+, [^}]\+}}},\?/!d' | sed -e 's;{\(\w\+\), [^,]\+, {\w\+, [^,]\+, {[^,]\+, [^}]\+}}},\?;deps/\1/rebar.config;')
ERL=erl
PA=$(shell pwd)/$(APP_DIR)/ebin 
ERL_LIBS=`pwd`/deps/
REBAR=./rebar

all: $(DEPS) $(OBJ)

test:
	echo $(DEPS)
	echo $(OBJ)

doc: FORCE
	$(REBAR) doc
clean: FORCE
	$(REBAR) clean
	-rm *.beam erl_crash.dump
	-rm -r rel/$(APP_NAME)
	-rm rel/$(APP_NAME).tar.bz2

$(DEPS):
	$(REBAR) get-deps
	$(REBAR) compile

$(APP_DIR)/ebin/%.app: $(APP_DIR)/src/%.app.src
	$(REBAR) compile

$(APP_DIR)/ebin/%.beam: $(APP_DIR)/src/%.erl
	$(REBAR) compile

shell: all
	ERL_LIBS="$(ERL_LIBS)" $(ERL) -pa $(PA) deps/*/ebin -s libhowl
	[ -f *.beam ] && rm *.beam || true
	[ -f erl_crash.dump ] && rm erl_crash.dump || true

remove_trash:
	-find . -name "*~" -exec rm {} \;.
	-rm *.beam erl_crash.dump
FORCE:

clean-docs:
	-rm doc/*.html doc/*.png doc/*.css doc/edoc-info

docs: clean-docs
	@$(REBAR) doc skip_deps=true
