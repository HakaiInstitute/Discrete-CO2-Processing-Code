%% Hakai Institute's Carbonate Calculation Code for discrete CO2 data
% Created: September 1st, 2021; By: Carrie Weekes
%-- Updated August 2nd, 2023

% Code will be used for CO2SYS carbonate calculations.
% Visit: https://www.mathworks.com/matlabcentral/fileexchange/78378-co2sysv3-for-matlab to download CO2SYS and for more information.
% Constants used: K1, K2 Constants - Waters et al., 2014; pH on the total scale;...
    % KSO4 - Dickson, 1990; KF - Perez & Fraga, 1987; Boron - Uppstrom, 1979

% First output will be for Corrected TA
% Second output will be for pCO2 @ 20C
% Third output will be for pCO2, pH_T, Omega_Ar, Omega_Ca & Revelle Factor @ in-situ temperature
% Fourth output is for CRM pCO2 calculated with specific batch information

% Load in text file with input parameters:
SRVC = load('SRVC_CO2_Carb_Calcs.txt');

% Column Headers:
% (1) Sample Salinity
% (2) Analysis Temperature
% (3) pCO2 @ Analysis Temperature
% (4) Adjusted TCO2
% (5) CRM Corrected TCO2
% (6) Temp = 20C
% (7) In-situ Temperature

%% Calculate Carbonate Parameters for CO2 Data with CO2SYS
% function [DATA,HEADERS,NICEHEADERS]=CO2SYS(PAR1,PAR2,PAR1TYPE,PAR2TYPE,SAL,TEMPIN,TEMPOUT,PRESIN,PRESOUT,SI,PO4,NH4,H2S,pHSCALEIN,K1K2CONSTANTS,KSO4CONSTANT,KFCONSTANT,BORON)

%-- Corrected TA:
% data = pCO2 @ AT, Adj.TCO2, 4, 2, YSI S, Tin = Analysis T, Tout = Analysis T, Pin = 0, Pout = 0, Si = 0, PO4 = 0, NH4 = 0, H2S = 0, pH = 1, K1K2 = 15, KSO4 = 1, KF = 2, B = 1
[results,headers,nheaders] = CO2SYS(SRVC(:,3),SRVC(:,4),4,2,SRVC(:,1),SRVC(:,2),SRVC(:,2),0,0,0,0,0,0,1,15,1,2,1);
TA = results(:,1);


%-- pCO2 @ 20C for IRM calcs & any triplicate comparisons at a common temperature:
% data = TA, TCO2, 1, 2, YSI S, Tin = 20, Tout = 20, Pin = 0, Pout = 0, Si = 0, PO4 = 0, NH4 = 0, H2S = 0, pH = 1, K1K2 = 15, KSO4 = 1, KF = 2, B = 1
[results2,headers,nheaders] = CO2SYS(TA,SRVC(:,5),1,2,SRVC(:,1),SRVC(:,6),SRVC(:,6),0,0,0,0,0,0,1,15,1,2,1);
pCO2_20C = results2(:,21);
pHt_20C = results2(:,20);


%-- pCO2, pH_T, aragonite saturation, calcite saturation, & revelle factor:
    % If CTD information are available, these calculations will be re-done
% data = TA, TCO2, 1, 2, YSI S, Tin = in-situ T, Tout = in-situ T, Pin = 0, Pout = 0, Si = 0, PO4 = 0, NH4 = 0, H2S = 0, pH = 1, K1K2 = 15, KSO4 = 1, KF = 2, B = 1
[results3,headers,nheaders] = CO2SYS(TA,SRVC(:,5),1,2,SRVC(:,1),SRVC(:,7),SRVC(:,7),0,0,0,0,0,0,1,15,1,2,1);
pCO2_ST = results3(:,21);
pH_T = results3(:,20);
Omega_Ar = results3(:,35);
Omega_Ca = results3(:,34);
RF = results3(:,33);


%% CRM pCO2 calculation using certified batch information
    % For specific CRM batch information visit:...
    % https://www.ncei.noaa.gov/access/ocean-carbon-acidification-data-system/oceans/Dickson_CRM/batches.html

% Batch 185: TCO2 = 2029.88, TA = 2220.67, S = 33.419 PO4 = 0.42, Si = 3.0
% data = CRM_TA, CRM_TCO2, 1, 2, CRM_S, Tin = Analysis_T, Tout = Analysis_T, Pin = 0, Pout = 0, CRM_Si, CRM_PO4, NH4 = 0, H2S = 0, pH = 1, K1K2 = 15, KSO4 = 1, KF = 2, B = 1
[results4,headers,nheaders] = CO2SYS(2220.67, 2029.88, 1, 2, 33.419, SRVC(:,2), SRVC(:,2),0,0,3.0,0.42,0,0,1,15,1,2,1);
pCO2_CRM = results4(:,21);




