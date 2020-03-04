% Trevor Seyller Final Project

% read in file
scanned = imread('sheetmusic.png');

% convert to grayscale
gray = rgb2gray(scanned);

% binarize image
binary = imbinarize(gray);

% segment out one staff only

% get compliment to segment properly
staffcomp = imcomplement(binary);
[A b] = bwlabel(staffcomp);
[c, d] = find(A==2);
cd = [c d];

for e=1:size(cd, 1)
            % replace pixels in one component with black to
            % isolate only one staff
            binary(cd(e, 1), cd(e, 2)) = 1;
end

% Remove horizontal staff lines

% create column vector of sums of each row
rowsums = sum(binary,2);

% rows with lowest sums are staff line rows
% find indices of staff line rows
staffind = find(rowsums < 100);

% set all of the pixels in these rows in original image to be white
binary(staffind,:) = 1;
% set all of these rows in a separate image to white to be used as 
% staff line segments
lines = zeros(size(binary, 1), size(binary, 2));
lines(staffind,:) = 1;

% figure, imshow(lines);

% Get compliment of image for morphology and
% segmentation methods to work properly
comp = imcomplement(binary);

% Mathematical morhpology - closing
% using 1 column wide structuring element
% to fill holes where staff lines were

% Structuring element
SE = [1;1;1;1;1;1;1];

% Perform morphological closing
closed = imclose(comp, SE);

% Separate symbols into connected components
[L n] = bwlabel(closed);
%CC = bwconncomp(filled);

% Eliminate connected components which arent notes

% Get bounding box information for each connected component
stats = regionprops(L, 'BoundingBox');

% For loop putting all widths into an array for me to look at
widths = [];
heights = [];
for i=1:n
    % Get dimenseion of connected component
    width = stats(i).BoundingBox(3);
    height = stats(i).BoundingBox(4);
    if width < 15 | width > 50 | height < 92
        % create array of pixel coordinates of connected 
        % component with dimensions similar to quarter note symbols
        [r, c]=find(L==i);
        rc = [r c];
        % rc is array of coordinates of pixels in the component
        for j=1:size(rc, 1)
            % replace pixels in the component with black in
            % the original closed image
            closed(rc(j, 1), rc(j, 2)) = 0;
        end
    else 
        widths(i) = width;
        heights(i) = height;
    end
    
end

% figure, imshow(closed)
% disp(heights)

% Get lineheights of all staff line pixels
lineheights = [];

for f=1:size(lines, 1)
    for g=1:size(lines, 2)
        if lines(f,g) == 1
            lineheights = [lineheights f];
        end
    end
end

% get rid of duplicates and adjacent pixels 
% (end up with one height measure per staff line)
filtered = [];
k = lineheights(1);
filtered = [filtered k];
for h=2:size(lineheights,2)
    if lineheights(1, h) > (lineheights(1, h-1)+1)
        filtered = [filtered lineheights(h)];
    end
end

% identify height of top staff line
topline = filtered(1);

% identify distance between staff lines
linespace = filtered(2) - filtered(1);

for h=2:size(lineheights,2)
    if lineheights(1, h) > (lineheights(1, h-1)+1)
        filtered = [filtered lineheights(h)];
    end
end

% Loop through image locating top pixel in each note
[Notes z] = bwlabel(closed);

tops = zeros(z, 1);
for y=1:size(Notes,1)
    for x=1:size(Notes,2)
        if Notes(y,x) > 0
            if tops((Notes(y,x)), 1) == 0
                tops(Notes(y,x)) = y;
            elseif y < tops(Notes(y,x))
                tops(Notes(y,x)) = y;
            end
        end
    end
end

% Translate height values into notes on scale
result = [];
for w=1:size(tops,1)
    v = tops(w);
    if v < 60
        result = [result 'G '];
    elseif v < 72
        result = [result 'F '];
    elseif v < 84
        result = [result 'E '];
    elseif v < 95
        result = [result 'D '];
    elseif v < 107
        result = [result 'C '];
    elseif v < 118
        result = [result 'B '];
    elseif v < 130
        result = [result 'A '];
  
    end
end
display (result);

