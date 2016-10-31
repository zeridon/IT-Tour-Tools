#!/usr/bin/env bash
#
# label generation
set -ex

# base vars
export SCRIPT_DIRECTORY=$(cd ${0%/*} && pwd -P )

# Logging support
logCommon(){
	local logLevel=$1
	local message=$2
	echo "`date +\"%Y-%m-%d %T\"` - $logLevel - $message"
}

logInfo(){
	logCommon "INFO" "$1"
}

logWarn(){
	logCommon "WARN" "$1"
}

logError(){
	logCommon "ERROR" "$1"
}

logFatal(){ 
	logCommon "FATAL" "$1"
	exit -99
}

# check if needed software is available
function check_requirements() {
	if ! type inkscape >/dev/null ; then
		logFatal "inkscape not found"
	fi

	if ! type python >/dev/null ; then
		logFatal "python not found"
	fi


	if [ ! -r ${SCRIPT_DIRECTORY}/of-template.svg ] ; then
		logFatal "Missing label Template"
	fi

	if [ ! -r ${SCRIPT_DIRECTORY}/tool/labelmaker.py ] ; then
		logFatal "labelmaker not available. get it from https://github.com/zeridon/labelmaker and link it to \"tool\""
	fi

	if [ ! -r ${SCRIPT_DIRECTORY}/label-config.ini ] ; then
		logFatal "label config not available."
	fi

	if [ ! -r ${SCRIPT_DIRECTORY}/teniski.csv ] ; then
		logFatal "input data not found ${SCRIPT_DIRECTORY}/teniski.csv"
	fi

	if ! type pdfunite >/dev/null ; then
		logFatal "pdfunite (popler-utils) not installed"
	fi
	if ! type pdfopt >/dev/null ; then
		logFatal "pdfopt (popler-utils) not installed"
	fi
}

# do the magic to have a usable template

# cleanup the data (just a bit)
function prepare_data(){
	head -n 1 ${SCRIPT_DIRECTORY}/teniski.csv > ${SCRIPT_DIRECTORY}/_junk
	echo 'timestamp,name,kroika,color,kartinka,razmer' > ${SCRIPT_DIRECTORY}/_data.csv
	fgrep -v -f ${SCRIPT_DIRECTORY}/_junk ${SCRIPT_DIRECTORY}/teniski.csv >> ${SCRIPT_DIRECTORY}/_data.csv
}

# prepare the sheets
function prepare_label_sheets(){
	# generate svg labels
	/usr/bin/env python ${SCRIPT_DIRECTORY}/tool/labelmaker.py ${SCRIPT_DIRECTORY}/of-template.svg ${SCRIPT_DIRECTORY}/label-config.ini ${SCRIPT_DIRECTORY}/_data.csv ${SCRIPT_DIRECTORY}/out.svg --dir=row

	# convert to various formats
	for fname in $( ls -1 ${SCRIPT_DIRECTORY}/out_*.svg ) ; do
		_base=$( echo ${fname} | sed -e 's/.svg//g' )
		inkscape \
			--without-gui \
			--export-dpi 300 \
			--export-area-page \
			--export-png ${_base}.png \
			--export-eps ${_base}.eps \
			--export-pdf ${_base}.pdf \
			--file ${_base}.svg > /dev/null 2>&1
	done

	# now merge pdf's for easier printing
	pdfunite ${SCRIPT_DIRECTORY}/out_*.pdf ${SCRIPT_DIRECTORY}/teniski_etiketi.pdf
	#pdfopt ${SCRIPT_DIRECTORY}/teniski_etiketi.pdf ${SCRIPT_DIRECTORY}/_tmp.pdf && mv ${SCRIPT_DIRECTORY}/_tmp.pdf ${SCRIPT_DIRECTORY}/teniski_etiketi.pdf
}

# now generate template
check_requirements
prepare_data
prepare_label_sheets
