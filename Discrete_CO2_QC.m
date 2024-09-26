% Hakai Discrete CO2 Data QC & Flagging Routine
% Code written by Katie Campbell & Wiley Evans
% Last edited 2024-09-19

% In this script sample data are flagged using: 

% 1. RMSE between YSI and CTD S (cut off = 8*RMSE)
% 2. pCO2 cutoff from TA(S) RMSE sensitivity
% 3. Manual QC of outliers in plots

% This script uses the following flagging scheme:
% 1 = good, 2 = duplicate, 3 = questionable, 4 = bad or NaN

clear all

%% Step 1. Import data

cd CTD_processing_bottle_file_generation
data = load('QU39_BTL_20160119_to_20231219.csv'); %load csv bottle file
cd ..

% Datafile column headers:

%(1) Collection_date_btl (Matlab SDN)
%(2) CTD_Start_time_UTC (Matlab SDN)
%(3) Target Depth (m) 
%(4) Adjusted TCO2 (µmol/kg)
%(5) Pressure (dbar)
%(6) NIST Temp (°C) 
%(7) YSI Salinity (PSS-78) 
%(8) CRM corrected TCO2 (µmol/kg) 
%(9) Alkalinity (µmol/kg) 
%(10) pCO2 @ analysisT (µatm) 
%(11) NIST Analysis Temp (°C) 
%(12) CTD Depth (m)
%(13) CTD Temperature (°C) 
%(14) CTD Salinity (PSS-78) 
%(15) NO2+NO3 (µmol/kg)
%(16) PO4 (µmol/kg)
%(17) SiO2 (µmol/kg)
%(18) pCO2 @ insituT&P (µatm) 
%(19) pHT @insituT&P (total scale)
%(20) Aragonite Saturation 
%(21) Calcite Saturation 
%(22) Revelle Factor 
%(23) Quality Flag (applied during sample analysis)
%(24) CTD Chlorophyll
%(25) CTD Turbidity
%(26) CTD O2 (µmol/kg)
%(27) CTD PAR
%(28) Station Lat
%(29) Station Lon
%(30) CTD Conductivity
%(31) Hakai Sample ID
%(32) Analysis Date (Matlab SDN)
%(33) NO2+NO3 Flag
%(34) PO4 Flag
%(35) SiO2 Flag

% plot QC flags with date and depth:
fig = figure;
set(fig,'DefaultAxesFontSize',15);
scatter(data(:,1),data(:,3),40,data(:,23),'filled')
cmap = colormap(parula(4));
set(gca,'ydir','reverse')
xtick = [min(data(:,1)):200:max(data(:,1))];
set(gca,'xtick',xtick,'xticklabel',datestr(xtick,'mmmyy'))
pbaspect([3 1 1])
h = colorbar('vert');
h.Label.String = 'QC Flag';
h.Ticks = [1 2 3 4];
axis([min(data(:,1)) max(data(:,1)) -5 260]) % adjust to max sample depth
title('Sample Quality Flags Before Running Routines');

%% QC Step 1: YSI vs. CTD Salinity

% This step uses the difference between YSI Salinity (measured directly
% from the sample) and CTD Salinity (extracted from the profile data) to 
% flag outliers that would indicate a sample collection issue, such as a
% sample drawn from the wrong Niskin or a Niskin tripped at the wrong
% depth.

% Note: CO2 system parameters (pCO2@in situ T, pH_T, and Omega_Arag) are
% calculated using YSI salinity not CTD salinity.

[b,stats] = robustfit(data(:,14),data(:,7)); % calculate statistics for a robust linear fit
RMSE_CTDs_YSIs = stats.mad_s % isolate RMSE value (QU39 RMSE = 0.12087)

