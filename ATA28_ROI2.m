%% ROI #2 - REFUEL SYSTEM INVESTIGATION
% Phase 1: Build Refuel-Specific Dataset

clear; clc;

%% Load ATA28 Cleaned Data

T = readtable('ATA28_Cleaned.xlsx');

% Convert dates

if ~isdatetime(T.ReportedDate)
    T.ReportedDate = datetime(T.ReportedDate);
end

if ismember('ResolvedDate',T.Properties.VariableNames)

    if ~isdatetime(T.ResolvedDate)
        T.ResolvedDate = datetime(T.ResolvedDate);
    end

end

%% Convert text columns to string

TextCols = {'DiscrepancyCategory','RepairCategory','Component',...
            'Subsystem','Description','CorrectiveAction'};

for i = 1:length(TextCols)

    if ismember(TextCols{i},T.Properties.VariableNames)
        T.(TextCols{i}) = string(T.(TextCols{i}));
    end

end

%% =====================================================================
% STEP 1 - EXTRACT REFUEL POPULATION
% ======================================================================

RefuelFilter = ...
    contains(upper(string(T.Subsystem)),"REFUEL/DEFUEL") | ...
    contains(upper(string(T.DiscrepancyCategory)),"REFUEL") | ...
    contains(upper(string(T.Description)),"REFUEL") | ...
    contains(upper(string(T.Description)),"FUELING") | ...
    contains(upper(string(T.Description)),"HIGH LEVEL SENSOR") | ...
    contains(upper(string(T.Description)),"PRESSURE REFUEL");

RefuelData = T(RefuelFilter,:);

fprintf('\n');
fprintf('=============================================\n');
fprintf('REFUEL ROI DATASET CREATED\n');
fprintf('=============================================\n');
fprintf('Total Refuel Records: %d\n',height(RefuelData));

%% =====================================================================
% STEP 2 - BUILD REFUEL FAILURE MODES
% ======================================================================

RefuelData.RefuelFailureMode = strings(height(RefuelData),1);

for i = 1:height(RefuelData)

    Cat  = upper(string(RefuelData.DiscrepancyCategory(i)));
    Desc = upper(string(RefuelData.Description(i)));

    if contains(Cat,"HIGH LEVEL") || ...
       contains(Desc,"HIGH LEVEL SENSOR")

        RefuelData.RefuelFailureMode(i) = ...
            "HIGH LEVEL SENSOR";

    elseif contains(Cat,"REFUEL PANEL")

        RefuelData.RefuelFailureMode(i) = ...
            "REFUEL PANEL";

    elseif contains(Cat,"INDICATION")

        RefuelData.RefuelFailureMode(i) = ...
            "REFUEL INDICATION";

    elseif contains(Cat,"FUEL LEAK")

        RefuelData.RefuelFailureMode(i) = ...
            "REFUEL LEAK";

    elseif contains(Cat,"CAP") || ...
           contains(Cat,"LANYARD")

        RefuelData.RefuelFailureMode(i) = ...
            "CAP/LANYARD";

    elseif contains(Cat,"REFUEL SYSTEM")

        RefuelData.RefuelFailureMode(i) = ...
            "REFUEL CONTROL";

    elseif contains(Desc,"UNABLE TO REFUEL")

        RefuelData.RefuelFailureMode(i) = ...
            "UNABLE TO REFUEL";

    elseif contains(Desc,"NOT TAKE FUEL")

        RefuelData.RefuelFailureMode(i) = ...
            "FUEL ACCEPTANCE FAILURE";
    elseif contains(Cat,"SHUTOFF VALVE")

        RefuelData.RefuelFailureMode(i) = ...
            "SHUTOFF VALVE";

    elseif contains(Cat,"GENERAL VALVE")

        RefuelData.RefuelFailureMode(i) = ...
            "VALVE";
    elseif contains(Cat,"FUEL PANEL")

        RefuelData.RefuelFailureMode(i) = ...
            "FUEL PANEL";
    elseif contains(Cat,"WARNING")

        RefuelData.RefuelFailureMode(i) = ...
            "WARNING MESSAGE";
    elseif contains(Cat,"VENT")

        RefuelData.RefuelFailureMode(i) = ...
            "VENT/DRAIN";
    elseif contains(Cat,"PUMP")

        RefuelData.RefuelFailureMode(i) = ...
            "PUMP";
    else

        RefuelData.RefuelFailureMode(i) = ...
            "OTHER";

    end

