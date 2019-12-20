
# **********************************************************
# Configuration file for processing non-ICOS data with RFlux
# **********************************************************



# **********************************************************
## Station ID 
site.ID <- "DE-RuS" 


# **********************************************************
## Directories 

# Path of RAW data files and ECMD table folder
input.dir.or <- "C:/WORK/R/PROJECTS/EC-Flux-nonICOS/DE-RuS_or"

# Path of RFlux compliant RAW data files and ECMD table folder
input.dir.R <- "C:/WORK/R/PROJECTS/EC-Flux-nonICOS/input"

# Path of RFlux output files
output.dir.R <- "C:/WORK/R/PROJECTS/EC-Flux-nonICOS/output"

# Path of EP output files
output.dir.EP <- "C:/WORK/R/PROJECTS/EC-Flux-nonICOS/EP"

# Path to EddyPro bin folder
EP.bin.path <- "C:/Program Files/LI-COR/EddyPro-7.0.4/bin"



# **********************************************************
# ORIGINAL RAW DATA file format 

# number of rows to skip (include the header)
raw.line.skip <- 1

# column separator [1 for "space", 2 for "comma", 3 for "tab", 4 for "semicolon"]
raw.sep  <- 2

# missing data string
raw.na.string  <- -9999

# first index of the date in the file names (it must be in YYYYmmddHHMM)
raw.date.str.first <- 1

# last index of the date in the file names (it must be in YYYYmmddHHMM)
raw.date.str.last  <- 12

## Column indexes of the following variable:
# IF CLOSED PATH GA: U,V,W,T_SONIC,CO2,H2O,SA_DIAG,GA_DIAG,T_CELL,T_CELL_IN,T_CELL_OUT,PRESS_CELL
# IF OPEN PATH GA: U,V,W,T_SONIC,CO2,H2O,SA_DIAG,GA_DIAG
# note: if a variable is not present in the original files, use NA as index
var.index <- c(1,2,3,4,8,9,NA,7)



# **********************************************************
# PROCESSING OPTIONS 

# . Parameters of the planar fit method and the spectral correction factors 
# taken from previous processing results (online=TRUE) or estimated by using the current set of EC rawdata (online=FALSE)
online.RF <- FALSE

# . Spectral assessment file location (set to "NULL" if not present)
path.sa.file.RF <- NULL

# . Planar fit file location (set to "NULL" if not present)
path.pf.file.RF <- NULL

# . Time-lag detection method (in EP)
# 0 None; 1 Constant time lag, 2 Maximum covariance with default; 3 Maximum covariance; 4 Automatic optimization
time.lag.method <- 2

# . Raw data despiking method (in EP)
# "None", not apply; "VM97", algorithm by Vickers and Mahrt (1997); "M13", algorithm by Mauder et al (2013)
despikig.method <- "VM97"

# . Raw data trend removal method (in EP)
# "BA" Block Average; "LD" Linear Detrending (Rannik and Vesala, 2001)
detrending.method <- "BA"

# . Anemometer axis rotation method (in EP)
# "DR" Double Rotation; "PF" Planar Fit (Wilczak et al, 2001)
tilt.method <- "DR"


