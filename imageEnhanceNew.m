% Panggil fungsi utama UI
imageEnhancementUI();

function imageEnhancementUI()
    % Persistent variables untuk digunakan dlm fungsi lain
    persistent greyHist;
    persistent enhancedImg;
    
    % Inisialisasi variable persistent
    if isempty(greyHist)
        greyHist = true;
    end
    if isempty(enhancedImg)
        enhancedImg = [];
    end

    % Create MATLAB UI
    fig = figure('Name', 'Image Enhancement', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);

    % Komponen UI
    uicontrol('Style', 'pushbutton', 'String', 'Load Image', 'Position', [20, 540, 100, 30], 'Callback', @loadImage);
    % uicontrol('Style', 'pushbutton', 'String', 'Toggle Histogram', 'Position', [350, 540, 100, 30], 'Callback', @toggleHist);
    parText = uicontrol('Style', 'text', 'String', 'Parameters:', 'Position', [20, 510, 100, 20]);
    aText = uicontrol('Style', 'text', 'String', 'a:', 'Position', [20, 490, 20, 20], 'Visible', 'off');
    aField = uicontrol('Style', 'edit', 'Position', [40, 490, 60, 20], 'Callback', @setA, 'Visible', 'off');
    bText = uicontrol('Style', 'text', 'String', 'b:', 'Position', [120, 490, 20, 20], 'Visible', 'off');
    bField = uicontrol('Style', 'edit', 'Position', [140, 490, 60, 20], 'Callback', @setB, 'Visible', 'off');
    refButton = uicontrol('Style', 'pushbutton', 'String', 'Load Reference', 'Position', [350, 490, 100, 30], 'Callback', @loadRef);

    uicontrol('Style', 'text', 'String', 'Upper Bound Value', 'Position', [520, 570, 100, 20]);
    upperRedText = uicontrol('Style', 'text', 'String', 'red:', 'Position', [410, 490, 40, 20]);
    upperRedField = uicontrol('Style', 'edit', 'Position', [440, 490, 60, 20], 'Callback', @setUpperRed);
    upperGreenText = uicontrol('Style', 'text', 'String', 'green:', 'Position', [506, 490, 40, 20]);
    uppergreenField = uicontrol('Style', 'edit', 'Position', [540, 490, 60, 20], 'Callback', @setUpperGreen);
    upperBlueText = uicontrol('Style', 'text', 'String', 'blue:', 'Position', [610, 490, 40, 20]);
    upperBlueField = uicontrol('Style', 'edit', 'Position', [640, 490, 60, 20], 'Callback', @setUpperBlue);

    uicontrol('Style', 'text', 'String', 'Lower Bound Value', 'Position', [520, 510, 100, 20]);
    lowerRedText = uicontrol('Style', 'text', 'String', 'red:', 'Position', [410, 550, 40, 20]);
    lowerRedField = uicontrol('Style', 'edit', 'Position', [440, 550, 60, 20], 'Callback', @setLowerRed);
    lowerGreenText = uicontrol('Style', 'text', 'String', 'green:', 'Position', [506, 550, 40, 20]);
    lowerGreenField = uicontrol('Style', 'edit', 'Position', [540, 550, 60, 20], 'Callback', @setLowerGreen);
    lowerBlueText = uicontrol('Style', 'text', 'String', 'blue:', 'Position', [610, 550, 40, 20]);
    lowerBlueField = uicontrol('Style', 'edit', 'Position', [640, 550, 60, 20], 'Callback', @setLowerBlue);

    % Enhancement operation dropdown menu
    enhancementMenu = uicontrol('Style', 'popupmenu', 'String', {'Fill Previous', 'Segment Previous', 'Laplacian Filter', 'LoG Filter', 'Sobel Filter', 'Prewitt Filter', 'Roberts Filter', 'Canny Filter'}, 'Position', [140, 530, 180, 30], 'Callback', @showHideParameters);
    
    uicontrol('Style', 'pushbutton', 'String', 'Enhance', 'Position', [220, 490, 100, 30], 'Callback', @enhanceImage);
    
    % Axes untuk display images dan histograms
    axesImageInput = axes('Position', [0.15, 0.425, 0.35, 0.35]);
    axesHistogramInput = axes('Position', [0.15, 0.1, 0.35, 0.25]);
    axesImageEnhanced = axes('Position', [0.55, 0.425, 0.35, 0.35]);
    axesHistogramEnhanced = axes('Position', [0.55, 0.1, 0.35, 0.25]);
    refText = uicontrol('Style', 'text', 'String', 'Reference:', 'Position', [450, 575, 100, 15]);
    axesImageRef = axes('Position', [0.6, 0.82, 0.125, 0.125]);
    
    % Inisialisasi dengan cameraman.tif
    img = imread('cameraman.tif');
    axes(axesImageInput);
    imshow(img);

    showHideParameters();

    if greyHist
        plotHistogram(axesHistogramInput, img);
    else
        plotRGBHistogram(axesHistogramInput, img);
    end
    
    % Inisialisasi variable lain
    a = 1;
    b = 0;
    upperRed = 255;
    upperGreen = 255;
    upperBlue = 255;
    lowerRed = -1;
    lowerGreen = -1;
    lowerBlue = -1;
    ref = [];
    
    % Callback functions
    function showHideParameters(~, ~)
        enhancementIdx = get(enhancementMenu, 'Value');
        
        % Set komponen "a" dan "b" hidden
        set(parText, 'Visible', 'off')
        set(aText, 'Visible', 'off');
        set(bText, 'Visible', 'off');
        set(aField, 'Visible', 'off');
        set(bField, 'Visible', 'off');
        set(refButton, 'Visible', 'off');
        set(refText, 'Visible', 'off');
        set(axesImageRef, 'Visible', 'off')
        axes(axesImageRef);
        imshow([]);
    
        % Show komponen "a" dan "b" berdasarkan enhancement yang dipilih
        switch enhancementIdx
            case 4
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
            if greyHist
                plotHistogram(axesHistogramInput, img);
            else
                plotRGBHistogram(axesHistogramInput, img);
            end
        end
    end

    % Load reference image
    function loadRef(~, ~)
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files (*.jpg, *.png, *.bmp, *.tif)'}, 'Select an image');
        if file
            ref = imread(fullfile(path, file));
            axes(axesImageRef);
            imshow(ref);
        end
    end

    % Toggle Histogram antara greyscale dan RGB (komponen R, G, dan B terpisah)
    function toggleHist(~, ~)
        if length(size(img)) > 2
            if greyHist
                greyHist = false;
                plotRGBHistogram(axesHistogramInput, img);
                if ~isempty(enhancedImg)
                    plotRGBHistogram(axesHistogramEnhanced, enhancedImg);
                end
            else
                greyHist = true;
                plotHistogram(axesHistogramInput, img);
                if ~isempty(enhancedImg)
                    plotHistogram(axesHistogramEnhanced, img);
                end
            end
        end
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
    
    function enhanceImage(~, ~)
        if ~isempty(img)
            % Get enhancement operation yang dipilih
            enhancementIdx = get(enhancementMenu, 'Value');
            hasChannel = length(size(img)) > 2;
            if hasChannel & lowerRed ~= -1
                doubleImg = double(img);
                % gray = uint8(((red/100) .* doubleImg(:, :, 1) + (green/100) .* doubleImg(:, :, 2) + (blue/100) .* doubleImg(:, :, 3)) ./ ((red + green + blue)/100));
                gray = (img(:, :, 1) <= upperRed & img(:, :, 1) >= lowerRed & img(:, :, 2) <= upperGreen & img(:, :, 2) >= lowerGreen & img(:, :, 3) <= upperBlue & img(:, :, 3) >= lowerBlue) .* 255;
            elseif hasChannel
                gray = im2gray(img);
            else
                gray = img;
            end
            
            switch enhancementIdx
                case 1
                    enhancedImg = fillHoles(enhancedImg);
                case 2
                    enhancedImg = segmentFunction(img, enhancedImg);
                case 3
                    enhancedImg = laplaceFunction(gray);
                case 4
                    enhancedImg = logFunction(gray, a);
                case 5
                    enhancedImg = sobelFunction(gray);
                case 6
                    enhancedImg = prewitt(gray);
                case 7
                    enhancedImg = roberts(gray);
                case 8
                    enhancedImg = canny(gray);
            end
            
            axes(axesImageEnhanced);
            imshow(enhancedImg);
            if greyHist
                plotHistogram(axesHistogramEnhanced, enhancedImg);
            else
                plotRGBHistogram(axesHistogramEnhanced, enhancedImg);
            end
        else
            msgbox('Please load an image first.', 'Error', 'error');
        end
    end
    
    function plotHistogram(axesHandle, image)
        axes(axesHandle);
    
        % Inisialisasi histogram
        grayHistogram = getHist(image);
    
        % Display histogram
        bar(0:256 - 1, grayHistogram); % 0-255
        title('Histogram');
        xlabel('Pixel Value');
        ylabel('Frequency');
    end

    function plotRGBHistogram(axesHandle, image)
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
    end


