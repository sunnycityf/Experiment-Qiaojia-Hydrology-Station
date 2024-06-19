disp("程序开始运行......");
disp("-------------------")
Data = readmatrix("Matlab.xlsx");
%% M8-1提取时间戳
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
    disp('发现以下位置存在时间中断:');
    disp(gap_indices);
    disp('中断的时间戳:');
    disp(timeseries(gap_indices));
end
%% M8-2插值处理
Data1972 = Data(6210:6576,1:4);


%%
disp("-------------------")
disp("程序运行成功！")
