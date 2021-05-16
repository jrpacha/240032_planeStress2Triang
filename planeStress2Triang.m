clearvars
close all

th =0.036;     %mm
tau0 = 1000.0; %N/mm^2;
E = 3.0e7;    %N/mm^2M
nu = 0.25;

nodes = [0,0;
    120, 0;
    120,160;
    0,160];

elem = [1,2,3;
    3,4,1];

numNodes = size(nodes,1);
numElem = size(elem,1);
dim = size(nodes,2);

K = zeros(dim*numNodes);
Q = zeros(dim*numNodes,1);
F = zeros(dim*numNodes,1);
B = cell(numElem,1);

model = 1; %model = 1: stress; model = 2; strain

C = zeros(3,3);
C(1,1)= E/(1-nu^2);
C(1,2)= nu*C(1,1);
C(2,1)= C(1,2);
C(2,2)= C(1,1);
C(3,3)= 0.5*E/(1+nu);

for e=1:numElem
    [Ke,Be] = stiffMatrixElastTriang(nodes,elem,C,th,e);
    rows = [dim*elem(e,1)-1, dim*elem(e,1), dim*elem(e,2)-1, dim*elem(e,2),...
        dim*elem(e,3)-1, dim*elem(e,3)];
    cols = rows;
    K(rows,cols) = K(rows,cols) + Ke;
    B{e} = Be;
end;

fixedNods = [];
nod=1;
fixedNods = [fixedNods,dim*nod-1,dim*nod];
nod=4;
fixedNods = [fixedNods,dim*nod-1,dim*nod];

freeNods = setdiff(1:dim*numNodes,fixedNods);

%Boundary Conditions;
%Natural B.C.: 
%Oon side 2 of element 1 (local nodes 2 and 3)
h = norm(nodes(elem(1,2),:)-nodes(elem(1,3),:));
nod=2; %global node (node 2 of element 1)
Q(2*nod-1) = th*h*tau0/2;
Q(2*nod) = 0.0;
nod=3; %global node (node 3 of element 1)
Q(2*nod-1) = th*h*tau0/2;
nod=3; %global node (node 3 of element 1)
Q(2*nod-1) = th*h*tau0/2;
Q(2*nod) = 0.0;

%Essential B.C.
u = zeros(dim*numNodes,1);
u(fixedNods,1) = 0;

%Reduced system
Km = K(freeNods,freeNods);
Qm = Q(freeNods) - K(freeNods,fixedNods)*u(fixedNods,1);

%Solve the reduced system
um = Km\Qm;
u(freeNods,1)= um;

fprintf('Displacements:\n')
fprintf('%2d%14.5e%12.5e\n',[(1:numNodes)',u(1:2:end),u(2:2:end)]')

sigma = zeros(3,numElem);

for e = 1:numElem
    rows = [dim*elem(e,1)-1, dim*elem(e,1), dim*elem(e,2)-1, dim*elem(e,2),...
        dim*elem(e,3)-1, dim*elem(e,3)];
    sigma(:,e) = C*B{e}*u(rows);
end

fprintf('Stress:\n');
fprintf('%2d%15.5e%15.5e%15.5e\n',[(1:numElem)',sigma']')






