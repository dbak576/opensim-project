function COP = compute_COP(F, M, FPorigin, copIndices)

n = size(F,1);

% With respect to the FP origin in the model coordinate system
COP = zeros(n, 3);
COP(copIndices,:) = [M(copIndices,3)./F(copIndices,2), zeros(length(copIndices),1), -M(copIndices,1)./F(copIndices,2)];
COP = COP + ones(n,1)*FPorigin';
