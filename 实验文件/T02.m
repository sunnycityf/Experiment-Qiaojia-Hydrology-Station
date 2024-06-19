clear
clc
warning('off', 'all');
warning('off', 'MATLAB:specificWarningID');warning('off', 'all');
warning('off', 'MATLAB:specificWarningID');
disp("程序开始运行......");
disp("---------------------------------")
Data = readmatrix("MatlabT01.xlsx");
%% M8-1校验时间戳完整性
Year = Data(:,1);
Month = Data(:,2);
Day = Data(:,3);
Hour = 0;
timeseries = datetime(Year,Month,Day,Hour,0,0);
time_gaps = diff(timeseries);
expected_interval = hours(24);
gap_indices = find(time_gaps > expected_interval);
if isempty(gap_indices)
    disp('时间序列中没有发现时间中断。');
else
    disp('中断的时间戳:');
    disp(timeseries(gap_indices));
end
%% M8-2插值处理
Data1972 = Data(6210:6575,1:4);
Data197207 = Data1972(183:213,1:4);
Data197211 = Data1972(306:335,1:4);
X197207 = Data197207(:,3);
X197211 = Data197211(:,3);
Y197207 = Data197207(:,4);
Y197211 = Data197211(:,4);
Year197207 = Data197207(:,1);
Month197207 = Data197207(:,2);
Day197207 = Data197207(:,3);
Timeseries197207 = datetime(Year197207,Month197207,Day197207,0,0,0);
Year197211 = Data197211(:,1);
Month197211 = Data197211(:,2);
Day197211 = Data197211(:,3);
Timeseries197211 = datetime(Year197211,Month197211,Day197211,0,0,0);
Flow_Rate7207 = Data197207(:,4);
Flow_Rate7211 = Data197211(:,4);
% 绘制流量图
figure(1)
plot(Timeseries197207,Flow_Rate7207,'x-','Color',[0,0,1],'LineWidth',1.5);
title('巧家站河流日流量（1972年7月）'); 
xlabel('时间'); 
ylabel('流量'); 
legend('1972.7','Location', 'northwest')
grid on
figure(2)
plot(Timeseries197211,Flow_Rate7211,'o-','Color',[1,0,0],'LineWidth',1.5);
title('巧家站河流日流量（1972年11月）'); 
xlabel('时间'); 
ylabel('流量'); 
legend('1972.11')
grid on
disp("流量图输出成功！")
% 插值
XC197207 = 1:1:31;
YC197207 = interp1(X197207,Y197207,XC197207,'spline');
XC197211 = 1:1:30;
YC197211 = interp1(X197211,Y197211,XC197211,'spline');
% 输出插值结果
YC197207 = YC197207(:,31);
YC197211 = YC197211(:,17);
disp("=============插值结果=============")
disp(['1972.07.31的流量为 ', num2str(YC197207), ' m³/s']);
disp(['1972.11.17的流量为 ', num2str(YC197211), ' m³/s']);
% 将插值结果返回给原数据
YR7207 = round(YC197207,0);
YR7211 = round(YC197211,0);
DataYR = Data;
DataYR(6422,4) = YR7207;
DataYR(6531,4) = YR7211;
DataYR1972 = Data1972;
DataYR1972(213,4) = YR7207;
DataYR1972(322,4) = YR7211;
% 插值后流量图形输出
Flow_Rate7207(31,:) = YR7207;
Flow_Rate7211(17,:) = YR7211;
figure(3)
plot(Timeseries197207,Flow_Rate7207,'x-','Color',[0,0,1],'LineWidth',1.5);
title('巧家站河流日流量（1972年7月）'); 
xlabel('时间'); 
ylabel('流量'); 
legend('1972.7','Location', 'northwest')
grid on
figure(4)
plot(Timeseries197211,Flow_Rate7211,'o-','Color',[1,0,0],'LineWidth',1.5);
title('巧家站河流日流量（1972年11月）'); 
xlabel('时间'); 
ylabel('流量'); 
legend('1972.11')
grid on
disp("----------------------")
disp("插值后的流量图输出成功！")
%% M8-3 实验内容一
Available_Year = [1940,1942:1948,1953:1955,1966:1976];
Available_Data = cell(length(Available_Year), 1);
for i = 1:length(Available_Year)
    YearCe = Available_Year(i);
    Idx = find(DataYR(:, 1) == YearCe);
    Available_Data{i} = DataYR(Idx, :);
end

