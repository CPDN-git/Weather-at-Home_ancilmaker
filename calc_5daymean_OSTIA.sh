#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# File:     calc_5daymean_OSTIA.sh
# Purpose:  A script for calculating 5-day mean OSTIA SST and SICE fields
#           for creating weather@home ancillary files.
# Author:   Mitchell Black (mtblack@student.unimelb.edu.au)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function usage {
    echo "USAGE: bash $0 INFILE YEAR"
    echo "   INFILE: full path of infile"
    echo "   YEAR:   Year to perform calculation on"
    echo "   FIELD:   SST or SICE"
    echo "   e.g. bash $0 ./OSTIA_SICE_N96_2014.nc 2014 SICE"
    exit 1
}

# Check correct number of input arguments:
narg=3
infile=$1
year=$2
field=$3

if [[ $# -ne $narg ]] ; then
  usage
fi

if [[ "$field" != "SICE" ]] && [[ "$field" != "SST" ]] ; then
   echo "Field must be SST or SICE"
   exit
fi

# Load modules:

module load cdo

# Calculate 5-day mean fields for each month:

cdo -splitmon -selyear,$year $infile ${year}_mon

for month in ${year}_mon04.nc ${year}_mon06.nc ${year}_mon09.nc ${year}_mon11.nc; do

  echo $month

  cdo splitday $month day  

  cdo ensmean day01.nc day02.nc day03.nc day04.nc day05.nc 5daymean_temp_1.nc
  cdo ensmean day06.nc day07.nc day08.nc day09.nc day10.nc 5daymean_temp_2.nc
  cdo ensmean day11.nc day12.nc day13.nc day14.nc day15.nc 5daymean_temp_3.nc
  cdo ensmean day16.nc day17.nc day18.nc day19.nc day20.nc 5daymean_temp_4.nc
  cdo ensmean day21.nc day22.nc day23.nc day24.nc day25.nc 5daymean_temp_5.nc
  cdo ensmean day26.nc day27.nc day28.nc day29.nc day30.nc 5daymean_temp_6.nc
   
  cdo mergetime 5daymean_temp_*.nc OSTIA_n96_${month}_5days.nc
 
  rm day*.nc
  rm 5daymean_temp_*.nc
  rm $month
done

for month in ${year}_mon01.nc ${year}_mon03.nc ${year}_mon05.nc ${year}_mon07.nc ${year}_mon08.nc ${year}_mon10.nc ${year}_mon12.nc; do

  echo $month

  cdo splitday $month day  
  cdo ensmean day01.nc day02.nc day03.nc day04.nc day05.nc 5daymean_temp_1.nc
  cdo ensmean day06.nc day07.nc day08.nc day09.nc day10.nc 5daymean_temp_2.nc
  cdo ensmean day11.nc day12.nc day13.nc day14.nc day15.nc 5daymean_temp_3.nc
  cdo ensmean day16.nc day17.nc day18.nc day19.nc day20.nc 5daymean_temp_4.nc
  cdo ensmean day21.nc day22.nc day23.nc day24.nc day25.nc 5daymean_temp_5.nc
  cdo ensmean day26.nc day27.nc day28.nc day29.nc day30.nc day31.nc 5daymean_temp_6.nc

  cdo mergetime 5daymean_temp_*.nc OSTIA_n96_${month}_5days.nc
   
  rm day*.nc
  rm 5daymean_temp_*.nc
  rm $month
done

for month in ${year}_mon02.nc; do  #special case because 28 days

  echo $month

  cdo splitday $month day 

  cdo ensmean day01.nc day02.nc day03.nc day04.nc day05.nc 5daymean_temp_1.nc
  cdo ensmean day06.nc day07.nc day08.nc day09.nc day10.nc 5daymean_temp_2.nc
  cdo ensmean day11.nc day12.nc day13.nc day14.nc day15.nc 5daymean_temp_3.nc
  cdo ensmean day16.nc day17.nc day18.nc day19.nc day20.nc 5daymean_temp_4.nc
  cdo ensmean day21.nc day22.nc day23.nc day24.nc 5daymean_temp_5.nc
  cdo ensmean day25.nc day26.nc day27.nc day28.nc 5daymean_temp_6.nc
   
  cdo mergetime 5daymean_temp_*.nc OSTIA_n96_${month}_5days.nc
 
  rm day*.nc
  rm 5daymean_temp_*.nc
  rm $month
done

cdo mergetime OSTIA_n96*_5days.nc OSTIA_${field}_N96_${year}_5daymean.nc
rm OSTIA_n96*_5days.nc
