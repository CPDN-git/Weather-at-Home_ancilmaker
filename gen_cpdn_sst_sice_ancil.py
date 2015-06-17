"""
Filename:     gen_cpdn_sst_ice_ancil.py
Author:       Mitchell Black, mtblack@student.unimelb.edu.au
              Building upon original code created by Neil Massey, massey@atm.ox.ac.uk

Description:  Convert SST and SICE NetCDF to ancillary format.
"""

import sys
import os
import numpy
import math
import datetime
import fnmatch
import argparse

EU = os.path.expanduser
sys.path.append(EU("/short/w42/mtb563/cpdn_repo.dir/cpdn_analysis/"))
sys.path.append(EU("/short/w42/mtb563/cpdn_repo.dir/cpdn_ancil_maker/"))

from write_sst_sice_ancil import *
from cpdn_box import *

def read_cpdnbox(var_ncfile, varname):

    var_nparray=numpy.zeros([13*6,1,145,192],"f") # Ostia N96 Grid

    var=cpdn_box()
    var.load(var_ncfile,varname)
    var_nparray=var.get_values()

    return var_nparray

def write_ancil(sst_nparray, sice_nparray, year):
    date=[01,12,year]       # first date in the file in format [day, month, year]
    period=5                # number of days in a timestep - 5 in our case
    grid="N96"              # Ostia N96 grid
    mv=2e20                 # missing values
    sst_data=sst_nparray    # sst data as a numpy array
    sst_fname='sst_ancil'  # output name of ice ancillary file
    sice_data=sice_nparray  # ice data as a numpy array
    sice_fname='sice_ancil'   # output name of ice ancillary file
    write_data_sst_sice(date, period, grid, sst_data, sice_data, mv, sst_fname, sice_fname)
      
def main(sst_infile, sst_varname, sice_infile, sice_varname, year):
     
    sst_data  = read_cpdnbox(sst_infile, sst_varname)
    sice_data = read_cpdnbox(sice_infile, sice_varname)
    
    write_ancil(sst_data,sice_data,year)

    print 'Finished!'


#Washerboard function that allows main() to run on running this file
if __name__=="__main__":
    extra_info = """ 
Usage:
    python gen_cpdn_sst_sice_ancil.py {SST_infile} {SST_varname} {SICE_infile} {SICE_varname} {Dec_Start_Year}
    
Author:
  Mitchell Black, mtblack@student.unimelb.edu.au
"""
    description='Calculate W@H SST and SICE ancillary files'
    parser = argparse.ArgumentParser(description=description,
                                     epilog=extra_info, 
                                     argument_default=argparse.SUPPRESS,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument("SST_infile", type=str, help="Input file name: SST N96")
    parser.add_argument("SST_varname", type=str, help="Name of SST field in NetCDF")
    parser.add_argument("SICE_infile", type=str, help="Input file name: SICE N96")
    parser.add_argument("SICE_varname", type=str, help="Name of SICE field in NetCDF")
    parser.add_argument("Dec_Start_Year", type=int, help="Starting Year of Model - remember, starts in Dec of prev year")
        
    args = parser.parse_args()            
    print ''
    print 'SST_infile: ', args.SST_infile
    print 'SST_varname: ', args.SST_varname
    print 'SICE_infile: ', args.SICE_infile
    print 'SICE_varname: ', args.SICE_varname
    print 'Start_Year: ', args.Dec_Start_Year
    print ''
    
    main(args.SST_infile, args.SST_varname, args.SICE_infile, args.SICE_varname, args.Dec_Start_Year)
   
      
