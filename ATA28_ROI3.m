clc;
clear;
close all;

fprintf('==============================\n');
fprintf('ROI #3 - FUEL LEAK ANALYSIS\n');
fprintf('==============================\n\n');

%% Clean/Sort Data %%
T = readtable('ATA28_Cleaned.xlsx');

FuelLeakRows = strcmpi(string(T.DiscrepancyCategory),'FUEL LEAK');

LeakData = T(FuelLeakRows,:);
fprintf('Fuel Leak Records: %d\n',height(LeakData));

Desc = upper(string(LeakData.Description));
CA   = upper(string(LeakData.CorrectiveAction));

FollowOnCheck = ...
    contains(Desc,"LEAK CHECK REQUIRED") | ...
    contains(Desc,"LEAK TEST REQUIRED")  | ...
    contains(CA,"LEAK CHECK GOOD")       | ...
    contains(CA,"NO LEAKS FOUND")        | ...
    contains(CA,"NO LEAK DETECTED");

TrueLeakData = LeakData(~FollowOnCheck,:);
fprintf('After removing leak checks: %d\n',height(TrueLeakData));

CA = upper(string(TrueLeakData.CorrectiveAction));

NotFuelLeak = ...
    contains(CA,"NO ACTIVE LEAK") | ...
    contains(CA,"RESIDUAL FUEL") | ...
    contains(CA,"NO FUEL LEAK") | ...
    contains(CA,"HYDRAULIC FLUID") | ...
    contains(CA,"OVERFUELED") | ...
    contains(CA,"NO LEAK DETECTED");

TrueLeakData = TrueLeakData(~NotFuelLeak,:);
Desc = upper(string(TrueLeakData.Description));
RemoveRows = ...
    contains(Desc,"LEAK TEST REQUIRED") | ...
    contains(Desc,"LEAK TEST DUE") | ...
    contains(Desc,"PERFORM LEAK TEST") | ...
    contains(Desc,"LEAK CHECK REQUIRED") | ...
    contains(Desc,"POSSIBLE FUEL LEAK") | ...
    contains(Desc,"SUSPECTED FUEL LEAK") | ...
    contains(Desc,"NO SUSPECTED FUEL LEAK") | ...
    contains(Desc,"CREATED IN ERROR") | ...
    contains(Desc,"CONDENSED WATER") | ...
    contains(Desc,"SEE TRF") | ...
    contains(Desc,"POST MX") | ...
    contains(Desc,"PARTS CLAIM") | ...
    contains(Desc,"WORK PERFORMED") | ...
    contains(Desc,"COMPLIED WITH") | ...
    contains(Desc,"TANK TIGERS") | ...
    contains(Desc,"DAILY FUEL SEEP") | ...
    contains(Desc,"FUEL SEEP CHECK") | ...
    contains(Desc,"REPEAT INSP");

LeakEvents = TrueLeakData(~RemoveRows,:);

fprintf('\nDATA REDUCTION SUMMARY\n');
fprintf('======================\n');

fprintf('Original Fuel Leak Records : %d\n',height(LeakData));
fprintf('After Leak Check Removal   : %d\n',height(TrueLeakData));
fprintf('Final Leak Population      : %d\n',height(LeakEvents));

%% DETERMINE TAIL COLUMN

Vars = LeakEvents.Properties.VariableNames;

if ismember('Tail',Vars)
    TailVar = string(LeakEvents.Tail);
elseif ismember('TailNumber',Vars)
    TailVar = string(LeakEvents.TailNumber);
else
    error('No Tail or TailNumber column found');
end

%% LEAK ORIGIN CLASSIFICATION

Desc = upper(string(LeakEvents.Description));

LeakOrigin = strings(height(LeakEvents),1);

% Refuel Hardware
LeakOrigin(contains(Desc,"SINGLE POINT")) = "SINGLE POINT";
LeakOrigin(contains(Desc,"SPR")) = "SINGLE POINT";
LeakOrigin(contains(Desc,"REFUEL PORT")) = "REFUEL PORT";
LeakOrigin(contains(Desc,"REFUEL CAP")) = "REFUEL CAP";
LeakOrigin(contains(Desc,"REFUEL")) = "REFUEL SYSTEM";
LeakOrigin(contains(Desc,"MANIFOLD")) = "FUEL MANIFOLD";
LeakOrigin(contains(Desc,"COUPLING")) = "COUPLING";

