all: setup update build install

.PHONY: rebuild setup update build update_repos update_deps install test clean build_normal build_min

rebuild: build install test

testbuild: build_normal install test


setup:
	@echo get ace
	[ -d ace ] || git clone https://github.com/ajaxorg/ace.git --depth 1 ace --recursive
	cd ace;git pull
	
	@echo get lua editor public
	[ -d lua_editor_gh ] || git clone --depth 1 "https://github.com/Metastruct/lua_editor.git" --branch gh-pages lua_editor_gh
	
	@echo get lua editor changes
	[ -d lua_editor_master ] || git clone --depth 1 "https://github.com/Metastruct/lua_editor.git" --branch master lua_editor_master

update: update_repos update_deps
	
update_repos:
	@echo update pages
	cd lua_editor_gh; git pull
	
	@echo update master
	cd lua_editor_master; git pull
	
	@echo Overlaying files
	cd lua_editor_master; cp ace_glua/* ../ace/lib/ace/ -r 

update_deps:	
	@echo update node deps
	cd ace; npm install; cd tool; npm install
	
	@echo Add glua to list
	cd ace/tool; node add_mode.js glua 'lua|glua' > ../../addmode.log

build: build_normal build_min

clean:
		@echo Remove existing build
		rm ace/build -rf

build_normal: clean

	@echo Normal build
	cd ace; node ./Makefile.dryice.js > ../build.log

build_min: clean

	@echo Minified build
	cd ace; node ./Makefile.dryice.js -m > ../buildmin.log 
	
install_clean:
	@echo Remove old ace version
	rm lua_editor_gh/ace/* -rf
	rm lua_editor_gh/debug/ace/* -rf

install: install_clean

	@echo Copy new minified one in lua_editor/ace
	[ ! -d ace/build/src-min ] || cp ace/build/src-min/* lua_editor_gh/ace/ -r 
	
	@echo copy normal build in lua_editor/dace
	[ ! -d ace/build/src ] || cp ace/build/src/* lua_editor_gh/debug/ace -r
	
	@cp -v lua_editor_gh/index.html lua_editor_gh/debug/index.html

.IGNORE: test

test:
	@echo Starting test http server on port 8080
	-trap 'true' INT TERM; cd lua_editor_gh; python3 -m http.server 8080
	@echo End test
