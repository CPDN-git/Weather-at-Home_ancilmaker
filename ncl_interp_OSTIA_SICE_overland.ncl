;***********************************************************
; Program: ncl_interp_OSTIA_SICE_overland.ncl
; Author:  Mitchell Black (mtblack@student.unimelb.edu.au)
; Purpose: Script to interpolate OSTIA field over land.
;          Script required for producing W@H ancillary files.
;
;***********************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; read infile
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 fin=addfile ("OSTIA_SICE_N96_2013_12_2014_12.nc" , "r");
 sic = fin->sea_ice_fraction;
 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; interpolation
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 guess     = 1                ; use zonal means
 is_cyclic = True             ; cyclic [global]
 nscan     = 2000             ; usually much less than this
 eps       = 1.e-2            ; variable dependent
 relc      = 0.6              ; relaxation coefficient
 opt       = 0                ; not used

 poisson_grid_fill( sic, is_cyclic, guess, nscan, eps, relc, opt)

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ouput
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 fout  = addfile ("OSTIA_SICE_N96_2013_12_2014_12_interp_land.nc", "c") 
 copy_VarAtts(fin,fout)

 fout->sic=sic

 end