% plot sample data
fig = figure;
set(fig,'DefaultAxesFontSize',15);
scatter(data(:,7), data(:,14), 30, data(:,12), 'filled')
cmap = colormap(parula);
h = colorbar('vert');
set(h,'YDir','reverse');
h.Label.String = 'Depth (m)';
axis square
title('QC Step1: Salinity Comparison')
xlabel('YSI Salinity')
ylabel('CTD Salinity')
hold on
plot([20 32],[20 32],'k-') % plot 1:1 line across salinity range
Sdiff = abs(data(:,14)-data(:,7)); % calculate salinity residuals (use absolute value)
ck = find(Sdiff > RMSE_CTDs_YSIs*8); % select residuals outside of 8xRMSE cut off
hold on
plot(data(ck,7),data(ck,14),'ko','markersize',10) % circle outliers in plot

% FLAG ASSIGNMENT:
length(ck) % check number of samples to be flagged
flags = data(:,23); % make a new flag column
flags(ck) = 3; % add Salinity flags
data = [data flags]; % add new flag column to end of dataset
%(36) QC Quality Flags

% check no flags of 4 were overwritten, if so change them back (ex below)
ck4_old = find(data(:,23) == 4); % previous flag = 4
length(ck4_old)
ck4_new = find(data(:,36) == 4); % flag = 4 after salinity flags applied
length(ck4_new)

% Compare the two variables above to find any missing flag 4 samples,
% locate sample ID numbers and re-vert flag to 4. Ex:
% ck = find(data(:,31) == 5850 | data(:,31) == 5907); 
% flags(ck) = 4;

% Additional figure: plot salinity residuals with RMSE cutoffs & newly flagged
% samples

fig = figure;
set(fig,'DefaultAxesFontSize',15);
scatter(data(:,1), data(:,7)-data(:,14),40,data(:,36),'filled')
cmap = colormap(parula(4));
h = colorbar('vert');
h.Label.String = 'QC Flag';
h.Ticks = [1 2 3 4];
title('QC Step1: Flagged Samples')
ylabel('YSI-CTD Salinity')
xlabel('Date')
xtick = [datenum(2016,1,1):300:datenum(2023,07,01)];
set(gca,'xtick',xtick,'xticklabel',datestr(xtick,'mm/yy'))
axis([min(data(:,1)) max(data(:,1)) -6 6])
hold on
plot([min(data(:,1)) max(data(:,1))], [0 0], '-r');
hold on

x1 = min(data(:,1));
x2 = max(data(:,1));
y1 = 0.1251*12;
y2 = 0.1251*-12;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'red','FaceColor',[0.4 0.4 0.4],'FaceAlpha',0.1,'EdgeAlpha',0)

y1 = 0.1251*10;
y2 = 0.1251*-10;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'red','FaceColor',[0.35 0.35 0.35],'FaceAlpha',0.1,'EdgeAlpha',0)

y1 = 0.1251*8;
y2 = 0.1251*-8;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'red','FaceColor',[0.3 0.3 0.3],'FaceAlpha',0.1,'EdgeAlpha',1)

y1 = 0.1251*6;
y2 = 0.1251*-6;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'c','FaceColor',[0.2 0.2 0.2],'FaceAlpha',0.1,'EdgeAlpha',0)

y1 = 0.1251*4;
y2 = 0.1251*-4;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'g','FaceColor',[0.1 0.1 0.1],'FaceAlpha',0.1,'EdgeAlpha',0)


%% QC Step 2: pCO2 from TA(S)

% In this step a regional alkalinity-salinity relationship is required to
% provide an estimate pCO2 from TCO2 and TA(S), this is compared to the
% measured pCO2 at analysis temperature to help identify questionable 
% measurements. The difference between the two pCO2 values is dependent on
% the buffering state of the sample (ie. the Alk:TCO2 ratio) therefore the
% flagging cutoff is scaled according to this.

% Alkalinity-salinity relationship used here: Evans et al. 2019
% Alk = S*59.88 + 278.79        RMSE = 22.47 µmol/kg

