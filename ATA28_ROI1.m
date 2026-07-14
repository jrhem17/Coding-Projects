%% ATA 28 ROI #1
% Transfer / XFLOW / SOV Analysis

clear
clc
close all

%% IMPORT

T = readtable("ATA28_Cleaned.xlsx");

T.EventDate = datetime(T.EventDate);
disp(class(T.EventDate))

disp(min(T.EventDate))
disp(max(T.EventDate))

disp(T.EventDate(1:20))
%% FILTER TRANSFER/XFLOW EVENTS

XFLOW = T(T.DiscrepancyCategory=="TRANSFER/XFLOW ISSUE",:);

disp(['Total Transfer/XFLOW Events: ' num2str(height(XFLOW))])

%% ---------------------------------------------------
%% QUESTION 1
%% WHAT PERCENTAGE RESULTED IN EACH REPAIR?
%% ---------------------------------------------------

RepairSummary = groupsummary( ...
    XFLOW,...
    "RepairCategory");

RepairSummary.Percent = ...
    100*RepairSummary.GroupCount/ ...
    sum(RepairSummary.GroupCount);

RepairSummary = sortrows( ...
    RepairSummary,...
    "Percent","descend");

disp(' ')
disp('TRANSFER/XFLOW REPAIR BREAKDOWN')
disp(RepairSummary)

%% ---------------------------------------------------
%% QUESTION 2
%% WHICH AIRCRAFT CREATE MOST XFLOW EVENTS?
%% ---------------------------------------------------

TailSummary = groupsummary( ...
    XFLOW,...
    "Tail");

TailSummary = sortrows( ...
    TailSummary,...
    "GroupCount","descend");

TopXflowAircraft = TailSummary( ...
    1:min(15,height(TailSummary)),:);

disp(' ')
disp('TOP XFLOW AIRCRAFT')
disp(TopXflowAircraft)

%% ---------------------------------------------------
%% QUESTION 3
%% CRJ700 VS CRJ900
%% ---------------------------------------------------

FleetSummary = groupsummary( ...
    XFLOW,...
    "FleetGroup");

FleetSummary = sortrows( ...
    FleetSummary,...
    "GroupCount","descend");

disp(' ')
disp('FLEET COMPARISON')
disp(FleetSummary)

%% EVENTS PER AIRCRAFT

 FleetAircraft = groupsummary( ...
    T,...
    "FleetGroup",...
    "numunique",...
    "Tail");


FleetAircraft.Properties.VariableNames{3} = ...
    'NumAircraft';

FleetAircraft = groupsummary( ...
    T,...
    "FleetGroup",...
    "numunique",...
    "Tail");

disp(FleetAircraft)

FleetSummary.Properties.VariableNames{'GroupCount'} = ...
    'TransferEvents';

FleetAircraft.Properties.VariableNames{'numunique_Tail'} = ...
    'NumAircraft';

FleetAnalysis = join( ...
    FleetSummary,...
    FleetAircraft,...
    'Keys','FleetGroup');

FleetAnalysis.EventsPerAircraft = ...
    FleetAnalysis.TransferEvents ./ ...
    FleetAnalysis.NumAircraft;

disp(FleetAnalysis)

disp(' ')
disp('NORMALIZED FLEET COMPARISON')
disp(FleetAnalysis)

%% ---------------------------------------------------
%% QUESTION 4
%% SOV RELATED RECURRENCE
%% ---------------------------------------------------

SOVEvents = T(T.Component=="SOV",:);

RepeatWindow = days(30);

RepeatCount = 0;

for i = 1:height(SOVEvents)

    currentTail = SOVEvents.Tail(i);
    currentDate = SOVEvents.EventDate(i);

    FutureEvents = T( ...
        strcmp(string(T.Tail), string(currentTail)) & ...
        T.EventDate > currentDate & ...
        T.EventDate <= currentDate + RepeatWindow & ...
        T.Component == "SOV", :);

    if height(FutureEvents) > 0
        RepeatCount = RepeatCount + 1;
    end

end

SOVRepeatRate = ...
    100 * RepeatCount / max(height(SOVEvents),1);

disp(' ')
disp(['SOV RELATED RECURRENCE RATE (30 DAYS): ' ...
      num2str(SOVRepeatRate) '%'])
%% ---------------------------------------------------
%% QUESTION 5
%% ATA 28 RECURRENCE AFTER SYSTEM RESET
%% ---------------------------------------------------

ResetEvents = T(T.RepairCategory=="SYSTEM RESET",:);

RepeatCount = 0;

