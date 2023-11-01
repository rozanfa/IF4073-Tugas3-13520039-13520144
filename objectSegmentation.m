% Panggil fungsi utama UI
imageEnhancementUI();

function imageEnhancementUI()
    % Persistent variables untuk digunakan dlm fungsi lain
    persistent greyHist;
    persistent edgeImg;
    persistent segmentedImage;
    persistent isUsingThreshold;
    persistent minimumPixel;

    % Inisialisasi variable persistent
    if isempty(greyHist)
        greyHist = true;
    end
    if isempty(edgeImg)
        edgeImg = [];
    end
    if isempty(segmentedImage)
        segmentedImage = [];
    end
    isUsingThreshold = false;
    minimumPixel = 500;

    % Create MATLAB UI
    fig = figure('Name', 'Image Enhancement', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 600]);

    % Komponen UI
    uicontrol('Style', 'pushbutton', 'String', 'Load Image', 'Position', [20, 540, 100, 30], 'Callback', @loadImage);

    parText = uicontrol('Style', 'text', 'String', 'Parameters:', 'Position', [20, 510, 100, 20]);
    aText = uicontrol('Style', 'text', 'String', 'a:', 'Position', [20, 490, 20, 20], 'Visible', 'off');
    aField = uicontrol('Style', 'edit', 'Position', [40, 490, 60, 20], 'Callback', @setA, 'Visible', 'off');
    bText = uicontrol('Style', 'text', 'String', 'b:', 'Position', [120, 490, 20, 20], 'Visible', 'off');
    bField = uicontrol('Style', 'edit', 'Position', [140, 490, 60, 20], 'Callback', @setB, 'Visible', 'off');

    uicontrol('Style', 'text', 'String', 'Remove connected components that have fewer than minimum pixels', 'Position', [400, 530, 200, 40], "HorizontalAlignment", "left");
    uicontrol('Style', 'text', 'String', 'Minimum pixels:', 'Position', [400, 518, 100, 20], "HorizontalAlignment", "left");
    uicontrol('Style', 'edit', 'Position', [480, 520, 100, 20], 'Callback', @setMinimumPixel, "String", minimumPixel);
    useThresholdCheckbox = uicontrol('Style', 'checkbox', 'String', 'Use Color Threshold', 'Position', [400, 490, 150, 20], 'Callback', @setIsUsingThreshold, "Enable","off");
    useThresholdError = uicontrol('Style', 'text', 'String', 'Threshold can only be used on colored image', 'Position', [400, 470, 240, 20], "HorizontalAlignment", "left", "Visible","on");

    upperBoundTitle = uicontrol('Style', 'text', 'String', 'Upper Bound Value', 'Position', [720, 510, 100, 20]);
    upperRedText = uicontrol('Style', 'text', 'String', 'red:', 'Position', [610, 490, 40, 20]);
    upperRedField = uicontrol('Style', 'edit', 'Position', [640, 490, 60, 20], 'Callback', @setUpperRed, "Enable", "off", "String", "255");
    upperGreenText = uicontrol('Style', 'text', 'String', 'green:', 'Position', [706, 490, 40, 20]);
    upperGreenField = uicontrol('Style', 'edit', 'Position', [740, 490, 60, 20], 'Callback', @setUpperGreen, "Enable", "off", "String", "255");
    upperBlueText = uicontrol('Style', 'text', 'String', 'blue:', 'Position', [810, 490, 40, 20]);
    upperBlueField = uicontrol('Style', 'edit', 'Position', [840, 490, 60, 20], 'Callback', @setUpperBlue, "Enable", "off", "String", "255");

    lowerBoundTitle = uicontrol('Style', 'text', 'String', 'Lower Bound Value', 'Position', [720, 570, 100, 20]);
    lowerRedText = uicontrol('Style', 'text', 'String', 'red:', 'Position', [610, 550, 40, 20]);
    lowerRedField = uicontrol('Style', 'edit', 'Position', [640, 550, 60, 20], 'Callback', @setLowerRed, "Enable", "off", "String", "0");
    lowerGreenText = uicontrol('Style', 'text', 'String', 'green:', 'Position', [706, 550, 40, 20]);
    lowerGreenField = uicontrol('Style', 'edit', 'Position', [740, 550, 60, 20], 'Callback', @setLowerGreen, "Enable", "off", "String", "0");
    lowerBlueText = uicontrol('Style', 'text', 'String', 'blue:', 'Position', [810, 550, 40, 20]);
    lowerBlueField = uicontrol('Style', 'edit', 'Position', [840, 550, 60, 20], 'Callback', @setLowerBlue, "Enable", "off", "String", "0");


    uicontrol('Style', 'text', 'String', 'Original Image', 'Position', [145, 185, 100, 20]);
    uicontrol('Style', 'text', 'String', 'Edge Image', 'Position', [450, 185, 100, 20]);
    uicontrol('Style', 'text', 'String', 'Result Image', 'Position', [755, 185, 100, 20]);


    % Enhancement operation dropdown menu
    filterMenu = uicontrol('Style', 'popupmenu', 'String',...
        {'Laplacian Filter', 'LoG Filter', 'Sobel Filter', 'Prewitt Filter', 'Roberts Filter', 'Canny Filter'},...
        'Position', [140, 530, 180, 30], 'Callback', @showHideParameters);

    uicontrol('Style', 'pushbutton', 'String', 'Filter', 'Position', [140, 490, 80, 30], 'Callback', @getEdgeImage);

    % uicontrol('Style', 'pushbutton', 'String', 'Fill', 'Position', [220, 490, 100, 30], 'Callback', @fillSegmentation);
    uicontrol('Style', 'pushbutton', 'String', 'Apply', 'Position', [240, 490, 80, 30], 'Callback', @applySegmentation);

    % Axes untuk display images dan histograms
    axesImageInput = axes('Position', [0.07, 0.35, 0.25, 0.40]);
    axesImageFiltered = axes('Position', [0.37, 0.35, 0.25, 0.40]);
    axesImageSegmented = axes('Position', [0.67, 0.35, 0.25, 0.40]);

    axesHistogram = axes('Position', [0.07, 0.1, 0.85, 0.15]);


    axes(axesImageFiltered);
    imshow([]);

    axes(axesImageSegmented);
    imshow([]);

    % Inisialisasi dengan cameraman.tif
    img = imread('cameraman.tif');
    axes(axesImageInput);
    imshow(img);
    plotRGBHistogram(axesHistogram, img)

    showHideParameters();

    % Inisialisasi variable lain
    a = 1;
    upperRed = 255;
    upperGreen = 255;
    upperBlue = 255;
    lowerRed = -1;
    lowerGreen = -1;
    lowerBlue = -1;

    % Callback functions
    function showHideParameters(~, ~)
        enhancementIdx = get(filterMenu, 'Value');
        
        % Set komponen "a" dan "b" hidden
        set(parText, 'Visible', 'off')
        set(aText, 'Visible', 'off');
        set(bText, 'Visible', 'off');
        set(aField, 'Visible', 'off');
        set(bField, 'Visible', 'off');
        
        % Show komponen "a" dan "b" berdasarkan enhancement yang dipilih
        switch enhancementIdx
            case 2
                set(parText, 'Visible', 'on')
                set(aText, 'Visible', 'on', 'String', 'n:');
                set(aField, 'Visible', 'on');
        end
    end

    % Load image
    function loadImage(~, ~)
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files (*.jpg, *.png, *.bmp, *.tif)'}, 'Select an image');
        if file
            img = imread(fullfile(path, file));
            axes(axesImageInput);
            imshow(img);
        end
        
        if length(size(img)) <= 2
            set(useThresholdCheckbox, "Enable", "off")
            set(useThresholdError, "Visible", "on")
        else
            set(useThresholdCheckbox, "Enable", "on")
            set(useThresholdError, "Visible", "off")
        end
        
        plotRGBHistogram(axesHistogram, img)
    end


    function setA(src, ~)
        a = str2double(get(src, 'String'));
    end

    function setB(src, ~)
        b = str2double(get(src, 'String'));
    end

    function setUpperRed(src, ~)
        upperRed = str2double(get(src, 'String'));
    end

    function setUpperGreen(src, ~)
        upperGreen = str2double(get(src, 'String'));
    end

    function setUpperBlue(src, ~)
        upperBlue = str2double(get(src, 'String'));
    end

    function setLowerRed(src, ~)
        lowerRed = str2double(get(src, 'String'));
    end

    function setLowerGreen(src, ~)
        lowerGreen = str2double(get(src, 'String'));
    end

    function setLowerBlue(src, ~)
        lowerBlue = str2double(get(src, 'String'));
    end

    function setMinimumPixel(src, ~)
        minimumPixel = str2double(get(src, 'String'));
    end

    function setIsUsingThreshold(src, ~)
        isUsingThreshold = get(src, 'Value');
        
        if isUsingThreshold
            set(upperRedField, 'Enable', 'on');
            set(upperGreenField, 'Enable', 'on');
            set(upperBlueField, 'Enable', 'on');
            
            set(lowerRedField, 'Enable', 'on');
            set(lowerGreenField, 'Enable', 'on');
            set(lowerBlueField, 'Enable', 'on');
        else
            set(upperRedField, 'Enable', 'off');
            set(upperGreenField, 'Enable', 'off');
            set(upperBlueField, 'Enable', 'off');
            
            set(lowerRedField, 'Enable', 'off');
            set(lowerGreenField, 'Enable', 'off');
            set(lowerBlueField, 'Enable', 'off');
        end
    end

    function getEdgeImage(~, ~)
        if ~isempty(img)
            % Get enhancement operation yang dipilih
            enhancementIdx = get(filterMenu, 'Value');
            hasChannel = length(size(img)) > 2;
            if hasChannel & isUsingThreshold
                % gray = uint8(((red/100) .* doubleImg(:, :, 1) + (green/100) .* doubleImg(:, :, 2) + (blue/100) .* doubleImg(:, :, 3)) ./ ((red + green + blue)/100));
                binary = (img(:, :, 1) <= upperRed & img(:, :, 1) >= lowerRed & img(:, :, 2) <= upperGreen & img(:, :, 2) >= lowerGreen & img(:, :, 3) <= upperBlue & img(:, :, 3) >= lowerBlue);
                gray = uint8(double(im2gray(img)) .* double(binary));
            elseif hasChannel
                gray = im2gray(img);
            else
                gray = img;
            end
            
            switch enhancementIdx
                case 1
                    edgeImg = laplaceFunction(gray);
                case 2
                    edgeImg = logFunction(gray, a);
                case 3
                    edgeImg = sobelFunction(gray);
                case 4
                    edgeImg = prewittFunctions(gray);
                case 5
                    edgeImg = robertsFunction(gray);
                case 6
                    edgeImg = cannyFunctions(gray);
            end
            
            axes(axesImageFiltered);
            imshow(edgeImg);
        else
            msgbox('Please load an image first.', 'Error', 'error');
        end
    end

    % Apply segmentation to the image
    function applySegmentation(~, ~)
        getEdgeImage()
        if ~isempty(edgeImg)
            segmentedImage = segmentFunction(img, edgeImg, minimumPixel);
            axes(axesImageSegmented);
            imshow(segmentedImage);
        else
            msgbox('Please load an image first.', 'Error', 'error');
        end
    end

    % Plot histogram
    function plotRGBHistogram(axesHandle, image)
        if ndims(image) == 3
            % Set level histogram
            levels = 256;
            
            [rows, cols, ~] = size(image);
            
            % Inisialisasi histogram untuk R, G, dan B masing-masing
            redHistogram = zeros(1, levels);
            greenHistogram = zeros(1, levels);
            blueHistogram = zeros(1, levels);
            
            % Hitung jumlah pixel setiap warna
            for r = 1:rows
                for c = 1:cols
                    pixelValueRed = image(r, c, 1);
                    pixelValueGreen = image(r, c, 2);
                    pixelValueBlue = image(r, c, 3);
                    
                    % Update masing-masing histogram warna
                    redHistogram(pixelValueRed + 1) = redHistogram(pixelValueRed + 1) + 1;
                    greenHistogram(pixelValueGreen + 1) = greenHistogram(pixelValueGreen + 1) + 1;
                    blueHistogram(pixelValueBlue + 1) = blueHistogram(pixelValueBlue + 1) + 1;
                end
            end
            
            % Buat subplot pada axes handle
            axes(axesHandle);
            
            histData = [redHistogram; greenHistogram; blueHistogram];
            
            % Buat bar chart dengan custom color
            bar(0:levels - 1, histData', 'grouped');
            
            % Set warna bar masing-masing R, G, B
            set(gca, 'ColorOrder', [1 0 0; 0 1 0; 0 0 1]);
            
            % Set title dan label
            title('RGB Histogram');
            xlabel('Pixel Value');
            ylabel('Frequency');
            legend('Red', 'Green', 'Blue');
        else
            axes(axesHandle);
            
            % Inisialisasi histogram
            grayHistogram = getHist(image);
            
            % Display histogram
            bar(0:256 - 1, grayHistogram); % 0-255
            title('Histogram');
            xlabel('Pixel Value');
            ylabel('Frequency');
        end
    end

end

% Get histogram of an image
function hist = getHist(img)
    [rows, cols] = size(img);
    levels = 256;
    hist = zeros(1, levels);
    for r = 1:rows
        for c = 1:cols
            val = img(r, c);
            hist(val+1) = hist(val+1) + 1;
        end
    end
end

% Function to fill holes in an edge image
function filledImg = fillHoles(img, minimumPixel)
    % closedImg = imclose(img, strel('disk', 4));
    binary = imbinarize(img, "global");
    % openedImg = imopen(binary, strel(ones(4,4)));
    dilateImg = imdilate(binary, strel('disk', 2));
    erodeImg = imerode(dilateImg, strel('disk', 1));
    bridgedImg = bwmorph(erodeImg, 'bridge');
    filledImg = imfill(bridgedImg, "holes");
    maskImg = bwareaopen(filledImg, minimumPixel);
    filledImg = maskImg;
end

% Image segmentation
% Segmentation using connected component
function segmentImg = segmentFunction(img, edgeImg, minimumPixel)
    binary = fillHoles(edgeImg, minimumPixel);

    if (sum(binary == 1, "all") > sum(binary == 0, "all"))
        binary = binary .^ 0;
    end

    segmentImg = uint8(double(img) .* double(binary));
end

% Laplacian edge detection
function laplaceImg = laplaceFunction(inputImg)
    % Create Laplacian filter
    filter = [0 1 0; 1 -4 1; 0 1 0];

    % Convolve the filter with the image
    laplaceImg = uint8(convn(double(inputImg), double(filter), 'same'));
end

% Laplacian of Gaussian (LoG) edge detection
function logImg = logFunction(inputImg, n)
    sigma = 1.4;

    % Create a meshgrid for the filter
    [X, Y] = meshgrid(-(n-1)/2:(n-1)/2, -(n-1)/2:(n-1)/2);

    % Calculate the Gaussian filter
    gaussianFilter = exp(-(X.^2 + Y.^2) / (2 * sigma^2));

    % Calculate the Laplacian of the Gaussian (LoG) filter
    filter = (X.^2 + Y.^2 - 2 * sigma^2) .* gaussianFilter;

    % Normalize the filter to ensure it sums to zero
    filter = filter - sum(filter, 'all') / n^2;

    % Ensure the filter sums to zero
    filter = filter - mean(filter, 'all');

    logImg = uint8(convn(double(inputImg), double(filter), 'same'));
end

% Sobel edge detection
function sobelImg = sobelFunction(inputImg)
    % Create Sx and Sy Sobel filters
    Sx = [-1 0 1; -2 0 2; -1 0 1];
    Sy = [1 2 1; 0 0 0; -1 -2 -1];

    % Convolve the filters with the image
    Jx = conv2(double(inputImg), double(Sx), 'same');
    Jy = conv2(double(inputImg), double(Sy), 'same');

    % Calculate the magnitude of the gradient
    sobelImg = uint8(sqrt(Jx.^2 + Jy.^2));
end

% Roberts edge detection
function res = robertsFunction(image)
    % Create R1 and R2 Roberts filters
    r1 = convolution(image, [1 0; 0 -1]);
    r2 = convolution(image, [0 1; -1 0]);

    % Calculate the magnitude of the gradient
    res = abs(r1) + abs(r2);

    % Convert to uint8
    res = uint8(res);
end

% Prewitt edge detection
function res = prewittFunctions(image)
    % Create P1 and P2 Prewitt filters
    Jx = convolution(image, [-1 0 1; -1 0 1; -1 0 1]);
    Jy = convolution(image, [-1 -1 -1; 0 0 0; 1 1 1]);


    % Calculate the magnitude of the gradient
    res = sqrt(Jx.^2 + Jy.^2);

    % Convert to uint8
    res = uint8(res);
end

% Canny edge detection
function res = cannyFunctions(image)
    res = im2uint8(edge(image, "canny"));
end

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

function image_size = get_image_size(image)
    image_size = size(image);
    if ismatrix(image)
        image_size = [image_size 1];
    end
end
