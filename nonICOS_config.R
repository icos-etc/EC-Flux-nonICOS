
# **********************************************************
# Configuration file for processing non-ICOS data with RFlux
# **********************************************************



# **********************************************************
## Station ID 
site.ID <- "DE-RuS" 


# **********************************************************
## Directories 

# Path of RAW data files and ECMD table folder
input.dir.or <- "..."

# Path of RFlux compliant RAW data files and ECMD table folder
input.dir.R <- "..."

# Path of RFlux output files
output.dir.R <- "..."

# Path of EP output files
output.dir.EP <- "..."

# Path to EddyPro bin folder
EP.bin.path <- ".../bin"



# **********************************************************
# ORIGINAL RAW DATA file format 

# number of rows to skip (include the header)
raw.line.skip <- NULL

# column separator [1 for "space", 2 for "comma", 3 for "tab", 4 for "semicolon"]
raw.sep  <- NULL

# missing data string
raw.na.string  <- NULL

# first index of the date in the file names (it must be in YYYYmmddHHMM)
raw.date.str.first <- NULL

# last index of the date in the file names (it must be in YYYYmmddHHMM)
raw.date.str.last  <- NULL

## Column indexes of the following variable:
# IF CLOSED PATH GA: U,V,W,T_SONIC,CO2,H2O,SA_DIAG,GA_DIAG,T_CELL,T_CELL_IN,T_CELL_OUT,PRESS_CELL
# IF OPEN PATH GA: U,V,W,T_SONIC,CO2,H2O,SA_DIAG,GA_DIAG
# note: if a variable is not present in the original files, use NA as index
var.index <- NULL



# **********************************************************
# PROCESSING OPTIONS 

# . Parameters of the planar fit method and the spectral correction factors 
# taken from previous processing results (online=TRUE) or estimated by using the current set of EC rawdata (online=FALSE)
online.RF <- NULL

# . Spectral assessment file location (set to "NULL" if not present)
path.sa.file.RF <- NULL

# . Planar fit file location (set to "NULL" if not present)
path.pf.file.RF <- NULL

# . Time-lag detection method (in EP)
# 0 None; 1 Constant time lag, 2 Maximum covariance with default; 3 Maximum covariance; 4 Automatic optimization
time.lag.method <- NULL

# . Raw data despiking method (in EP)
# "None", not apply; "VM97", algorithm by Vickers and Mahrt (1997); "M13", algorithm by Mauder et al (2013)
despikig.method <- NULL

# . Raw data trend removal method (in EP)
# "BA" Block Average; "LD" Linear Detrending (Rannik and Vesala, 2001)
detrending.method <- NULL

# . Anemometer axis rotation method (in EP)
# "DR" Double Rotation; "PF" Planar Fit (Wilczak et al, 2001)
tilt.method <- NULL