for i = 1:height(ResetEvents)

    currentTail = ResetEvents.Tail(i);
    currentDate = ResetEvents.EventDate(i);

   FutureEvents = T( ...
    strcmp(string(T.Tail), string(currentTail)) & ...
    T.EventDate > currentDate & ...
    T.EventDate <= currentDate + RepeatWindow & ...
    T.Component == "SOV", :);

    if height(FutureEvents) > 0
        RepeatCount = RepeatCount + 1;
    end

end

ResetRepeatRate = ...
    100 * RepeatCount / max(height(ResetEvents),1);

disp(' ')
disp(['POST-RESET ATA28 RECURRENCE RATE: ' ...
      num2str(ResetRepeatRate) '%'])


%% ---------------------------------------------------
%% QUESTION 6
%% CHRONIC AIRCRAFT
%% ---------------------------------------------------

ATA28Tails = groupsummary( ...
    T,...
    "Tail");

ATA28Tails = sortrows( ...
    ATA28Tails,...
    "GroupCount","descend");

ChronicAircraft = ...
    ATA28Tails(1:min(20,height(ATA28Tails)),:);

disp(' ')
disp('TOP CHRONIC ATA 28 AIRCRAFT')
disp(ChronicAircraft)


%% ---------------------------------------------------
%% FQGC NO-FAULT-FOUND ANALYSIS
%% ---------------------------------------------------

FQGCData = ...
    T(T.RepairCategory=="FQGC REPLACEMENT",:);

NoFaultFound = false(height(FQGCData),1);

for i = 1:height(FQGCData)

    txt = upper(string( ...
        FQGCData.CorrectiveAction(i)));

    NoFaultFound(i) = ...
        contains(txt,"NO FAULT") | ...
        contains(txt,"NO FAULT FOUND") | ...
        contains(txt,"OPS CHECK GOOD") | ...
        contains(txt,"FAULT CLEARED") | ...
        contains(txt,"MESSAGE EXTINGUISHED") | ...
        contains(txt,"UNABLE TO DUPLICATE");

end

NFF_Count = sum(NoFaultFound);

NFF_Percent = ...
    100 * NFF_Count / ...
    max(height(FQGCData),1);

disp(' ')
disp(['FQGC NO-FAULT-FOUND RATE: ' ...
    num2str(NFF_Percent) '%'])

%% ---------------------------------------------------
%% POST-SOV FQGC INVESTIGATION
%% ---------------------------------------------------

SOVEvents = ...
    T(T.RepairCategory=="SOV REPLACEMENT",:);

FQGC_FollowUps = 0;

for i = 1:height(SOVEvents)

    currentTail = ...
        string(SOVEvents.Tail(i));

    currentDate = ...
        SOVEvents.EventDate(i);

    FollowUps = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate > currentDate & ...
        T.EventDate <= currentDate + days(30) & ...
        (T.Component == "FQGC" | ...
        T.RepairCategory == "FQGC REPLACEMENT"), :);

    if height(FollowUps) > 0

        FQGC_FollowUps = ...
            FQGC_FollowUps + 1;

    end

end

FollowUpPercent = ...
    100 * FQGC_FollowUps / ...
    max(height(SOVEvents),1);

disp(' ')
disp(['POST-SOV FQGC FOLLOW-UP RATE: ' ...
    num2str(FollowUpPercent) '%'])
%% ---------------------------------------------------
%% CHRONIC AIRCRAFT SCORE
%% ---------------------------------------------------

ChronicThreshold = 10;

ATA28Counts = groupsummary(T,"Tail");

ChronicAircraft = ATA28Counts( ...
    ATA28Counts.GroupCount >= ChronicThreshold,:);

disp(' ')
disp('CHRONIC AIRCRAFT (>10 ATA28 EVENTS)')
disp(ChronicAircraft)

%% ---------------------------------------------------
%% FQGC REPLACEMENT EFFECTIVENESS
%% ---------------------------------------------------

FQGCEvents = T(T.RepairCategory=="FQGC REPLACEMENT",:);

RepeatWindow = days(30);

FQGC_Repeats = 0;

for i = 1:height(FQGCEvents)

    currentTail = string(FQGCEvents.Tail(i));
    currentDate = FQGCEvents.EventDate(i);

    FutureEvents = XFLOW( ...
        strcmp(string(XFLOW.Tail),currentTail) & ...
        XFLOW.EventDate > currentDate & ...
        XFLOW.EventDate <= currentDate + RepeatWindow,:);

    if height(FutureEvents) > 0
        FQGC_Repeats = FQGC_Repeats + 1;
    end

