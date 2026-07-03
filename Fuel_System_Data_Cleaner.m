%% ATA 28 Fuel System Data Cleaner
% PSA Engineering Reliability Project
% Version 1

clear;
clc;
close all;

%% 1. IMPORT EXCEL FILE

[file,path] = uigetfile({'*.csv'}, ...
    'Select ATA 28 Fuel Data File');

filename = fullfile(path,file);

T = readtable(filename, ...
    'VariableNamingRule','preserve');

disp('Raw Data Imported');

%% 2. STANDARDIZE COLUMN NAMES

T.Properties.VariableNames = matlab.lang.makeValidName( ...
    T.Properties.VariableNames);

%% 3. CONVERT DESCRIPTION & CORRECTIVE ACTION TO STRING

if iscell(T.Description)
    T.Description = string(T.Description);
end

if iscell(T.CorrectiveAction)
    T.CorrectiveAction = string(T.CorrectiveAction);
end

%% 4. CLEAN TEXT

T.Description = upper(T.Description);
T.CorrectiveAction = upper(T.CorrectiveAction);

% Remove extra spaces

T.Description = regexprep(T.Description,'\s+',' ');
T.CorrectiveAction = regexprep(T.CorrectiveAction,'\s+',' ');

% Remove leading/trailing spaces

T.Description = strtrim(T.Description);
T.CorrectiveAction = strtrim(T.CorrectiveAction);

%% 5. REMOVE DUPLICATE ROWS

rows_before = height(T);

T = unique(T);

rows_after = height(T);

disp(['Duplicates Removed: ' num2str(rows_before-rows_after)])

%% 6. CREATE DISCREPANCY CATEGORY COLUMN (VERSION 3)

T.DiscrepancyCategory = strings(height(T),1);

for i = 1:height(T)

    txt = T.Description(i);

    % HANDLE BLANK DISCREPANCIES
    if strlength(strtrim(txt)) == 0

        T.DiscrepancyCategory(i) = "NO DISCREPANCY TEXT";

    % --- LEAKS ---
    elseif contains(txt, ["LEAK","SEEP","DRIP","WET","FUEL RESIDUE"])
        T.DiscrepancyCategory(i) = "FUEL LEAK";

    % --- SENSORS ---
    elseif contains(txt, ["HIGH LEVEL","LEVEL SENSOR"])
        T.DiscrepancyCategory(i) = "HIGH LEVEL SENSOR FAULT";

    elseif contains(txt, "PROBE")
        T.DiscrepancyCategory(i) = "FUEL PROBE ISSUE";

    % --- XFLOW / TRANSFER ---
    elseif contains(txt, ["XFLOW","CROSSFLOW","TRANSFER"])
        T.DiscrepancyCategory(i) = "TRANSFER/XFLOW ISSUE";

    % --- PUMPS ---
    elseif contains(txt, ["BOOST PUMP","PUMP INOP","PUMP FAIL"])
        T.DiscrepancyCategory(i) = "BOOST PUMP FAULT";

    elseif contains(txt, "PUMP") 
        T.DiscrepancyCategory(i) = "GENERAL PUMP ISSUE";

    % --- QUANTITY / INDICATION ---
    elseif contains(txt, ["QUANTITY","GAUGING","INDICATION","EICAS"])
        T.DiscrepancyCategory(i) = "FUEL QUANTITY INDICATION";

    elseif contains(txt, ["INDICATOR","DISPLAY"])
        T.DiscrepancyCategory(i) = "INDICATION ISSUE";

    % --- REFUEL / DEFUEL ---
    elseif contains(txt, ["REFUEL PANEL","CONTROL PANEL","PANEL NOT WORKING"])
        T.DiscrepancyCategory(i) = "REFUEL PANEL FAULT";

    elseif contains(txt, ["REFUEL","DEFUEL","FUELING"])
        T.DiscrepancyCategory(i) = "REFUEL SYSTEM ISSUE";

    % --- VALVES ---
    elseif contains(txt, "SOV")
        T.DiscrepancyCategory(i) = "SHUTOFF VALVE ISSUE";

    elseif contains(txt, "VALVE")
        T.DiscrepancyCategory(i) = "GENERAL VALVE ISSUE";

    % --- STRUCTURE / PANELS ---
    elseif contains(txt, ["PANEL","ACCESS PANEL"])
        T.DiscrepancyCategory(i) = "FUEL PANEL / STRUCTURE";

    elseif contains(txt, ["VENT","DRAIN"])
        T.DiscrepancyCategory(i) = "VENT / DRAIN ISSUE";

    % --- CAP / LANYARD ---
    elseif contains(txt, ["LANYARD","CAP","CHAIN","FILLER"])
        T.DiscrepancyCategory(i) = "CAP OR LANYARD DAMAGE";

    % --- WARNINGS ---
    elseif contains(txt, ["LIGHT","MESSAGE","CAUTION","WARNING"])
        T.DiscrepancyCategory(i) = "WARNING MESSAGE";

    % --- MAINTENANCE TASKS ---
    elseif contains(txt, ["INSTALL","REMOVE","TASK","PERFORM"])
        T.DiscrepancyCategory(i) = "MAINTENANCE TASK";

    else
        T.DiscrepancyCategory(i) = "OTHER";
    end

