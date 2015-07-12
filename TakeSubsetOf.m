function [Msubset,Rnk] = TakeSubsetOf(M,T)
%% Description
% M = Cell Matrix of points (assumed to be in a regular grid somehow)
% T = Threshold gradient value (inversely proportional to number of output
% points)
% M must have values for the entire grid

%% setting default T
if nargin < 2;
    T = 1;
end

%% Eliminating points that don't pass the threshold
Msubset = M;
for k1 = 1:size(M,1)
    for k2 = 1:size(M,2)
        for i = -1:1
            for j = -1:1
                if i ~= 0 & j ~= 0 & (k1+i) >= 1 & (k1+i) <= size(M,1) & (k2+j) >= 1 & (k2+j) <= size(M,2) 
                    X = M{k1,k2} - M{k1+i,k2+j};
                    absslope(i+2,j+2) = abs(X(3)./sqrt((X(1)).^2 +(X(2)).^2));
                end
            end
        end
        if sum(sum((absslope ~= 0))) ~= 0
            SlopeMatrix(k1,k2) = sum(absslope(:))/sum(sum((absslope ~= 0)));
        else
            SlopeMatrix(k1,k2) = 0;
        end
        if  sum(sum((absslope ~= 0))) ~= 0 & SlopeMatrix(k1,k2) < T
            Msubset{k1,k2} = [];
        end
        absslope = zeros(size(M,1),size(M,2));
    end
end

% checks if eliminated points are actually close to local max/mins (checks
% the direct neighborhood around points)
k3 = 1;
ImpPnts = {};
for k1 = 1:size(M,1)
    for k2 = 1:size(M,2)
        if isempty(Msubset{k1,k2}) == 1
            for i = -1:1
                for j = -1:1
                    if i ~= 0 & j ~= 0 & (k1+i) >= 1 & (k1+i) <= size(M,1) & (k2+j) >= 1 & (k2+j) <= size(M,2)
                        Empt(i+2,j+2) = isempty(Msubset{k1+i,k2+j});
                    end
                end
            end
            if sum(Empt(:)) == 0  % might need to change this value
                Msubset{k1,k2} = M{k1,k2};
                ImpPnts{k3} = [k1,k2];
                k3 = k3 + 1;
            end
        end
    end
end

            
        
               
%% Search for best grid subset of M that contains the a lot of the points that passed yet minimizes the amount of points that didn't pass
% Ranking points
for k1 = 1:size(Msubset,1)
    for k2 = 1:size(Msubset,2)
        if isempty(Msubset{k1,k2}) == 0
            Rnk(k1,k2) = SlopeMatrix(k1,k2)/(max(SlopeMatrix(:))/10);
        elseif isempty(Msubset{k1,k2}) == 1
            Rnk(k1,k2) = -1;
        end
    end
end

if isempty(ImpPnts) == 0
    for p = 1:length(ImpPnts)
        Rnk(ImpPnts{p}(1), ImpPnts{p}(2)) = 10;
    end
end


% Creating vertical/horizontal grids
for k3 = 1:2
    Q{1} = 1:size(Rnk,k3);
    k2 = 2;
    n = length(Q{1}); 
    nlim = n;
    while nlim ~= 0
        for k1 = 1:length(Q(k2-1,:))
            n = length(Q{k2-1,k1});
            if n > 2
                P{1} = Q{k2-1,k1}(2*[1:(floor((n+1)/2))]-1);
                P{2} = Q{k2-1,k1}(2*[1:(floor(n/2))]);
            else 
                P{1} = [];
                P{2} = [];
            end
            Q{k2,2*k1-1} = P{1};
            Q{k2,2*k1} = P{2};
        end
        nlim = length(Q{k2,1});
        if length(Q{k2}) > 1
            for p = 2:length(Q(k2))
                nlim = nlim + length(Q{k2,p});
            end
        end
        k2 = k2 + 1;
    end
    Seq{k3} = Q;
end

for k1 = 1:length(Seq{1})
    for k2 = 1:length(Seq{2})
        RowSeq = Seq{1}{k1};
        ColSeq = Seq{2}{k2};
        TestRnk = Rnk(RowSeq, ColSeq);
        GridScore(k1,k2) = sum(TestRnk(:));
    end
end

LocMax = find(GridScore == max(GridScore(:)));
RowMax = rem(LocMax, length(Seq{1}));
for k1 = 1:length(RowMax)
    if RowMax(k1) == 0
    RowMax(k1) = length(Seq{1});
    end
end

ColMax = ceil(LocMax / length(Seq{1}));

for k1 = 1:length(Seq{1}(RowMax))
    for k2 = 1:length(Seq{2}(ColMax))
        t = Seq{1}(RowMax);
        u = Seq{2}(ColMax);
        Msubset = M(t{k1}, u{k2});
    end
end




        





        








        
        