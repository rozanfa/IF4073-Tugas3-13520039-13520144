image = imread("img\image-009.jpg");
gray_image = im2gray(image);
edge_image = prewitt(gray_image);
edge_image = apply_tresshold(edge_image, 100);
figure(Name="edge_image");
imshow(edge_image);
% Close disconnected edges 
closed_image = imclose(edge_image,strel('line',10,0));
figure(Name="closed_image");
imshow(closed_image);

% Fill inside the edges
filled_image = imfill(closed_image, 'holes');

figure(Name="filled_image");
imshow(filled_image);

% Remove small objects
opened_image = imopen(filled_image, strel(ones(3,3)));
mask_image = bwareaopen(opened_image,3000);
figure(Name="opened_image");
imshow(opened_image);

% Apply mask to each of the RGB layer
red_processed = image(:,:,1).*uint8(mask_image);
green_processed = image(:,:,2).*uint8(mask_image);
blue_processed = image(:,:,3).*uint8(mask_image);
segmented_image = cat(3, red_processed, green_processed, blue_processed);

figure(Name="segmented_image");
imshow(segmented_image);

function res = apply_tresshold(image, tresshold)
    image_size = get_image_size(image);
    res = zeros(image_size);
    for i=1:image_size(0)
        for j=1:image_size(1)
            if image(i,j) > tresshold
                res(i,j) = 255;
            end
        end
    end
end