LUA_SCRIPT_DIR="/usr/share/lua/5.3"
DOCS_DIR="./docs"


.PHONY: clean docs docs-clean

all:

clean:

install:
	# first install all the Lua scripts
	install -d $(DESTDIR)$(LUA_SCRIPT_DIR)/izo
	install -m 644 lua/izo.lua $(DESTDIR)$(LUA_SCRIPT_DIR)
	install -m 644 lua/izo/*.lua $(DESTDIR)$(LUA_SCRIPT_DIR)/izo

docs:
	@if ! which ldoc 2>&1 > /dev/null ; then\
		echo "Failed to locate ldoc. Try 'luarocks ldoc'";\
		false;\
	fi
	ldoc -c ./ldoc-config.ld -d $(DOCS_DIR) .

docs-clean:
	rm -rf $(DOCS_DIR)
