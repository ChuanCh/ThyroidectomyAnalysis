function outArray = cropVRP(Mask, Data)

outArray = zeros(size(Mask, 1), size(Data,2));
outrow = 1;

for inrow = 1 : size(Mask, 1)
    dataIx = find(Data(:,1) == Mask(inrow,1));
    for j = 1 : length(dataIx)
        % Data(dataIx(j))
        if Data(dataIx(j),2) == Mask(inrow, 2)
          outArray(outrow,:) = Data(dataIx(j),:);
          outrow = outrow + 1;
        end;
    end
end
outArray = outArray(1:outrow-1,:);
end