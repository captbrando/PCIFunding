# Load some stuff.

## Load some libs
library(tidyverse)
library(stringr)
library(data.table)
library(lazyeval)
library(splitstackshape)

# Grab my user defined functions.
source("functions.R")


# Now load data.
# 
# Data will come in two forms. The first is exported directly from the Council's
# website at http://www.pcisecuritystandards.org/. Once you refresh the data, all
# the models will work. 
# 
# The second form of data is data pulled from the Council's website and reconstructed
# in CSV format. Those are the fees. There are two conditions you must be aware of.
# The first is if the fees change, you must update the corresponding CSV to 
# ensure the models will represent accurate revenue collection. The second is if
# a new entity registers in a previously vacant country, such as Fiji, you will
# need to add a new entry with the correct fees from the website in order
# to include it in your calculations.
# 
# But seriously, who needs PCI in Fiji?  
# 
# For this read, you will notice I am doing a few things. I thought about sticking
# this into a function, but given that each one is slightly different, I thought
# it would defeat the purpose and not really provide better readability in the code.
# 
# Generally, what I am doing is this. 
# 
#  1) Define the column types I will be reading—avoids coercion later.
#  2) Define the column names. I could use the ones supplied by the Council, but
#     I decided not to because they have spaces in them. 
#  3) Read in the data.
#  4) Sometimes count the number of rows if the data contains a nested CSV.
#  5) Split out nested CSVs.
#  6) Convert data.frame to a data.table for dplyr ease of use.
#  7) OPTIONAL, if there is a fee table that I needed to create due to complex
#     fee structures (good gracious, some of these are rediculous), I would read
#     that in for later manipulation.

#QSA Data
colCls <- c(rep("character", 6))
myNames <- c("Company", "Website", "PlaceOfBusiness", "PrimaryContact", "Market", 
             "Languages")
qsadata <- read.csv("RefreshThisData/qsa_companies.csv", colClasses = colCls, 
                 na.strings = "", sep = ",", col.names = myNames, skip = 1)
numQSAs <- nrow(qsadata)
qsadata <- cSplit(qsadata, "Market", ",", "long") # Unnest CSV column Market
qsadata <- tbl_df(qsadata)

#QSA Fee Data
colCls <- c("character", rep("numeric", 4))
myNames <- c("Market", "Initial", "Annual", "QSAInitial", "QSARequal")
qsafeedata <- read.csv("RequiredForFeeCalc/qsafees.csv", colClasses = colCls, 
                    na.strings = "", sep = ",", col.names = myNames, skip = 1)
qsafeedata <- tbl_df(qsafeedata)

#PA-QSA Data
colCls <- c(rep("character", 6))
myNames <- c("Company", "Website", "PlaceOfBusiness", "PrimaryContact", "Market", 
             "Languages")
paqsadata <- read.csv("RefreshThisData/paqsa_companies.csv", colClasses = colCls, 
                    na.strings = "", sep = ",", col.names = myNames, skip = 1)
numPAQSAs <- nrow(paqsadata)
paqsadata <- cSplit(paqsadata, "Market", ",", "long") # Unnest CSV column Market
paqsadata <- tbl_df(paqsadata)

#PA-QSA Fee Data
colCls <- c("character", rep("numeric", 4))
myNames <- c("Market", "Initial", "Annual", "PAQSAInitial", "PAQSARequal")
paqsafeedata <- read.csv("RequiredForFeeCalc/paqsafees.csv", colClasses = colCls, 
                       na.strings = "", sep = ",", col.names = myNames, skip = 1)
paqsafeedata <- tbl_df(paqsafeedata)

#ASV Data
colCls <- c(rep("character", 6))
myNames <- c("Company","Website","Product","Email","Locations","CertificateNum")
asvdata <- read.csv("RefreshThisData/asv_scanning_vendors.csv", colClasses = colCls, 
                    na.strings = "", sep = ",", col.names = myNames, skip = 1)
asvdata <- tbl_df(asvdata)

#PFI Data
colCls <- c(rep("character", 6))
myNames <- c("Company", "Website", "PlaceOfBusiness", "PrimaryContact", "Market", 
             "Languages")