end
RefuelControlRows = RefuelData( ...
    strcmp(string(RefuelData.DiscrepancyCategory), ...
    "REFUEL SYSTEM ISSUE"), :);



%% =====================================================================
% STEP 3 - BUILD REFUEL REPAIR GROUPS
% ======================================================================

RefuelData.RefuelRepairGroup = strings(height(RefuelData),1);

for i = 1:height(RefuelData)

    Repair = upper(string(RefuelData.RepairCategory(i)));

    if contains(Repair,"SYSTEM RESET")

        RefuelData.RefuelRepairGroup(i) = ...
            "RESET";

    elseif contains(Repair,"FQGC")

        RefuelData.RefuelRepairGroup(i) = ...
            "FQGC ACTION";

    elseif contains(Repair,"SOV")

        RefuelData.RefuelRepairGroup(i) = ...
            "SOV ACTION";

    elseif contains(Repair,"O-RING")

        RefuelData.RefuelRepairGroup(i) = ...
            "SEAL/O-RING REPAIR";

    elseif contains(Repair,"SEAL")

        RefuelData.RefuelRepairGroup(i) = ...
            "SEAL/O-RING REPAIR";

    elseif contains(Repair,"PANEL")

        RefuelData.RefuelRepairGroup(i) = ...
            "REFUEL PANEL ACTION";

    elseif contains(Repair,"OPERATIONAL CHECK")

        RefuelData.RefuelRepairGroup(i) = ...
            "OPERATIONAL CHECK";

    elseif contains(Repair,"MEL")

        RefuelData.RefuelRepairGroup(i) = ...
            "MEL ACTION";

    elseif contains(Repair,"INSPECTION")

        RefuelData.RefuelRepairGroup(i) = ...
            "INSPECTION";

    elseif contains(Repair,"INSTALL")

        RefuelData.RefuelRepairGroup(i) = ...
            "INSTALLATION";

    elseif contains(Repair,"REMOVE")

        RefuelData.RefuelRepairGroup(i) = ...
            "REMOVAL";

    elseif contains(Repair,"MODIFICATION")

        RefuelData.RefuelRepairGroup(i) = ...
            "MODIFICATION";

    elseif contains(Repair,"NO CORRECTIVE ACTION")

        RefuelData.RefuelRepairGroup(i) = ...
            "NO ACTION";
    elseif contains(Repair,"LEAK CHECK")

        RefuelData.RefuelRepairGroup(i) = ...
            "LEAK CHECK";

    elseif contains(Repair,"GASKET")

        RefuelData.RefuelRepairGroup(i) = ...
            "SEAL/GASKET REPAIR";

    elseif contains(Repair,"SECURE") || ...
            contains(Repair,"ADJUST")

        RefuelData.RefuelRepairGroup(i) = ...
            "MECHANICAL ADJUSTMENT";

    elseif contains(Repair,"REATTACH") || ...
            contains(Repair,"RECONNECT")

        RefuelData.RefuelRepairGroup(i) = ...
            "CONNECTION REPAIR";

    elseif contains(Repair,"TROUBLESHOOT")

        RefuelData.RefuelRepairGroup(i) = ...
            "TROUBLESHOOTING";

    elseif contains(Repair,"VALVE")

        RefuelData.RefuelRepairGroup(i) = ...
            "VALVE REPAIR";

    elseif contains(Repair,"SENSOR")

        RefuelData.RefuelRepairGroup(i) = ...
            "SENSOR REPLACEMENT";

    elseif contains(Repair,"GENERAL REPLACEMENT")

        RefuelData.RefuelRepairGroup(i) = ...
            "GENERAL REPLACEMENT";

    elseif contains(Repair,"ADMINISTRATIVE")

        RefuelData.RefuelRepairGroup(i) = ...
            "ADMINISTRATIVE";

    elseif contains(Repair,"REMOVAL")

        RefuelData.RefuelRepairGroup(i) = ...
            "REMOVAL";
    else

        RefuelData.RefuelRepairGroup(i) = ...
            "OTHER";
   

    end

end



RefuelOtherComp = RefuelControlRows( ...
    RefuelControlRows.Component=="OTHER",:);

