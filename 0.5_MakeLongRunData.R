#############################
# Plot Arrests by AOR and Apprehension Method, Relative to Inauguration
#############################
# By Adam Sawyer 
# June 16, 2026
#############################

#############################
# This uses DDP and Garcia Hernandez data to create a single dataset with 
# # arrests and % convicted over time
#############################

#=============================
# Load Packages  
#=============================

library(tidyverse)
library(tidylog)
library(openxlsx)
library(lubridate)
library(janitor)
library(purrr)
library(zoo)
library(xts)
library(utils)

setwd("") # Set working directory path here

#=============================
# Define Helper Function: read all sheets from an Excel file
#=============================

file_reader <- function(file){
  # Get all sheet names
  sheets <- getSheetNames(file)
  
  # Read all sheets into a named list
  data_list <- lapply(sheets, function(sheet) {
    read.xlsx(file, sheet = sheet)
  })
  
  # Name each list element by sheet name
  names(data_list) <- sheets
  
  all_data <- bind_rows(data_list, .id = "SheetName")
}

#=============================
# Dataset 1: Garcia Hernandez Data (FY2015--FY2023)
#=============================

path <- "" # Set path to where this data is saved here

# Get list of all Excel files
files <- list.files(path, pattern = "\\.xlsx?$", full.names = TRUE)

# Read and combine — adds source filename as a column
combined_df <- map_dfr(files, ~ {
  df <- read.xlsx(.x)
  df$source_file <- basename(.x)
  df
})

# Clean and Aggregate
final_garcia <- combined_df |>
  row_to_names(row_number = 3) |>
  mutate(`Apprehension Date` = as.Date(as.numeric(`Apprehension Date And Time`), origin = "1899-12-30")) |>
  mutate(`Apprehension Date` = format(as.Date(`Apprehension Date`), "%Y-%m-%d")) |>
  distinct() |>
  mutate(criminality = ifelse(`Most Serious Criminal Conviction Charge Status` == "Convicted",
                              "Convicted", "Pending/NA")) |>
  select(c(`Apprehension Date`, criminality, `Apprehension Method`)) |>   # optionally add `Apprehension Method`
  mutate(criminality = ifelse(is.na(criminality), "Pending/NA", criminality)) |>   # convert NA to Pending/NA
  mutate(arrest_date = date(`Apprehension Date`)) |>
  group_by(arrest_date, criminality, `Apprehension Method`) |>   # optionally add `Apprehension Method`
  count() |>
  filter(!is.na(arrest_date)) |>
  group_by(arrest_date) |>
  mutate(pct = 100 * (n / sum(n))) |>   # percent of daily arrests by criminality category
  mutate(dataset = "Garcia") |>
  filter(arrest_date <= as.Date("2023-08-31"))

# Save Appended Garcia Hernandez Data
appended_garcia <- combined_df |>
  row_to_names(row_number = 3) |>
  mutate(`Apprehension Date` = as.Date(as.numeric(`Apprehension Date And Time`), origin = "1899-12-30")) |>
  mutate(`Apprehension Date` = format(as.Date(`Apprehension Date`), "%Y-%m-%d"))

write.csv(appended_garcia, "./Data/Appended_Garcia.csv")

#=============================
# Dataset 3: DDP Data (FY2023--2026)
#=============================

path <- "" # Set path to where DDP data is saved here

# Get list of all Excel files
files <- list.files(path, pattern = "^[^~].*\\.xlsx?$", full.names = TRUE)

# Read and combine — adds source filename as a column
combined_df <- map_dfr(files, ~ {
  df <- read.xlsx(.x)
  df$source_file <- basename(.x)
  df
})

arrests_clean <- combined_df |>
  row_to_names(row_number = 4)

no_duplicates <- arrests_clean |>
  distinct() |>
  select(c("Apprehension Date", "TOA Current Duty AOR", "Apprehension Method",
           "Apprehension Criminality"))

# Clean and Aggregate
final_ddp <- no_duplicates |>
  mutate(`Apprehension Date` = convertToDateTime(`Apprehension Date`)) |>
  mutate(arrest_date = date(`Apprehension Date`)) |>
  group_by(arrest_date, `Apprehension Criminality`, `Apprehension Method`) |>   # optionally add `Apprehension Method`
  count() |>
  filter(!is.na(arrest_date)) |>
  group_by(arrest_date) |>
  mutate(pct = 100 * (n / sum(n))) |>
  rename(criminality = `Apprehension Criminality`) |>
  mutate(dataset = "DDP") |>
  mutate(criminality = ifelse(criminality == "1 Convicted Criminal", "Convicted", "Pending/NA")) |>   # align labels with Garcia
  filter(arrest_date >= as.Date("2023-09-01"))

#=============================
# Combine Datasets (FY2015--2026)
#=============================

all_arrests <- bind_rows(final_ddp, final_garcia) |>
  rename(`Apprehension Date` = arrest_date,
         arrests = n)

# Write csv
write.csv(all_arrests, "Data/unsmoothed_arrests_criminality_method_fy15_26.csv", row.names = FALSE)


