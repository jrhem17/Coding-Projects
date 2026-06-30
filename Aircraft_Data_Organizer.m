%% ==========================
% OVERALL STATISTICS
% ===========================

fprintf('\n=====================================\n');
fprintf('OVERALL DATASET STATISTICS\n');
fprintf('=====================================\n');

qty = allData.Quantity;

meanQty = mean(qty);
medianQty = median(qty);
modeQty = mode(qty);

fprintf('Average Quantity per Record: %.2f\n',meanQty);
fprintf('Median Quantity: %.2f\n',medianQty);
fprintf('Most Common Quantity: %.2f\n',modeQty);
fprintf('Maximum Quantity: %.2f\n',max(qty));
fprintf('Minimum Quantity: %.2f\n',min(qty));

fprintf('\nExplanation:\n');
fprintf('- Mean = Average quantity across all records\n');
fprintf('- Median = Middle quantity value\n');
fprintf('- Mode = Most frequently occurring quantity\n');
fprintf('- Max = Largest quantity found in dataset\n');
fprintf('- Min = Smallest quantity found in dataset\n');

%% ==========================
% CRJ700 ANALYSIS
% ===========================

CRJ700 = allData(allData.Aircraft=="CRJ700",:);

fprintf('\n=====================================\n');
fprintf('CRJ700 STATISTICS\n');
fprintf('=====================================\n');

fprintf('Records: %d\n',height(CRJ700));
fprintf('Average Quantity: %.2f\n',mean(CRJ700.Quantity));
fprintf('Median Quantity: %.2f\n',median(CRJ700.Quantity));
fprintf('Mode Quantity: %.2f\n',mode(CRJ700.Quantity));

%% ==========================
% CRJ900 ANALYSIS
% ===========================

CRJ900 = allData(allData.Aircraft=="CRJ900",:);

fprintf('\n=====================================\n');
fprintf('CRJ900 STATISTICS\n');
fprintf('=====================================\n');

fprintf('Records: %d\n',height(CRJ900));
fprintf('Average Quantity: %.2f\n',mean(CRJ900.Quantity));
fprintf('Median Quantity: %.2f\n',median(CRJ900.Quantity));
fprintf('Mode Quantity: %.2f\n',mode(CRJ900.Quantity));

%% ==========================
% TOP REPEATING ITEMS
% ===========================

repeat700 = groupsummary(CRJ700,"ItemName","numel");
repeat700 = sortrows(repeat700,"GroupCount","descend");

repeat700.Properties.VariableNames(end) = "Occurrence_Count";

fprintf('\nTOP 10 REPEATING ITEMS - CRJ700\n');
disp(repeat700(1:10,:));

repeat900 = groupsummary(CRJ900,"ItemName","numel");
repeat900 = sortrows(repeat900,"GroupCount","descend");

repeat900.Properties.VariableNames(end) = "Occurrence_Count";

fprintf('\nTOP 10 REPEATING ITEMS - CRJ900\n');
disp(repeat900(1:10,:));

top700 = repeat700(1:15,:);

figure('Name','CRJ700 Top Repeating Items');

barh(top700.Occurrence_Count)

yticks(1:height(top700))
yticklabels(top700.ItemName)

xlabel('Number of Occurrences')
ylabel('Item Name')

title('CRJ700 Top Repeating SAIB Items')

grid on

top900 = repeat900(1:15,:);

figure('Name','CRJ900 Top Repeating Items');

barh(top900.Occurrence_Count)

yticks(1:height(top900))
yticklabels(top900.ItemName)

xlabel('Number of Occurrences')
ylabel('Item Name')

title('CRJ900 Top Repeating SAIB Items')

grid on


%% ==========================
% ATA ANALYSIS
% ===========================

ATAsummary = groupsummary(allData,...
    "ATA","sum","Quantity");

ATAsummary = sortrows(ATAsummary,...
    "sum_Quantity","descend");

ATAsummary.Properties.VariableNames(end) = ...
    "Total_Quantity";

