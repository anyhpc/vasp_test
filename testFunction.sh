#!/bin/sh
#########functions##########
function mainTest {
initAndBackup
testNPAR
endTest
}
function initAndBackup {
makeAline
source /public/software/profile.d/compiler_intel-composer_xe_2015.2.164.sh
source /public/software/profile.d/mpi_intelmpi-5.0.2.044.sh
ulimit -s unlimited
###set the path of vasp-gpu and vasp-cpu
#VASP_GPU_EXE=/public/software/apps/vasp/5.4.4/gpu/bin/vasp_gpu
#VASP_CPU_EXE=/public/software/apps/vasp/5.4.4/cpu/bin/vasp_std
VASP_CPU_EXE=/public/software/apps/vasp/5.4.1/intelmpi/cpu/vasp_std
VASP_GPU_EXE=/public/software/apps/vasp/5.4.1/intelmpi/gpu/vasp_std  
touch ./resultdir/testresult.md
mv ./resultdir/testresult.md  ./resultdir/testresult.md.bac."`date`"
touch ./resultdir/testresult.md
echo "init And Backup time:" `date` >> ./resultdir/testresult.md
CPU_CORE=(2  4)
GPU_NUM=(0 1)
NPAR_VALU=(1 2)
}
function testNPAR {
makeAline
echo "Begin test NPAR" >> ./resultdir/testresult.md
for ((k=0; k<"${#NPAR_VALU[@]}"; k++))
	do
		sed -i  "8c    NPAR = ${NPAR_VALU[$k]}" ./INCAR
		echo "NPAR = ${NPAR_VALU[k]}" >> ./resultdir/testresult.md
		makeAline
		testCPU
		testGPU		
	done
echo "NPAR test done" >> ./resultdir/testresult.md		
}
function testCPU {
echo "Begin test CPU" >> ./resultdir/testresult.md
for ((i=0; i<"${#CPU_CORE[@]}"; i++))
	do 
		echo "Process begin time:" `date` >> ./resultdir/testresult.md
		mpirun -np "${CPU_CORE[$i]}" "${VASP_CPU_EXE}" &> ./outdir/out"_""${CPU_CORE[$i]}CPU""_""${NPAR_VALU[$k]}NPAR"
		cp OUTCAR ./OUTCARDIR/OUTCAR_"${#CPU_CORE[@]}"_CPU"_""${NPAR_VALU[$k]}NPAR"
		echo ``${CPU_CORE[$i]}CPU_${NPAR_VALU[$k]}NPAR`` >> ./resultdir/testresult.md
		saveResult
	done
echo "CPU test done time:"`date` >> ./resultdir/testresult.md
echo "CPU test done" >> ./resultdir/testresult.md
makeAline
}
function testGPU {
echo "Begin test GPU" >> ./resultdir/testresult.md
echo `date` >> ./resultdir/testresult.md
echo `test GPU` >> ./resultdir/testresult.md 
for ((j=0; j<"${#GPU_NUM[@]}"; j++))
	do
		echo "GPU_NUM = ${GPU_NUM[j]}" >> ./resultdir/testresult.md
		for ((i=0; i<"${#CPU_CORE[@]}"; i++))
			do 
				echo "Process begin time:" `date` >> ./resultdir/testresult.md
				mpirun -np "${CPU_CORE[$i]}" "${VASP_GPU_EXE}" &> ./outdir/out"_""${GPU_NUM[$j]}GPU""_""${CPU_CORE[$i]}CPU""_""${NPAR_VALU[$k]}NPAR"
				cp OUTCAR ./OUTCARDIR/OUTCAR"_""${GPU_NUM[$j]}""_""${CPU_CORE[$i]}""_""${NPAR_VALU[$k]}NPAR"
				echo ``${GPU_NUM[$j]}GPU_${CPU_CORE[$i]}CPU_${NPAR_VALU[$k]}NPAR`` >> ./resultdir/testresult.md
				saveResult
			done
	done
echo "GPU test done time:" `date` >> ./resultdir/testresult.md
echo "GPU test done" >> ./resultdir/testresult.md
makeAline
}
function saveResult {
echo "Process end time:" `date` >> ./resultdir/testresult.md
echo `grep time OUTCAR | tail -4` >> ./resultdir/testresult.md
makeAline
}
function makeAline {
echo "###################################################################" >> ./resultdir/testresult.md
}
function endTest {
echo `date` >> ./resultdir/testresult.md
echo "ALL test done" >> ./resultdir/testresult.md
makeAline
exit 0
}
###########maiProgram#########
mainTest
##############################