RefuelControlRows = RefuelData( ...
    strcmp(string(RefuelData.DiscrepancyCategory), ...
    "REFUEL SYSTEM ISSUE"), :);

fprintf('\n');
fprintf('REFUEL SYSTEM ISSUE RECORDS: %d\n', ...
    height(RefuelControlRows));
RefuelControlRows.ControlSubMode = strings(height(RefuelControlRows),1);

for i = 1:height(RefuelControlRows)

    Desc = upper(string(RefuelControlRows.Description(i)));

    % CAP / LANYARD

    if contains(Desc,"LANYARD") || ...
            contains(Desc,"CHAIN") || ...
            contains(Desc,"CAP BROKEN") || ...
            contains(Desc,"CAP MISSING") || ...
            contains(Desc,"CAP CRACKED")

        RefuelControlRows.ControlSubMode(i) = ...
            "CAP/LANYARD";

        % GASKET / SEAL

    elseif contains(Desc,"GASKET") || ...
            contains(Desc,"SEAL") || ...
            contains(Desc,"DRY ROTTED") || ...
            contains(Desc,"TORN")

        RefuelControlRows.ControlSubMode(i) = ...
            "SEAL/GASKET";

        % PANEL

    elseif contains(Desc,"PANEL") || ...
            contains(Desc,"NO POWER TO REFUEL")

        RefuelControlRows.ControlSubMode(i) = ...
            "REFUEL PANEL";

        % SHUTOFF VALVE

    elseif contains(Desc,"SOV") || ...
            contains(Desc,"SHUTOFF VALVE") || ...
            contains(Desc,"VALVE")

        RefuelControlRows.ControlSubMode(i) = ...
            "VALVE/SOV";

        % MANIFOLD / TUBING

    elseif contains(Desc,"MANIFOLD") || ...
            contains(Desc,"TUBE ASSEMBLY") || ...
            contains(Desc,"PORT OF THE REFUEL")

        RefuelControlRows.ControlSubMode(i) = ...
            "MANIFOLD/TUBING";

        % FUEL SPILL / OVERFLOW

    elseif contains(Desc,"FUEL POURED") || ...
            contains(Desc,"FUEL SPILL") || ...
            contains(Desc,"COME OUT FROM UNDER")

        RefuelControlRows.ControlSubMode(i) = ...
            "OVERFLOW/SPILL";

        % WILL NOT ACCEPT FUEL

    elseif contains(Desc,"WOULD NOT TAKE FUEL") || ...
            contains(Desc,"NOT SENDING FUEL") || ...
            contains(Desc,"NOT ACCEPT FUEL")

        RefuelControlRows.ControlSubMode(i) = ...
            "FUEL ACCEPTANCE FAILURE";

        % PRESSURE REFUEL

    elseif contains(Desc,"PRESSURE REFUEL")

        RefuelControlRows.ControlSubMode(i) = ...
            "PRESSURE REFUEL";
    elseif contains(Desc,"INOP") || ...
            contains(Desc,"NOT TAKE FUEL") || ...
            contains(Desc,"NOT ACCEPTING FUEL") || ...
            contains(Desc,"UNABLE TO DEFUEL") || ...
            contains(Desc,"AUTO REFUEL") || ...
            contains(Desc,"AUTOMATIC MODE") || ...
            contains(Desc,"FUELING ERROR") || ...
            contains(Desc,"WILL NOT WORK")

        RefuelControlRows.ControlSubMode(i) = ...
            "REFUEL OPERATION FAILURE";

    elseif contains(Desc,"FAULT CODE") || ...
            contains(Desc,"ERROR CODE") || ...
            contains(Desc,"FAULT DETECT") || ...
            contains(Desc,"COMPUTER") || ...
            contains(Desc,"NO POWER TO REFUEL")

        RefuelControlRows.ControlSubMode(i) = ...
            "REFUEL CONTROL SYSTEM";

    elseif contains(Desc,"FUEL IMBALANCE") || ...
            contains(Desc,"FUEL QTY") || ...
            contains(Desc,"AMBER DASHES")

        RefuelControlRows.ControlSubMode(i) = ...
            "FUEL QUANTITY INDICATION";

    elseif contains(Desc,"VENT") || ...
            contains(Desc,"OVERFUEL") || ...
            contains(Desc,"DUMPED GAS") || ...
            contains(Desc,"FUEL SPRAY") || ...
            contains(Desc,"COMING OUT")

        RefuelControlRows.ControlSubMode(i) = ...
            "OVERFLOW/VENT";

    elseif contains(Desc,"STRUCTURE") || ...
            contains(Desc,"REINFORCING RING") || ...
            contains(Desc,"GROMMET") || ...
            contains(Desc,"SUPPORT") || ...
            contains(Desc,"LOCK ON")

        RefuelControlRows.ControlSubMode(i) = ...
            "ADAPTER/STRUCTURAL HARDWARE";
    else

        RefuelControlRows.ControlSubMode(i) = ...
            "OTHER";

        

    end