pfidata <- read.csv("RefreshThisData/pfi_companies.csv", colClasses = colCls, 
                    na.strings = "", sep = ",", col.names = myNames, skip = 1)
numPFIs <- nrow(pfidata)
pfidata <- cSplit(pfidata, "Market", ",", "long") # Unnest CSV column Market
pfidata <- tbl_df(pfidata)

#PFI Fee Data
colCls <- c("character", rep("numeric", 2))
myNames <- c("Market", "Initial", "Annual")
pfifeedata <- read.csv("RequiredForFeeCalc/pfifees.csv", colClasses = colCls, 
                       na.strings = "", sep = ",", col.names = myNames, skip = 1)
pfifeedata <- tbl_df(pfifeedata)

#PTS Data
colCls <- c(rep("character", 16))
myNames <- c("ManufacturerName","ModelName","HardWareNumber","FirmWareNumber",
             "ApplicationNumber","ApprovalNumber","Version","ProductType",
             "ExpiryDate","ApprovalClass","PINSupport","KeyManagement",
             "PromptControl","PINEntryTechnology","FunctionsProvided","not_marketed")
ptsdata <- read.csv("RefreshThisData/approved_pin_transaction_security.csv", colClasses = colCls, 
                    na.strings = "", sep = ",", col.names = myNames, skip = 1)
ptsdata <- tbl_df(ptsdata)

#P2PE Data
colCls <- c(rep("character", 7))
myNames <- c("Company", "Website", "Type", "PlaceOfBusiness", "PrimaryContact", "Market", 
             "Languages")
p2pedata <- read.csv("RefreshThisData/p2pe_companies.csv", colClasses = colCls, 
                    na.strings = "", sep = ",", col.names = myNames, skip = 1)
p2pedata <- cSplit(p2pedata, "Type", ",", "long") # Unnest CSV column Type
p2pedata <- cSplit(p2pedata, "Market", ",", "long") # Unnest CSV column Market
p2pedata <- tbl_df(p2pedata)

#P2PE Fee Data
colCls <- c("character", rep("numeric", 4))
myNames <- c("Market", "Initial", "Annual", "P2PEQSAInitial", "P2PEQSARequal")
p2pefeedata <- read.csv("RequiredForFeeCalc/p2pefees.csv", colClasses = colCls, 
                       na.strings = "", sep = ",", col.names = myNames, skip = 1)
p2pefeedata <- tbl_df(p2pefeedata)

#QIR Data
colCls <- c(rep("character", 6))
myNames <- c("Company", "Website", "PlaceOfBusiness", "PrimaryContact", "Languages", 
             "DateListed")
qirdata <- read.csv("RefreshThisData/qir_companies.csv", colClasses = colCls, 
                    na.strings = "", sep = ",", col.names = myNames, skip = 1)
numQIRs <- nrow(qirdata)
qirdata <- tbl_df(qirdata)

#Validated Application Data
colCls <- c(rep("character", 13))
myNames <- c("ApplicationVendor","Website","PaymentApp","Version","ApplicationType",
             "TargetMarket","ReferenceNum","ValidatedBy","DeploymentNotes",
             "RevalidateDate","ExpiryDate","ValidatedbyPA-QSA","Description")
valappdata <- read.csv("RefreshThisData/validated_payment_applications.csv", colClasses = colCls, 
                    na.strings = "", sep = ",", col.names = myNames, skip = 1)
numValApps <- nrow(valappdata)
valappdata <- tbl_df(valappdata)

rm(myNames, colCls) # Remove these temporary variables from our namespace.

# Data Transformation Section
# 
# In this section, I will do a few data transforms that will help us later on. 
# 
# First, we want to join the fees all together in one table.
# 
# This is a temporary step in order to do the big calculation at the end.
AggregateQSAFeeData <- doMarketGrouping(qsadata, qsafeedata)
AggregatePAQSAFeeData <- doMarketGrouping(paqsadata, paqsafeedata)
AggregatePFIFeeData <- doMarketGrouping(pfidata, pfifeedata)
AggregateP2PEFeeData <- doMarketGrouping(p2pedata, p2pefeedata)