% Drain System
LeakOrigin(contains(Desc,"DRAIN MAST")) = "DRAIN MAST";
LeakOrigin(contains(Desc,"DRAIN")) = "DRAIN SYSTEM";

% Vent System
LeakOrigin(contains(Desc,"NACA")) = "VENT SYSTEM";
LeakOrigin(contains(Desc,"VENT")) = "VENT SYSTEM";

% MLI
LeakOrigin(contains(Desc,"MAGNETIC LEVEL")) = "MLI";
LeakOrigin(contains(Desc,"MLI")) = "MLI";

% Center Tank
LeakOrigin(contains(Desc,"CENTER BELLY")) = "CENTER TANK";
LeakOrigin(contains(Desc,"CENTER OF AIRCRAFT")) = "CENTER TANK";
LeakOrigin(contains(Desc,"CENTER OF THE PLANE")) = "CENTER TANK";
LeakOrigin(contains(Desc,"CENTER TANK")) = "CENTER TANK";
LeakOrigin(contains(Desc,"BELLY")) = "CENTER TANK";

% Wing Root
LeakOrigin(contains(Desc,"WING ROOT")) = "WING ROOT";

% Flap Fairing
LeakOrigin(contains(Desc,"HINGE BOX")) = "FLAP FAIRING";
LeakOrigin(contains(Desc,"FLAP FAIRING")) = "FLAP FAIRING";
LeakOrigin(contains(Desc,"FLAP")) = "FLAP FAIRING";

% Trunion
LeakOrigin(contains(Desc,"TRUNION")) = "TRUNION AREA";

% Fuel Feed System
LeakOrigin(contains(Desc,"FEED SHROUD")) = "FUEL FEED SHROUD";
LeakOrigin(contains(Desc,"SHROUD")) = "FUEL FEED SHROUD";
LeakOrigin(contains(Desc,"FEED TUBE")) = "FUEL FEED SYSTEM";
LeakOrigin(contains(Desc,"FUEL FEED")) = "FUEL FEED SYSTEM";

% Fuel Panels
LeakOrigin(contains(Desc,"ACCESS PANEL")) = "FUEL PANEL";
LeakOrigin(contains(Desc,"FUEL PANEL")) = "FUEL PANEL";
LeakOrigin(contains(Desc,"PANEL")) = "FUEL PANEL";

% Wing Leaks
LeakOrigin(contains(Desc,"LEFT WING")) = "WING";
LeakOrigin(contains(Desc,"RIGHT WING")) = "WING";
LeakOrigin(contains(Desc,"LH WING")) = "WING";
LeakOrigin(contains(Desc,"RH WING")) = "WING";

% Fuselage
LeakOrigin(contains(Desc,"FUSELAGE")) = "FUSELAGE";
LeakOrigin(contains(Desc,"GEAR DOOR")) = "FUSELAGE";

% Sensors
LeakOrigin(contains(Desc,"SENSOR")) = "SENSOR";

% Remaining
LeakOrigin(contains(Desc,"FUEL/DEFUEL PORT")) = "REFUEL PORT";
LeakOrigin(contains(Desc,"FUEL DEFUEL PORT")) = "REFUEL PORT";

LeakOrigin(contains(Desc,"SINGLE ADAPTER")) = "SINGLE POINT";

LeakOrigin(contains(Desc,"COLLECTOR TANK")) = "COLLECTOR TANK";

LeakOrigin(contains(Desc,"CENTER WING")) = "CENTER TANK";

LeakOrigin(contains(Desc,"WINGROOT")) = "WING ROOT";

LeakOrigin(contains(Desc,"FUEL SUMP")) = "DRAIN SYSTEM";
LeakOrigin(contains(Desc,"SUMP PORT")) = "DRAIN SYSTEM";

LeakOrigin(contains(Desc,"PRESSURE RELIEF VALVE")) = "RELIEF VALVE";

LeakOrigin(contains(Desc,"MAGNETIC FUEL LEVEL")) = "MLI";
LeakOrigin(contains(Desc,"LEVEL INDICATOR")) = "MLI";

LeakOrigin(LeakOrigin=="") = "OTHER";

LeakEvents.LeakOrigin = LeakOrigin;

%% LEAK LOCATION RANKING

[G,Origins] = findgroups(LeakEvents.LeakOrigin);
Counts = splitapply(@numel,LeakEvents.LeakOrigin,G);