end
disp(' ');
disp('REFUEL CONTROL BREAKDOWN');
disp('========================');

[GroupNames,~,idx] = unique(RefuelControlRows.ControlSubMode);

Counts = accumarray(idx,1);

Breakdown = table(GroupNames,Counts,...
    'VariableNames',{'FailureMode','Count'});

Breakdown.Percent = ...
    round(100*Breakdown.Count/sum(Breakdown.Count),2);

Breakdown = sortrows(Breakdown,'Count','descend');

disp(Breakdown)


%% =====================================================================
% SUMMARY OUTPUTS
% ======================================================================

disp(' ');
disp('=========================================');
disp('REFUEL FAILURE MODES');
disp('=========================================');

[FailureGroups,~,idx] = unique(RefuelData.RefuelFailureMode);

FailureCounts = accumarray(idx,1);

FailureSummary = table(FailureGroups,...
                       FailureCounts,...
                       'VariableNames',...
                       {'FailureMode','Count'});

FailureSummary = sortrows(FailureSummary,...
                         'Count','descend');

disp(FailureSummary);

disp(' ');
disp('=========================================');
disp('REFUEL REPAIR GROUPS');
disp('=========================================');

[RepairGroups,~,idx] = unique(RefuelData.RefuelRepairGroup);

RepairCounts = accumarray(idx,1);

RepairSummary = table(RepairGroups,...
                      RepairCounts,...
                      'VariableNames',...
                      {'RepairGroup','Count'});

RepairSummary = sortrows(RepairSummary,...
                        'Count','descend');

disp(RepairSummary);


%% =====================================================
% OPERATIONAL REFUEL FAILURE POPULATION
% ======================================================

OperationalRows = RefuelControlRows( ...
    RefuelControlRows.ControlSubMode == "REFUEL OPERATION FAILURE" | ...
    RefuelControlRows.ControlSubMode == "REFUEL CONTROL SYSTEM" | ...
    RefuelControlRows.ControlSubMode == "VALVE/SOV" | ...
    RefuelControlRows.ControlSubMode == "OVERFLOW/VENT" | ...
    RefuelControlRows.ControlSubMode == "FUEL QUANTITY INDICATION" | ...
    RefuelControlRows.ControlSubMode == "REFUEL PANEL", :);

fprintf('\n');
fprintf('========================================\n');
fprintf('OPERATIONAL REFUEL FAILURE POPULATION\n');
fprintf('========================================\n');
fprintf('Records = %d\n',height(OperationalRows));
fprintf('Percent of All Refuel Events = %.1f%%\n', ...
    100*height(OperationalRows)/height(RefuelData));

disp(' ');
disp('OPERATIONAL FAILURE MODES');
disp('=========================');

tabulate(OperationalRows.ControlSubMode)

disp(' ');
disp('COMPONENT BREAKDOWN');
disp('===================');

tabulate(OperationalRows.Component)
disp(' ');
disp('REPAIR BREAKDOWN');
disp('================');

tabulate(OperationalRows.RepairCategory)


disp(' ');
disp('AUTO REFUEL FAILURE COMPONENTS');
disp('==============================');

AutoRows = OperationalRows( ...
    contains(upper(string(OperationalRows.Description)),"AUTO") | ...
    contains(upper(string(OperationalRows.Description)),"AUTOMATIC"), :);

if height(AutoRows)==0

    fprintf('\nNo Auto Refuel Records Found\n');

