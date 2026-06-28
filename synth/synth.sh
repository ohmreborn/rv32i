DB_DIR=/nextpnr-xilinx/xilinx/external/prjxray-db
CHIPDB=/mnt/synth/chipdb
CHIPFAM=artix7

TOP=SOC
CONSTRAIN=SOC.xdc
BUILD=/mnt/synth/build
PART=xc7a35tcpg236-1

yosys -s synth.ys
pypy3 /nextpnr-xilinx/xilinx/python/bbaexport.py --device ${PART} --bba ${PART}.bba
bbasm -l ${PART}.bba ${CHIPDB}/${PART}.bin
rm -f ${PART}.bba
nextpnr-xilinx --chipdb ${CHIPDB}/${PART}.bin --xdc ${CONSTRAIN} --json ${BUILD}/${TOP}.json --fasm ${BUILD}/${TOP}.fasm
# fasm2frames --part ${PART} --db-root ${DB_DIR}/${CHIPFAM} ${BUILD}/${TOP}.fasm > ${BUILD}/${TOP}.frames
# xc7frames2bit --part_file ${DB_DIR}/${CHIPFAM}/${PART}/part.yaml --part_name ${PART} --frm_file ${BUILD}/${TOP}.frames --output_file ${BUILD}/${TOP}.bit
