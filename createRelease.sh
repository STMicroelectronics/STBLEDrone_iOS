#! /bin/bash -x

versionName=$1

cd BlueSTSDK
git tag $versionName
git push --tags origin
cd ..

cd BlueSTSDK_Gui
git tag $versionName
git push --tags origin
cd ..

git tag $versionName
git push --tags origin 

zip -r ../$versionName.zip . -x '*.git*'
