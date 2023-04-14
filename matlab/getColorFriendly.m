function [colors] = getColorFriendly(nColors)
    % Manually create a colorfriendly color scheme.
    % nColors max is 10. No need for more clusters for now.
    paletteN = 10; % set palette color number to 10
    cMat = [];
    [cMat] = addColor(cMat, 127,59,8); %rgb now =cmap
    [cMat] = addColor(cMat, 179,88,6);
    [cMat] = addColor(cMat, 224,130,20);
    [cMat] = addColor(cMat, 253,184,99);
    [cMat] = addColor(cMat, 254,224,182);
    [cMat] = addColor(cMat, 216,218,235);
    [cMat] = addColor(cMat, 178,171,210);
    [cMat] = addColor(cMat, 128,115,172);
    [cMat] = addColor(cMat, 84,39,136);
    [cMat] = addColor(cMat, 45,0,75);
    if nColors < paletteN +1

        switch nColors
            %manually pick up the right color combinations
            case 2
                index = [5,10];
            case 3
                index = [5,7,10];
            case 4
                index = [1,5,7,10];
            case 5
                index = [1,3,5,7,10];
            case 6
                index = [1,3,5,7,8,10];
            case 7
                index = [1,2,3,5,7,8,10];
            case 8
                index = [1,2,3,4,5,7,8,10];
            case 9
                index = [1,2,3,4,5,7,8,9,10];
            case 10
                index = [1,2,3,4,5,6,7,8,9,10];
        end
            colors = cMat(index, :);
    end
    function [mat] = addColor(mat, R,G,B)
        rgbRow = [R/255, G/255, B/255];
        mat = [mat;rgbRow];
    end
end
