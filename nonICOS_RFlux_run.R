
#''***************************************************************************
#
# + Support code to Rflux library +
# 
# Utility for processing of non-ICOS files with the RFlux library
# Job: processes RFlux compliant files (converted by non_ICOS_to_RFlux.R) with RFlux package functions 
# The outpus are saved into a user defined directory
#
# @author: Giacomo Nicolini
# @contact: g.nicolini@unitus.it
# @date: 2019-12-11
#
#''***************************************************************************


# **********************************************************
## Libraries & Functions 

## In case of a new RFlux release
# install.packages("devtools")
# devtools::install_github("domvit81/RFlux", force = TRUE)
# help(package=RFlux)

kpacks <- c('RFlux', 'data.table', 'crayon')
new.packs <- kpacks[!(kpacks %in% installed.packages()[,"Package"])]
if(length(new.packs)){
  devtools::install_github("domvit81/RFlux", force = TRUE)
  install.packages(new.packs[-which(new.packs == 'RFlux')])
}
lapply(kpacks, require, character.only=T)
remove(kpacks, new.packs)

# Global options
options(scipen = 9999)


cat('\n\n')
cat(cyan('**********************************************************\n'))
cat(cyan('NON-ICOS files processing with RFlux\n'))
cat(cyan('Allow for processing of non-ICOS formatted EC files with RFlux\nConverts whichever native format and processes)\n'))
cat(cyan('**********************************************************'))
cat('\n\n')

### Create and set directories 

# cat(cyan('Set directories:\n\n '))
# # Path of RFlux complinat RAW data files and ECMD table folder
# input.dir.R <- readline(prompt = "- Path of the directory in which RFlux compliant raw data and ECMD table will be saved [no quotes]:\n ")
# # Path of RFlux output files
# output.dir.R <- readline(prompt = "- Path of the directory in which RFlux outputs will be saved [no quotes]:\n ")
# # Path of EP output files
# output.dir.EP <- readline(prompt = "- Path of the directory in which EddyPro outputs will be saved [no quotes]:\n ")
# # Path to EddyPro 'bin' folder
# EP.bin.path <- readline(prompt = '- Path to the EddyPro "bin" folder [no quotes]:\n ')


## Run the utility to convert non-ICOS files to RFlux compliant files
source(paste0(getwd(), '/nonICOS_config.R'))


## Run the utility to convert non-ICOS files to RFlux compliant files
source(paste0(getwd(), '/nonICOS_to_RFlux.R'))


# ### SET THE PROCESSING OPTIONS (as prompts to users)
# 
# cat(cyan('Set processing parameters:\n\n '))
# 
# # . Parameters of the planar fit method and the spectral correction factors 
# # taken from previous processing results (online=TRUE) or estimated by using the current set of EC rawdata (online=FALSE)
# online.RF <- readline(prompt = '- Processing options (1/7): planar fit method and spectral correction assessment files \n(from previous processing results (TRUE) or estimated using the current EC raw dataset (FALSE)): ')
# 
# # . Spectral assessment file location
# path.sa.file.RF <- readline(prompt = '- Processing options (2/7): spectral assessment file location \n(set to "NULL" if not present): ')
# 
# # . Planar fit file location
# path.pf.file.RF <- readline(prompt = '- Processing options (3/7): planar fit file location \n(set to "NULL" if not present): ')
# 
# # . Time-lag detection method (in EP)
# time.lag.method <- readline(prompt = '- Processing options (4/7): method for time lag detection in EP \n(0 None; 1 Constant time lag, 2 Maximum covariance with default; 3 Maximum covariance; 4 Automatic optimization): ')
# 
# # . Raw data despiking method (in EP)
# despikig.method <- readline(prompt = '- Processing options (5/7): method for raw data despiking in EP \n("None", not apply; "VM97", algorithm by Vickers and Mahrt (1997); "M13", algorithm by Mauder et al (2013)): ')
# 
# # . Raw data trend removal method (in EP)
# detrending.method <- readline(prompt = '- Processing options (6/7): method for trend removal in EP \n("BA" Block Average; "LD" Linear Detrending (Rannik and Vesala, 2001)): ')
# 
# # . Anemometer axis rotation method (in EP)
# tilt.method <- readline(prompt = '- Processing options (7/7): method for anemometer axis rotation in EP \n("DR" Double Rotation; "PF" Planar Fit (Wilczak et al, 2001)): ')



