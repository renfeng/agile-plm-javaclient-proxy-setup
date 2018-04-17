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
unzip -oq JavaClient.war pcclient.jnlp

echo Current serverURL
serverURL=`grep -Po '(?<=serverURL=)[^<]*(?=<)' pcclient.jnlp`
echo "${serverURL:-(empty)} - pcclient.jnlp"

echo
if [ $# -eq 1 ] && [ -n "${url}" ]; then
	echo "New serverURL:  ${url:-(empty)}"
	sed -Ei "s~serverURL=[^<]*~serverURL=${url}~g" pcclient.jnlp
	zip -q JavaClient.war pcclient.jnlp
	zip -q application.ear JavaClient.war
else
	echo "To change serverURL, run the following command line. url cannot be empty."
	echo "jnlp-serverURL.sh 'url'"
fi

rm -r JavaClient.war pcclient.jnlp

popd > /dev/null
