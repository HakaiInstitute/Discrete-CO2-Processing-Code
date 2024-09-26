# Discrete CO2 Processing Code

Matlab scripts for post-processing of discrete CO2 data.

CO2SYS.m: CO2SYSv3 software compatible with MATLAB for calculating marine CO2 system variables (Sharp et al., 2023).

SRVC_CO2_Carb_Calcs.m: calculates derived carbonate parameters from directly measured TCO2 and pCO2 of discrete bottle samples. Code outputs: corrected alakalinity, in-situ pCO2, pH, aragonite and calcite saturation states, and pCO2 calculated at a common temp of 20ºC.

regional_TAS_algorithm_sensitivity.m: uses a regional TA/S relationship (Evans et al., 2019) to generate pCO2 flagging limits across a range of Alk:TCO2 ratios. Code outputs: mat file of cutoff values to be used in QC routine (Discrete_CO2_QC.m).

Discrete_CO2_QC.m: quality control and flagging routine for discrete CO2 bottle data. Sample data are flagged using 3 different methods to isolate and remove erroneous samples from the dataset. Code outputs: QC'ed mat file of discrete bottle data and QC flags.


# Sample Analysis Templates

For access to the different templates used by Hakai Institute follow this link to a Google Drive folder: https://drive.google.com/file/d/1cUh5CcJgtYXKy2bxg6QkVtkp3_JzP6B1/view?usp=sharing

Use the Lab Primary and Lab Std Prep templates to track the preparation of primary solutions and TCO2 liquid standards that are used for calibration curves during discrete sample analysis.

The DI Blank Runs template is filled out after TCO2 liquid standards have been made and the DI blank correction is being applied to the known concentrations post-standard completion. 

The SRVC CO2 IRM/CRM check template is used to assess the pre-run calibration curves and correction factors before sample analysis begins.

The YSI Calibration Log template is used for tracking any YSI instrument drift during sample analysis from pre- to post-run.

The template metadata mastersheet is filled out during sample analysis and contains all information collected from the field, during the analysis and from the completed SRVC CO2 ver2.0 spreadsheet.

The SRVC CO2 ver2.0 spreadsheet is filled out during or after the samples have been analyzed. The spreadsheet contains specific calculations for TCO2 and pCO2 analyzed during the processing day. The user will paste pre-run, mid-run and post-run standards and all samples analyzed into the spreadsheet to obtain preliminary CO2 data. Following the completion of the SRVC CO2 spreadsheet, use the SRVC CO2 Carb Calcs excel sheet and matlab script to calculate in-situ values and carbonate calculations. Once these data have been calculated, enter the derived parameters into the SRVC CO2 spreadsheet and the metadata mastersheet.

The Compiled IRM/CRM Runs template is used to track any drift of the reference materials after being made internally (IRM) or externally (CRM). The templates track correction factors, TCO2, pCO2, and Total Alkalinity changes while comparing the analyzed values to the certified values of each batch of IRM/CRMs. 


# References

Evans, W., Pocock, K., Hare, A., Weekes, C., Hales, B., Jackson, J., Gurney-Smith, H., Mathis, J. T., Alin, S. R., and Feely, R. A., 2019. Marine CO2 Patterns in the Northern Salish Sea, Front. Mar. Sci., 5, 536. https://doi.org/10.3389/fmars.2018.00536

Lewis, E., Wallace, D. W. R., 1998. Program Developed for CO2 System Calculations. ORNL/CDIAC-105. Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, Oak Ridge, TN.

Sharp, J.D., Pierrot, D., Humphreys, M.P., Epitalon, J.-M., Orr, J.C., Lewis, E.R., Wallace, D.W.R. (2023, Jan. 19). CO2SYSv3 for MATLAB (Version v3.2.1). Zenodo. http://doi.org/10.5281/zenodo.3950562

van Heuven, S., Pierrot, D., Rae, J.W.B., Lewis, E., Wallace, D.W.R., 2011. MATLAB Program Developed for CO2 System Calculations. ORNL/CDIAC-105b. Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, Oak Ridge, TN.

