function res = prewitt(image)
    image = im2gray(image);
    Jx = convolution(image, [-1 0 1; -1 0 1; -1 0 1]);
    Jy = convolution(image, [-1 -1 -1; 0 0 0; 1 1 1]);
    res = sqrt(Jx.^2 + Jy.^2);
    res = uint8(res);
end