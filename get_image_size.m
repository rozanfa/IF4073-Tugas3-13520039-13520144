function image_size = get_image_size(image)
    image_size = size(image);
    if ismatrix(image)
        image_size = [image_size 1];
    end
end