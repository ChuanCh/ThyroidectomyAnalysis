function map = colormapFD(nColors, saturation)
hues = zeros(nColors, 3);
map = hues;
sat = saturation;
for i = 1:nColors
    hues(i,:) = [(i-1)/nColors sat 1]; 
end
map = hsv2rgb(hues);
end
