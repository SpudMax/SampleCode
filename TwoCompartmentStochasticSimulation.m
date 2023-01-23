% Stochastic simulation for a two compartment system.
% S0A + EA <-> S0EA -> S1A + EA
% S0B + EB <-> S0EB -> S1B + EB
% S1A + EA <-> S1EA -> S2A + EA
% S1B + EB <-> S1EB -> S2B + EB
% S2A + PA <-> S2PA -> S1A + PA
% S2B + PB <-> S2PB -> S1B + PB
% S1A + PA <-> S1PA -> S0A + PA
% S1B + PB <-> S1PB -> S0B + PB
% CA <-> CB 


%-------------------------------
% PROVIDE RNG SEED
%-------------------------------

rng('shuffle')

%-------------------------------
% SPECIFY PARAMETERS
%-------------------------------
initialS0A = 50;
initialS0B = 50;
initialS1A = 0;
initialS1B = 0;
initialS2A = 50;
initialS2B = 50;
initialEA = 25;
initialEB = 25;
initialPA = 25;
initialPB = 25;
initialS0EA = 0;
initialS0EB = 0;
initialS1EA = 0;
initialS1EB = 0;
initialS1PA = 0;
initialS1PB = 0;
initialS2PA = 0;
initialS2PB = 0;



nTraj = 1000; % Number of tragectories 
tMax = 10000; % Maximum time for the simulation
deltaTime = 0.1; % timestep for data collection
timeArray = 0:deltaTime:tMax; % array of time steps to be iterated over 
nTime = floor(tMax/deltaTime)+1; %number of time steps in the simulation

%-------------------------------
% DEFINE VOLUME PARAMETERS
%-------------------------------

vA = 0.32; %\mu m^3
vB = 10; %\mu m^3

%-------------------------------
% DEFINE RATE PARAMETERS
%-------------------------------
 
