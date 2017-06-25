% FLEXIBLE ROBOT ARM
% system definition with dynamic matrices generated by extra script

% System form:  dz = Az + Bu + Ed, y = theta = Cz
% State:        z = [eta,deta,q1,dq1,...,qN,dqN]'
% Inputs:       (r,d,u)
% Outputs:      (e,q,u,y)
% Disturbance:  (d)

function [P,channels] = system_def()

    % Load precalculated & auxiliary structure:
    load('dyn_param.mat')    
    if(gamm~=0) % check if empty
        N = length(gamm);
    else % no mode case
        N = 0;
    end
    n = size(Adyn,1);
    C1 = [1 0 zeros(1,2*N)];
    C2 = [zeros(N,2) kron(eye(N),[1 0])];
    load('eigfun.mat')
    phiL = phi(end,:); L = X(end);

    % State-space representation:
    A = Adyn;
    Bw = [zeros(2*(N+1),1) [0;1;zeros(2*N,1)]]; % just d
    Bu = Bdyn;
    if(gamm~=0) % check if empty
        Cz = [C1+gamm*C2;C2;zeros(1,n)]; % error+q
%         Cz = [C1+(gamm+phiL/L)*C2;C2;zeros(1,n)];
        Cy = C1+gamm*C2; % delta theta
    else % no mode case
        Cz = [C1;zeros(1,n)]; % error
        Cy = C1; % delta theta
    end
    Dzw = [[-1;zeros(N,1);0] [zeros(N+1,1);0]]; % just r
    Dzu = [zeros(N+1,1);1]; % input considered
    Dyw = [-1 0];    

    % Channel structure:
    channels = initMORC(); % init
    channels.contr = [N+3;3];
%     channels.H2 = [N+2;1];
    channels.Hinf = [3;2];               
%     channels.passive = [1;2];

    % Total system:
    P = ss(A,[Bw Bu],[Cz;Cy],[Dzw Dzu; Dyw zeros(1,1)]);

end