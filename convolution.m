% Convolution of an image with a filter
function res = convolution(image, filter)
    image = double(image);
    filter = double(filter);
    image_size = get_image_size(image);
    [filter_length_x, filter_length_y] = size(filter);

    % Check if filter is a square matrix
    if filter_length_x ~= filter_length_y
        error("Filter must be a square matrix")
    end

    filter_length = filter_length_x;
    res = zeros(image_size);

    % Loop over all channels
    for c = 1:image_size(3)
        % Loop over all pixels
        for i = 1:image_size(1)-filter_length+1
            for j = 1:image_size(2)-filter_length+1
                res(i,j,c) = sum(dot(image(i:i+filter_length-1, j:j+filter_length-1, c), filter), "all");
            end
        end
    end
end