Month_Ava = 1:12;
Avaliable_Month_Data = cell(length(Available_Year), 1);
for a = 1:length(Available_Year)
    CurrentData = Available_Data{a};
    StructArray = struct();
    for j = 1:length(Month_Ava)
        MonthCe = Month_Ava(j);
        Idx = find(CurrentData(:, 2) == MonthCe);
        FilteredData = CurrentData(Idx, :);
        StructArray(j).MonthData = FilteredData;
    end
    Avaliable_Month_Data{a} = StructArray;
end

for b = 1:length(Avaliable_Month_Data)
    for c = 1:length(Month_Ava)
        MonthData = Avaliable_Month_Data{b}(c).MonthData;
        MonthData(:, 4) = MonthData(:, 4) * 60 * 60 * 24;
        Avaliable_Month_Data{b}(c).MonthData = MonthData;
    end
end

Sum_Month = cell(length(Available_Year), 1);
for c = 1:length(Avaliable_Month_Data)
    StructArray = struct();
    for e = 1:length(Month_Ava)
        MonthData = Avaliable_Month_Data{c}(e).MonthData;
        SummedValue = sum(MonthData(:, 4));
        StructArray(e).SummedValue = SummedValue;
    end
    Sum_Month{c} = reshape([StructArray.SummedValue], [], 1);
end

Sum_Year = zeros(length(Sum_Month), 1);
for f = 1:length(Sum_Month)
    Sum_Year(f) = sum(Sum_Month{f});
end

Sum_Year = Sum_Year ./ 100000000;
for h = 1:length(Available_Year)
    for month = 1:12
        Sum_Month{h}(month) = Sum_Month{h}(month) / 100000000;
    end
end

disp("============年径流量数据============")
for g = 1:length(Available_Year)
    disp([num2str(Available_Year(g)), '年的流量为: ', num2str(Sum_Year(g)), ' 亿m³']);
end
disp("============月径流量数据============")
for g = 1:length(Available_Year)
    for month = 1:12
        disp([num2str(Available_Year(g)), '年', num2str(month), '月的径流量为: ', num2str(Sum_Month{g}(month)), ' 亿m³']);
    end
end

Year_New = 1940:1976;
Year_New = Year_New';
Year_New(1,2) = Sum_Year(1,:);
Year_New(3:9,2) = Sum_Year(2:8,:);
Year_New(14:16,2) = Sum_Year(9:11,:);
Year_New(27:37,2) = Sum_Year(12:22,:);
Sum_Year_New = Year_New(:,2);
Sum_Year_New(Sum_Year_New == 0) = NaN;
% 绘制年径流量图
figure(5)
plot(1940:1976,Sum_Year_New,'o-','Color',[0,0,0],'LineWidth',1.5,'MarkerFaceColor',[0,0,1]);
title('巧家站河流年径流量'); 
xlabel('时间（年）'); 
ylabel('径流量（亿m³）'); 
legend('径流量')
grid on
disp("----------------------")
disp("全年径流量图输出成功！")
% 绘制月径流图
for k = 1:22
    figure(5+k); 
        Monthly = Sum_Month{k};
        plot(Monthly, 'o-','Color',[0,0,0],'LineWidth',1.5,'MarkerFaceColor',[0,0,1]);
    xlabel('月份');
    ylabel('流量 (亿m³)');
    title([ num2str(Available_Year(k)), ' 年的月径流量']);
end
disp("全月径流量图输出成功！")

All_Monthly_Flows = cell(length(Available_Year), 12);
for l = 1:length(Available_Year)
    for month = 1:12
        All_Monthly_Flows{l, month} = Sum_Month{l}(month);
    end
end
Monthly_Flows = cell2mat(All_Monthly_Flows);
Ave = zeros(12, 1);

% 绘制月平均径流量图
for m = 1:12
    Ave(m) = mean(Monthly_Flows(:, m));
end
figure(28)
plot(1:12,Ave,'o-','Color',[0,0,0],'LineWidth',1.5,'MarkerFaceColor',[0,0,1]);
title('巧家站河流月平均径流量'); 
xlabel('时间（月）'); 
ylabel('径流量（亿m³）'); 
legend('径流量','Location', 'northwest')
grid on
disp("月平均径流量图输出成功！")

% 单提取1972年的月径流量数据
Month1972 = Sum_Month{17};
disp("========1972年月径流量数据=========")
for n = 1:12
        disp([ '1972年', num2str(n), '月的径流量为: ', num2str(Month1972(n)), ' 亿m³']);
end

% 径流模数
Year_Flow_Sum = zeros(length(Sum_Month), 1);
for o = 1:22
    YearQ = Available_Data{o}(:,4);
    Year_Flow_Sum(o) = sum(YearQ);
