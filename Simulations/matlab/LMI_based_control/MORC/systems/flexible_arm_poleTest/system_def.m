% FLEXIBLE ROBOT ARM
% system definition with dynamic matrices generated by extra script
% with 1 mode q considered

% System form:  dz = Az + Bu + Ed, y = theta = Cz
% State:        z = [eta,deta,q1,dq1,...,qN,dqN]'
% Inputs:       (r,d,u)
% Outputs:      (e,q,u,y)
% Disturbance:  (d)

function [P,channels] = system_def(strain_ind)

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
    phiL = phi(:,end); L = X(end);
    
    % Strain gauge use:
    if(nargin<1) % no extra measurement
        Cy2 = zeros(0,2*(N+1));
        Dyw2 = zeros(0,2);
    else % extra measurement
        Cy2 = -Th/2 * [0 0 kron(D2phi(strain_ind,:),[1 0])];
        Dyw2 = zeros(1,2);
    end

    % State-space representation:
    A = Adyn;
    Bw = [zeros(2*(N+1),1) Bdyn];%[0;1;zeros(2*N,1)]]; % just d
    Bu = Bdyn;
    if(gamm~=0) % check if empty
        Cz = [C1+gamm*C2;C2;zeros(1,n)]; % error+q
%         Cz = [C1+(gamm+phiL/L)*C2;C2;zeros(1,n)]; % end-effector
        Cy = [C1+gamm*C2;Cy2]; % delta theta
    else % no mode case
        Cz = [C1;zeros(1,n)]; % error
        Cy = [C1;Cy2]; % delta theta
    end
    Dzw = [[-1;zeros(N,1);0] [zeros(N+1,1);0]]; % just r
    Dzu = [zeros(N+1,1);1]; % input considered
    Dyw = [-1 0;Dyw2];    

    % Channel structure:
    channels = initMORC(); % init
    channels.contr.out = [N+3:N+3+(size(Cy,1)-1)]; channels.contr.in = 3;
    channels.integ.meas = 1;
%     channels.Hinf.out = 1; channels.Hinf.in = 2; % d->e
%     channels.Hinf.out = 2; channels.Hinf.in = 2; % d->q
%     channels.Hinf.out = [1 2]; channels.Hinf.in = 2;
%     channels.H2.out = 3; channels.H2.in = 1; % r->u
%     channels.passive.out = 1; channels.passive.in = 2; % attention: nz=nw
%     channels.nomreg.out = 1; channels.nomreg.in = 1;

    % Total system:
    P = ss(A,[Bw Bu],[Cz;Cy],[Dzw Dzu; Dyw zeros(size(Cy,1),1)]);
    P.u = 'w';
    P.u{end} = 'u';
    P.y = 'z';
    if(nargin<1)
        P.y{end} = 'y';
    else
        P.y{end-(size(Cy,1)-1)} = 'y(1)';
        P.y{end} = 'y(2)';
    end

end