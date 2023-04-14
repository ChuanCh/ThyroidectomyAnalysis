function [names, dataArray, vrpArray] = FonaDynArraysLogFileToVRP(data, nClusters)
% arg data is the array loaded from a file of type *_Log.aiff. 
% arg nClusters should be max(data(:,7)) + 1;
% This track order is expected (FonaDyn v2.1):
% [time, freq, amp, clarity, crest, specbal, cluster_number, sampen, iContact, dEGGmax, qContact] ++ amps ++ phases
% dataArray becomes a sparse array (1:layers,1:fo_values,1:spl_values] corresponding to the voice field.
% dataArray and names can be passed to FonaDynPlotVRP or FonaDynPlotVRPratios/-diffs
% vrpArray is filled as for a _VRP.csv format file with one cell per row.
% names is filled with the log file track names for version 2.1.

names = {'MIDI', 'dB', 'Total', 'Clarity', 'Crest', 'SpecBal', 'Entropy', 'Icontact', 'dEGGmax', 'Qcontact', 'maxCluster'};
paramCols = size(names,2) - 2;

for c = 1 : nClusters
    names{paramCols+2+c} = char( ['Cluster ' num2str(c)]);
end

% Assumes fo range 30...96 (MIDI), SPL range 40...120 (dB)
VRPx=zeros(paramCols+nClusters,66,80);

for i = 1 : size(data, 1)
    foIx = max(1, round(data(i, 2)) - 29);
    if foIx > 66 
        continue
    end
    splIx  = max(1, round(data(i, 3)) - 39);
    if splIx > 80
        continue
    end
    VRPx(1, foIx, splIx) = VRPx(1, foIx, splIx)  +  1 ;   % accumulate total cycles
    VRPx(2, foIx, splIx) = data(i, 4);   % latest clarity
    VRPx(3, foIx, splIx) = VRPx(3, foIx, splIx) + data(i, 5);  % accumulate crest factor
    VRPx(4, foIx, splIx) = VRPx(4, foIx, splIx) + data(i, 6); % accumulate spectrum balance
    VRPx(5, foIx, splIx) = VRPx(5, foIx, splIx) + data(i, 8); % accumulate entropy
    VRPx(6, foIx, splIx) = VRPx(6, foIx, splIx) + data(i, 9); % accumulate iContact
    VRPx(7, foIx, splIx) = VRPx(7, foIx, splIx) + data(i, 10); % accumulate dEGGmax/Qdelta
    VRPx(8, foIx, splIx) = VRPx(8, foIx, splIx) + data(i, 11); % accumulate qContact
    clusterNo = data(i, 7);   % get the cluster number of this cycle
    VRPx(paramCols+clusterNo, foIx, splIx) = VRPx(paramCols+clusterNo, foIx, splIx) + 1; % accumulate cycles per cluster
end

vArr = [];
row = 1;
for foIx = 1 : 66
    for splIx = 1 : 80
        totCycles = VRPx(1, foIx, splIx);
        if totCycles > 0
            VRPx(3, foIx, splIx) = VRPx(3, foIx, splIx) / totCycles;
            VRPx(4, foIx, splIx) = VRPx(4, foIx, splIx) / totCycles;
            VRPx(5, foIx, splIx) = VRPx(5, foIx, splIx) / totCycles;
            VRPx(6, foIx, splIx) = VRPx(6, foIx, splIx) / totCycles;
            VRPx(7, foIx, splIx) = VRPx(7, foIx, splIx) / totCycles;
            VRPx(8, foIx, splIx) = VRPx(8, foIx, splIx) / totCycles;
            VRPx(9, foIx, splIx) = VRPx(9, foIx, splIx) / totCycles;
            [maxVal maxIx] = max(VRPx(paramCols+1:paramCols+nClusters, foIx, splIx));
            VRPx(paramCols, foIx, splIx) = maxIx;
            vArr(row, :) = [foIx+29; splIx+39; VRPx(1:paramCols+nClusters, foIx, splIx)]';
            row = row+1;
        end
    end
end
dataArray = VRPx;
vrpArray = vArr;
end