OriginTable = table(Origins,Counts);
OriginTable = sortrows(OriginTable,'Counts','descend');

fprintf('\nLEAK LOCATION RANKING\n');
fprintf('=====================\n');
disp(OriginTable)

%% LEAK LOCATION CHART

figure

bar(OriginTable.Counts)

xlabel('Leak Location')
ylabel('Number of Leak Events')
title('Fuel Leak Locations')

xticks(1:height(OriginTable))
xticklabels(cellstr(OriginTable.Origins))
xtickangle(45)

grid on

%% CHRONIC AIRCRAFT

[G,Tails] = findgroups(TailVar);
LeakCounts = splitapply(@numel,TailVar,G);

TailTable = table(Tails,LeakCounts);
TailTable = sortrows(TailTable,'LeakCounts','descend');

fprintf('\nTOP CHRONIC LEAK AIRCRAFT\n');
fprintf('=========================\n');

disp(TailTable(1:min(20,height(TailTable)),:))

%% REPEAT LEAK COMBINATIONS

LeakEvents.LeakKey = strcat(TailVar,"_",LeakEvents.LeakOrigin);

[G,Keys] = findgroups(LeakEvents.LeakKey);

Counts = splitapply(@numel,LeakEvents.LeakKey,G);

RepeatLeakTable = table(Keys,Counts);
RepeatLeakTable = sortrows(RepeatLeakTable,'Counts','descend');

fprintf('\nREPEAT LEAK LOCATIONS\n');
fprintf('=====================\n');

disp(RepeatLeakTable(1:min(25,height(RepeatLeakTable)),:))

%% REPAIR EFFECTIVENESS INPUT

if ismember('RepairCategory',Vars)

    [G,Repairs] = findgroups(LeakEvents.RepairCategory);

    RepairCounts = splitapply(@numel,...
        LeakEvents.RepairCategory,G);

    RepairTable = table(Repairs,RepairCounts);

    RepairTable = sortrows(RepairTable,...
        'RepairCounts','descend');
    %% IMPROVE REPAIR CATEGORIZATION

    CA = upper(string(LeakEvents.CorrectiveAction));

    RepairCategory = string(LeakEvents.RepairCategory);

    %% Leak Rate Checks

    RepairCategory( ...
        contains(CA,"LEAK RATE CHECK")) = "LEAK RATE CHECK";

    %% Tightening / Torque

    RepairCategory( ...
        contains(CA,"TIGHTEN")) = "TORQUE/ADJUST";

    RepairCategory( ...
        contains(CA,"TORQUED")) = "TORQUE/ADJUST";

    RepairCategory( ...
        contains(CA,"LOOSE SCREW")) = "TORQUE/ADJUST";

    RepairCategory( ...
        contains(CA,"LOOSE BOLT")) = "TORQUE/ADJUST";

    %% Reseating

    RepairCategory( ...
        contains(CA,"RESEAT")) = "RESEAT";

    RepairCategory( ...
        contains(CA,"RESEATED")) = "RESEAT";

    RepairCategory( ...
        contains(CA,"INCORRECTLY SEATED")) = "RESEAT";

    %% Reseal

    RepairCategory( ...
        contains(CA,"SEALANT")) = "RESEAL";

    RepairCategory( ...
        contains(CA,"RESEAL")) = "RESEAL";

    %% Drain Repairs

    RepairCategory( ...
        contains(CA,"WATER DRAIN")) = "DRAIN REPAIR";

    RepairCategory( ...
        contains(CA,"DRAIN POPPET")) = "DRAIN REPAIR";

    RepairCategory( ...
        contains(CA,"DRAIN MAST")) = "DRAIN REPAIR";

    %% Monitoring

    RepairCategory( ...
        contains(CA,"MONITOR")) = "MONITOR";

    RepairCategory( ...
        contains(CA,"MONITORED")) = "MONITOR";

    %% Fueling Verification

    RepairCategory( ...
        contains(CA,"PRESSURE REFUEL")) = "REFUEL CHECK";

    RepairCategory( ...
        contains(CA,"AUTOMATIC PRESSURE REFUELING")) = "REFUEL CHECK";

    RepairCategory( ...
        contains(CA,"PERFORMED REFUEL")) = "REFUEL CHECK";

    %% Outsourced Repairs

    RepairCategory( ...
        contains(CA,"TANK TIGERS")) = "OUTSOURCED REPAIR";

    %% Administrative Actions

    RepairCategory( ...
        contains(CA,"SEE TRF")) = "ADMINISTRATIVE";

    RepairCategory( ...
        contains(CA,"PARTS CLAIM")) = "ADMINISTRATIVE";

    RepairCategory( ...
        contains(CA,"WORK PERFORMED")) = "ADMINISTRATIVE";

    RepairCategory( ...
        contains(CA,"COMPLIED WITH")) = "ADMINISTRATIVE";

    %% Save updated category

    LeakEvents.RepairCategory = RepairCategory;

    fprintf('\nREPAIR DISTRIBUTION\n');
    fprintf('===================\n');

    disp(RepairTable)

