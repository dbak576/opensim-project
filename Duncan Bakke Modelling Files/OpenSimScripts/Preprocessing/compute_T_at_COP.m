function T = compute_T_at_COP(COP, F, M, FPorigin)

n = size(F,1);

T = M - cross((COP - ones(n,1)*FPorigin'), F);