% Run regional_TAS_algorithm_sensitivity.m script for calculation of cutoff 
% values. To center the cutoffs around the data use the median analysis 
% temperature and salinity of the sample dataset (18.7°C and 29.6).

med_anal_T = median(data(:,11),'omitnan');
med_S = median(data(:,7),'omitnan');

% load TaS pCO2 cuttoff values from regional_TAS_algorithm_sensitivity.m
load TaS_pCO2_cutoff;

% Plot Alk:TCO2 ratio of samples, Alk vs Alk(S), and measured vs estimated pCO2

% Alk:TCO2 ratio
fig = figure;
set(fig,'DefaultAxesFontSize',15);

subplot(2,2,1)
plot(data(:,9)./data(:,8), data(:,12), 'ko')
set(gca,'ydir','reverse')
xlabel('Alk:TCO2')
ylabel('Pressure')
sgtitle('QC Step2: pCO2 Comparison', 'fontweight', 'bold')
axis square

% Alk(S) vs Alk(pCO2,TCO2)
subplot(2,2,2)
TA = data(:,7).*59.88 + 278.79; % use regional Alk/S relationship here
TAdiff = TA - data(:,8);
plot(data(:,8), TAdiff,'ko')
xlabel('Alk(pCO2,TCO2)')
ylabel('Alk(S)-Alk(pCO2,TCO2)')
axis square

% pCO2@analysisT vs pCO2@analysisT-pCO2(TCO2,Alk(S))
subplot(2,2,3)
TA = data(:,7).*59.74 + 279.33;
[output3] = CO2SYS(TA, data(:,8), 1, 2, data(:,7), data(:,11), data(:,11), 0, 0, 0, 0, 0, 0, 1, 15, 1, 2, 1);
pCO2_ck = output3(:,4);
pCO2diff = data(:,10)-pCO2_ck;
plot(data(:,10), pCO2diff,'ko')
xlabel('pCO2@analysisT')
ylabel('pCO2@analysisT-pCO2(TCO2,TA(S))')
axis square

% pCO2@analysisT vs pCO2@analysisT-pCO2(TCO2,Alk(S)), Alk:TCO2 on z-axis
subplot(2,2,4)
scatter(data(:,10), pCO2diff,30,data(:,9)./data(:,8),'filled')
xlabel('pCO2@analysisT')
ylabel('pCO2@analysisT-pCO2(TCO2,TA(S))')
axis  square
colorbar('vert')
h = colorbar;
ylabel(h, 'Alk:TCO2')

% FLAG ASSIGNMENT:
TAtCO2 = [0.9:0.001:1.4]; % range of Alk:TCO2 ratios
ratio = data(:,9)./data(:,8);
for i = 1:length(ratio);
    ck = find(TAtCO2 > ratio(i)-0.0005 & TAtCO2< ratio(i)+0.0005);
    thres = TaS_pCO2_cutoff(ck).*2;
    if abs(pCO2diff(i)) > thres;
        data(i,36) = 3;
    end
end

% check no flags of 4 were overwritten, if so change them back
ck4_old = find(data(:,23) == 4); % previous flag = 4
length(ck4_old)
ck4_new = find(data(:,36) == 4); % flag = 4 after salinity flags applied
length(ck4_new)

% Plot pCO2 comparison with cutoff limits

fig = figure;
set(fig,'DefaultAxesFontSize',15);
scatter(data(:,9)./data(:,8), pCO2diff,20,data(:,36),'filled')
cmap = colormap(parula(4));
colorbar('vert')
h = colorbar
h.Label.String = 'QC Flag';
h.Ticks = [1 2 3 4];
xlabel('Alk:TCO2')
ylabel('pCO2@analysisT-pCO2(TCO2,Alk(S))')
title('QC Step2: Flagged Samples')
axis square
box on
hold on
plot(TAtCO2, TaS_pCO2_cutoff, 'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-1, 'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*2, 'b-','linewidth',2)
hold on
plot(TAtCO2, (TaS_pCO2_cutoff.*-1).*2, 'b-','linewidth',2)