disp(ATAsummary(1:10,:))
figure('Name','ATA Chapter Analysis');

bar(ATAsummary.ATA,...
    ATAsummary.Total_Quantity)

xlabel('ATA Chapter')
ylabel('Total Quantity')

title('SAIB Quantities by ATA Chapter')

grid on

%% ==========================
%% ==========================
% ENGINEERING INSIGHTS
% ===========================

fprintf('\n=====================================\n');
fprintf('ENGINEERING INSIGHTS\n');
fprintf('=====================================\n');

topATA = ATAsummary(1,:);

fprintf('\nTop ATA Chapter:\n');
fprintf('ATA %d\n',topATA.ATA);
fprintf('Total Quantity = %d\n',...
    topATA.Total_Quantity);

topItem = repeat700(1,:);

fprintf('\nMost Repeated CRJ700 Item:\n');
disp(topItem)

topItem900 = repeat900(1,:);

fprintf('\nMost Repeated CRJ900 Item:\n');
disp(topItem900)

%% ==========================
% COMMONALITY ANALYSIS
% ===========================

parts700 = unique(CRJ700.OEMPart);
parts900 = unique(CRJ900.OEMPart);

commonParts = intersect(parts700,parts900);

commonalityPct = ...
    length(commonParts) / ...
    min(length(parts700),length(parts900))...
    *100;

fprintf('\n=====================================\n');
fprintf('FLEET COMMONALITY ANALYSIS\n');
fprintf('=====================================\n');

fprintf('Unique CRJ700 Parts: %d\n',...
    length(parts700));

fprintf('Unique CRJ900 Parts: %d\n',...
    length(parts900));

fprintf('Common Parts: %d\n',...
    length(commonParts));

fprintf('Commonality Percentage: %.2f%%\n',...
    commonalityPct);

%% ==========================
% OUTLIER DETECTION
% ===========================

Q1 = quantile(qty,0.25);
Q3 = quantile(qty,0.75);

IQRvalue = Q3 - Q1;

UpperLimit = Q3 + 1.5*IQRvalue;

Outliers = allData(...
    allData.Quantity > UpperLimit,:);

fprintf('\nPotential Outliers Found: %d\n',...
    height(Outliers));

disp(Outliers(:,...
    {'Aircraft','ItemName','Quantity'}));

%% ==========================
% EXECUTIVE SUMMARY
% ===========================

fprintf('\n');
fprintf('=====================================\n');
fprintf('EXECUTIVE SUMMARY\n');
fprintf('=====================================\n');

fprintf('Total Records: %d\n',height(allData));

fprintf('CRJ700 Records: %d\n',...
    height(CRJ700));

fprintf('CRJ900 Records: %d\n',...
    height(CRJ900));

fprintf('Most Common Quantity: %.0f\n',...
    modeQty);

fprintf('Top ATA Chapter: %d\n',...
    topATA.ATA);

fprintf('Fleet Commonality: %.1f%%\n',...
    commonalityPct);

fprintf('Outliers Found: %d\n',...
    height(Outliers));

%% =====================================
% CRJ700 VS CRJ900 ATA COMPARISON
% =====================================

ATA700 = groupsummary(CRJ700,"ATA","sum","Quantity");
ATA900 = groupsummary(CRJ900,"ATA","sum","Quantity");

ATACompare = outerjoin(ATA700,ATA900,...
    "Keys","ATA",...
    "MergeKeys",true);

ATACompare = fillmissing(ATACompare,'constant',0);

figure('Name','CRJ700 vs CRJ900 ATA Comparison',...
    'Position',[100 100 1200 600]);

bar(categorical(ATACompare.ATA),...
    [ATACompare.sum_Quantity_ATA700 ...
    ATACompare.sum_Quantity_ATA900])

title('ATA Chapter Comparison')
xlabel('ATA Chapter')
ylabel('Total Quantity')

legend('CRJ700','CRJ900')
grid on

%% =====================================
% ATA HEATMAP
% =====================================

uniqueATA = unique(allData.ATA);

HeatMatrix = zeros(2,length(uniqueATA));

