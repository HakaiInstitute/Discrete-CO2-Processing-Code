% Calculated pCO2 sensitivity to RMSE in TA(S) 
% for high and low TA:TCO2 cases

clear all

% Defining high and low Alk:TCO2 
hTAtCO2 = 1.4;
lTAtCO2 = 0.97;

% Arbitrary RMSE in Alk(S)
RMSE = 20;

% Define TCO2 range and calc high and low Alk conditions
tCO2 = [1600:2100];
TAh = tCO2.*hTAtCO2;
TAl = tCO2.*lTAtCO2;

% Median analysis T and sample S
T = 18.7;
S = 29.6;

% pCO2 from high Alk +/- RMSE
%CO2SYS(PAR1,PAR2,PAR1TYPE,PAR2TYPE,SAL,TEMPIN,TEMPOUT,PRESIN,PRESOUT,SI,PO4,NH4,H2S,pHSCALEIN,K1K2CONSTANTS,KSO4CONSTANT,KFCONSTANT,BORON)
[upperH] = CO2SYS(TAh+RMSE,tCO2,1,2,S,T,T,0,0,0,0,0,0,1,15,1,2,1);
pCO2upperH = upperH(:,4);
[upperL] = CO2SYS(TAh-RMSE,tCO2,1,2,S,T,T,0,0,0,0,0,0,1,15,1,2,1);
pCO2upperl = upperL(:,4);

% pCO2 from low Alk +/- RMSE
[lowerH] = CO2SYS(TAl+RMSE,tCO2,1,2,S,T,T,0,0,0,0,0,0,1,15,1,2,1);
pCO2lowerH = lowerH(:,4);
[lowerL] = CO2SYS(TAl-RMSE,tCO2,1,2,S,T,T,0,0,0,0,0,0,1,15,1,2,1);
pCO2lowerl = lowerL(:,4);

figure
plot(tCO2,pCO2upperH,'r-')
hold on
plot(tCO2,pCO2upperl,'r--')
hold on
plot(tCO2,pCO2lowerH,'b-')
hold on
plot(tCO2,pCO2lowerl,'b--')
axis square
legend('High TA:TCO2 upper', 'High TA:TCO2 lower','Low TA:TCO2 upper','Low TA:TCO2 lower')
xlabel('TCO2 (\mumol/kg)')
ylabel('Computed pCO2')
title('pCO2 from high and low Alk:TCO2 +/- RMSE across TCO2 range')

% shows RMSE has bigger effect, i.e. difference between +RMSE and -RMSE, at low Alk:TCO2

% for high and low TCO2 cases

% set TCO2
hTCO2 = 2100;
lTCO2 = 1600;
RMSE = 22.47; %RMSE of TA/S relationship

% Define range of Alk across Alk:TCO2 conditions
TAtCO2 = [0.9:0.001:1.4];
TAh = TAtCO2.*hTCO2;
TAl = TAtCO2.*lTCO2;

% Median analysis T and sample S
T = 18.7;
S = 29.6;

% pCO2 for high TCO2 case
[upperH] = CO2SYS(TAh+RMSE,hTCO2.*ones(length(TAh),1),1,2,S,T,T,0,0,0,0,0,0,1,15,1,2,1);
pCO2upperH = upperH(:,4);
[upperL] = CO2SYS(TAh-RMSE,hTCO2.*ones(length(TAh),1),1,2,S,T,T,0,0,0,0,0,0,1,15,1,2,1);
pCO2upperl = upperL(:,4);

% pCO2 for low TCO2 case
[lowerH] = CO2SYS(TAl+RMSE,lTCO2.*ones(length(TAh),1),1,2,S,T,T,0,0,0,0,0,0,1,15,1,2,1);
pCO2lowerH = lowerH(:,4);
[lowerL] = CO2SYS(TAl-RMSE,lTCO2.*ones(length(TAh),1),1,2,S,T,T,0,0,0,0,0,0,1,15,1,2,1);
pCO2lowerl = lowerL(:,4);

figure
plot(TAtCO2,pCO2upperH,'r-')
hold on
plot(TAtCO2,pCO2upperl,'r--')
hold on
plot(TAtCO2,pCO2lowerH,'b-')
hold on
plot(TAtCO2,pCO2lowerl,'b--')
axis square
legend('High TCO_{2}, TA+RMSE', 'High TCO_{2}, TA-RMSE','Low TCO_{2}, TA+RMSE','Low TCO_{2}, TA-RMSE')
xlabel('TA:TCO_{2}')
ylabel('Derived pCO_{2}')

% shows computed pCO2 is most sensitive to RMSE in Alk(S) at low Alk:TCO2
% at both high and low TCO2

figure
plot(TAtCO2,pCO2upperl-pCO2upperH,'r-')
hold on
plot(TAtCO2,pCO2lowerl-pCO2lowerH,'b-')
axis square
legend('Diff High TCO_{2}','Diff Low TCO_{2}')
xlabel('TA:TCO_{2}')
ylabel('Difference between TA+RMSE and TA-RMSE derived pCO_{2}')

TaS_pCO2_cutoff = pCO2upperl-pCO2upperH;
save TaS_pCO2_cutoff TaS_pCO2_cutoff
