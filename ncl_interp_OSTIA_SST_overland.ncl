;***********************************************************
; Program: ncl_interp_OSTIA_SST_overland.ncl
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

 fin=addfile ("OSTIA_SST_N96_2013_12_2014_12.nc" , "r");
 tos = fin->analysed_sst;
 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; interpolation
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 guess     = 1                ; use zonal means
 is_cyclic = True             ; cyclic [global]
 nscan     = 2000             ; usually much less than this
 eps       = 1.e-2            ; variable dependent
 relc      = 0.6              ; relaxation coefficient
 opt       = 0                ; not used

 poisson_grid_fill( tos, is_cyclic, guess, nscan, eps, relc, opt)

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ouput
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 fout  = addfile ("OSTIA_SST_N96_2013_12_2014_12_interp_land.nc", "c") 
 copy_VarAtts(fin,fout)

 fout->tos=tos

 end