cat(cyan('Start processing...\n\n '))


### Process the metadata (ECMD table) [RFLux] -------------------------
# Metadata file management: Returns the input files required by LI-COR EddyPro software.

cat(cyan('ECMD metadata table processing...\n '))
get_md(path_ecmd = paste0(input.dir.R, '/', site.ID, '_ecmd.csv'),
       path_rawdata = input.dir.R,
       path_output = output.dir.EP,
       online = online.RF, 
       path_sa_file = path.sa.file.RF,
       path_pf_file = path.pf.file.RF, 
       tlag_meth = time.lag.method, 
       despike_meth = despikig.method, 
       detrend_meth = detrending.method,
       tilt_correction_meth = tilt.method) 
cat(cyan('Done.\n'))



### Test statistics of the quality control routines on RAW data -------------------------
# Returns the test statistics of the quality control routines described by Vitale et al (2019).

ec.raw.list <- list.files(input.dir.R, pattern = 'xx', full.names = TRUE)
cat(cyan('Computing statistics for the data quality control...\n '))
qcStats.res <- as.data.frame(
  do.call(rbind,
          lapply(ec.raw.list, function(x) qcStat(x, path_output = NULL, FileName = NULL))
  )
)
cat(cyan('Done.\n'))
write.csv(qcStats.res, paste0(output.dir.R, '/', site.ID, '_qcStat.csv'), quote = F, row.names = F)


### Process the data with EddyPro [RFLux] -------------------------
# Estimates flux values and other micrometeorological parameters through a call to LI-COR EddyPro software
cat(cyan('Launch EddyPro processing...\n'))
eddypro_run(siteID = site.ID,
            path_eddypro_bin = EP.bin.path,
            path_eddypro_projfiles = output.dir.EP,
            showLOG = TRUE)



### Create the dataset to be QCed [RFLux] -------------------------
# Merge time series with common indexes (times) and returns the workset data frame to be used as
# input for the data cleaning procedure via cleanFlux function
cat(cyan('Merging time series...\n'))
WorkSet <- ecworkset(path_EPout = paste0(output.dir.EP, '/', list.files(output.dir.EP, pattern = 'full_output')),
                     path_EPqc = paste0(output.dir.EP, '/', list.files(output.dir.EP, pattern = 'qc_details')),
                     path_EPmd = paste0(output.dir.EP, '/', list.files(output.dir.EP, pattern = '_metadata_')),
                     path_QCstat = paste0(output.dir.R, '/', list.files(output.dir.R, pattern = 'qcStat')),
                     path_output = output.dir.R,
                     FileName = paste0(site.ID, '_WorkSet'))
if(exists('WorkSet')){
  cat(cyan('Done.\nTime series have been merged!\n'))
}else{
  cat(red('Oops: \nan error occurred while merging time series!\n'))
}



### Cleaning eddy covariane flux measurements [RFLux] -------------------------
# Data cleaning procedure described by Vitale et al (2019).
cat(cyan('Cleaning eddy covariance fluxes...\n'))
cleanset <- cleanFlux(path_workset = paste0(output.dir.R, '/', list.files(output.dir.R, pattern = '_WorkSet')),
                      path_ecmd = paste0(input.dir.R, '/', list.files(input.dir.R, pattern = '_ecmd')),
                      path_output = output.dir.R,
                      FileName = paste0(site.ID, '_cleanset'),
                      plotQC = TRUE)
if(exists('cleanset')){
  cat(cyan('Done.\nFlux data have been processed!\n'))
}else{
  cat(red('Oops: an error occurred while cleaning data!\n'))
}


# # Save Rdata
# save.image(paste0(output.dir, '_', site.ID, '_', format(Sys.Date(), '%Y%m%d'), '.Rdata'))

