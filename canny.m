image = imread("img\image-007.png");
res = acanny(im2gray(image));

function res = acanny(image)
    res = edge(image, "canny");
    res = im2uint8(res);
end