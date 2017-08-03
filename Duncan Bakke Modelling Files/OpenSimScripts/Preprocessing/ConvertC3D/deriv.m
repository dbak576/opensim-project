function dxdt = deriv(x, dt)
% Compute the numerical derivative using central difference method
% with forward and backward for the end points (data points as rows)
% and different curves as columns.
% USAGE: dxdt = deriv(x, dt);
%        dt can be a scalar or column vector of length(x)-1 

[ns, nc] = size(x);

dxdt = zeros(ns, nc);

forw = x(3:ns,:); 
back = x(1:ns-2,:);

nt = length(dt);
if nt == ns-1,
    dt = dt*ones(1, nc);
    dt2 = dt(1:ns-2,:)+dt(2:ns-1,:);
elseif nt ~= 1,
    error('Input dt must be a scalar or same length as data set');
else
    dt2 = 2*dt;
end

dxdt = [(x(2,:)-x(1,:))./dt(1,:); (forw-back)./dt2; (x(ns,:)-x(ns-1,:))./dt(end,:)]; 