%% QC Step 3: Manual QC of Outliers

% The following figures are examples of ways to visualize the bottle data and
% identify erroneous samples.

% Plot relationship b/w alkalinity and salinity w/ pCO2 on z-axis

fig = figure
set(fig,'DefaultAxesFontSize',15);

ax1 = subplot(1,2,1)
scatter(data(:,7), data(:,9),40,data(:,36),'filled')   % pCO2 on z-axis
hold on
x = data(:,7);
y = data(:,7).*59.88 + 278.79; % Evans et. al regional Alk/S relationship
line(x,y,'LineWidth',2,'Color','k');
cmap = colormap(ax1,parula(4));
h = colorbar('vert');
h.Label.String = 'QC Flag';
h.Ticks = [1 2 3 4];
xlabel('YSI Salinity')
ylabel('Alkalinity (\mumol/kg)')
[QU39,STATS] = robustfit(data(:,7), data(:,9));
[a, r] = regress_linear(data(:,7), data(:,9));
h = lsline % Add a least squares line to the plot
set(h,'color','r','LineWidth',2)
box on
axis square
legend('Samples','NSS 2019','2016-2023 fit (all samples)');
ylim = [1500 2200];
xlim = [20 31.5];
set(gca,'xlim',xlim)
set(gca,'ylim',ylim)
title('All QU39 Samples');

ax2 = subplot(1,2,2)
ck = find(data(:,36) == 1 | data(:,36) == 2);
scatter(data(ck,7), data(ck,9),40,data(ck,1),'filled')   % pCO2 on z-axis
hold on
x = data(ck,7);
y = data(ck,7).*59.88 + 278.79; % Evans et. al regional Alk/S relationship
line(x,y,'LineWidth',2,'Color','k');
xlabel('YSI Salinity')
ylabel('Alkalinity (\mumol/kg)')
[QU39,STATS] = robustfit(data(ck,7), data(ck,9));
[a, r] = regress_linear(data(ck,7), data(ck,9));
h = lsline % Add a least squares line to the plot
set(h,'color','r','LineWidth',2)
box on
axis square
legend('Samples','NSS 2019','2016-2023 fit (QF 1 or 2 only)');
ylim = [1500 2200];
xlim = [20 31.5];
set(gca,'xlim',xlim)
set(gca,'ylim',ylim)
cmap = colormap(ax2,parula(8));
h2 = colorbar;
ylabel(h2, 'Date')
h2.Ticks = [datenum(2016,6,15) datenum(2017,6,15) datenum(2018,6,15) datenum(2019,6,15) datenum(2020,6,15) datenum(2021,6,15) datenum(2022,6,15) datenum(2023,6,15)]
h2.TickLabels = [2016 2017 2018 2019 2020 2021 2022 2023];
title('QU39 Samples with Flag 1 or 2');

% Find & flag outliers (example below)

% % Low alkalinity (<1700) high salinity (>24.5) from 2017
% ck = find(data(:,9) < 1700 & data(:,7) > 24.4); 
% data(ck,36) = 3; % 2 samples


% Contour plot examples:

% plot only flag 1 and 2:
ck = find(data(:,36) == 1 | data(:,36) == 2);
good_data = data(ck,:);

% contourplot: pCO2
ck = ~isnan(good_data(:,18));
pCO2 = good_data(ck,:);
x = unique(pCO2(:,1));
y = [0:260]; % depth range of samples
[X,Y] = meshgrid(x,y);
Vq = griddata(pCO2(:,1), pCO2(:,3), pCO2(:,18), X, Y);