end

%% SEAL RELATED REPAIRS

if ismember('RepairCategory',Vars)

    SealRows = ...
        contains(upper(string(LeakEvents.RepairCategory)),"SEAL") | ...
        contains(upper(string(LeakEvents.RepairCategory)),"O-RING") | ...
        contains(upper(string(LeakEvents.RepairCategory)),"GASKET");

    SealData = LeakEvents(SealRows,:);

    fprintf('\nSEAL RELATED LEAK LOCATIONS\n');
    fprintf('===========================\n');

    tabulate(SealData.LeakOrigin)

end

%% SAVE CLEAN DATASET

writetable(LeakEvents,'ATA28_FuelLeakDataset.xlsx');

fprintf('\nAnalysis Complete\n');

%% Questions To Answer

fprintf('\nREPEAT LEAK LOCATION ANALYSIS\n');
fprintf('============================\n');

LeakEvents.LeakKey = strcat( ...
    TailVar,"_", ...
    string(LeakEvents.LeakOrigin));

[G,Keys] = findgroups(LeakEvents.LeakKey);

Counts = splitapply(@numel,LeakEvents.LeakKey,G);

RepeatLocationTable = table(Keys,Counts);

RepeatLocationTable = sortrows( ...
    RepeatLocationTable,...
    'Counts','descend');

disp(RepeatLocationTable(1:min(25,height(RepeatLocationTable)),:))

fprintf('\nREPAIR EFFECTIVENESS INPUT\n');
fprintf('==========================\n');

[G,Repairs] = findgroups(LeakEvents.RepairCategory);

RepairCounts = splitapply(@numel,...
    LeakEvents.RepairCategory,G);

RepairTable = table(Repairs,RepairCounts);

RepairTable = sortrows(RepairTable,...
    'RepairCounts','descend');

disp(RepairTable)

fprintf('\nN630NN CASE STUDY\n');
fprintf('=================\n');

N630Rows = LeakEvents(TailVar=="N630NN",:);

disp(N630Rows(:,{'LeakOrigin'}))

fprintf('\nSEAL DEGRADATION ANALYSIS\n');
fprintf('=========================\n');

SealRows = ...
    contains(upper(string(LeakEvents.RepairCategory)),"SEAL") | ...
    contains(upper(string(LeakEvents.RepairCategory)),"O-RING") | ...
    contains(upper(string(LeakEvents.RepairCategory)),"GASKET");

SealData = LeakEvents(SealRows,:);

tabulate(SealData.LeakOrigin)

fprintf('\nFLEET COMPARISON\n');
fprintf('================\n');

[G,Fleet,Origin] = findgroups( ...
    string(LeakEvents.FleetType), ...
    string(LeakEvents.LeakOrigin));

Counts = splitapply(@numel,...
    LeakEvents.LeakOrigin,G);

FleetTable = table(Fleet,Origin,Counts);

FleetTable = sortrows(FleetTable,...
    'Counts','descend');

disp(FleetTable)

ValidRows = ...
    ~strcmpi(string(LeakEvents.Component),"OTHER");

CompData = LeakEvents(ValidRows,:);

[G,Origin,Component] = findgroups( ...
    string(CompData.LeakOrigin), ...
    string(CompData.Component));

Counts = splitapply(@numel,...
    CompData.Component,...
    G);

ComponentTable = table( ...
    Origin,...
    Component,...
    Counts);

ComponentTable = sortrows( ...
    ComponentTable,...
    'Counts','descend');

fprintf('\nTOP COMPONENTS BY LEAK LOCATION\n');
fprintf('===============================\n');

disp(ComponentTable(1:min(50,height(ComponentTable)),:))

