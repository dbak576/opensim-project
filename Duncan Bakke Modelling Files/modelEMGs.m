function lowEMG = modelEMGs(model)
%modelEMGs: run processEMGs for all trials in model
for j = 1:10
    if strcmp(model,'H25s1')
        if j < 9
            lowEMG{j} = processEMGs(model,strcat('Walk',num2str(j)));
        end
    elseif strcmp(model,'H26s1')
        if j < 10
            lowEMG{j} = processEMGs(model,strcat('Walk',num2str(j)));
        end
    else
        lowEMG{j} = processEMGs(model,strcat('Walk',num2str(j)));
    end 
end
err =0;
end

