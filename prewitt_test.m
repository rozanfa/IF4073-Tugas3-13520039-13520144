image = imread("img/test/shiina.png");
image = im2gray(image);
res = prewitt(image);
imshow(res);