figure
f = pcolor(X,Y,Vq);
shading(gca,'interp')
set(gca,'ydir','reverse')
pbaspect([3 1 1])
set(gca,'xtick',xtick,'xticklabel',datestr(xtick,12))
axis tight
load zissou2
colormap(zissou2)
h = colorbar('vert')
ylabel(h, 'pCO_2 (\muatm)')
ylabel('Depth (m)')
title('pCO2@insituT&P')
box on
hold on
plot(pCO2(:,1), pCO2(:,3),'o','color',[0.7 0.7 0.7]) %show samples on grid
set(gca,'clim',[100 1300]) 
axis([min(pCO2(:,1)) max(pCO2(:,1)) 0 260])
hold on
v = [300,300,500,500,700,700,900,900,1100,1100];% add contour lines
[c,h]=contour(X,Y,Vq,v);
set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
set(h,'color',[0.3 0.3 0.3],'linewidth',0.75)
set(gca,'FontSize',15)

%contourplot: TCO2
ck = ~isnan(good_data(:,8));
TCO2 = good_data(ck,:);
x = unique(TCO2(:,1));
y = [0:270]; % depth range of samples
[X,Y] = meshgrid(x,y);
Vq = griddata(TCO2(:,1), TCO2(:,3), TCO2(:,8), X, Y);

figure
f = pcolor(X,Y,Vq);
shading(gca,'interp')
set(gca,'ydir','reverse')
pbaspect([3 1 1])
set(gca,'xtick',xtick,'xticklabel',datestr(xtick,12))
axis tight
load zissou2
colormap(zissou2)
h = colorbar('vert')
ylabel(h, 'TCO_2 (\mumol/kg)')
ylabel('Depth (m)')
box on
hold on
plot(TCO2(:,1), TCO2(:,3),'o','color',[0.7 0.7 0.7])% show samples on grid
set(gca,'clim',[1600 2100]) 
axis([min(TCO2(:,1)) max(TCO2(:,1)) 0 260])
title('TCO2')
v = [1600,1600,1700,1700,1800,1800,1900,1900,2000,2000,2100,2100]; 
[c,h]=contour(X,Y,Vq,v); % add contour lines
set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
set(h,'color',[0.3 0.3 0.3],'linewidth',0.75)
set(gca,'FontSize',15)

%% Save QC'ed data file


final_dataset = data(:,[2 3 5 6 7 8 4 10 11 2 12 5 13 14 26 15 16 17 9 18 19 20 21 22 36 32 33 34 35]);

%(1) CTD_Start_time_UTC (Matlab SDN) 
%(2) Target Depth (m) 
%(3) Niskin Depth (m, target depth used when no solo, may not be actual collection depth for bottom niskin)
%(4) NIST temp (°C) 
%(5) YSI salinity (PSS-78) 
%(6) CRM corrected TCO2 (µmol kg -1 ) 
%(7) Adjusted TCO2 (µmol kg -1 ) 
%(8) pCO2 @analysisT (µatm) 
%(9) NIST Analysis T (°C) 
%(10) CTD Start Time (Matlab SDN, UTC)
%(11) CTD Depth (m) 
%(12) CTD Pres_dbar (bin)
%(13) CTD temperature (°C) 
%(14) CTD Salinity (PSS-78) 
%(15) CTD Oxygen (umol/kg)
%(16) NO2+NO3 (µmol/kg)
%(17) PO4 (µmol/kg)
%(18) SiO2 (µmol/kg)
%(19) Alkalinity (µmol kg -1 ) 
%(20) pCO2 @insituT&P (µatm) 
%(21) pHT @insituT&P (total scale)
%(22) aragonite saturation 
%(23) calcite saturation 
%(24) Revelle factor
%(25) CO2 Quality flag (1=good, 2=dup, 3=questionable, 4=NaN)
%(26) CO2 Analysis date (Matlab SDN)
%(27) NO2+NO3 Flag (1=good, 2=dup, 3=questionable, 4=NaN)
%(28) PO4 Flag (1=good, 2=dup, 3=questionable, 4=NaN)
%(29) SiO2 Flag (1=good, 2=dup, 3=questionable, 4=NaN)

save QU39_2016_to_2023_QC_KC_20240214 final_dataset -ascii -double -tabs