fprintf('\nSEAL REPAIR LOCATION ANALYSIS\n');
fprintf('=============================\n');

SealRows = ...
    contains(upper(string(LeakEvents.RepairCategory)),"SEAL") | ...
    contains(upper(string(LeakEvents.RepairCategory)),"O-RING") | ...
    contains(upper(string(LeakEvents.RepairCategory)),"GASKET");

SealData = LeakEvents(SealRows,:);

[G,Origins] = findgroups(SealData.LeakOrigin);

Counts = splitapply(@numel,...
    SealData.LeakOrigin,G);

SealLocationTable = table(Origins,Counts);

SealLocationTable = sortrows( ...
    SealLocationTable,...
    'Counts','descend');

disp(SealLocationTable)

fprintf('\nPOST-MAINTENANCE LEAKS\n');
fprintf('======================\n');

Desc = upper(string(LeakEvents.Description));

PostMXRows = ...
    contains(Desc,"POST MX") | ...
    contains(Desc,"AFTER MX") | ...
    contains(Desc,"AFTER MAINTENANCE") | ...
    contains(Desc,"AFTER REPAIR") | ...
    contains(Desc,"AFTER FUELING");

PostMXData = LeakEvents(PostMXRows,:);

fprintf('Suspected Post-MX Leak Events: %d\n', ...
    height(PostMXData));

tabulate(PostMXData.LeakOrigin)

fprintf('\nRECURRING LEAK LOCATIONS\n');
fprintf('========================\n');

LeakEvents.LeakKey = strcat( ...
    TailVar,"_", ...
    string(LeakEvents.LeakOrigin));

[G,Keys] = findgroups(LeakEvents.LeakKey);

Counts = splitapply(@numel,...
    LeakEvents.LeakKey,G);

RecurrenceTable = table(Keys,Counts);

RecurrenceTable = sortrows( ...
    RecurrenceTable,...
    'Counts','descend');

RecurringOnly = RecurrenceTable( ...
    RecurrenceTable.Counts > 1,:);

disp(RecurringOnly)

fprintf('\nLEAK LOCATION RECURRENCE RATE\n');
fprintf('=============================\n');

[G,Origins] = findgroups(LeakEvents.LeakOrigin);

TotalEvents = splitapply(@numel,...
    LeakEvents.LeakOrigin,G);

RecurringEvents = zeros(size(TotalEvents));

for i = 1:length(Origins)

    Rows = strcmp(string(LeakEvents.LeakOrigin),...
        string(Origins(i)));

    Temp = LeakEvents(Rows,:);

    Keys = strcat(TailVar(Rows),"_",...
        string(Temp.LeakOrigin));

    [G2,~] = findgroups(Keys);

    Counts2 = splitapply(@numel,Keys,G2);

    RecurringEvents(i) = sum(Counts2 > 1);

end

RecurrenceRate = 100 * ...
    RecurringEvents ./ TotalEvents;

LocationRecurrence = table( ...
    Origins,...
    TotalEvents,...
    RecurringEvents,...
    RecurrenceRate);

LocationRecurrence = sortrows( ...
    LocationRecurrence,...
    'RecurrenceRate','descend');

disp(LocationRecurrence)

fprintf('\nCHRONIC AIRCRAFT\n');
fprintf('================\n');

[G,Tails] = findgroups(TailVar);

LeakCounts = splitapply(@numel,...
    TailVar,G);

UniqueLocations = splitapply( ...
    @(x) numel(unique(x)), ...
    string(LeakEvents.LeakOrigin),...
    G);

ChronicTable = table( ...
    Tails,...
    LeakCounts,...
    UniqueLocations);

ChronicTable = sortrows( ...
    ChronicTable,...
    'LeakCounts','descend');

disp(ChronicTable(1:min(25,height(ChronicTable)),:))

fprintf('\nREPAIR RECURRENCE ANALYSIS\n');
fprintf('==========================\n');

Repairs = unique(string(LeakEvents.RepairCategory));

RepairRecurrence = [];

for i = 1:length(Repairs)

    Rows = strcmp( ...
        string(LeakEvents.RepairCategory),...
        Repairs(i));

    Temp = LeakEvents(Rows,:);

    Keys = strcat( ...
        TailVar(Rows),"_", ...
        string(Temp.LeakOrigin));

    [G2,~] = findgroups(Keys);

    Counts2 = splitapply(@numel,...
        Keys,G2);

    RepeatCount = sum(Counts2 > 1);

    RepairRecurrence = ...
        [RepairRecurrence;
        Repairs(i), ...
        string(RepeatCount)];