else

    disp(' ');
    disp('AUTO REFUEL FAILURE COMPONENTS');
    disp('==============================');

    tabulate(AutoRows.Component)

    disp(' ');
    disp('AUTO REFUEL FAILURE REPAIRS');
    disp('===========================');

    tabulate(AutoRows.RepairCategory)

end
tabulate(AutoRows.Component)

disp(' ');
disp('AUTO REFUEL FAILURE REPAIRS');
disp('===========================');


tabulate(AutoRows.RepairCategory)

TankFailRows = OperationalRows( ...
    contains(upper(string(OperationalRows.Description)), ...
    "NOT TAKE FUEL") | ...
    contains(upper(string(OperationalRows.Description)), ...
    "NOT ACCEPTING FUEL"), :);

disp(' ');
disp('TANK WILL NOT ACCEPT FUEL');
disp('=========================');

tabulate(TankFailRows.Component)

tabulate(TankFailRows.RepairCategory)

FaultRows = OperationalRows( ...
    contains(upper(string(OperationalRows.Description)), ...
    "FAULT") | ...
    contains(upper(string(OperationalRows.Description)), ...
    "ERROR CODE") | ...
    contains(upper(string(OperationalRows.Description)), ...
    "CODE"), :);

disp(' ');
disp('FAULT CODE POPULATION');
disp('=====================');

disp(FaultRows(:, ...
    {'Tail','Component','RepairCategory'}))

disp(' ');
disp('FAULT CODE 30-DAY RECURRENCE');
disp('============================');

Returned30 = 0;

for i = 1:height(FaultRows)

    Tail = string(FaultRows.Tail(i));
    EventDate = FaultRows.ReportedDate(i);

    FutureEvents = RefuelData( ...
        string(RefuelData.Tail)==Tail & ...
        RefuelData.ReportedDate > EventDate & ...
        RefuelData.ReportedDate <= EventDate + days(30), :);

    if ~isempty(FutureEvents)
        Returned30 = Returned30 + 1;
    end

end

fprintf('Returned Within 30 Days: %d\n',Returned30);
fprintf('No Return: %d\n',height(FaultRows)-Returned30);
fprintf('Return Rate: %.1f%%\n', ...
    100*Returned30/height(FaultRows));

disp(' ');
disp('NEXT EVENT AFTER FAULT CODE');
disp('===========================');

for i = 1:height(FaultRows)

    Tail = string(FaultRows.Tail(i));
    EventDate = FaultRows.ReportedDate(i);

    FutureEvents = RefuelData( ...
        string(RefuelData.Tail)==Tail & ...
        RefuelData.ReportedDate > EventDate,:);

    FutureEvents = sortrows(FutureEvents,...
        'ReportedDate','ascend');

    if height(FutureEvents) > 0

        fprintf('\n--- %s ---\n',Tail);

        disp(FutureEvents(1,...
            {'ReportedDate',...
            'RefuelFailureMode',...
            'RepairCategory'}));

    end
end


disp(' ');
disp('FAULT CODE REPAIR ACTIONS');
disp('=========================');

tabulate(FaultRows.RepairCategory)


FaultTails = unique(string(FaultRows.Tail));

for i = 1:length(FaultTails)

    TailEvents = OperationalRows( ...
        string(OperationalRows.Tail)==FaultTails(i),:);

    if height(TailEvents) >= 3

        fprintf('\nCHRONIC: %s (%d events)\n', ...
            FaultTails(i),height(TailEvents));

    end

end

disp(' ');
disp('POST-FAULT MEL ANALYSIS');
disp('=======================');

MELAfter = 0;

for i = 1:height(FaultRows)

    Tail = string(FaultRows.Tail(i));

    EventDate = FaultRows.ReportedDate(i);

    FutureEvents = RefuelData( ...
        string(RefuelData.Tail)==Tail & ...
        RefuelData.ReportedDate > EventDate,:);

    if any(FutureEvents.RefuelRepairGroup=="MEL ACTION")

        MELAfter = MELAfter + 1;

    end

end

fprintf('Eventually MEL''d: %d\n',MELAfter);
fprintf('Not MEL''d: %d\n',height(FaultRows)-MELAfter);
fprintf('MEL Rate: %.1f%%\n', ...
    100*MELAfter/height(FaultRows));

disp(' ');
disp('FAULT CODE OUTCOME SUMMARY');
disp('==========================');