# Now we want the TOTAL fees in each column. For this, we will make some assumptions:
# 
# Assume an average of 4 QSAs per company per market. This is a HUGE swag, but 
# actually ends up working out quite nicely based on data presented by Orfei at the
# last community meeting. Will also leverage this count for P2PE and PA QSA.
# 
# Yes, I know this is messy code. It could probably be dropped into a function
# using dots and lazyeval. 
#  
# If you want to adjust, simply change the variable below:
AverageQSACount <- 4
AggregateQSAFeeData$Initial <- AggregateQSAFeeData$count * AggregateQSAFeeData$Initial
AggregateQSAFeeData$Annual <- AggregateQSAFeeData$count * AggregateQSAFeeData$Annual
AggregateQSAFeeData$QSAInitial <- 
  AggregateQSAFeeData$count * AggregateQSAFeeData$QSAInitial * AverageQSACount
AggregateQSAFeeData$QSARequal <- 
  AggregateQSAFeeData$count * AggregateQSAFeeData$QSARequal * AverageQSACount

# PAQSA data.
AggregatePAQSAFeeData$Initial <- AggregatePAQSAFeeData$count * AggregatePAQSAFeeData$Initial
AggregatePAQSAFeeData$Annual <- AggregatePAQSAFeeData$count * AggregatePAQSAFeeData$Annual
AggregatePAQSAFeeData$PAQSAInitial <- 
  AggregatePAQSAFeeData$count * AggregatePAQSAFeeData$PAQSAInitial * AverageQSACount
AggregatePAQSAFeeData$PAQSARequal <- 
  AggregatePAQSAFeeData$count * AggregatePAQSAFeeData$PAQSARequal * AverageQSACount

# PFI data.
AggregatePFIFeeData$Initial <- AggregatePFIFeeData$count * (AggregatePFIFeeData$Initial + 2500)
AggregatePFIFeeData$Annual <- AggregatePFIFeeData$count * AggregatePFIFeeData$Annual

# P2PE data.
AggregateP2PEFeeData$Initial <- AggregateP2PEFeeData$count * AggregateP2PEFeeData$Initial
AggregateP2PEFeeData$Annual <- AggregateP2PEFeeData$count * AggregateP2PEFeeData$Annual
AggregateP2PEFeeData$P2PEQSAInitial <- 
  AggregateP2PEFeeData$count * AggregateP2PEFeeData$P2PEQSAInitial * AverageQSACount
AggregateP2PEFeeData$P2PEQSARequal <- 
  AggregateP2PEFeeData$count * AggregateP2PEFeeData$P2PEQSARequal * AverageQSACount

# Now we will total some things up for fun. First QSA Fees.
QSAFeeSummary <- AggregateQSAFeeData %>% 
  select(Initial,Annual,QSAInitial,QSARequal) %>% 
  summarize_each(funs(sum))

# Then PA-QSA Fees
PAQSAFeeSummary <- AggregatePAQSAFeeData %>% 
  select(Initial,Annual,PAQSAInitial,PAQSARequal) %>% 
  summarize_each(funs(sum))

# Then PFI Fees
PFIFeeSummary <- AggregatePFIFeeData %>% 
  select(Initial,Annual) %>% 
  summarize_each(funs(sum))

# Then P2PE Fees
P2PEFeeSummary <- AggregateP2PEFeeData %>% 
  select(Initial,Annual,P2PEQSAInitial) %>% 
  summarize_each(funs(sum))


# Next, let's grab ASV data.
# 
# This is relatively easy. The ASV program has an initial and an annual
# fee. So we're just going to focus on the recurring revenue with the following
# additional assumptions. 
# 
# 5% of companies require retesting.
# 2% of companies do an optional mid-year check.
# Each ASV company has at least 4 employees to train per yer.
# 
# If you want to adjust those assumptions, just change the variables below:

ASVRetest <- .05
ASVMidYear <- .02
ASVEmployee <- 4

ASVFeeData <- data.table(AnnualRequal = nrow(asvdata) * 12500,
                         AnnualRetest = nrow(asvdata) * 6500 * ASVRetest,
                         MidYearRev = nrow(asvdata) * 6500 * ASVMidYear,
                         AnnualTraining = nrow(asvdata) * 1095 * ASVEmployee)


