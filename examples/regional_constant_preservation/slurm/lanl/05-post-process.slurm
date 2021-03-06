#!/bin/bash
#
#SBATCH
#
# //////////////////////////// #
#

mkdir -p ${OUTDIR}/post/diff/absmax
mkdir -p ${OUTDIR}/post/plots/Volume_00/absmax
mkdir -p ${OUTDIR}/post/plots/DyeTracer_00/error

# Start the curve file
echo "# iterate, error" > ${OUTDIR}/post/diff/absmax/error.curve

for f in ${OUTDIR}/Tracer.00000.00*.nc; do

  outfile=$(echo $f | awk -F '/' '{print $(NF)}')
  iterate=$(echo $outfile | awk -F '.' '{print $3}' | sed 's/^0*//')

  echo $outfile

  ## <><><><><><><><><><><><> Calculate Tracer Error <><><><><><><><><><><><> ##
  #
  # Take the difference between the initial tracer field and a later field
  # For this test case, the exact solution has the field maintaining a constant value,
  # thus, the difference with the initial condition is a measure of the error
  ncdiff ${OUTDIR}/Tracer.00000.init.nc $f ${OUTDIR}/post/diff/${outfile}

  # Calculate the absolute max for each diff file
  ncwa -y mabs ${OUTDIR}/post/diff/${outfile} ${OUTDIR}/post/diff/absmax/${outfile}

  # Get the absolute max value from the netcdf file and write to the curve file
  ncdump -v DyeTracer_00 ${OUTDIR}/post/diff/absmax/${outfile} | grep "DyeTracer_00 = " | awk -F '=' '{print $2}' | sed 's/;//g' >> ${OUTDIR}/post/diff/absmax/error.curve


  ## <><><><><><><><><><><><> Plot Volume Scatter Plot <><><><><><><><><><><><> ##
  #
  # Here, we call a python script to plot the volume correction term as a scatter plot
  # with the volume varying in the x-axis and the depth in the y-axis

  python3 zProfile.py plot $f --opts="logx" --field="Volume_00" --stats="absmax" --out="${OUTDIR}/post/plots/Volume_00/absmax"

  ## <><><><><><><><><><><><> Plot Volume Scatter Plot <><><><><><><><><><><><> ##
  #
  # Here, we call a python script to plot vertical profiles of the tracer error
  # we calculated earlier.

  python3 zProfile.py plot ${OUTDIR}/post/diff/${outfile} --opts="logx" --field="DyeTracer_00" --out="${OUTDIR}/post/plots/DyeTracer_00/error"

done