tabulate(FaultRows.Component)
tabulate(FaultRows.RepairCategory)


%% ==========================================================
% ROI #2 - ENGINEERING EFFECTIVENESS ANALYSIS
% ==========================================================

disp(' ');
disp('FAILURE MODES RESULTING IN MEL ACTION');
disp('=========================');

MELRows = RefuelData( ...
    RefuelData.RefuelRepairGroup=="MEL ACTION",:);

tabulate(MELRows.RefuelFailureMode)


disp(' ');
disp('OPERATIONAL FAILURE BREAKDOWN');
disp('=============================');

tabulate(OperationalRows.ControlSubMode)

disp(' ');
disp('OPERATIONAL FAILURE COMPONENTS');
disp('==============================');

tabulate(OperationalRows.Component)

disp(' ');
disp('OPERATIONAL FAILURE REPAIRS');
disp('===========================');

tabulate(OperationalRows.RepairCategory)

disp(' ');
disp('POST-FQGC OUTCOMES');
disp('==================');

FQGCRows = RefuelData( ...
    contains(string(RefuelData.RepairCategory), ...
    "FQGC"),:);

for i = 1:min(height(FQGCRows),100)

    Tail = FQGCRows.Tail(i);

    EventDate = FQGCRows.ReportedDate(i);

    LaterRows = RefuelData( ...
    strcmp(string(RefuelData.Tail),string(Tail)) & ...
    datenum(RefuelData.ReportedDate) > datenum(EventDate), :);

    if height(LaterRows) > 0

        fprintf('\nTail %s\n',string(Tail));

        disp(LaterRows(1,...
            {'ReportedDate',...
            'RefuelFailureMode',...
            'RepairCategory'}));

    end
end


disp(' ');
disp('POST-SOV OUTCOMES');
disp('=================');

SOVRows = RefuelData( ...
    contains(string(RefuelData.RepairCategory), ...
    "SOV"),:);

for i = 1:min(height(SOVRows),100)

    Tail = SOVRows.Tail(i);

    EventDate = SOVRows.ReportedDate(i);

    LaterRows = RefuelData( ...
    strcmp(string(RefuelData.Tail),string(Tail)) & ...
    datenum(RefuelData.ReportedDate) > datenum(EventDate), :);

    if height(LaterRows) > 0

        fprintf('\nTail %s\n',string(Tail));

        disp(LaterRows(1,...
            {'ReportedDate',...
            'RefuelFailureMode',...
            'RepairCategory'}));

    end
end

disp(' ');
disp('30-DAY REFUEL RECURRENCE');
disp('========================');

Returns30 = 0;

for i = 1:height(RefuelData)

    Tail = RefuelData.Tail(i);

    EventDate = RefuelData.ReportedDate(i);

    LaterRows = RefuelData( ...
        strcmp(string(RefuelData.Tail),string(Tail)) & ...
        RefuelData.ReportedDate > EventDate & ...
        RefuelData.ReportedDate <= EventDate + days(30),:);

    if height(LaterRows) > 0

        Returns30 = Returns30 + 1;

    end

end

fprintf('\n30-Day Return Rate = %.1f%%\n',...
    100*Returns30/height(RefuelData));


disp(' ');
disp('REPAIR EFFECTIVENESS');
disp('====================');

MajorRepairs = {
    'FQGC REPLACEMENT'
    'SOV REPLACEMENT'
    'PANEL REPAIR'
    'GASKET REPLACEMENT'
    };

for r = 1:length(MajorRepairs)

    RepairName = MajorRepairs{r};

    Rows = RefuelData( ...
        contains(string(RefuelData.RepairCategory), ...
        RepairName),:);

    Returns = 0;

    for i = 1:height(Rows)

        Tail = Rows.Tail(i);

        EventDate = Rows.ReportedDate(i);

        LaterRows = RefuelData( ...
            strcmp(string(RefuelData.Tail),string(Tail)) & ...
            RefuelData.ReportedDate > EventDate & ...
            RefuelData.ReportedDate <= EventDate + days(30),:);

        if height(LaterRows) > 0

            Returns = Returns + 1;

        end

    end

    if height(Rows) > 0

        fprintf('\n%s\n',RepairName);

        fprintf('Records: %d\n',height(Rows));

        fprintf('30-Day Return Rate: %.1f%%\n',...
            100*Returns/height(Rows));

    end