end

disp(RepairRecurrence)

fprintf('\nN630NN HISTORY\n');
fprintf('==============\n');

N630 = LeakEvents(TailVar=="N630NN",:);

disp(N630(:,{'LeakOrigin','RepairCategory'}))

fprintf('\nN630NN TIMELINE\n');
fprintf('===============\n');

N630Rows = LeakEvents(TailVar=="N630NN",:);

if ismember('ReportedDate',N630Rows.Properties.VariableNames)

    N630Rows = sortrows(N630Rows,'ReportedDate');

    disp(N630Rows(:,{'ReportedDate',...
        'LeakOrigin',...
        'RepairCategory',...
        'Component'}))

else

    disp(N630Rows(:,{'LeakOrigin',...
        'RepairCategory',...
        'Component'}))

end

fprintf('\nWING LEAK BREAKDOWN\n');
fprintf('===================\n');

WingRows = LeakEvents( ...
    LeakEvents.LeakOrigin=="WING",:);

tabulate(WingRows.Component)

tabulate(WingRows.RepairCategory)

fprintf('\nFUEL FEED SYSTEM INVESTIGATION\n');
fprintf('=============================\n');

FeedRows = LeakEvents( ...
    LeakEvents.LeakOrigin=="FUEL FEED SYSTEM",:);

tabulate(FeedRows.Component)

tabulate(FeedRows.RepairCategory)

fprintf('\nDRAIN SYSTEM INVESTIGATION\n');
fprintf('==========================\n');

DrainRows = LeakEvents( ...
    LeakEvents.LeakOrigin=="DRAIN SYSTEM",:);

tabulate(DrainRows.Component)

tabulate(DrainRows.RepairCategory)

fprintf('\nMLI INVESTIGATION\n');
fprintf('=================\n');

MLIRows = LeakEvents( ...
    LeakEvents.LeakOrigin=="MLI",:);

tabulate(MLIRows.Component)

tabulate(MLIRows.RepairCategory)

fprintf('\nREPAIR VS INSPECTION\n');
fprintf('====================\n');

RepairRows = ...
    ~ismember( ...
    string(LeakEvents.RepairCategory), ...
    ["INSPECTION", ...
    "LEAK CHECK", ...
    "ADMINISTRATIVE", ...
    "REFUEL CHECK", ...
    "LEAK RATE CHECK"]);

fprintf('Actual Repairs: %d\n', ...
    sum(RepairRows));

fprintf('Non-Repair Actions: %d\n', ...
    height(LeakEvents)-sum(RepairRows));


fprintf('\nREPAIR RECURRENCE MATRIX\n');
fprintf('========================\n');

Repairs = unique(string(LeakEvents.RepairCategory));

for i = 1:length(Repairs)

    Rows = strcmp( ...
        string(LeakEvents.RepairCategory), ...
        Repairs(i));

    Temp = LeakEvents(Rows,:);

    Keys = strcat( ...
        TailVar(Rows),"_", ...
        string(Temp.LeakOrigin));

    [G2,~] = findgroups(Keys);

    Counts2 = splitapply(@numel,Keys,G2);

    fprintf('%s : %d recurring\n', ...
        Repairs(i), ...
        sum(Counts2 > 1));

end

fprintf('\nCRJ700 VS CRJ900\n');
fprintf('================\n');

tabulate(LeakEvents.FleetType)

[G,Fleet,Origin] = findgroups( ...
    string(LeakEvents.FleetType), ...
    string(LeakEvents.LeakOrigin));

Counts = splitapply(@numel,...
    LeakEvents.LeakOrigin,G);

FleetCompare = table(Fleet,Origin,Counts);

FleetCompare = sortrows(FleetCompare,...
    'Counts','descend');

disp(FleetCompare)

fprintf('\nCOMPONENT RELIABILITY\n');
fprintf('=====================\n');

ValidRows = ...
    ~strcmpi(string(LeakEvents.Component),"OTHER");

CompData = LeakEvents(ValidRows,:);

[G,Components] = findgroups( ...
    string(CompData.Component));

Counts = splitapply(@numel,...
    CompData.Component,G);

ComponentTable = table( ...
    Components,...
    Counts);