end

FQGC_RepeatRate = ...
    100 * FQGC_Repeats / max(height(FQGCEvents),1);

disp(' ')
disp(['FQGC REPLACEMENT RECURRENCE RATE (30 DAYS): ' ...
    num2str(FQGC_RepeatRate) '%'])
%% ---------------------------------------------------
%% SOV REPLACEMENT EFFECTIVENESS
%% ---------------------------------------------------

SOVReplaceEvents = ...
    T(T.RepairCategory=="SOV REPLACEMENT",:);

SOVReplaceRepeats = 0;

for i = 1:height(SOVReplaceEvents)

    currentTail = string(SOVReplaceEvents.Tail(i));
    currentDate = SOVReplaceEvents.EventDate(i);

    FutureEvents = XFLOW( ...
        strcmp(string(XFLOW.Tail),currentTail) & ...
        XFLOW.EventDate > currentDate & ...
        XFLOW.EventDate <= currentDate + RepeatWindow,:);

    if height(FutureEvents) > 0
        SOVReplaceRepeats = SOVReplaceRepeats + 1;
    end

end

SOVReplacementRepeatRate = ...
    100 * SOVReplaceRepeats / ...
    max(height(SOVReplaceEvents),1);

disp(' ')
disp(['POST-SOV REPLACEMENT RECURRENCE RATE (30 DAYS): ' ...
    num2str(SOVReplacementRepeatRate) '%'])

%% ---------------------------------------------------
%% CORRECTIVE ACTION EFFECTIVENESS
%% ---------------------------------------------------

RepairsToEvaluate = [ ...
    "SYSTEM RESET"
    "SOV REPLACEMENT"
    "FQGC REPLACEMENT"
    "INSPECTION"
    "OPERATIONAL CHECK"];

Results = table();

for r = 1:length(RepairsToEvaluate)

    currentRepair = RepairsToEvaluate(r);

    RepairEvents = ...
        T(T.RepairCategory==currentRepair,:);

    RepeatCount = 0;

    for i = 1:height(RepairEvents)

        currentTail = ...
            string(RepairEvents.Tail(i));

        currentDate = ...
            RepairEvents.EventDate(i);

        FutureEvents = XFLOW( ...
            strcmp(string(XFLOW.Tail),currentTail) & ...
            XFLOW.EventDate > currentDate & ...
            XFLOW.EventDate <= currentDate + RepeatWindow,:);

        if height(FutureEvents) > 0

            RepeatCount = RepeatCount + 1;

        end

    end

    Rate = 100 * RepeatCount / ...
        max(height(RepairEvents),1);

    Results = [Results;
        table(currentRepair,...
        height(RepairEvents),...
        Rate,...
        'VariableNames',...
        {'RepairAction',...
        'TotalEvents',...
        'RecurrenceRate'})];

end

Results = sortrows( ...
    Results,...
    'RecurrenceRate',...
    'ascend');

disp(' ')
disp('CORRECTIVE ACTION EFFECTIVENESS')
disp(Results)

%% ---------------------------------------------------
%% FQGC VS SOV EFFECTIVENESS
%% ---------------------------------------------------

disp(' ')
disp('FQGC VS SOV EFFECTIVENESS')
disp('--------------------------')

disp(['FQGC Replacement Recurrence: ' ...
    num2str(FQGC_RepeatRate) '%'])

disp(['SOV Replacement Recurrence: ' ...
    num2str(SOVReplacementRepeatRate) '%'])

ImprovementFactor = ...
    SOVReplacementRepeatRate / FQGC_RepeatRate;

disp(['FQGC Performs Better By Factor Of: ' ...
    num2str(ImprovementFactor)])

%% ---------------------------------------------------
%% CHRONIC AIRCRAFT CROSS-CATEGORY ANALYSIS
%% ---------------------------------------------------

disp(' ')
disp('CHRONIC AIRCRAFT CROSS-CATEGORY ANALYSIS')

ATA28Tails = groupsummary(T,"Tail");

ATA28Tails = sortrows( ...
    ATA28Tails,...
    "GroupCount","descend");

TopChronicTails = string(ATA28Tails.Tail(1:10));

CrossCategoryResults = table();

