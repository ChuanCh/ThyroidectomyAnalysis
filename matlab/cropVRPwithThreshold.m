function outArray = cropVRPwithThreshold(Mask, Data, threshold)

outArray = zeros(size(Mask, 1), size(Data,2));
outrow = 1;

for inrow = 1 : size(Mask, 1)
    dataIx = find(Data(:,1) == Mask(inrow,1));
    for j = 1 : length(dataIx)
        % Data(dataIx(j))
        if Data(dataIx(j),2) == Mask(inrow, 2)
            if (Data(dataIx(j),3) >= threshold) & (Mask(inrow,3) >= threshold)
              outArray(outrow,:) = Data(dataIx(j),:);
              outrow = outrow + 1;
            end;
        end;
    end
end
outArray = outArray(1:outrow-1,:);
end