ComponentTable = sortrows( ...
    ComponentTable,...
    'Counts','descend');

disp(ComponentTable)

fprintf('\nSEAL FAILURE RANKING\n');
fprintf('====================\n');

SealRows = ...
    contains(upper(string(LeakEvents.Component)),"SEAL") | ...
    contains(upper(string(LeakEvents.Component)),"O-RING") | ...
    contains(upper(string(LeakEvents.Component)),"GASKET");

SealData = LeakEvents(SealRows,:);

tabulate(SealData.LeakOrigin)

fprintf('\nTOP LEAK DRIVERS\n');
fprintf('================\n');

tabulate(LeakEvents.LeakOrigin)

fprintf('\nTOP CHRONIC AIRCRAFT\n');
fprintf('====================\n');

disp(ChronicTable(1:min(20,height(ChronicTable)),:))

fprintf('\nRECURRING LEAK LOCATIONS\n');
fprintf('========================\n');

disp(LocationRecurrence)

fprintf('\nMOST COMMON REPAIRS\n');
fprintf('===================\n');

disp(RepairTable)

fprintf('\nSEAL-DRIVEN LEAK LOCATIONS\n');
fprintf('==========================\n');

disp(SealLocationTable)

fprintf('\nN630NN ROOT CAUSE REVIEW\n');
fprintf('========================\n');

N630Rows = LeakEvents(TailVar=="N630NN",:);

if ismember('ReportedDate',N630Rows.Properties.VariableNames)

    N630Rows = sortrows(N630Rows,'ReportedDate');

end

disp(N630Rows(:,{'ReportedDate',...
    'LeakOrigin',...
    'Component',...
    'RepairCategory'}))

fprintf('\nN630NN LEAK LOCATION BREAKDOWN\n');
fprintf('=============================\n');

tabulate(N630Rows.LeakOrigin)

fprintf('\nN630NN COMPONENT BREAKDOWN\n');
fprintf('=========================\n');

tabulate(N630Rows.Component)

fprintf('\nN630NN REPAIR BREAKDOWN\n');
fprintf('======================\n');

tabulate(N630Rows.RepairCategory)

fprintf('\nWING LEAK ROOT CAUSE REVIEW\n');
fprintf('===========================\n');

WingRows = LeakEvents( ...
    LeakEvents.LeakOrigin=="WING",:);

tabulate(WingRows.Component)

tabulate(WingRows.RepairCategory)

fprintf('\nWING LEAK DESCRIPTIONS\n');
fprintf('======================\n');

for i = 1:height(WingRows)

    fprintf('\n%s\n', ...
        string(WingRows.Description(i)));

end

fprintf('\nREPAIR SUCCESS ANALYSIS\n');
fprintf('=======================\n');

Repairs = unique(string(LeakEvents.RepairCategory));

SuccessTable = [];

for i = 1:length(Repairs)

    Rows = strcmp( ...
        string(LeakEvents.RepairCategory), ...
        Repairs(i));

    Temp = LeakEvents(Rows,:);

    Keys = strcat( ...
        TailVar(Rows),"_", ...
        string(Temp.LeakOrigin));

    [G,~] = findgroups(Keys);

    Counts = splitapply(@numel,Keys,G);

    RepeatCount = sum(Counts > 1);

    TotalCount = height(Temp);

    SuccessRate = ...
        100*(1 - RepeatCount/max(TotalCount,1));

    SuccessTable = [SuccessTable;
        Repairs(i), ...
        string(TotalCount), ...
        string(RepeatCount), ...
        string(round(SuccessRate,1))];
end

disp(SuccessTable)

fprintf('\nRECURRENCE ROOT CAUSE\n');
fprintf('=====================\n');

RecurringRows = [];

for i = 1:height(LeakEvents)

    Key = strcat( ...
        TailVar(i),"_", ...
        string(LeakEvents.LeakOrigin(i)));

    MatchRows = strcmp( ...
        strcat(TailVar,"_", ...
        string(LeakEvents.LeakOrigin)), ...
        Key);

    if sum(MatchRows) > 1

        RecurringRows(i) = true;

    else

        RecurringRows(i) = false;

    end
end

RecurringData = LeakEvents(logical(RecurringRows),:);

fprintf('\nRECURRING COMPONENTS\n');
fprintf('====================\n');

tabulate(RecurringData.Component)

fprintf('\nRECURRING REPAIR TYPES\n');
fprintf('======================\n');

