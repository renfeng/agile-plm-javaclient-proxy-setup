#!/usr/bin/env bash

if [ ! -d agileDomain/applications ]; then
        >&2 echo "Must run in the directory of AGILE_HOME"
        exit 1
fi
if [ $# -gt 1 ]; then
        >&2 echo "Illegal Argument: $2"
        exit 1
fi

pushd agileDomain/applications > /dev/null

url=$1

unzip -oq application.ear JavaClient.war
unzip -oq JavaClient.war custom.jnlp pcclient.jnlp wls/ext.jnlp hotfixes/hf*.jnlp 2> /dev/null

list=(custom.jnlp pcclient.jnlp wls/ext.jnlp)
if [ -d hotfixes ]; then
	while read -r item; do
		list+=(hotfixes/$item)
	done <<< "`ls -v hotfixes`"
fi

echo Current codebase
for item in ${list[*]}; do
	codebase=`grep -Po '(?<=codebase=")[^"]*(?=")' ${item}`
	echo "${codebase:-(empty)} - ${item}"
done

echo
if [ $# -eq 1 ]; then
	echo "New codebase:  ${url:-(empty)}"
	for item in ${list[*]}; do
		sed -Ei 's~codebase="[^"]*"~codebase="'${url}'"~g' ${item}
	done
	zip -q JavaClient.war custom.jnlp pcclient.jnlp wls/ext.jnlp hotfixes/hf*.jnlp
	zip -q application.ear JavaClient.war
else
	echo "To change codebase, run the following command line. url can be empty."
	echo "jnlp-codebase.sh 'url'"
	echo "jnlp-codebase.sh ''"
fi

rm -r JavaClient.war custom.jnlp pcclient.jnlp wls/
if [ -d hotfixes ]; then
	rm -r hotfixes
fi

popd > /dev/null