end
Year_New(1,4) = Year_Flow_Sum(1,:);
Year_New(3:9,4) = Year_Flow_Sum(2:8,:);
Year_New(14:16,4) = Year_Flow_Sum(9:11,:);
Year_New(27:37,4) = Year_Flow_Sum(12:22,:);
M_Year = Year_New(:,4);
M_Year(M_Year == 0) = NaN;

M1940 = Year_New(1,4) ./ 366;
M1944 = Year_New(5,4) ./ 366;
M1948 = Year_New(9,4) ./ 366;
M1968 = Year_New(29,4) ./ 366;
M1972 = Year_New(33,4) ./ 366;
M1976 = Year_New(37,4) ./ 366;
MYear = M_Year ./ 365;
MYear(1,1) = M1940;
MYear(5,1) = M1944;
MYear(9,1) = M1948;
MYear(29,1) = M1968;
MYear(33,1) = M1972;
MYear(37,1) = M1976;

F = 450696;
M = MYear ./ F;
M(isnan(M)) = [];

disp("=============径流模数=============")
for p = 1:length(Available_Year)
    disp([num2str(Available_Year(p)), '年的径流模数为: ', num2str(M(p)), ' m³⁄s·km²']);
end

Year_New(1,5) = M(1,:);
Year_New(3:9,5) = M(2:8,:);
Year_New(14:16,5) = M(9:11,:);
Year_New(27:37,5) = M(12:22,:);
MY = Year_New(:,5);
MY(MY == 0) = NaN;

figure(30)
plot(1940:1976,MY,'o-','Color',[0,0,0],'LineWidth',1.5,'MarkerFaceColor',[0,0,1]);
title('巧家站河流年径流模数'); 
xlabel('时间（年）'); 
ylabel('径流模数（m³⁄s·km²）'); 
legend('径流模数')
grid on
disp("----------------------")
disp("年径径流模数图输出成功！")


% 径流深度
W = Sum_Year * 100000000;
R = W ./ (1000 * F);
disp("=============径流深度=============")
for q = 1:length(Available_Year)
    disp([num2str(Available_Year(q)), '年的径流深度为: ', num2str(R(q)), ' mm']);
end
Year_New(1,3) = R(1,:);
Year_New(3:9,3) = R(2:8,:);
Year_New(14:16,3) = R(9:11,:);
Year_New(27:37,3) = R(12:22,:);
R_AllYear = Year_New(:,3);
R_AllYear(R_AllYear == 0) = NaN;
figure(29)
plot(1940:1976,R_AllYear,'o-','Color',[0,0,0],'LineWidth',1.5,'MarkerFaceColor',[0,0,1]);
title('巧家站河流年径流深度'); 
xlabel('时间（年）'); 
ylabel('径流深度（mm）'); 
legend('径流深度')
grid on
disp("----------------------")
disp("年径流深度图输出成功！")

% 不均匀系数
Ki = cell(length(Available_Year),1);
for r = 1:22
    MKi = Sum_Month{r};
    YKi = Sum_Year(r,:);
    Ki{r} = MKi ./ YKi;
end

KM = 0.0833;

Sum_KiM = zeros(length(Available_Year),1);
for r =1:22
    KCI = Ki{r};
    KiM = (KCI ./KM - 1) .^ 2;
    Sum_KiM(r) = sum(KiM);
end
SR = Sum_KiM ./ 12;
CVY = SR .^ 0.5;

disp("============不均匀系数=============")
for p = 1:length(Available_Year)
    disp([num2str(Available_Year(p)), '年的不均匀系数为: ', num2str(CVY(p))]);
end

Year_New(1,6) = CVY(1,:);
Year_New(3:9,6) = CVY(2:8,:);
Year_New(14:16,6) = CVY(9:11,:);
Year_New(27:37,6) = CVY(12:22,:);
CVYA = Year_New(:,5);
CVYA(CVYA == 0) = NaN;

figure(31)
plot(1940:1976,CVYA,'o-','Color',[0,0,0],'LineWidth',1.5,'MarkerFaceColor',[0,0,1]);
title('巧家站河流年不均匀系数'); 
xlabel('时间（年）'); 
ylabel('不均匀系数'); 
legend('不均匀系数')
grid on
disp("----------------------")
disp("不均匀系数图输出成功！")

DataMonthly = readmatrix("MatlabT02.xlsx");
YearMonthly = DataMonthly(133:264,1);
MonthMonthly = DataMonthly(133:264,2);
TimeseriesMonthly = datetime(YearMonthly,MonthMonthly,0,0,0,0);
MonthlyFlow = DataMonthly(133:264,3);
figure(32)
plot(TimeseriesMonthly,MonthlyFlow,'o-','Color',[0,0,0],'LineWidth',1.5,'MarkerFaceColor',[0,0,1]);
title('巧家站河流月均径流量'); 
xlabel('时间'); 
ylabel('径流量（m³）'); 
legend('径流量')
grid on
disp("----------------------")
disp("月均径流量图输出成功！")