end

% Fungsi untuk menghitung histogram dari gambar
function hist = getHist(img)
    [rows, cols] = size(img); % Mendapatkan dimensi gambar
    levels = 256; % Menentukan banyaknya level keabuan pada gambar
    hist = zeros(1, levels); % Inisialisasi histogram dengan nilai 0
    for r = 1:rows
        for c = 1:cols
            val = img(r, c); % Mengambil nilai keabuan dari pixel
            hist(val+1) = hist(val+1) + 1; % Menambahkan frekuensi keabuan ke histogram
        end
    end
end

function filledImg = fillHoles(img)
    closedImg = imclose(img, strel('line',10,0));
    binary = imbinarize(closedImg, "global");
    % binary = imbinarize(img, "global");
    filledImg = imfill(binary, "holes");
    filledImg = imopen(filledImg, strel(ones(3,3)));
end

function segmentImg = segmentFunction(img, holes)
    binary = fillHoles(holes);
    segmentImg = uint8(double(img) .* double(binary));
end

function laplaceImg = laplaceFunction(inputImg)
    filter = [0 1 0; 1 -4 1; 0 1 0];
    laplaceImg = uint8(convn(double(inputImg), double(filter), 'same'));
end

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

function sobelImg = sobelFunction(inputImg)
    Sx = [-1 0 1; -2 0 2; -1 0 1];
    Sy = [1 2 1; 0 0 0; -1 -2 -1];
    Jx = conv2(double(inputImg), double(Sx), 'same');
    Jy = conv2(double(inputImg), double(Sy), 'same');
    sobelImg = uint8(sqrt(Jx.^2 + Jy.^2));
end

function res = roberts(image)
    image = im2gray(image);
    r1 = convolution(image, [1 0; 0 -1]);
    r2 = convolution(image, [0 1; -1 0]);
    res = abs(r1) + abs(r2);
    res = uint8(res);
end

function res = prewitt(image)
    image = im2gray(image);
    Jx = convolution(image, [-1 0 1; -1 0 1; -1 0 1]);
    Jy = convolution(image, [-1 -1 -1; 0 0 0; 1 1 1]);
    res = sqrt(Jx.^2 + Jy.^2);
    res = uint8(res);
end

function res = canny(image)
    res = im2uint8(edge(image, "canny"));
end