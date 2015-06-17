# Weather@home - procedure for creating ancillary files

Author: Mitchell Black (mtblack@student.unimelb.edu.au)

Note: The examples shown here are for generating the Dec 2013 -- Dec 2014 SST and SICE ancil files.

#### 1. Sourcing OSTIA data

* [MyOcean portal registration](http://www.myocean.eu/web/56-user-registration-form.php)

*	[Download OSTIA SST (via MyOcean portal)](ftp://data.ncof.co.uk/Core/SST_GLO_SST_L4_NRT_OBSERVATIONS_010_001/METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2/2014/sst/)

#### 2. Regrid OSTIA SST and SICE to N96

`bash regrid_OSTIA_N96.sh 2013 /data/ostia/2013`

`bash regrid_OSTIA_N96.sh 2014 /data/ostia/2014`

> **Code**: [regrid_OSTIA_N96.sh](https://github.com/MitchellBlack/CPDN/blob/master/regrid_OSTIA_N96.sh)
>
> **Operation**: `bash regrid_OSTIA_N96.sh {year_of_files_to_regrid} {path_to_directory_containing_files}`
>
> **Required software modules**: [cdo](https://code.zmaw.de/projects/cdo), [netcdf](http://www.unidata.ucar.edu/software/netcdf/)
>
> **Input**: _Directories containing daily OSTIA files downloaded from MyOcean portal._
>
> **Output**: _OSTIA_SICE_N96_2013.nc, OSTIA_SICE_N96_2014.nc, OSTIA_SST_N96_2013.nc, OSTIA_SST_N96_2014.nc_

#### 3. Calculate 5-day average OSTIA SST and SICE fields

SST:

`bash calc_5daymean_OSTIA.sh ./OSTIA_SST_N96_2013.nc 2013 SST`

`bash calc_5daymean_OSTIA.sh ./OSTIA_SST_N96_2014.nc 2014 SST`

SICE:

`bash calc_5daymean_OSTIA.sh ./OSTIA_SICE_N96_2013.nc 2013 SICE`

`bash calc_5daymean_OSTIA.sh ./OSTIA_SICE_N96_2014.nc 2014 SICE`

> **Code**: [calc_5daymean_OSTIA.sh](https://github.com/MitchellBlack/CPDN/blob/master/calc_5daymean_OSTIA.sh)
>
> **Operation**: `bash calc_5daymean_OSTIA.sh {infile}  {year} {field: SST or SICE }`
>
> **Required software modules**: [cdo](https://code.zmaw.de/projects/cdo)
>
> **Input**: _OSTIA_SICE_N96_2013.nc, OSTIA_SICE_N96_2014.nc, OSTIA_SST_N96_2013.nc, OSTIA_SST_N96_2014.nc_
>
> **Output**: _OSTIA_SICE_N96_2013_5daymean.nc, OSTIA_SICE_N96_2014_5daymean.nc, OSTIA_SST_N96_2013_5daymean.nc, OSTIA_SST_N96_2014_5daymean.nc_

#### 4. Select time steps for model year 

SST:

`cdo mergetime -selmon,12 OSTIA_SST_N96_2013_5daymean.nc -selmon,1,2,3,4,5,6,7,8,9,10,11,12 OSTIA_SST_N96_2014_5daymean.nc OSTIA_SST_N96_2013_12_2014_12.nc`

SICE:

`cdo mergetime -selmon,12 OSTIA_SICE_N96_2013_5daymean.nc -selmon,1,2,3,4,5,6,7,8,9,10,11,12 OSTIA_SICE_N96_2014_5daymean.nc OSTIA_SICE_N96_2013_12_2014_12.nc`

> **Output**: OSTIA_SST_N96_2013_12_2014_12.nc, OSTIA_SICE_N96_2013_12_2014_12.nc

#### 5. Interpolate OSTIA fields over land

`ncl ncl_interp_OSTIA_SST_overland.ncl`

`ncl ncl_interp_OSTIA_SICE_overland.ncl`

> **Code**: [ncl_interp_OSTIA_SST_overland.ncl](https://github.com/MitchellBlack/CPDN/blob/master/ncl_interp_OSTIA_SST_overland.ncl), [ncl_interp_OSTIA_SICE_overland.ncl](https://github.com/MitchellBlack/CPDN/blob/master/ncl_interp_OSTIA_SICE_overland.ncl)
>
> **Operation**: change input and output name in scripts
>
> **Output**: OSTIA_SICE_N96_2013_12_2014_12_interp_land.nc, OSTIA_SST_N96_2013_12_2014_12_interp_land.nc


#### 6. Adapt land sea mask of HadAM3P model

HadAM3P land-sea mask: [lsm_n96_add.nc](https://www.dropbox.com/s/j1dgrxdny0jhfmd/lsm_n96_add.nc?dl=0)

SST:

`cdo -add lsm_n96_add.nc -invertlat OSTIA_SST_N96_2013_12_2014_12_interp_land.nc OSTIA_SST_N96_2013_12_2014_12_landmask.nc`

SICE:

`cdo -add lsm_n96_add.nc -invertlat OSTIA_SICE_N96_2013_12_2014_12_interp_land.nc OSTIA_SICE_N96_2013_12_2014_12_landmask.nc`

#### 7. Create ancillary files

*	Clone [Neil Massey's cpdn repository](https://github.com/nrmassey/) onto your machine.

`python gen_cpdn_sst_sice_ancil.py OSTIA_SST_N96_2013_12_2014_12_landmask.nc tos OSTIA_SICE_N96_2013_12_2014_12_landmask.nc sic 2013`

> **Code**: [gen_cpdn_sst_sice_ancil.py](https://github.com/MitchellBlack/CPDN/blob/master/gen_cpdn_sst_sice_ancil.py)
>
> **Operation**: `gen_cpdn_sst_sice_ancil.py -h`
>
> >Change path to Neil's cpdn repo (lines 18-19 of code)
>
> **Output**: sice_ancil, sst_ancil

#### 8. Check ancillary files

| Unit   | Check | 
| :----- | :----- |
| no. time steps | 78 (starting YYYY/12/03:12.00) | 
| no. time steps | 6 time steps per month |
| no. longitude | 192 (0 to 358.125) |
| no. latitude | 145 (90 to –90) |
| SST units | SURFACE TEMPERATURE AFTER TIMESTEP (K) |
| SICE units | SEA ICE FRACTION AFTER TIMESTEP (0—1) |
