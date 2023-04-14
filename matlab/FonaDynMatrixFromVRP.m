function [outMatrix] = FonaDynMatrixFromVRP(vrpArray, threshold)
% outMatrix becomes a flat array (1:layers,1:fo_values,1:spl_values] corresponding to the voice field.

dataCols = size(vrpArray, 2) - 2; % cols 1 and 2 hold the indices
VRPx=zeros(dataCols,66,80);

for i = 1 : size(vrpArray, 1)
    foIx  = vrpArray(i, 1) - 29;
    splIx = vrpArray(i, 2) - 39;
    if foIx > 66 
        continue
    end
    if splIx < 1
        continue
    end
    if vrpArray(i, 3) >= threshold
        for j = 1:dataCols
            VRPx(j, foIx, splIx) = vrpArray(i, j+2);
        end
    end
end

outMatrix = VRPx;
end