end


%% =====================================================
% SOV RECURRENCE ANALYSIS
% =====================================================

disp(' ');
disp('SOV RECURRENCE ANALYSIS');
disp('=======================');

SOVEvents = RefuelData( ...
    contains(upper(string(RefuelData.Description)),'SOV') | ...
    string(RefuelData.Component)=="SOV", :);

Returned = 0;

for i = 1:height(SOVEvents)

    Tail = string(SOVEvents.Tail(i));
    EventDate = SOVEvents.ReportedDate(i);

    FutureRows = RefuelData( ...
        string(RefuelData.Tail)==Tail & ...
        RefuelData.ReportedDate > EventDate & ...
        RefuelData.ReportedDate <= EventDate + days(30), :);

    if ~isempty(FutureRows)

        Returned = Returned + 1;

    end

end

fprintf('SOV Records: %d\n',height(SOVEvents));
fprintf('Returned Within 30 Days: %d\n',Returned);
fprintf('30-Day Return Rate: %.1f%%\n', ...
    100*Returned/height(SOVEvents));

%% =====================================================
% REFUEL PANEL RECURRENCE
% =====================================================

disp(' ');
disp('REFUEL PANEL RECURRENCE');
disp('=======================');

PanelRows = RefuelData( ...
    contains(upper(string(RefuelData.Description)),'PANEL') | ...
    string(RefuelData.Component)=="REFUEL PANEL", :);

Returned = 0;

for i = 1:height(PanelRows)

    Tail = string(PanelRows.Tail(i));
    EventDate = PanelRows.ReportedDate(i);

    FutureRows = RefuelData( ...
        string(RefuelData.Tail)==Tail & ...
        RefuelData.ReportedDate > EventDate & ...
        RefuelData.ReportedDate <= EventDate + days(30), :);

    if ~isempty(FutureRows)

        Returned = Returned + 1;

    end

end

fprintf('Panel Records: %d\n',height(PanelRows));
fprintf('Returned Within 30 Days: %d\n',Returned);
fprintf('30-Day Return Rate: %.1f%%\n', ...
    100*Returned/height(PanelRows));

%% =====================================================
% CHRONIC AIRCRAFT INVESTIGATION
% =====================================================

ChronicTails = { ...
    'N510AE'
    'N501BG'
    'N575NN'
    'N705PS'
    'N723PS'};

for t = 1:length(ChronicTails)

    TailRows = RefuelData( ...
        string(RefuelData.Tail)==ChronicTails{t}, :);

    TailRows = sortrows(TailRows,'ReportedDate');

    fprintf('\n');
    fprintf('===================================\n');
    fprintf('TAIL %s\n',ChronicTails{t});
    fprintf('===================================\n');

    disp(TailRows(:, ...
        {'ReportedDate',...
        'RefuelFailureMode',...
        'Component',...
        'RepairCategory'}));

end

%% =====================================================
% OPERATIONAL FAILURES THAT BECAME MELS
% =====================================================

disp(' ');
disp('OPERATIONAL FAILURE -> MEL');
disp('==========================');

for i = 1:height(OperationalRows)

    Tail = string(OperationalRows.Tail(i));

    EventDate = OperationalRows.ReportedDate(i);

    FutureRows = RefuelData( ...
        string(RefuelData.Tail)==Tail & ...
        RefuelData.ReportedDate > EventDate,:);

    FutureRows = sortrows(FutureRows,'ReportedDate');

    MELFound = any( ...
        FutureRows.RefuelRepairGroup=="MEL ACTION");

    if MELFound

        fprintf('\n');
        fprintf('TAIL: %s\n',Tail);

        fprintf('FAILURE MODE: %s\n', ...
            string(OperationalRows.ControlSubMode(i)));

        fprintf('COMPONENT: %s\n', ...
            string(OperationalRows.Component(i)));

    end

end

%% =====================================================================
% EXPORT FOR PHASE 2 ANALYSIS
% ======================================================================

writetable(RefuelData,...
          'ATA28_Refuel_ROI.xlsx');

fprintf('\n');
fprintf('Refuel dataset exported:\n');
fprintf('ATA28_Refuel_ROI.xlsx\n');
fprintf('\n');