end



%% 7. CREATE CORRECTIVE ACTION CATEGORY (VERSION 3)

T.RepairCategory = strings(height(T),1);

for i = 1:height(T)

    txt = T.CorrectiveAction(i);

    % HANDLE BLANK CORRECTIVE ACTIONS FIRST
    if strlength(strtrim(txt)) == 0

        T.RepairCategory(i) = "NO CORRECTIVE ACTION";

    % --- FQGC ---
    elseif contains(txt, ["FQGC","FUEL QUANTITY GAUGING COMPUTER"])
        T.RepairCategory(i) = "FQGC REPLACEMENT";

        % MEL / M-FUNCTION

    elseif contains(txt,["M FUNCTION","M-FUNCTION","M/FUNCTION","MEL"])
        T.RepairCategory(i) = "MEL COMPLIANCE";

        % INSPECTIONS

    elseif contains(txt,["INSPECTED","INSPECTION","INSP","GVI"])
        T.RepairCategory(i) = "INSPECTION";

        % BONDING

    elseif contains(txt,["BOND CHECK","BOND TEST"])
        T.RepairCategory(i) = "BOND CHECK";

        % ADMINISTRATIVE

    elseif contains(txt,["REFER TO","REFERENCE","DUPLICATE CARD"])
        T.RepairCategory(i) = "ADMINISTRATIVE";

        % REATTACHMENT

    elseif contains(txt,["REATTACHED","RE-ATTACHED","RECONNECTED","CONNECTED"])
        T.RepairCategory(i) = "REATTACH/RECONNECT";

        % SECURING

    elseif contains(txt,["RESECURED","SECURED"])
        T.RepairCategory(i) = "SECURE/ADJUST";

        % MODIFICATION

    elseif contains(txt,["MODIFICATION","COMPLIED WITH TO_"])
        T.RepairCategory(i) = "MODIFICATION";

        % DEFERRED

    elseif contains(txt,"DEFERRED")
        T.RepairCategory(i) = "DEFERRAL ACTION";

        % TROUBLESHOOTING

    elseif contains(txt,["TROUBLESHOT","T/S"])
        T.RepairCategory(i) = "TROUBLESHOOTING";

        % MIPM

    elseif contains(txt,["MIPM","FAULT EXTINGUISHED","MSG EXTINGUISHED"])
        T.RepairCategory(i) = "SYSTEM RESET";

    % --- SENSOR ---
    elseif contains(txt, ["HIGH LEVEL SENSOR","SENSOR"])
        T.RepairCategory(i) = "SENSOR REPLACEMENT";

    % --- PROBE ---
    elseif contains(txt, "PROBE")
        T.RepairCategory(i) = "PROBE REPLACEMENT";

    % --- SEALS ---
    elseif contains(txt, ["O-RING","O RING"])
        T.RepairCategory(i) = "O-RING REPLACEMENT";

    elseif contains(txt, ["SEAL","PACKING"])
        T.RepairCategory(i) = "SEAL REPLACEMENT";

    elseif contains(txt, "GASKET")
        T.RepairCategory(i) = "GASKET REPLACEMENT";

    % --- PANELS ---
    elseif contains(txt, ["CONTROL PANEL","REFUEL PANEL"])
        T.RepairCategory(i) = "REFUEL PANEL REPLACEMENT";

    elseif contains(txt, "PANEL")
        T.RepairCategory(i) = "PANEL REPAIR";

    % --- VALVES ---
    elseif contains(txt, "SOV")
        T.RepairCategory(i) = "SOV REPLACEMENT";

    elseif contains(txt, "VALVE")
        T.RepairCategory(i) = "VALVE REPAIR";

    % --- CHECKS ---
    elseif contains(txt, "LEAK CHECK")
        T.RepairCategory(i) = "LEAK CHECK";

    elseif contains(txt, ["OPS CHECK","FUNCTIONAL","TEST"])
        T.RepairCategory(i) = "OPERATIONAL CHECK";

    % --- RESET ---
    elseif contains(txt, ["RESET","CB","CYCLED"])
        T.RepairCategory(i) = "SYSTEM RESET";

    % --- INSTALL / REMOVE ---
    elseif contains(txt, "INSTALL")
        T.RepairCategory(i) = "INSTALLATION";

    elseif contains(txt, "REMOVE")
        T.RepairCategory(i) = "REMOVAL";

    % --- GENERAL REPLACEMENT ---
    elseif contains(txt, ["REPLACED","R/R","REMOVED AND REPLACED"])
        T.RepairCategory(i) = "GENERAL REPLACEMENT";

    else
        T.RepairCategory(i) = "OTHER";
    end

