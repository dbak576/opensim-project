function plot_columns(qq, labels)
% labels either a cell array of strings or a single string

if ~ iscell(qq)
    qq = {qq};
end

%styles = [ '-' '.' 'x' 'o' ];
styles = [ 'r' 'g' 'b' 'k' ];
fulllegend = {};

figure;
hold on;
for i=1:length(qq)
    q = qq{i};

    if nargin < 2
        columns = 1:length(q.labels);
    else
        columns = find_columns_by_label(q.labels, labels);
    end

    time = time_data(q);

    if length(columns)
        s = styles(mod(i-1,length(styles))+1);
        if length(time)
            plot(time, q.data(:,columns),s);
            xlabel('time');
        else
            plot(q.data(:,columns),s);
        end

        if length(qq)==1
            fulllegend = q.labels(columns);
        else
            for j=1:length(columns)
                fulllegend = {fulllegend{:} sprintf('[%d] %s',i,q.labels{columns(j)})};
            end
        end
    else
        disp('No columns matching label(s)');
    end
end
legend(fulllegend,'Interpreter','none');
hold off;
