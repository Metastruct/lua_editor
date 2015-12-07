all: setup update build install

.PHONY: rebuild setup update build update_repos update_deps install serve servebg  clean build_debug build_prod refresh_overlay build_fast ci build_slow

rebuild: build install

build_fast: build_debug install
build_slow: build_prod install


setup:
	@echo --- get ace
	[ -d ace ] || git clone https://github.com/ajaxorg/ace.git --depth 1 ace --recursive
	cd ace;git pull
	
	@echo --- get lua editor public
	[ -d lua_editor_gh ] || git clone --depth 1 "https://github.com/Metastruct/lua_editor.git" --branch gh-pages lua_editor_gh
	
	@echo --- get lua editor changes
	[ -d lua_editor_master ] || git clone --depth 1 "https://github.com/Metastruct/lua_editor.git" --branch master lua_editor_master

update: update_repos update_deps

update_repos:
	@echo --- update pages
	cd lua_editor_gh; git pull
	
	@echo --- update master
	cd lua_editor_master; git pull
	
refresh_overlay:
	@echo --- Overlaying files
	cd lua_editor_master; cp ace_glua/* ../ace/lib/ace/ -r 

	@echo --- Apply ace editor wide patch due to limitations
	#@patch -N -i lua_editor_master/ace_glua_patch1 -p0 -R > /dev/null || true
	cd ace; git checkout lib/ace/autocomplete/util.js
	patch -N -i lua_editor_master/ace_glua_patch1 -p0
	
update_deps: refresh_overlay
	@echo --- update node deps
	cd ace; npm install; cd tool; npm install
		
	@echo --- Add glua to list
	cd ace/tool; node add_mode.js glua 'lua|glua' > ../../addmode.log

build: build_debug build_prod

clean: clean_prod clean_debug
	@echo Cleaned everything
	
	
	
clean_prod:
	@echo --- Remove existing prod build
	rm ace/build/src-min -rf

clean_debug:
	@echo --- Remove existing debug build
	rm ace/build/src -rf

	
	
build_debug: clean_debug refresh_overlay

	@echo --- Debug build
	cd ace; node ./Makefile.dryice.js > ../build.log

build_prod: clean_prod refresh_overlay

	@echo --- Production build
	cd ace; node ./Makefile.dryice.js -m > ../buildmin.log 
	
	
	
install_clean:
	@echo --- Remove old ace version
	rm lua_editor_gh/ace/* -rf
	rm lua_editor_gh/debug/ace/* -rf

install: install_clean

	@echo --- Copy new minified one in lua_editor/ace
	[ ! -d ace/build/src-min ] || cp ace/build/src-min/* lua_editor_gh/ace/ -r 
	
	@echo --- copy prod build in lua_editor/dace
	[ ! -d ace/build/src ] || cp ace/build/src/* lua_editor_gh/debug/ace -r
	
	@cp -v lua_editor_gh/index.html lua_editor_gh/debug/index.html

	
	
	
.IGNORE: serve servebg ci
 

## Helper commands ##



serve:
	@echo --- Starting test http server on port 8080
	@python3 --version
	-trap 'true' INT TERM; cd lua_editor_gh; python3 -m http.server 8080
	@echo --- End test
	
servebg:
	@echo --- Starting test http server on port 8080
	@python3 --version
	cd lua_editor_gh; python3 -m http.server 8080 &
	@sleep 1
	@echo --- End test

ci:
	when-changed lua_editor_master/ace_glua/mode/glua* lua_editor_gh/index.html -c $(MAKE) build_fast