end

%% 8. CREATE FLEET GROUP

T.FleetGroup = string(T.FleetType);

%% CREATE FLEET-SPECIFIC TABLES

CRJ700_Data = T(T.FleetGroup == "CRJ700", :);

CRJ900_Data = T(T.FleetGroup == "CRJ900", :);

disp(['CRJ700 Records: ' num2str(height(CRJ700_Data))])
disp(['CRJ900 Records: ' num2str(height(CRJ900_Data))])

%% CRJ700 DISCREPANCIES

CRJ700_Disc = groupsummary( ...
    CRJ700_Data,...
    "DiscrepancyCategory");

CRJ700_Disc = sortrows( ...
    CRJ700_Disc,...
    "GroupCount","descend");

disp(' ')
disp('CRJ700 TOP DISCREPANCIES')
disp(CRJ700_Disc)

%% CRJ900 DISCREPANCIES

CRJ900_Disc = groupsummary( ...
    CRJ900_Data,...
    "DiscrepancyCategory");

CRJ900_Disc = sortrows( ...
    CRJ900_Disc,...
    "GroupCount","descend");

disp(' ')
disp('CRJ900 TOP DISCREPANCIES')
disp(CRJ900_Disc)

%% CRJ700 REPAIRS

CRJ700_Repair = groupsummary( ...
    CRJ700_Data,...
    "RepairCategory");

CRJ700_Repair = sortrows( ...
    CRJ700_Repair,...
    "GroupCount","descend");

disp(' ')
disp('CRJ700 TOP REPAIRS')
disp(CRJ700_Repair)

%% CRJ900 REPAIRS

CRJ900_Repair = groupsummary( ...
    CRJ900_Data,...
    "RepairCategory");

CRJ900_Repair = sortrows( ...
    CRJ900_Repair,...
    "GroupCount","descend");

disp(' ')
disp('CRJ900 TOP REPAIRS')
disp(CRJ900_Repair)


%% 9. MEL FLAG

T.MELFlag = false(height(T),1);

if ismember('FaultStatus', T.Properties.VariableNames)

    T.MELFlag = contains( ...
        string(T.FaultStatus), ...
        "MEL", ...
        'IgnoreCase', true);
end

%% 10. CALCULATE REPAIR HOURS

T.RepairHours = NaN(height(T),1);

try

    reported = datetime(T.ReportedDate);

    resolved = datetime(T.ResolvedDate);

    T.RepairHours = hours(resolved - reported);

catch

    warning('Could not calculate repair duration');

end

%% 11. CREATE DELAY TOTAL COLUMN

T.DelayImpact = zeros(height(T),1);

if ismember('DELMin',T.Properties.VariableNames)

    T.DelayImpact = T.DELMin;

end

%% 12. CREATE FUEL SUBSYSTEM COLUMN

T.Subsystem = strings(height(T),1);

for i = 1:height(T)

    ata = string(T.ATA(i));

    if startsWith(ata,"2813")
        T.Subsystem(i) = "TRANSFER/XFLOW";

    elseif startsWith(ata,"2825")
        T.Subsystem(i) = "REFUEL/DEFUEL";

    elseif startsWith(ata,"2840")
        T.Subsystem(i) = "FUEL QUANTITY";

    elseif startsWith(ata,"2823")
        T.Subsystem(i) = "BOOST PUMP";

    elseif startsWith(ata,"2821")
        T.Subsystem(i) = "FEED SYSTEM";

    elseif startsWith(ata,"2810")
        T.Subsystem(i) = "TANK STRUCTURE";

    else
        T.Subsystem(i) = "OTHER";
    end

end


%% 13. CREATE CLEANED FILE

outputFile = 'ATA28_Cleaned.xlsx';

writetable(T,outputFile);

disp(' ');
disp('ATA28 CLEANING COMPLETE');
disp(['Cleaned File Created: ' outputFile]);

%% 14. QUICK QUALITY CHECKS

disp(' ');
disp('Top Discrepancy Categories');

disp(groupsummary(T,"DiscrepancyCategory"));

disp(' ');
disp('Top Repair Categories');

disp(groupsummary(T,"RepairCategory"));

