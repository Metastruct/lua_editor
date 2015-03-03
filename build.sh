git clone https://github.com/ajaxorg/ace.git --depth 1
cd ace
git pull || exit 1
cd ..

git clone --depth 1 https://github.com/Metastruct/lua_editor.git --branch gh-pages lua_editor_gh
git clone --depth 1 https://github.com/Metastruct/lua_editor.git --branch master lua_editor_master
cd lua_editor_gh
git pull || exit 1
cd ../lua_editor_master || exit 1
git pull || exit 1

cp ace_glua/* ../ace/lib/ace/ -r || exit 6
cd ..

cd ace || exit 1
npm install || exit 2
rm build -rf
node ./Makefile.dryice.js || exit 3
node ./Makefile.dryice.js -m || exit 3
rm ../lua_editor_gh/ace/* -rf || exit 9
cp build/src-min/* ../lua_editor_gh/ace/ -r || exit 10
