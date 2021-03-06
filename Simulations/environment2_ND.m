normVec = @(a) sqrt(sum(a.^2,2)); % Nx1 norm of a Nx2 vector
%% path 2
id = 'environment 2';
ts = 0.5;
dt = 0.05;
v=0:dt:1;
v=[v ones(size(v))];
N=length(v);
phi=0:dt:pi;
dt=0.1;
x=zeros(N,2);
for k=2:N,
   U=[v(k-1)*cos(phi(k-1)),v(k-1)*sin(phi(k-1))]; 
   x(k,:)=x(k-1,:)+U;
end
L = length(x);
dx = diff(x); dx = [dx(1,:); dx];
v = normVec(dx)/ts; 
theta = atan2(dx(:,2),dx(:,1));

accuracy_x = [1, 1];

% Landmarks
S =     [6 2;
         8 15;
         12 20];
NS = size(S,1); % number of landmarks

%% Define noise and measurement

% angle distance (data to be measured)
v_measure = v + sqrt(sigma_v)*randn(size(v));

% theta_measure = theta + 2*(rand(size(theta))-0.5)*sigma_theta;
theta_measure = theta + sqrt(sigma_theta)*randn(size(theta));

v_dist = abs(bsxfun(@minus,x(:,1) + 1i*x(:,2),S(:,1)' + 1i*S(:,2)'));
measureFunc = @(x,y,s) sqrt((x-s(1)).^2 + (y-s(2)).^2);
%measureFunc = @(x,s) sqrt((x(1)-s(1)).^2 + (x(2)-s(2)).^2);
measure = v_dist + sqrt(sigma)*randn(size(v_dist)); % Measured distance
h = @(x,k) [measureFunc(x(1),x(2),S(1,:));measureFunc(x(1),x(2),S(2,:));measureFunc(x(1),x(2),S(3,:))];
% Define array with all measurement error functions
pe = cell(NS+2,1);
for m = 1:NS
        pe{m} = @(x,y,k) normpdf(measureFunc(x,y,S(m,:)),measure(k,m),sqrt(sigma));
end
pe{end-1} = @(v,k) normpdf(v,v_measure(k),sqrt(sigma_v));
pe{end} = @(theta,k) normpdf(theta,theta_measure(k),sqrt(sigma_theta));
%% State Function inputs (measures y2 and y3)
U = cell(N,1);
for k = 1:N
    U{k} = [Interval(v_measure(k)).inflate(sqrt(sigma_v)),Interval(theta_measure(k)).inflate(sqrt(sigma_theta))];
end
stateInput = [[v_measure(1); diff(v_measure)],[theta_measure(1); diff(theta_measure)]];