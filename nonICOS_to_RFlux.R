
#''***************************************************************************

# + non-ICOS to RFlux files +
# 
# Utility for processing of non-ICOS formatted files with the RFlux package.
# Job: 1. converts any raw data native format to that one usable as input to RFlux
#      2. verifies the compliance of the respective metadata (named ECMD table) and possibly adjust it
# The RFlux input files and the formatted ECMD table are saved into a user defined directory
# 
# Note: original rawdata file names must contain the time reference as YYYYmmddHHMM (possibly interspaced by "-", "_" or "T )
#
# @author: Giacomo Nicolini
# @contact: g.nicolini@unitus.it
# @date: 2019-12-20

#''***************************************************************************


## Libraries & Functions 

kpacks <- c('data.table', 'crayon')
new.packs <- kpacks[!(kpacks %in% installed.packages()[,"Package"])]
if(length(new.packs)){install.packages(new.packs)}
lapply(kpacks, require, character.only=T)
remove(kpacks, new.packs)

# Global options
options(scipen = 9999)



## Original raw data files list
or.file.list <- grep(list.files(input.dir.or, full.names = FALSE), pattern='ecmd', inv=T, value=T) # excluding the ecmd file


## - CHECK & SET ECMD table

# Check for presence of station metadata, possibly check and save it into the input folder
if(length(list.files(paste0(input.dir.or, '/'), pattern = '_ecmd')) == 0){
  cat(red('Error: a proper metadata table is required for processing.\nPlease create and save it in the original data input directory using this name:\n'))
  cat(paste0(input.dir.or, '/', site.ID, '_ecmd.csv'))
  cat(yellow('\nSee the RFlux help for variable meaning and requirements.\n\n'))
}else{
  cat(cyan('OK, a metadata table was found in the original data input directory.\nChecking its compliance...\n\n'))
  
  ## read it 
  ecmd <- fread(list.files(paste0(input.dir.or, '/'), pattern = '_ecmd', full.names = TRUE), header = T, sep=',', data.table = F)
  
  ## check and modiied it
  
  # . metadata time range
  if(ecmd$DATE_OF_VARIATION_EF[1] > as.numeric(gsub("[-_T+]", '', substr(or.file.list[1], raw.date.str.first, raw.date.str.last)))){
    cat(red('Error: raw data are earlier than metadata.\nCorrect the metadata time range and restart processing.\n\n'))
    stop('')
  }
  
  # . force number of header rows to 1 (as expected from RFlux)
  ecmd$NROW_HEADER <- 1
  
  # . force columnn separator to comma (as expected from RFlux)
  ecmd$SEPARATOR <- 'comma'
  
  
  # . sonic north alignement 
  sa.Na.na <- is.na(ecmd$SA_NORTH_ALIGNEMENT)
  if(any(ecmd$SA_MANUFACTURER[sa.Na.na] == 'gill')){
    cat(red('Error: the sonic north alignement (SA_NORTH_ALIGNEMENT) must be defined. Please specify it and restart processing.\n\n'))
    stop('')
  }
  
  # . metadata variable names: capital letters
  sens.var.names <- c('SA_MANUFACTURER','SA_MODEL','SA_WIND_DATA_FORMAT','SA_NORTH_ALIGNEMENT',
                      'GA_PATH','GA_MANUFACTURER','GA_MODEL','FILE_EXTENSION','UVW_UNITS','T_SONIC_UNITS','T_CELL_UNITS','P_CELL_UNITS',
                      'CO2_measure_type','CO2_UNITS','H2O_measure_type','H2O_UNITS','SA_DIAG','GA_DIAG')
  ecmd.sens.var <- as.list(ecmd[, sens.var.names])
  ecmd.sens.var.UP <- lapply(lapply(ecmd.sens.var, function(x) unlist(gregexpr("[A-Z]", x))), function(x) x > 0)
  if(any(unlist(ecmd.sens.var.UP))){
    # lowercase names
    ecmd[, sens.var.names] <- apply(ecmd[, sens.var.names], 2, tolower)
    cat(yellow('WARNING: some metadata variable names contain capital letters.\n'))
    cat(silver('This is not compliant and have been properly renamed.\n\n'))
  }
  
  # . metadata variable names: names complinace !TODO
  
  # . wind sector exclusion
  if(any(is.na(ecmd$SA_INVALID_WIND_SECTOR_c1))){
    # add fake values
    ecmd$SA_INVALID_WIND_SECTOR_c1 <- 1
    ecmd$SA_INVALID_WIND_SECTOR_c1 <- 0
    cat(yellow('WARNING: at least one wind sector to exclude (SA_INVALID_WIND_SECTOR_c1) must be defined, toghether with its width (SA_INVALID_WIND_SECTOR_w1).\n'))
    cat(silver('Artificial values (1 and 0) have been added to the table as it is assumed that there is not any wind sector to exclude.\n'))
    cat(silver('If however there actually is a wind sector to exclude, please add it to the table and restart processing.\n\n'))
  }
  
  
  # . force non-LI7200 closed path GA to LI-7200 (as expected from RFlux)
  # temporary patch to handle GA_DIAG in any case (will be ignored)
  if(any(ecmd$GA_PATH == 'closed')){
    if(any(ecmd$GA_MANUFACTURER != 'licor')){ecmd$GA_MANUFACTURER[ecmd$GA_MANUFACTURER != 'licor'] <- 'licor'}
    if(any(ecmd$GA_MODEL != 'li7200_1')){
      ecmd$GA_MODEL[ecmd$GA_MODEL != 'li7200_1'] <- 'li7200_1'
      cat(silver('NOTE: the actual GA has been renamed as "LI-7200" for a proper diagnostic handling. This is just a fake name and will not affect the data processing.\n'))
    }
  }
  # . force non-LI7500 open path GA to LI-7500 (as expected from RFlux)
  # temporary patch to handle GA_DIAG in any case (will be ignored)
  if(any(ecmd$GA_PATH == 'open')){
    if(any(ecmd$GA_MANUFACTURER != 'licor')){ecmd$GA_MANUFACTURER[ecmd$GA_MANUFACTURER != 'licor'] <- 'licor'}
    if(any(ecmd$GA_MODEL != 'li7500_1')){
      ecmd$GA_MODEL[ecmd$GA_MODEL != 'li7500_1'] <- 'li7500_1'
      cat(silver('NOTE: the actual GA has been renamed as "LI-7500" for a proper diagnostic handling. This is just a fake name and will not affect the data processing.\n'))}
  }
  
  # . convert NAs to characters to let them in the new table
  ecmd[is.na(ecmd)] <- 'NA'
  
  # save it to the RFlux input directory
  fwrite(ecmd, paste0(input.dir.R, '/', site.ID, '_ecmd.csv'), quote = F, sep = ',')
  
}

