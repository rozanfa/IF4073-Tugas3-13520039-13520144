image = imread("a.png");
gray_image = im2gray(image);
edge_image = canny(gray_image);
imshow(edge_image);
image_size = size(image);
main_dots = [];
list_count = [];
res = zeros(image_size(1), image_size(2));
for i = 1:image_size(1)
    for j = 1:image_size(2)
        temp_edge_image = edge_image;
        if temp_edge_image(i,j) == 1
            current_dot = [i j];
            main_dots = current_dot;

            temp_dots = {};
            prev_dot = [0 0];
            next_dot = [0 0];
            count = 0;
            
            while next_dot(1) ~= -1
                temp_edge_image(current_dot(1), current_dot(2)) = 0;
                next_dot = get_next_dot(current_dot, prev_dot, temp_edge_image, image, 50);
                temp_dots{count+1} = next_dot;
                prev_dot = current_dot;
                current_dot = next_dot;
                count = count + 1;
            end
            list_count = [list_count count];
            length = size(temp_dots);
            if count > 50
                for e = 1:length(2)/2
                    c = temp_dots{e};
                    res(c(1), c(2)) = 1;
                end
            end

        end
    end
end
res = uint8(res);

figure(Name="res");
res = res .* 100;

figure;

function next_dot = get_next_dot(current_dot, prev_dot, edge_image, image, treshold)
    image_size = size(image);

    x = current_dot(1);
    y = current_dot(2);

    left = max(x-1, 0);
    bot = max(y-1, 0);
    top = min(y+1, image_size(2));
    right = min(x+1, image_size(1));

    next_dot = [-1 -1];

    for i = 1:8
        switch i
            case 1
                candidate_next_dot = [left top];
            case 2
                candidate_next_dot = [x top];
            case 3
                candidate_next_dot = [right top];
            case 4
                candidate_next_dot = [right y];
            case 5
                candidate_next_dot = [right bot];
            case 6
                candidate_next_dot = [x bot];
            case 7
                candidate_next_dot = [left bot];
            case 8
                candidate_next_dot = [left y];
        end

        if candidate_next_dot ~= prev_dot
            if (edge_image(candidate_next_dot(1), candidate_next_dot(2)) == 1)
                % if abs(sum(image(current_dot(1), current_dot(2), :)) - sum(image(candidate_next_dot(1), candidate_next_dot(2), :))) < treshold * 3
                    next_dot = candidate_next_dot;
                %     return
                % end
            end
        end
    end
    
end