for i = 1:length(TopChronicTails)

    currentTail = TopChronicTails(i);

    TailData = T( ...
        strcmp(string(T.Tail),currentTail),:);

    XFlowCount = sum( ...
        TailData.DiscrepancyCategory == ...
        "TRANSFER/XFLOW ISSUE");

    FuelQtyCount = sum( ...
        TailData.DiscrepancyCategory == ...
        "FUEL QUANTITY INDICATION");

    IndicationCount = sum( ...
        TailData.DiscrepancyCategory == ...
        "INDICATION ISSUE");

    CrossCategoryResults = ...
        [CrossCategoryResults;
         table(currentTail,...
               XFlowCount,...
               FuelQtyCount,...
               IndicationCount,...
               'VariableNames',{ ...
               'Tail',...
               'TransferXFLOW',...
               'FuelQuantity',...
               'IndicationIssue'})];

end

disp(CrossCategoryResults)

%% ---------------------------------------------------
%% RESET ROOT CAUSE ANALYSIS
%% ---------------------------------------------------

ResetEvents = ...
    T(T.RepairCategory=="SYSTEM RESET",:);

ResetSummary = groupsummary( ...
    ResetEvents,...
    "DiscrepancyCategory");

ResetSummary.Percent = ...
    100 * ResetSummary.GroupCount / ...
    sum(ResetSummary.GroupCount);

ResetSummary = sortrows( ...
    ResetSummary,...
    "Percent","descend");

disp(' ')
disp('SYSTEM RESET EVENT BREAKDOWN')
disp(ResetSummary)

%% ---------------------------------------------------
%% WHAT HAPPENS AFTER A RESET?
%% ---------------------------------------------------

ResetEvents = ...
    T(T.RepairCategory=="SYSTEM RESET",:);

NextReset = 0;
NextFQGC = 0;
NextSOV = 0;
NextMEL = 0;
NoFollowUp = 0;

for i = 1:height(ResetEvents)

    currentTail = string(ResetEvents.Tail(i));
    currentDate = ResetEvents.EventDate(i);

    FutureEvents = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate > currentDate,:);

    if isempty(FutureEvents)

        NoFollowUp = NoFollowUp + 1;
        continue

    end

    FutureEvents = sortrows( ...
        FutureEvents,...
        "EventDate");

    NextEvent = FutureEvents(1,:);

    if NextEvent.RepairCategory == "SYSTEM RESET"

        NextReset = NextReset + 1;

    elseif NextEvent.RepairCategory == "FQGC REPLACEMENT"

        NextFQGC = NextFQGC + 1;

    elseif NextEvent.RepairCategory == "SOV REPLACEMENT"

        NextSOV = NextSOV + 1;

    elseif contains( ...
            upper(string(NextEvent.CorrectiveAction)),...
            "MEL")

        NextMEL = NextMEL + 1;

    else

        NoFollowUp = NoFollowUp + 1;

    end

end

TotalEvents = NextReset + NextFQGC + ...
    NextSOV + NextMEL + ...
    NoFollowUp;

fprintf('\n');
fprintf('NEXT EVENT AFTER RESET\n');
fprintf('========================\n');

fprintf('Another Reset: %d (%.2f%%)\n', ...
    NextReset,...
    100*NextReset/TotalEvents);

fprintf('FQGC Replacement: %d (%.2f%%)\n', ...
    NextFQGC,...
    100*NextFQGC/TotalEvents);

fprintf('SOV Replacement: %d (%.2f%%)\n', ...
    NextSOV,...
    100*NextSOV/TotalEvents);

fprintf('MEL Related: %d (%.2f%%)\n', ...
    NextMEL,...
    100*NextMEL/TotalEvents);

fprintf('No ATA28 Follow Up: %d (%.2f%%)\n', ...
    NoFollowUp,...
    100*NoFollowUp/TotalEvents);

%% ---------------------------------------------------
%% RESETS BEFORE FQGC REPLACEMENT
%% ---------------------------------------------------

FQGCEvents = T(T.RepairCategory=="FQGC REPLACEMENT",:);

ResetsBeforeFQGC = [];

for i = 1:height(FQGCEvents)

    currentTail = string(FQGCEvents.Tail(i));
    currentDate = FQGCEvents.EventDate(i);

    PriorResets = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate < currentDate & ...
        T.RepairCategory=="SYSTEM RESET", :);

    ResetsBeforeFQGC(end+1) = height(PriorResets);

end

fprintf('\n');
fprintf('RESETS BEFORE FQGC REPLACEMENT\n');
fprintf('===============================\n');

fprintf('Average Resets Before FQGC: %.2f\n', ...
    mean(ResetsBeforeFQGC));

fprintf('Median Resets Before FQGC: %.2f\n', ...
    median(ResetsBeforeFQGC));

