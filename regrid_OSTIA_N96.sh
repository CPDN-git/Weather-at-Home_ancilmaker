#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# File:     regrid_OSTIA_N96.sh
# Purpose:  A script for regridding daily OSTIA files to N96 resolution.
# Author:   Mitchell Black (mtblack@student.unimelb.edu.au)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function usage {
    echo "USAGE: bash $0 year dir_path"
    echo "   year: year to regrid"
    echo "   dir_path: path to files"
    echo "   e.g. bash $0 2014 /data/ostia/2014"
    exit 1
}

# Check correct number of input arguments:
narg=2

if [[ $# -ne $narg ]] ; then
  usage
fi

# Assign input arguments:

year=$1
dir_path=$2

echo "Year" $year
echo "File directory" $dir_path

# Load modules
  
module load cdo
module load nco
module load netcdf

# Create list of input files:

ls ${dir_path}/${year}*OSTIA*.nc > infile
file_list=`cat infile`     
rm infile

# Regrid SST and SICE to N96:
 
counter=1
for i in $file_list 

  do
     # files >2006 are HDF5, so convert to classic netcdf for use in cdo:

     nccopy -k classic ${i} classic.nc
    
     # unpack netcdf files:
     
     ncpdq -U classic.nc unpacked.nc
     
     cdo -remapbil,r192x145 -selvar,analysed_sst unpacked.nc SST_N96_${counter}.nc
     cdo -remapbil,r192x145 -selvar,sea_ice_fraction unpacked.nc SICE_N96_${counter}.nc
     rm classic.nc unpacked.nc

     counter=$((counter+1))
  done     

# Merge timesteps

cdo mergetime SST_N96_*.nc OSTIA_SST_N96_${year}.nc
cdo mergetime SICE_N96_*.nc OSTIA_SICE_N96_${year}.nc

# Remove unwanted files

rm SST_N96_*.nc
rm SICE_N96_*.nc