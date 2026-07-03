%% IMPORT DATA

clear;
clc;
close all;

[file,path] = uigetfile({'*.xlsx'},...
    'Select ATA28_Cleaned.xlsx');

filename = fullfile(path,file);

T = readtable(filename);

disp('Data Imported Successfully')
%% TOP DISCREPANCIES

DiscSummary = groupsummary(...
    T,...
    "DiscrepancyCategory");

DiscSummary = sortrows(...
    DiscSummary,...
    "GroupCount","descend");

disp(' ')
disp('TOP DISCREPANCIES')
disp(DiscSummary)

figure
barh(DiscSummary.GroupCount)

yticklabels(DiscSummary.DiscrepancyCategory)

title('Top ATA28 Discrepancies')

xlabel('Occurrences')

grid on
%% TOP REPAIRS

RepairSummary = groupsummary(...
    T,...
    "RepairCategory");

RepairSummary = sortrows(...
    RepairSummary,...
    "GroupCount","descend");

disp(' ')
disp('TOP REPAIRS')
disp(RepairSummary)

figure
barh(RepairSummary.GroupCount)

yticklabels(RepairSummary.RepairCategory)

title('Top ATA28 Repairs')

xlabel('Occurrences')

grid on
%% RECURRING COMPONENT ANALYSIS

keywords = [
    "FQGC"
    "SENSOR"
    "HIGH LEVEL"
    "O-RING"
    "SEAL"
    "REFUEL PANEL"
    "XFLOW"
    "SOV"
    "PROBE"
    ];

count = zeros(length(keywords),1);

allText = upper( ...
    string(T.Description) + " " + ...
    string(T.CorrectiveAction));

for i = 1:length(keywords)

    count(i) = sum( ...
        contains(allText,...
        keywords(i)));

end

ComponentSummary = table(...
    keywords,...
    count,...
    'VariableNames',...
    {'Component','Occurrences'});

ComponentSummary = sortrows(...
    ComponentSummary,...
    'Occurrences',...
    'descend');

disp(' ')
disp('RECURRING COMPONENTS')
disp(ComponentSummary)

figure

bar(ComponentSummary.Occurrences)

xticklabels(ComponentSummary.Component)

xtickangle(45)

ylabel('Occurrences')

title('Recurring Components')

grid on
%% PROBABLE ROOT CAUSE MATRIX

RootCause = groupsummary( ...
    T,...
    ["DiscrepancyCategory","RepairCategory"]);

RootCause = sortrows(...
    RootCause,...
    "GroupCount","descend");

disp(' ')
disp('TOP ROOT CAUSE COMBINATIONS')

disp(RootCause(1:min(20,height(RootCause)),:))
%% RELIABILITY TRENDS

if ismember('ReportedDate', ...
        T.Properties.VariableNames)

    T.Month = dateshift( ...
        datetime(T.ReportedDate), ...
        'start','month');

    TrendData = groupsummary( ...
        T,...
        "Month");

    figure

    plot(TrendData.Month,...
        TrendData.GroupCount,...
        '-o',...
        'LineWidth',2)

    title('ATA28 Reliability Trend')

    ylabel('Events')

    xlabel('Month')

    grid on

end
%% CHRONIC AIRCRAFT

if ismember('TailNumber',...
        T.Properties.VariableNames)

    TailSummary = groupsummary( ...
        T,...
        "TailNumber");

    TailSummary = sortrows( ...
        TailSummary,...
        "GroupCount","descend");

    disp(' ')
    disp('CHRONIC AIRCRAFT')

    disp(TailSummary( ...
        1:min(20,height(TailSummary)),:))

    figure

    TopTail = TailSummary( ...
        1:min(15,height(TailSummary)),:);

    bar(TopTail.GroupCount)

    xticklabels(TopTail.TailNumber)

    xtickangle(45)

    title('Aircraft With Most ATA28 Events')

    ylabel('Occurrences')

    grid on

end
%% CRJ700 VS CRJ900

FleetSummary = groupsummary( ...
    T,...
    ["FleetGroup","DiscrepancyCategory"]);

FleetPivot = unstack( ...
    FleetSummary,...
    "GroupCount",...
    "FleetGroup");

figure

bar(categorical( ...
    FleetPivot.DiscrepancyCategory),...
    [FleetPivot.CRJ700 FleetPivot.CRJ900])

legend('CRJ700','CRJ900')

title('Fleet Reliability Comparison')

ylabel('Occurrences')

xtickangle(45)

grid on
%% ENGINEERING RECOMMENDATIONS

disp(' ')
disp('================================')
disp('ENGINEERING RECOMMENDATIONS')
disp('================================')

topIssue = string(DiscSummary.DiscrepancyCategory(1));

fprintf('\nPriority #1\n')
fprintf('Investigate %s\n',topIssue)

disp(' ')
disp('Priority #2')
disp('Review recurring fuel leak causes')

disp(' ')
disp('Priority #3')
disp('Analyze FQGC related failures')

disp(' ')
disp('Priority #4')
disp('Review sensor and high level sensor reliability')

disp(' ')
disp('Priority #5')
disp('Investigate chronic aircraft trends')