fprintf('Maximum Resets Before FQGC: %d\n', ...
    max(ResetsBeforeFQGC));

%% ---------------------------------------------------
%% WHAT DISCREPANCIES LEAD TO FQGC REPLACEMENT?
%% ---------------------------------------------------

LeadingDiscrepancies = table();

for i = 1:height(FQGCEvents)

    currentTail = string(FQGCEvents.Tail(i));
    currentDate = FQGCEvents.EventDate(i);

    PriorEvents = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate < currentDate,:);

    if ~isempty(PriorEvents)

        PriorEvents = sortrows(PriorEvents,...
            "EventDate","descend");

        LeadingDiscrepancies = ...
            [LeadingDiscrepancies;
            table(PriorEvents.DiscrepancyCategory(1), ...
            'VariableNames',{'Category'})];

    end

end

LeadingSummary = groupsummary( ...
    LeadingDiscrepancies,...
    "Category");

LeadingSummary.Percent = ...
    100*LeadingSummary.GroupCount/ ...
    sum(LeadingSummary.GroupCount);

LeadingSummary = sortrows( ...
    LeadingSummary,...
    "Percent","descend");

disp(' ')
disp('DISCREPANCIES MOST COMMONLY LEADING TO FQGC REPLACEMENT')
disp(LeadingSummary)

%% ---------------------------------------------------
%% CHRONIC AIRCRAFT MAINTENANCE BURDEN
%% ---------------------------------------------------

TopTails = string(ATA28Tails.Tail( ...
    1:min(15,height(ATA28Tails))));

ChronicBurden = table();

for i = 1:length(TopTails)

    currentTail = TopTails(i);

    TailData = T( ...
        strcmp(string(T.Tail),currentTail),:);

    TotalATA28 = height(TailData);

    Resets = sum( ...
        TailData.RepairCategory=="SYSTEM RESET");

    MELs = sum(contains( ...
        upper(string( ...
        TailData.CorrectiveAction)), ...
        "MEL"));

    FQGCs = sum( ...
        TailData.RepairCategory=="FQGC REPLACEMENT");

    ChronicBurden = ...
        [ChronicBurden;
        table(currentTail,...
        TotalATA28,...
        Resets,...
        MELs,...
        FQGCs,...
        'VariableNames',{ ...
        'Tail',...
        'ATA28Events',...
        'Resets',...
        'MELs',...
        'FQGCReplacements'})];

end

ChronicBurden = sortrows( ...
    ChronicBurden,...
    'ATA28Events',...
    'descend');

disp(' ')
disp('CHRONIC AIRCRAFT MAINTENANCE BURDEN')
disp(ChronicBurden)

%% ---------------------------------------------------
%% WHAT CLEARS THE MEL?
%% ---------------------------------------------------

MELEvents = T(contains( ...
    upper(string(T.CorrectiveAction)), ...
    "MEL"),:);

MELtoFQGC = 0;
MELtoReset = 0;
MELtoSOV = 0;
MELtoNoFurtherAction = 0;

for i = 1:height(MELEvents)

    currentTail = string(MELEvents.Tail(i));
    currentDate = MELEvents.EventDate(i);

    FutureEvents = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate > currentDate,:);

    if isempty(FutureEvents)

        MELtoNoFurtherAction = ...
            MELtoNoFurtherAction + 1;

        continue

    end

    FutureEvents = sortrows( ...
        FutureEvents,...
        "EventDate");

    NextEvent = FutureEvents(1,:);

    if NextEvent.RepairCategory=="FQGC REPLACEMENT"

        MELtoFQGC = MELtoFQGC + 1;

    elseif NextEvent.RepairCategory=="SYSTEM RESET"

        MELtoReset = MELtoReset + 1;

    elseif NextEvent.RepairCategory=="SOV REPLACEMENT"

        MELtoSOV = MELtoSOV + 1;

    else

        MELtoNoFurtherAction = ...
            MELtoNoFurtherAction + 1;

    end

end

TotalMEL = MELtoFQGC + ...
    MELtoReset + ...
    MELtoSOV + ...
    MELtoNoFurtherAction;

fprintf('\n');
fprintf('WHAT CLEARS THE MEL?\n');
fprintf('=====================\n');

fprintf('FQGC Replacement: %.2f%%\n', ...
    100*MELtoFQGC/TotalMEL);

fprintf('System Reset: %.2f%%\n', ...
    100*MELtoReset/TotalMEL);

fprintf('SOV Replacement: %.2f%%\n', ...
    100*MELtoSOV/TotalMEL);

