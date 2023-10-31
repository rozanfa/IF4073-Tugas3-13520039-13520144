function res = robert(image)
    image = im2gray(image);
    r1 = convolution(image, [1 0; 0 -1]);
    r2 = convolution(image, [0 1; -1 0]);
    res = abs(r1) + abs(r2);
    res = uint8(res);
end