% 极值比
MaxYear = max(Sum_Year);
MinYear = min(Sum_Year);
Extremal_Ratio = MaxYear ./ MinYear;
disp("==============极值比==============")
disp(['极值比: ', num2str(Extremal_Ratio)]);

% 离差系数
MeanYear = mean(Sum_Year);
Ki_Year = Sum_Year ./ MeanYear;
Ki_Square = (Ki_Year - 1) .^ 2;
Ki_Square_Sum = sum(Ki_Square);
Ki_E = Ki_Square_Sum ./ 21;
Ki_Last = Ki_E .^ 0.5;
disp("=============离差系数=============")
disp(['离差系数: ', num2str(Ki_Last)]);

%% M8-4：实验内容3
Ki_Sub = (Ki_Year - 1);
% 经验频率
ExperienceF = 1:22;
E = 22;
Experience = ExperienceF ./ (E+1);
Experience = Experience' .* 100;
disp("=============经验频率1=============")
for u = 1:22
    disp([num2str(Experience(u))]);
end

% 适线流量
Data_Curve = readmatrix("MatlabT04.xlsx");
Cv2 = Data_Curve(:,1);
Cv3 = Data_Curve(:,2);
Cv35 = Data_Curve(:,3);
Qi2 = MeanYear .* Cv2;
Qi3 = MeanYear .* Cv3;
Qi35 = MeanYear .* Cv35;
disp("=============适线流量=============")
disp("-------K=2-------")
disp([num2str(Qi2)])
disp("-------K=3-------")
disp([num2str(Qi3)])
disp("------K=3.5------")
disp([num2str(Qi35)])


% 处理最大流量
DataMax_Flow = readmatrix("MatlabT05.xlsx");
YearMaxFlow = DataMax_Flow(:,1);
Max_Flow = DataMax_Flow(:,2);
MaxDirFlow = Max_Flow * 60 *60 * 24  / 100000000; % 径流量
Mean_MaxDirFlow = mean(MaxDirFlow); % 平均径流量
KMAXFlow = MaxDirFlow ./ Mean_MaxDirFlow; % 模比系数
KMAXFlowSub = KMAXFlow - 1; % ki-1
KMAXFlowSquare = KMAXFlowSub .^ 2; % (ki-1)^2
KMAXFlowSum = sum(KMAXFlowSquare);
YearLength = length(Max_Flow);
KMAXFlowE = KMAXFlowSum ./ (YearLength - 1);
KMAXFlowLast = KMAXFlowE .^ 0.5; % 离差系数
disp("===========最大流量处理===========")
disp("-------径流量-------")
for z = 1:length(MaxDirFlow)
    disp([num2str(YearMaxFlow(z)),'年的洪峰径流量为: ', num2str(MaxDirFlow(z)),'亿m³']);
end
MaxMax = max(MaxDirFlow);
MinMax = min(MaxDirFlow);
disp("------统计信息------")
disp(['平均洪峰径流量为: ',num2str(Mean_MaxDirFlow),'亿m³'])
disp(['最大洪峰径流量为: ',num2str(MaxMax),'亿m³'])
disp(['最小洪峰径流量为: ',num2str(MinMax),'亿m³'])

disp("------离差系数------")
disp(['洪峰径流离差系数: ',num2str(KMAXFlowLast)])

% 经验频率
ExperienceFM = 1:25;
EM = 25;
ExperienceM = ExperienceFM ./ (EM+1);
ExperienceM = ExperienceM' .* 100;
disp("=============经验频率2=============")
for y = 1:25
    disp([num2str(ExperienceM(y))]);
end

% 适线处理
Data_CurveM = readmatrix("MatlabT06.xlsx");
Cv2M = Data_CurveM(:,1);
Cv3M = Data_CurveM(:,2);
Cv35M = Data_CurveM(:,3);
Qi2M = Mean_MaxDirFlow .* Cv2M;
Qi3M = Mean_MaxDirFlow .* Cv3M;
Qi35M = Mean_MaxDirFlow .* Cv35M;
disp("=============适线流量2=============")
disp("-------K=2-------")
disp([num2str(Qi2M)])
disp("-------K=3-------")
disp([num2str(Qi3M)])
disp("------K=3.5------")
disp([num2str(Qi35M)])

%% 结果通知
Date_End = datetime("now");
disp("---------------------------------")
disp('程序运行时间:')
disp(Date_End)
disp("程序运行成功！")