fprintf('Other / No Further ATA28: %.2f%%\n', ...
    100*MELtoNoFurtherAction/TotalMEL);

%% ---------------------------------------------------
%% WHAT HAPPENS AFTER THE SECOND RESET?
%% ---------------------------------------------------

DoubleResetToFQGC = 0;
DoubleResetToMEL = 0;
DoubleResetToAnotherReset = 0;
DoubleResetNoFollowUp = 0;

T = sortrows(T,"EventDate");

AircraftList = unique(string(T.Tail));

for a = 1:length(AircraftList)

    TailData = T(strcmp(string(T.Tail),AircraftList(a)),:);

    ResetIdx = find(TailData.RepairCategory=="SYSTEM RESET");

    if length(ResetIdx) < 2
        continue
    end

    SecondResetRow = ResetIdx(2);

    FutureEvents = TailData(SecondResetRow+1:end,:);

    if isempty(FutureEvents)
        DoubleResetNoFollowUp = DoubleResetNoFollowUp + 1;
        continue
    end

    NextEvent = FutureEvents(1,:);

    if NextEvent.RepairCategory=="FQGC REPLACEMENT"

        DoubleResetToFQGC = DoubleResetToFQGC + 1;

    elseif contains( ...
            upper(string(NextEvent.CorrectiveAction)),...
            "MEL")

        DoubleResetToMEL = DoubleResetToMEL + 1;

    elseif NextEvent.RepairCategory=="SYSTEM RESET"

        DoubleResetToAnotherReset = ...
            DoubleResetToAnotherReset + 1;

    else

        DoubleResetNoFollowUp = ...
            DoubleResetNoFollowUp + 1;

    end

end

disp(' ')
disp('AFTER SECOND RESET')
fprintf('FQGC Replacement: %d\n',DoubleResetToFQGC);
fprintf('MEL: %d\n',DoubleResetToMEL);
fprintf('Another Reset: %d\n',DoubleResetToAnotherReset);
fprintf('No Follow-Up: %d\n',DoubleResetNoFollowUp);

%% ---------------------------------------------------
%% RESET ESCALATION THRESHOLD
%% ---------------------------------------------------

ThresholdTable = table();

for ResetThreshold = 1:5

    Escalated = 0;
    Total = 0;

    for a = 1:length(AircraftList)

        TailData = T( ...
            strcmp(string(T.Tail),AircraftList(a)),:);

        NumResets = sum( ...
            TailData.RepairCategory=="SYSTEM RESET");

        HasFQGC = any( ...
            TailData.RepairCategory=="FQGC REPLACEMENT");

        if NumResets >= ResetThreshold

            Total = Total + 1;

            if HasFQGC
                Escalated = Escalated + 1;
            end

        end

    end

    ThresholdTable = [ThresholdTable;
        table(ResetThreshold,...
        Total,...
        Escalated,...
        100*Escalated/max(Total,1),...
        'VariableNames',...
        {'ResetThreshold',...
        'Aircraft',...
        'FQGCAircraft',...
        'PercentFQGC'})];

end

disp(' ')
disp('RESET ESCALATION THRESHOLD')
disp(ThresholdTable)

%% ---------------------------------------------------
%% INVESTIGATE "OTHER" LEADING TO FQGC REPLACEMENT
%% ---------------------------------------------------

FQGCEvents = T(T.RepairCategory=="FQGC REPLACEMENT",:);

OtherLeadingRows = [];

for i = 1:height(FQGCEvents)

    currentTail = string(FQGCEvents.Tail(i));
    currentDate = FQGCEvents.EventDate(i);

    PriorEvents = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate < currentDate,:);

    if ~isempty(PriorEvents)

        PriorEvents = sortrows(PriorEvents,...
            "EventDate","descend");

        if PriorEvents.DiscrepancyCategory(1) == "OTHER"

            OtherLeadingRows = ...
                [OtherLeadingRows;
                 PriorEvents(1,:)];

        end

    end

end

disp(' ')
disp('OTHER EVENTS LEADING TO FQGC REPLACEMENT')
disp(OtherLeadingRows(:, ...
    {'Tail',...
      'Description',...
      'CorrectiveAction'}))

%% ---------------------------------------------------
%% CHRONIC AIRCRAFT FINAL OUTCOME
%% ---------------------------------------------------

TopChronic = [
    "N509AE"
    "N712PS"
    "N723PS"
    "N703PS"
    ];

