# ICE-Arrests-Varition-in-Targeting

Files for the replication of "ICE Arrests, 2015-2026: Variation in Targeting, Method, and Geography" by Chloe N. East, Caitlin Patler, and Elizabeth Cox 

To replicate these results, users need to set the paths in 00_setup.do (and the working drives in the R files) to match their directories, and run the files in the "analysis" folder in sequential order. 

Analysis Files: 
- 00_setup.do: Sets global paths in stata for where to read data and save results
- 0.25_CleanACS: Appends and saves 5-year ACS detailed tables (B05001) with non-citizen count for all U.S. counties
- 0.5_MakeLongRunData.R: Appends and saves Garcia Hernandez data and Deportation Data Project data covering 2015-2026 for longer run analysis
- 0.75_AppendDDP.do: Appends and saves Deportation Data Project data for shorter run analysis
- 01_NationalAnalysis.do: Uses saved cleaned data to perform longer run analysis and decomposition exercise
- 02_AnalysisByAOR.do: Creates series for term 1 and term 2 for the number of arrests by apprehension method by AOR, and saves for final plotting
- 03_PlotByAOR.R: Uses data saved in 02_AnalysisByAOR.do to create final plot
