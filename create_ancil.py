"""
Filename:     calc_natSST.py
Author:       Mitchell Black, mtblack@student.unimelb.edu.au
Date:         14-11-2014 
Description:  Calculates the delta-SST fields after considering sea ice extent.
"""

## Import general Python modules ##

import numpy as np
import cdms2
import MV2
import os
import sys
import copy
import argparse

EU = os.path.expanduser
sys.path.append(EU("/Users/mtblack/Documents/University.dir/PhD.dir/Code.dir/modules.dir/"))
sys.path.append(EU("/Users/mtblack/Documents/University.dir/PhD.dir/Code.dir/data_processing.dir/"))
sys.path.append(EU("/Users/mtblack/Documents/University.dir/PhD.dir/W@H.dir/cpdn_analysis"))
sys.path.append(EU("/Users/mtblack/Documents/University.dir/PhD.dir/W@H.dir/cpdn_ancil_maker"))

from modules_netcdf import *
from cpdn_box import *
from cpdn_smooth import *

def main(rawSST_infile, deltaSST_infile, SICE_infile, HadAM3P_lsm, CMIP5_model, Model_Start_Year):
    """Calculate natural SST from observed and delta SST fields.
        
        Note:   natSST = rawSST - deltaSST
        
        Author: Mitchell Black, mtblack@student.unimelb.edu.au    
    """
    
    # Read infiles
    
    raw_SST      = read_infile(rawSST_infile,'tos')
    delta_SST    = read_infile(deltaSST_infile,'tos')
    lsm          = read_infile(HadAM3P_lsm,'lsm')
        
    # Check units: deltaSST [K]
    
    check_units(delta_SST,'K')
    check_units(raw_SST,'kelvin')

    # Check same lat/lon:
    
    check_latlon_same(delta_SST,raw_SST)

    # Duplicate deltaSST to get daily fields (repeat 6 times along time axis):
    
    delta_SST = MV2.repeat(delta_SST,repeats=6,axis=0)
    
    # Subtract deltaSST from rawSST:
    
    nat_SST = MV2.subtract(raw_SST,delta_SST)

    # Check that the mask for nat_SST is equivalent to the land sea mask
    
    if not(np.array_equiv(nat_SST.mask,lsm.mask)):
        raise ValueError, 'nat_SST mask is not the HadAM3P mask'
    
    # Write nat_SST to file:
    
    os.system('rm natSST.nc')    
    
    nat_SST.units = 'K'
    nat_SST.long_name = 'NATURAL SST'
    nat_SST.id  = 'tos'    
    write_netcdf(nat_SST,"natSST.nc")

    # Create ancillary files:
    
    cmdstring = 'python ~/Documents/University.dir/PhD.dir/Code.dir/modules.dir/gen_cpdn_sst_sice_ancil.py natSST.nc '+SICE_infile+' '+Model_Start_Year
    os.system(cmdstring)
    
    # Rename and remove files:
    oyear = str(int(Model_Start_Year)+1)
    os.system('rm sice_ancil')
    cmdstring = 'mv sst_ancil ancil_OSTIA_deltaSST_'+CMIP5_model+'_'+oyear
    os.system(cmdstring)


if __name__ == '__main__':
    
    extra_info = """ 
Usage:
    python calc_natSST.py {rawSST_infile} {deltaSST_infile} {SICE_infile} {HadAM3P_lsm} {CMIP5_model} {Model_Start_Year}
 
Author:
  Mitchell Black, mtblack@student.unimelb.edu.au
"""
    description='Calculate natural SST fields using observed and delta fields'
    parser = argparse.ArgumentParser(description=description,
                                     epilog=extra_info, 
                                     argument_default=argparse.SUPPRESS,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument("rawSST_infile", type=str, help="Input file name: observed SST")
    parser.add_argument("deltaSST_infile", type=str, help="Input file name: delta SST")
    parser.add_argument("SICE_infile", type=str, help="Input file name: SICE")
    parser.add_argument("HadAM3P_lsm", type=str, help="HadAM3P N96 land-sea mask")
    parser.add_argument("CMIP5_model", type=str, help="CMIP5 model used to calculate delta-SST")
    parser.add_argument("Model_Start_Year", type=str, help="Starting Year of Model - remember, starts in Dec of prev year")

        
    args = parser.parse_args()            
    print ''
    print 'rawSST_infile: ', args.rawSST_infile
    print 'deltaSST_infile: ', args.deltaSST_infile
    print 'SICE_infile: ', args.SICE_infile
    print 'HadAM3P_lsm: ', args.HadAM3P_lsm
    print 'CMIP5_model: ', args.CMIP5_model
    print 'Model_Start_Year: ', args.Model_Start_Year
    print ''
    
    main(args.rawSST_infile, args.deltaSST_infile, args.SICE_infile, args.HadAM3P_lsm, args.CMIP5_model, args.Model_Start_Year)