# stop in case there is not an ecmd  
if((length(list.files(paste0(input.dir.or, '/'), pattern = '_ecmd')) == 0)) stop('See the warnings above!')

cat(cyan('Done!\n '))


## - CHECK & SET raw data

# Close vs open path GA required column names
if(unique(ecmd$'GA_PATH') == 'closed'){
  names.compl.raw <- c('U','V','W','T_SONIC','CO2','H2O','SA_DIAG','GA_DIAG','T_CELL','T_CELL_IN','T_CELL_OUT','PRESS_CELL')
}else{
  names.compl.raw <- c('U','V','W','T_SONIC','CO2','H2O','SA_DIAG','GA_DIAG')
}

if(length(or.file.list) == 0){
  cat(yellow('WARNING: There are no data in the provided directory!\n\n'))
} else {
  cat(cyan('OK,' %+% as.character(length(or.file.list)) %+% ' files were fetched in the provided directory!\n'))
  cat(silver('If you need to see which are the required variable meaning and format please see the RFlux help.\n\n'))
  if(length(var.index) == length(names.compl.raw)){
    cat(cyan('OK, column indexes correctly reported.\n'))
  } else {
    cat(red('Error: the provided column index vector does not contain all the needed variables!'))
    stop('')
  }
}


## - Import and convert the EC raw data 

# Format the raw data according to the RFlux requirements
cat(cyan('Formatting the EC raw data...\n '))
if(raw.sep == 1){raw.sep <- ' '}
if(raw.sep == 2){raw.sep <- ','}
if(raw.sep == 3){raw.sep <- '\t'}
if(raw.sep == 4){raw.sep <- ';'}
i <- 1
for(i in 1:length(or.file.list)){
  
  # Read and extract only useful columns
  cur.raw <- fread(paste0(input.dir.or, '/', or.file.list[i]), header = FALSE, skip = as.numeric(raw.line.skip), sep = raw.sep, na.strings = as.character(raw.na.string), data.table = FALSE)
  cur.raw <- cur.raw[, na.omit(var.index)]
  names(cur.raw) <- names.compl.raw[!is.na(var.index)]
  # Possibly add the missing columns
  if(ncol(cur.raw) != length(names.compl.raw)){
    filling.df <- as.data.frame(matrix(data=-9999, nrow = nrow(cur.raw), ncol = (length(names.compl.raw)-length(na.omit(var.index)))))
    names(filling.df) <- names.compl.raw[which(is.na(var.index))]
    cur.raw <- cbind(cur.raw, filling.df)
  }
  # Arrange columns
  cur.raw <- cur.raw[, names.compl.raw]
  # save the formatted raw files
  fwrite(cur.raw, paste0(input.dir.R, '/', site.ID, '_xx_', gsub("[-_T+]", '', substr(or.file.list[i], raw.date.str.first, raw.date.str.last)), '_xxx.csv'), sep=',')
}
cat(cyan('All done! Files coverted.\n '))



