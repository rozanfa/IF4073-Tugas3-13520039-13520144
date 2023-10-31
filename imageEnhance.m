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
    uicontrol('Style', 'pushbutton', 'String', 'Toggle Histogram', 'Position', [350, 540, 100, 30], 'Callback', @toggleHist);
    parText = uicontrol('Style', 'text', 'String', 'Parameters:', 'Position', [20, 510, 100, 20]);
    aText = uicontrol('Style', 'text', 'String', 'a:', 'Position', [20, 490, 20, 20], 'Visible', 'off');
    aField = uicontrol('Style', 'edit', 'Position', [40, 490, 60, 20], 'Callback', @setA, 'Visible', 'off');
    bText = uicontrol('Style', 'text', 'String', 'b:', 'Position', [120, 490, 20, 20], 'Visible', 'off');
    bField = uicontrol('Style', 'edit', 'Position', [140, 490, 60, 20], 'Callback', @setB, 'Visible', 'off');
    refButton = uicontrol('Style', 'pushbutton', 'String', 'Load Reference', 'Position', [350, 490, 100, 30], 'Callback', @loadRef);

    % Enhancement operation dropdown menu
    enhancementMenu = uicontrol('Style', 'popupmenu', 'String', ...
        {'None', 'Laplace', 'LoG', 'Sobel', 'Prewitt', 'Roberts', 'Canny'}, 'Position', [140, 530, 180, 30], 'Callback', @showHideParameters);
    
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
            case 1
                set(parText, 'Visible', 'on')
                % set(aText, 'Visible', 'on', 'String', 'a:');
                % set(aField, 'Visible', 'on');
                % set(bText, 'Visible', 'on', 'String', 'b:');
                % set(bField, 'Visible', 'on');
            case 2
                set(parText, 'Visible', 'on')                
                % set(aText, 'Visible', 'on', 'String', 'c:');
                % set(aField, 'Visible', 'on');
            case 3
                set(parText, 'Visible', 'on')
                % set(aText, 'Visible', 'on', 'String', 'c:');
                % set(aField, 'Visible', 'on');
                % set(bText, 'Visible', 'on', 'String', 'γ:');
                % set(bField, 'Visible', 'on');
            case 4
                set(refButton, 'Visible', 'on');
                % set(refText, 'Visible', 'on');
                % set(axesImageRef, 'Visible', 'on')
            case 5
                set(refButton, 'Visible', 'on');
                % set(refText, 'Visible', 'on');
                % set(axesImageRef, 'Visible', 'on')
            case 6
                set(refButton, 'Visible', 'on');
                % set(refText, 'Visible', 'on');
                % set(axesImageRef, 'Visible', 'on')
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
    
    function enhanceImage(~, ~)
        if ~isempty(img)
            % Get enhancement operation yang dipilih
            enhancementIdx = get(enhancementMenu, 'Value');
            
            switch enhancementIdx
                case 1
                    % No enhancement
                    enhancedImg = img;
                case 2
                    % Laplace
                    enhancedImg = brightenImageFunction(img, a, b);
                case 3
                    % LoG
                    enhancedImg = negativeImageFunction(img);
                case 4
                    % Sobel
                    enhancedImg = logTransformFunction(img, a);
                case 5
                    % Prewitt
                    enhancedImg = prewitt(img);
                case 6
                    % Robert
                    enhancedImg = robert(img);
                case 7
                    % Canny
                    enhancedImg = canny(img);
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

% Fungsi untuk meningkatkan kecerahan gambar
function brightenImg = brightenImageFunction(inputImg, a, b)
    brightenImg = uint8(a * inputImg + b); % Menggunakan transformasi linier
end

% Fungsi untuk mendapatkan negatif dari gambar
function negativeImg = negativeImageFunction(inputImg)
    negativeImg = 255 - inputImg; % Menginversi pixel terhadap nilai pixel tertinggi
end

% Fungsi untuk melakukan transformasi logaritmik pada gambar
function logTransformedImg = logTransformFunction(inputImg, c)
    logTransformedImg = uint8(255 * (c * log(1 + im2double(inputImg)))); % Menggunakan transformasi logaritmik
end

% Fungsi untuk melakukan transformasi power pada gambar
function powerTransformedImg = powerTransformFunction(inputImg, c, gamma)
    powerTransformedImg = uint8(255 * (c * (im2double(inputImg) .^ gamma))); % Menggunakan transformasi pangkat
end

% Fungsi untuk melakukan peregangan kontras pada gambar
function stretchedImg = contrastStretchingFunction(inputImg)
    q = quantile(inputImg, [0.25 0.75], "all"); % Mendapatkan kuartil pertama dan ketiga dari gambar
    % Di sini digunakan sedikit heuristik untuk mendapatkan rmin dan rmax
    % Karena jika kita mengambil dari nilai terendah dan tertinggi, banyak
    % gambar tidak akan diregangkan dengan bagus
    rmin = q(1) - abs(q(2)-q(1)); % Menentukan nilai minimum setelah peregangan
    rmax = q(2) + abs(q(2)-q(1)); % Menentukan nilai maksimum setelah peregangan
    stretchedImg = uint8((inputImg - rmin).*(255/(rmax-rmin))); % Melakukan peregangan kontras
end

% Fungsi untuk melakukan ekualisasi histogram
function equalizedImg = equalizeHistogram(inputImg)
    [rows, cols] = size(inputImg);

    grayHistogram = getHist(inputImg); % Menghitung histogram dari gambar

    % Hitung cumulative distribution function (CDF)
    cdf = cumsum(grayHistogram) / (rows * cols);
    
    equalizedImg = uint8(255 * cdf(inputImg + 1)); % Menggunakan CDF untuk ekualisasi histogram
end

% Fungsi untuk melakukan pencocokan histogram
function matchedImg = matchHistogram(inputImg, ref)
    if ~isempty(ref) % Memeriksa apakah gambar referensi ada
        [rows, cols, ~] = size(inputImg);
        [refRows, refCols, ~] = size(ref);
        if rows == refRows & cols == refCols % Memastikan ukuran gambar referensi sesuai dengan gambar utama
            imgHist = getHist(inputImg); % Mendapatkan histogram dari gambar utama
            refHist = getHist(ref); % Mendapatkan histogram dari gambar referensi

            imgCDF = cumsum(imgHist) / (rows * cols); % Menghitung CDF dari gambar utama
            refCDF = cumsum(refHist) / (rows * cols); % Menghitung CDF dari gambar referensi

            mappingFunction = zeros(1, 256);

            for i = 1:256
                [~, index] = min(abs(imgCDF(i) - refCDF)); % Mencari mapping terdekat antara CDF gambar utama dan gambar referensi
                mappingFunction(i) = index - 1;
            end

            % Apply histogram matching ke input image
            matchedImg = uint8(mappingFunction(inputImg + 1));
        else
            msgbox('Reference image size must match main image.', 'Error', 'error');
        end
    else
        msgbox('Please load a reference image first.', 'Error', 'error');
    end
end