tabulate(RecurringData.RepairCategory)

fprintf('\nRECURRING LEAK LOCATIONS\n');
fprintf('========================\n');

tabulate(RecurringData.LeakOrigin)

fprintf('\nRECURRING WING LEAKS ONLY\n');
fprintf('=========================\n');

RecurringWing = LeakEvents( ...
    LeakEvents.LeakOrigin=="WING",:);

Keys = strcat( ...
    TailVar(LeakEvents.LeakOrigin=="WING"),"_WING");

[G,KeyNames] = findgroups(Keys);

Counts = splitapply(@numel,Keys,G);

RepeatWingTable = table(KeyNames,Counts);

RepeatWingTable = sortrows( ...
    RepeatWingTable,...
    'Counts','descend');

disp(RepeatWingTable)

fprintf('\nWING SUBCATEGORY ANALYSIS\n');
fprintf('========================\n');

WingRows = LeakEvents(LeakEvents.LeakOrigin=="WING",:);

WingDesc = upper(string(WingRows.Description));

WingSub = strings(height(WingRows),1);

WingSub(contains(WingDesc,"WING ROOT")) = "WING ROOT";
WingSub(contains(WingDesc,"WEEP")) = "WEEP HOLE";
WingSub(contains(WingDesc,"NACA")) = "VENT";
WingSub(contains(WingDesc,"VENT")) = "VENT";

WingSub(contains(WingDesc,"MLI")) = "MLI";
WingSub(contains(WingDesc,"LEVEL INDICATOR")) = "MLI";

WingSub(contains(WingDesc,"PANEL")) = "ACCESS PANEL";

WingSub(contains(WingDesc,"DRAIN")) = "WATER DRAIN";

WingSub(contains(WingDesc,"FLAP")) = "FLAP AREA";

WingSub(contains(WingDesc,"TIP")) = "WING TIP";

WingSub(WingSub=="") = "GENERAL WING";

tabulate(WingSub)

fprintf('\nFUEL FEED ROOT CAUSE\n');
fprintf('====================\n');

FeedRows = LeakEvents( ...
    LeakEvents.LeakOrigin=="FUEL FEED SYSTEM",:);

fprintf('\nDESCRIPTIONS\n');
fprintf('============\n');

for i = 1:height(FeedRows)

    fprintf('\n%s\n', ...
        string(FeedRows.Description(i)));

end

fprintf('\nCOMPONENTS\n');
fprintf('==========\n');

tabulate(FeedRows.Component)

fprintf('\nREPAIRS\n');
fprintf('=======\n');

tabulate(FeedRows.RepairCategory)

fprintf('\nN630NN DESCRIPTION REVIEW\n');
fprintf('========================\n');

N630Rows = LeakEvents(TailVar=="N630NN",:);

if ismember('ReportedDate', ...
        N630Rows.Properties.VariableNames)

    N630Rows = sortrows( ...
        N630Rows,'ReportedDate');

end

for i = 1:height(N630Rows)

    fprintf('\n====================================\n');

    fprintf('Date: %s\n', ...
        string(N630Rows.ReportedDate(i)));

    fprintf('Origin: %s\n', ...
        string(N630Rows.LeakOrigin(i)));

    fprintf('Repair: %s\n', ...
        string(N630Rows.RepairCategory(i)));

    fprintf('Description:\n%s\n', ...
        string(N630Rows.Description(i)));

end


fprintf('\nDISCOVERY VS ACTUAL REPAIR\n');
fprintf('==========================\n');

NonRepairRows = ...
    ismember(string(LeakEvents.RepairCategory), ...
    ["INSPECTION", ...
    "ADMINISTRATIVE", ...
    "LEAK CHECK", ...
    "REFUEL CHECK", ...
    "LEAK RATE CHECK", ...
    "MONITOR"]);

ActualRepairRows = ~NonRepairRows;

ActualRepairs = sum(ActualRepairRows);
NonRepairs = sum(NonRepairRows);

fprintf('Actual Repairs      : %d\n',ActualRepairs);
fprintf('Inspection/Tracking : %d\n',NonRepairs);

fprintf('Actual Repairs %%    : %.1f%%\n', ...
    100*ActualRepairs/height(LeakEvents));

fprintf('Non-Repair %%        : %.1f%%\n', ...
    100*NonRepairs/height(LeakEvents));
































































































































