for i = 1:length(TopChronic)

    TailData = T( ...
        strcmp(string(T.Tail),TopChronic(i)),:);

    TailData = sortrows( ...
        TailData,...
        "EventDate");

    LastEvent = TailData(end,:);

    fprintf('\n');
    fprintf('TAIL %s\n',TopChronic(i));

    disp(LastEvent.RepairCategory)
    disp(LastEvent.DiscrepancyCategory)
    disp(LastEvent.CorrectiveAction)

end

%% ---------------------------------------------------
%% FQGC REPLACEMENT SUCCESS RATE (30 DAYS)
%% ---------------------------------------------------

SuccessCount = 0;
FailureCount = 0;

for i = 1:height(FQGCEvents)

    currentTail = string(FQGCEvents.Tail(i));
    currentDate = FQGCEvents.EventDate(i);

    FutureEvents = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate > currentDate & ...
        T.EventDate <= currentDate + days(30),:);

    if isempty(FutureEvents)

        SuccessCount = SuccessCount + 1;

    else

        FailureCount = FailureCount + 1;

    end

end

TotalEvaluated = SuccessCount + FailureCount;

fprintf('\n');
fprintf('FQGC REPLACEMENT 30-DAY EFFECTIVENESS\n');
fprintf('=====================================\n');

fprintf('No ATA28 Return: %d (%.2f%%)\n', ...
    SuccessCount,...
    100*SuccessCount/TotalEvaluated);

fprintf('ATA28 Returned: %d (%.2f%%)\n', ...
    FailureCount,...
    100*FailureCount/TotalEvaluated);

%% ---------------------------------------------------
%% POST-FQGC XFLOW RECURRENCE
%% ---------------------------------------------------

FQGCEvents = T(T.RepairCategory=="FQGC REPLACEMENT",:);

XFlowReturned = 0;
NoXFlowReturn = 0;

for i = 1:height(FQGCEvents)

    currentTail = string(FQGCEvents.Tail(i));
    currentDate = FQGCEvents.EventDate(i);

    FutureEvents = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate > currentDate & ...
        T.EventDate <= currentDate + days(30) & ...
        T.DiscrepancyCategory=="TRANSFER/XFLOW ISSUE",:);

    if isempty(FutureEvents)

        NoXFlowReturn = NoXFlowReturn + 1;

    else

        XFlowReturned = XFlowReturned + 1;

    end

end

Total = XFlowReturned + NoXFlowReturn;

fprintf('\n');
fprintf('POST-FQGC XFLOW RECURRENCE\n');
fprintf('==========================\n');

fprintf('No XFLOW Return: %d (%.2f%%)\n', ...
    NoXFlowReturn,...
    100*NoXFlowReturn/Total);

fprintf('XFLOW Returned: %d (%.2f%%)\n', ...
    XFlowReturned,...
    100*XFlowReturned/Total);

%% ---------------------------------------------------
%% B1-006805 ROOT CAUSE ANALYSIS
%% ---------------------------------------------------

Code6805 = T(contains(string(T.FaultCode),"006805"),:);

fprintf('\n');
fprintf('B1-006805 ANALYSIS\n');
fprintf('===================\n');
fprintf('Total Events: %d\n',height(Code6805));

%% Discrepancies

Code6805_Discrepancies = groupsummary( ...
    Code6805,...
    "DiscrepancyCategory");

Code6805_Discrepancies.Percent = ...
    100 * Code6805_Discrepancies.GroupCount / ...
    sum(Code6805_Discrepancies.GroupCount);

disp(' ')
disp('DISCREPANCIES WITH B1-006805')
disp(sortrows(Code6805_Discrepancies,...
    'Percent','descend'));

%% Repairs

Code6805_Repairs = groupsummary( ...
    Code6805,...
    "RepairCategory");

Code6805_Repairs.Percent = ...
    100 * Code6805_Repairs.GroupCount / ...
    sum(Code6805_Repairs.GroupCount);

disp(' ')
disp('REPAIRS WITH B1-006805')
disp(sortrows(Code6805_Repairs,...
    'Percent','descend'));

%% ---------------------------------------------------
%% WHAT HAPPENS AFTER B1-006805?
%% ---------------------------------------------------

ToReset = 0;
ToFQGC = 0;
ToMEL = 0;
ToSOV = 0;
NoFollowUp = 0;