% % Need two versions of k1 and k4 to account for the cases where vA DNE vB
%(These are second order which is why they're scaled by volume)
k1A = 0.045/vA; %%\mu m^3/s 
k1B = 0.045/vB; %%\mu m^3/s
k2 = 1.35;  %% s^-1
k3 = 1.5;   %% s^-1
k4A = 0.093/vA; %% \mu m^3/s
k4B = 0.093/vB; %% \mu m^3/s
k5 = 1.73;  %% s^-1
k6 = 15;    %% s^-1
kAS0B = 100.00;
kAS1B = 100.00;
kAS2B = 100.00;
kAEB = 100.00;
kAPB = 100.00; 
kAS0EB = 100.00;
kAS1EB = 100.00;
kAS1PB = 100.00;
kAS2PB = 100.00;
kBS0A = 100.00;
kBS1A = 100.00;
kBS2A = 100.00;
kBEA = 100.00;
kBPA = 100.00;
kBS0EA = 100.00;
kBS1EA = 100.00;
kBS1PA = 100.00;
kBS2PA = 100.00;

%-------------------------------
% ARRAYS FOR STORAGE
%-------------------------------

nS0AStore = zeros(nTraj,nTime); 
nS0BStore = zeros(nTraj,nTime); 
nS1AStore = zeros(nTraj,nTime);
nS1BStore = zeros(nTraj,nTime);
nS2AStore = zeros(nTraj,nTime);
nS2BStore = zeros(nTraj,nTime);
nEAStore = zeros(nTraj,nTime);
nEBStore = zeros(nTraj,nTime);
nPAStore = zeros(nTraj,nTime);
nPBStore = zeros(nTraj,nTime);
nS0EAStore = zeros(nTraj, nTime);
nS0EBStore = zeros(nTraj, nTime);
nS1EAStore = zeros(nTraj, nTime);
nS1EBStore = zeros(nTraj, nTime);
nS1PAStore = zeros(nTraj, nTime);
nS1PBStore = zeros(nTraj, nTime);
nS2PAStore = zeros(nTraj, nTime);
nS2PBStore = zeros(nTraj, nTime);


%-------------------------------
% ENTERING INTO STOCHASTIC SIM
%-------------------------------

for indexTraj = 1:nTraj
    
    time = 0; %%Initializing time
    nS0A = initialS0A; 
    nS0B = initialS0B; 
    nS1A = initialS1A; 
    nS1B = initialS1B;
    nS2A = initialS2A;
    nS2B = initialS2B;
    nEA = initialEA;
    nEB = initialEB;
    nPA = initialPA;
    nPB = initialPB;
    nS0EA = initialS0EA;
    nS0EB = initialS0EB;
    nS1EA = initialS1EA;
    nS1EB = initialS1EB;
    nS1PA = initialS1PA;
    nS1PB = initialS1PB;
    nS2PA = initialS2PA;
    nS2PB = initialS2PB;
    
    nS0AStore(indexTraj,1) = nS0A;
    nS0BStore(indexTraj,1) = nS0B;
    nS1AStore(indexTraj,1) = nS1A;
    nS1BStore(indexTraj,1) = nS1B;
    nS2AStore(indexTraj,1) = nS2A; 
    nS2BStore(indexTraj,1) = nS2B;
    nEAStore(indexTraj,1) = nEA;
    nEBStore(indexTraj,1) = nEB;
    nPAStore(indexTraj,1) = nPA;
    nPBStore(indexTraj,1) = nPB;
    nS0EAStore(indexTraj,1) = nS0EA;
    nS0EBStore(indexTraj,1) = nS0EB;
    nS1EAStore(indexTraj,1) = nS1EA;
    nS1EBStore(indexTraj,1) = nS1EB;
    nS1PAStore(indexTraj,1) = nS1PA;
    nS1PBStore(indexTraj,1) = nS1PB;
    nS2PAStore(indexTraj,1) = nS2PA;
    nS2PBStore(indexTraj,1) = nS2PB;
    
    
    intTime = deltaTime;
    indexTime = 2;
    
    while time < tMax
        
        a1 = k1A*nS0A*nEA; 
        a2 = k1B*nS0B*nEB; 
        a3 = k2*nS0EA;
        a4 = k2*nS0EB;
        a5 = k6*nS1PA;
        a6 = k6*nS1PB;
        a7 = k3*nS0EA; 
        a8 = k3*nS0EB;
        a9 = k4A*nS1A*nEA; 
        a10 = k4B*nS1B*nEB;
        a11 = k5*nS1EA; 
        a12 = k5*nS1EB;
        a13 = k3*nS2PA; 
        a14 = k3*nS2PB;
        a15 = k4A*nS1A*nPA;
        a16 = k4B*nS1B*nPB;
        a17 = k5*nS1PA;
        a18 = k5*nS1PB;
        a19 = k1A*nS2A*nPA; 
        a20 = k1B*nS2B*nPB;
        a21 = k2*nS2PA; 
        a22 = k2*nS2PB;
        a23 = k6*nS1EA; 
        a24 = k6*nS1EB; 
        a25 = kBS0A*nS0A;
        a26 = kAS0B*nS0B;
        a27 = kBS1A*nS1A;
        a28 = kAS1B*nS1B;
        a29 = kBS2A*nS2A;
        a30 = kAS2B*nS2B;
        a31 = kBEA*nEA;
        a32 = kAEB*nEB;
        a33 = kBPA*nPA;
        a34 = kAPB*nPB;
        a35 = kBS0EA*nS0EA;
        a36 = kAS0EB*nS0EB;
        a37 = kBS1EA*nS1EA;
        a38 = kAS1EB*nS1EB;
        a39 = kBS1PA*nS1PA;
        a40 = kAS1PB*nS1PB;
        a41 = kBS2PA*nS2PA;
        a42 = kAS2PB*nS2PB;
        
        aTot = a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11 + ...
            a12 + a13 + a14 + a15 + a16 + a17 + a18 + a19 + a20 + a21 + ...
            a22 + a23 + a24 + a25 + a26 + a27 + a28 + a29 + a30 + a31 + ...
            a32 + a33 + a34 + a35 + a36 + a37 + a38 + a39 + a40 + a41 + ...
            a42;

        r1 = rand();
        r2 = rand();
        
        tau = -log(r1)/aTot; 
        time = time + tau;
        
        if time > intTime
            while indexTime <= ceil(time/deltaTime) && indexTime <= nTime 
                    nS0AStore(indexTraj,indexTime) = nS0A;
                    nS0BStore(indexTraj,indexTime) = nS0B;
                    nS1AStore(indexTraj,indexTime) = nS1A;
                    nS1BStore(indexTraj,indexTime) = nS1B;
                    nS2AStore(indexTraj,indexTime) = nS2A;
                    nS2BStore(indexTraj,indexTime) = nS2B;
                    nEAStore(indexTraj,indexTime) = nEA;
                    nEBStore(indexTraj,indexTime) = nEB;
                    nPAStore(indexTraj,indexTime) = nPA;
                    nPBStore(indexTraj,indexTime) = nPB;
                    nS0EAStore(indexTraj,indexTime) = nS0EA;
                    nS0EBStore(indexTraj,indexTime) = nS0EB;
                    nS1EAStore(indexTraj,indexTime) = nS1EA;
                    nS1EBStore(indexTraj,indexTime) = nS1EB;
                    nS1PAStore(indexTraj,indexTime) = nS1PA;
                    nS1PBStore(indexTraj,indexTime) = nS1PB;
                    nS2PAStore(indexTraj,indexTime) = nS2PA;
                    nS2PBStore(indexTraj,indexTime) = nS2PB;
                intTime = intTime + deltaTime;
                indexTime = indexTime + 1;
            end
        end

        %---------------------------------------------------------------
        % UPDATING PARTICLE NUMBER BASED ON PROPENSITY AND RANDOM NUMBER
        %---------------------------------------------------------------

        if r2 < a25/aTot %a25 = kB*nS0A
            nS0A = nS0A - 1;
            nS0B = nS0B + 1;
        elseif r2 < (a25+a26)/aTot %a26 = kA*nS0B
            nS0A = nS0A + 1;
            nS0B = nS0B - 1;
        elseif r2 < (a25+a26+a1)/aTot %a1 = k1*nS0A*nEA;
            nS0A = nS0A - 1;
            nEA = nEA - 1;
            nS0EA = nS0EA + 1;
        elseif r2 < (a25+a26+a1+a3)/aTot  % a3 = k2*nS0EA;
            nS0A = nS0A + 1;
            nEA = nEA + 1;
            nS0EA = nS0EA - 1;    
        elseif r2 < (a25+a26+a1+a3+a5)/aTot %a5 = k6*nS1PA;
            nS1PA = nS1PA - 1;
            nS0A = nS0A + 1;
            nPA = nPA +1;
        elseif r2 < (a25+a26+a1+a3+a5+a2)/aTot %a2 = k1*nS0B*nEB;    
            nS0B = nS0B - 1;
            nEB = nEB - 1;
            nS0EB = nS0EB + 1;
         elseif r2 < (a25+a26+a1+a3+a5+a2+a4)/aTot  % a4 = k2*nS0EB;
            nS0B = nS0B + 1;
            nEB = nEB + 1;
            nS0EB = nS0EB - 1;    
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6)/aTot %a6 = k6*nS1PB;
            nS1PB = nS1PB - 1;
            nS0B = nS0B + 1;
            nPB = nPB +1;   
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27)/aTot  %a27 = kB*nS1A;
            nS1A = nS1A - 1;
            nS1B = nS1B + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28)/aTot  %a28 = kA*nS1B;
            nS1B = nS1B - 1;
            nS1A = nS1A + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7)/aTot  %a7 = k3*nS0EA;
            nS0EA = nS0EA - 1;
            nS1A = nS1A + 1;
            nEA = nEA + 1;   
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9)/aTot %a9 = k4*nS1A*nEA;
            nS1A = nS1A - 1;
            nEA = nEA - 1;
            nS1EA = nS1EA + 1;   
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11)/aTot %a11 = k5*nS1EA;
            nS1EA = nS1EA - 1;
            nS1A = nS1A + 1;
            nEA = nEA + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13)/aTot %a13 = k3*nS2PA;
            nS2PA = nS2PA - 1;
            nS1A = nS1A + 1;
            nPA = nPA + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15)/aTot  %a15 = k4*nS1A*nPA;
            nS1A = nS1A - 1;
            nPA = nPA - 1;
            nS1PA = nS1PA + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17)/aTot %a17 = k5*nS1PA;
            nS1PA = nS1PA - 1;
            nS1A = nS1A + 1;
            nPA = nPA +1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+a8)/aTot  %a8 = k3*nS0EB;
            nS0EB = nS0EB - 1;
            nS1B = nS1B + 1;
            nEB = nEB + 1;    
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                a8+a10)/aTot %a10 = k4*nS1B*nEB;
            nS1B = nS1B - 1;
            nEB = nEB - 1;
            nS1EB = nS1EB + 1;
         elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12)/aTot %a12 = k5*nS1EB;
            nS1EB = nS1EB - 1;
            nS1B = nS1B + 1;
            nEB = nEB + 1;
         elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14)/aTot %a14 = k3*nS2PB;
            nS2PB = nS2PB - 1;
            nS1B = nS1B + 1;
            nPB = nPB + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                a8+a10+a12+a14+a16)/aTot  %a16 = k4*nS1B*nPB;
            nS1B = nS1B - 1;
            nPB = nPB - 1;
            nS1PB = nS1PB + 1;  
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                a8+a10+a12+a14+a16+a18)/aTot %a18 = k5*nS1PB;
            nS1PB = nS1PB - 1;
            nS1B = nS1B + 1;
            nPB = nPB +1;
         elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29)/aTot %a29 = kB*nS2A;
            nS2A = nS2A - 1;
            nS2B = nS2B + 1;
          elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30)/aTot %a30 = kA*nS2B;
            nS2A = nS2A + 1;
            nS2B = nS2B - 1;   
      
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19)/aTot  %a19 = k1*nS2A*nPA; 
            nS2A = nS2A - 1;
            nPA = nPA - 1;
            nS2PA = nS2PA + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21)/aTot %a21 = k2*nS2PA; 
            nS2PA = nS2PA - 1;
            nS2A = nS2A + 1;
            nPA = nPA + 1;
        elseif  r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23)/aTot %a23 = k6*nS1EA;
            nS1EA = nS1EA - 1; 
            nS2A = nS2A + 1;
            nEA = nEA + 1; 
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20)/aTot  %a20 = k1*nS2B*nPB; 
            nS2B = nS2B - 1;
            nPB = nPB - 1;
            nS2PB = nS2PB + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22)/aTot %a22 = k2*nS2PB; 
            nS2PB = nS2PB - 1;
            nS2B = nS2B + 1;
            nPB = nPB + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24)/aTot %a24 = k6*nS1EB;
            nS1EB = nS1EB - 1; 
            nS2B = nS2B + 1;
            nEB = nEB + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31)/aTot %a31 = kB*nEA;
             nEA = nEA - 1;
             nEB = nEB + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32)/aTot %a32 = kA*nEB;
             nEA = nEA + 1;
             nEB = nEB - 1;   
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32+a33)/aTot %a33 = kB*nPA;
             nPA = nPA - 1;
             nPB = nPB + 1; 
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32+a33+a34)/aTot %a34 = kA*nPB;
             nPA = nPA + 1;
             nPB = nPB - 1; 
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32+a33+a34+a35)/aTot %a35 = kB*nS0EA;
             nS0EA = nS0EA - 1;
             nS0EB = nS0EB + 1; 
         elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32+a33+a34+a35+a36)/aTot %a36 = kA*nS0EB;
             nS0EA = nS0EA + 1;
             nS0EB = nS0EB - 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32+a33+a34+a35+a36+a37)/aTot %a37 = kB*nS1EA;
             nS1EA = nS1EA - 1;
             nS1EB = nS1EB + 1;
         elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32+a33+a34+a35+a36+a37+a38)/aTot %a38 = kA*nS1EB;
             nS1EA = nS1EA + 1;
             nS1EB = nS1EB - 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32+a33+a34+a35+a36+a37+a38+...
                 a39)/aTot %a39 = kB*nS1PA;
             nS1PA = nS1PA - 1;
             nS1PB = nS1PB + 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32+a33+a34+a35+a36+a37+a38+...
                 a39+a40)/aTot %a40 = kA*nS1PB;
             nS1PA = nS1PA + 1;
             nS1PB = nS1PB - 1;
        elseif r2 < (a25+a26+a1+a3+a5+a2+a4+a6+a27+a28+a7+a9+a11+a13+a15+a17+...
                 a8+a10+a12+a14+a16+a18+a29+a30+a19+a21+a23+a20+a22+...
                 a24+a31+a32+a33+a34+a35+a36+a37+a38+...
                 a39+a40+a41)/aTot %a41 = kB*nS2PA;
             nS2PA = nS2PA - 1;
             nS2PB = nS2PB + 1;
        else %a42 = kA*nS2PB; 
            nS2PA = nS2PA + 1;
            nS2PB = nS2PB - 1;
        end % if/else statement
        
        
    end % while time < tMax
    
    disp(indexTraj)
    
end % sum over all trajectories