for i = 1:length(uniqueATA)

    currentATA = uniqueATA(i);

    HeatMatrix(1,i) = ...
        sum(CRJ700.Quantity(CRJ700.ATA==currentATA));

    HeatMatrix(2,i) = ...
        sum(CRJ900.Quantity(CRJ900.ATA==currentATA));

end

figure('Name','ATA Heatmap',...
    'Position',[100 100 1300 500])

heatmap(string(uniqueATA),...
    {'CRJ700','CRJ900'},...
    HeatMatrix)

title('ATA Quantity Heatmap')
xlabel('ATA Chapter')
ylabel('Aircraft')

%% =====================================
% OEM PART COMMONALITY
% =====================================

part700 = unique(string(CRJ700.OEMPart));
part900 = unique(string(CRJ900.OEMPart));

sharedParts = intersect(part700,part900);

CRJ700only = setdiff(part700,part900);
CRJ900only = setdiff(part900,part700);

fprintf('\n=====================================\n');
fprintf('OEM PART COMMONALITY ANALYSIS\n');
fprintf('=====================================\n');

fprintf('CRJ700 Unique Parts: %d\n',...
    length(part700));

fprintf('CRJ900 Unique Parts: %d\n',...
    length(part900));

fprintf('Shared Parts: %d\n',...
    length(sharedParts));

fprintf('CRJ700 Only Parts: %d\n',...
    length(CRJ700only));

fprintf('CRJ900 Only Parts: %d\n',...
    length(CRJ900only));

CommonalityPercent = ...
    (length(sharedParts) / ...
    length(union(part700,part900))) * 100;

fprintf('Fleet Commonality: %.2f %%\n',...
    CommonalityPercent);

writetable(table(sharedParts),...
    'Shared_Parts.csv');

%% =====================================
% DISCREPANCY DETECTION
% =====================================

summary700 = groupsummary(CRJ700,...
    "ItemName","sum","Quantity");

summary900 = groupsummary(CRJ900,...
    "ItemName","sum","Quantity");

comparison = outerjoin(summary700,...
    summary900,...
    "Keys","ItemName",...
    "MergeKeys",true);

comparison = fillmissing(comparison,...
    'constant',0);

comparison.Difference = ...
    abs(comparison.sum_Quantity_CRJ700 - ...
    comparison.sum_Quantity_CRJ900);

comparison = sortrows(...
    comparison,...
    'Difference',...
    'descend');

fprintf('\n=====================================\n');
fprintf('TOP ITEM DIFFERENCES\n');
fprintf('=====================================\n');

disp(comparison(1:min(20,height(comparison)),:))

writetable(comparison,...
    'Fleet_Discrepancies.csv');
%% =====================================
% TEMPORARY REPAIR TRACKER
% =====================================

% Future File Structure Example:
%
% Aircraft
% Repair_Number
% Part_Number
% Date_Installed
% Expiration_Date
% Status

if isfile('TemporaryRepairs.xlsx')

    Repairs = readtable('TemporaryRepairs.xlsx');

    TodayDate = datetime('today');

    ActiveRepairs = ...
        Repairs(Repairs.Expiration_Date > ...
        TodayDate,:);

    ExpiringSoon = ...
        Repairs(Repairs.Expiration_Date < ...
        TodayDate+30,:);

    fprintf('\nACTIVE TEMP REPAIRS: %d\n',...
        height(ActiveRepairs));

    fprintf('EXPIRING WITHIN 30 DAYS: %d\n',...
        height(ExpiringSoon));

end
%% =====================================
% DASHBOARD DATA PACKAGE
% =====================================

Dashboard.TopItems700 = ...
    repeat700(1:15,:);

Dashboard.TopItems900 = ...
    repeat900(1:15,:);

Dashboard.ATAAnalysis = ...
    ATAsummary;

Dashboard.CommonParts = ...
    table(sharedParts);

Dashboard.FleetDiscrepancies = ...
    comparison;

save('DashboardData.mat',...
    'Dashboard')