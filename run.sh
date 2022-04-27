cd RTL/five_stage/
vlog -sv *.sv
vsim -c tb_top -do "run -all"
cd ../../Synthesis/
#source dotcshrc
export LD_LIBRARY_PATH=/cae/apps/data/synopsys-2021/lc/S-2021.06/linux64/nwtn/shlib:${LD_LIBRARY_PATH}
export TERM=xterm-basic
source /cae/apps/env/synopsys-dc_shell-vS-2021.06 
rm -rf outputs_old reports_old
mv outputs outputs_old
mv reports reports_old
dc_shell -f ./syn_script.tcl -output_log_file ./dc_output.txt
cd ../APR/
rm top.vg top.sdc
cp ../Synthesis/outputs/* .
#source dotcshrc
export LD_LIBRARY_PATH=/cae/apps/data/synopsys-2021/lc/S-2021.06/linux64/nwtn/shlib:${LD_LIBRARY_PATH}
export TERM=xterm-basic
source /cae/apps/env/synopsys-icc-vS-2021.06
rm -rf outputs_old reports_old
mv outputs outputs_old
mv reports reports_old
icc_shell -f ./apr_script.tcl -shared_license
cd ../Performance
rm -rf outputs_old reports_old
mv outputs outputs_old
mv reports reports_old
rm top.post_route*
cp -f ../APR/outputs/top.post_route* .
gunzip top.post_route.spef.gz
export LD_LIBRARY_PATH=/cae/apps/data/synopsys-2021/lc/S-2021.06/linux64/nwtn/shlib:${LD_LIBRARY_PATH}
export TERM=xterm-basic
source /cae/apps/env/synopsys-PrimeTime-2021
pt_shell -f ./pt_script.tcl
