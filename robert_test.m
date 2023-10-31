image = imread("img/test/shiina.png");
image = im2gray(image);
res = robert(image);
imshow(res);