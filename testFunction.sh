#!/bin/sh
#########functions##########
function mainTest {
initAndBackup
testNPAR
endTest
}
function initAndBackup {
#source /public/software/profile.d/compiler_intel-composer_xe_2015.2.164.sh
#source /public/software/profile.d/mpi_intelmpi-5.0.2.044.sh
#ulimit -s unlimited
###set the path of vasp-gpu and vasp-cpu
VASP_GPU_EXE=/public/software/apps/vasp/5.4.4/gpu/bin/vasp_gpu
VASP_CPU_EXE=/public/software/apps/vasp/5.4.4/cpu/bin/vasp_std   
touch testresult.md 
cp testresult.md ./testresult.md.bac."`date`"
echo "init And Backup time:" `date` >> testresult.md
CPU_CORE=(2  4)
GPU_NUM=(0 1)
NPAR_VALU=(1 2)
}
function testNPAR {
makeAline
echo "Begin test NPAR" >> testresult.md
for ((k=0; k<"${#NPAR_VALU[@]}"; k++))
	do
		sed -i  "8c    NPAR = ${NPAR_VALU[$k]}" ./INCAR
		echo "NPAR = ${NPAR_VALU[k]}" >> testresult.md
		makeAline
		testCPU
		testGPU		
	done
echo "NPAR test done" >> testresult.md		
}
function testCPU {
echo "Begin test CPU" >> testresult.md
for ((i=0; i<"${#CPU_CORE[@]}"; i++))
	do 
		echo "${CPU_CORE[$i]}" "${VASP_CPU_EXE}" &> ./out"_""${CPU_CORE[$i]}CPU""_""${NPAR_VALU[$k]}NPAR"
		cp ./OUTCAR ./OUTCAR_0_GPU_"${#CPU_CORE[@]}"_CPU"_""${NPAR_VALU[$k]}NPAR"
		echo "Process begin time:" `date` >> testresult.md
		echo ``${CPU_CORE[$i]}CPU_${NPAR_VALU[$k]}NPAR`` >> testresult.md
		saveResult
	done
echo "CPU test done time:"`date` >> testresult.md
echo "CPU test done" >> testresult.md
makeAline
}
function testGPU {
echo "Begin test GPU" >> testresult.md
echo `date` >> testresult.md
echo `test GPU` >> testresult.md 
for ((j=0; j<"${#GPU_NUM[@]}"; j++))
	do
		echo "GPU_NUM = ${GPU_NUM[j]}" >> testresult.md
		for ((i=0; i<"${#CPU_CORE[@]}"; i++))
			do 
				echo "${CPU_CORE[$i]}" "${VASP_GPU_EXE}" &> ./out"_""${GPU_NUM[$j]}GPU""_""${CPU_CORE[$i]}CPU""_""${NPAR_VALU[$k]}NPAR"
				cp ./OUTCAR ./OUTCAR"_""${GPU_NUM[$j]}""_""${CPU_CORE[$i]}""_""${NPAR_VALU[$k]}NPAR"
				echo "Process begin time:" `date` >> testresult.md
				echo ``${GPU_NUM[$j]}GPU_${CPU_CORE[$i]}CPU_${NPAR_VALU[$k]}NPAR`` >> testresult.md
				saveResult
			done
	done
echo "GPU test done time:" `date` >> testresult.md
echo "GPU test done" >> testresult.md
makeAline
}
function saveResult {
echo "Process end time:" `date` >> testresult.md
echo `grep time OUTCAR | tail -4` >> testresult.md
makeAline
}
function makeAline {
echo "###################################################################" >> testresult.md
}
function endTest {
echo `date` >> testresult.md
echo "ALL test done" >> testresult.md
makeAline
exit 0
}
###########maiProgram#########
mainTest
##############################