for i = 1:height(Code6805)

    currentTail = string(Code6805.Tail(i));
    currentDate = Code6805.EventDate(i);

    FutureEvents = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate > currentDate,:);

    if isempty(FutureEvents)

        NoFollowUp = NoFollowUp + 1;
        continue

    end

    FutureEvents = sortrows(FutureEvents,"EventDate");

    NextEvent = FutureEvents(1,:);

    if NextEvent.RepairCategory=="SYSTEM RESET"

        ToReset = ToReset + 1;

    elseif NextEvent.RepairCategory=="FQGC REPLACEMENT"

        ToFQGC = ToFQGC + 1;

    elseif NextEvent.RepairCategory=="SOV REPLACEMENT"

        ToSOV = ToSOV + 1;

    elseif contains( ...
            upper(string(NextEvent.CorrectiveAction)),...
            "MEL")

        ToMEL = ToMEL + 1;

    else

        NoFollowUp = NoFollowUp + 1;

    end

end

Total = ToReset + ToFQGC + ToSOV + ...
    ToMEL + NoFollowUp;

fprintf('\n');
fprintf('POST-B1-006805 OUTCOMES\n');
fprintf('========================\n');

fprintf('Reset: %.2f%%\n', ...
    100*ToReset/Total);

fprintf('FQGC Replacement: %.2f%%\n', ...
    100*ToFQGC/Total);

fprintf('SOV Replacement: %.2f%%\n', ...
    100*ToSOV/Total);

fprintf('MEL: %.2f%%\n', ...
    100*ToMEL/Total);

fprintf('No Follow-Up: %.2f%%\n', ...
    100*NoFollowUp/Total);

%% ---------------------------------------------------
%% B1-008362 ROOT CAUSE ANALYSIS
%% ---------------------------------------------------

Code8362 = T(contains(string(T.FaultCode),"008362"),:);

fprintf('\n');
fprintf('B1-008362 ANALYSIS\n');
fprintf('===================\n');
fprintf('Total Events: %d\n',height(Code8362));

%% Discrepancies

Code8362_Discrepancies = groupsummary( ...
    Code8362,...
    "DiscrepancyCategory");

Code8362_Discrepancies.Percent = ...
    100 * Code8362_Discrepancies.GroupCount / ...
    sum(Code8362_Discrepancies.GroupCount);

disp(' ')
disp('DISCREPANCIES WITH B1-008362')
disp(sortrows(Code8362_Discrepancies,...
    'Percent','descend'));

%% Repairs

Code8362_Repairs = groupsummary( ...
    Code8362,...
    "RepairCategory");

Code8362_Repairs.Percent = ...
    100 * Code8362_Repairs.GroupCount / ...
    sum(Code8362_Repairs.GroupCount);

disp(' ')
disp('REPAIRS WITH B1-008362')
disp(sortrows(Code8362_Repairs,...
    'Percent','descend'));

%% ---------------------------------------------------
%% WHAT HAPPENS AFTER B1-008362?
%% ---------------------------------------------------

ToReset = 0;
ToFQGC = 0;
ToMEL = 0;
ToSOV = 0;
NoFollowUp = 0;

for i = 1:height(Code8362)

    currentTail = string(Code8362.Tail(i));
    currentDate = Code8362.EventDate(i);

    FutureEvents = T( ...
        strcmp(string(T.Tail),currentTail) & ...
        T.EventDate > currentDate,:);

    if isempty(FutureEvents)

        NoFollowUp = NoFollowUp + 1;
        continue

    end

    FutureEvents = sortrows(FutureEvents,"EventDate");

    NextEvent = FutureEvents(1,:);

    if NextEvent.RepairCategory=="SYSTEM RESET"

        ToReset = ToReset + 1;

    elseif NextEvent.RepairCategory=="FQGC REPLACEMENT"

        ToFQGC = ToFQGC + 1;

    elseif NextEvent.RepairCategory=="SOV REPLACEMENT"

        ToSOV = ToSOV + 1;

    elseif contains( ...
            upper(string(NextEvent.CorrectiveAction)),...
            "MEL")

        ToMEL = ToMEL + 1;

    else

        NoFollowUp = NoFollowUp + 1;

    end

end

Total = ToReset + ToFQGC + ToSOV + ...
    ToMEL + NoFollowUp;

fprintf('\n');
fprintf('POST-B1-008362 OUTCOMES\n');
fprintf('========================\n');

fprintf('Reset: %.2f%%\n', ...
    100*ToReset/Total);

fprintf('FQGC Replacement: %.2f%%\n', ...
    100*ToFQGC/Total);

fprintf('SOV Replacement: %.2f%%\n', ...
    100*ToSOV/Total);

fprintf('MEL: %.2f%%\n', ...
    100*ToMEL/Total);

fprintf('No Follow-Up: %.2f%%\n', ...
    100*NoFollowUp/Total);