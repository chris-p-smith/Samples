%%%%%%%%%%%%%%%%%
% Final Project %
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Introduction:
% 
% The aim of the code is to detect skin across multiple lighting and tone
% conditions. The theory behind this code is to use the YCbCr color map.
% Skin tones are clustered in this map. Compared to RGB, YCbCr only has a
% small range where skin is represented. An outline of the code will
% explain the step-by-step process.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
% Outline %
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Reading the images
%   - The images are called into the program
%   - Their sizes are recorded
%   - Masks of the same size as their respective images are called
%   - The images are converted to YCbCr, and the Cb and Cr variables are
%   declared
% 2. Detecting flesh
%   - The command 'find' detects pixels that are of the proper value
%   - 77<Cb<127 and 133<Cr<173
%   - In order to have the values fit into a double value type, they are
%   divided by 255. This allows the final masking to occur, as it is
%   required to be in double type.
%   - The command puts the found pixels in a matrix corresponding to their
%   points in the referenced image
%   - The number of rows of found values will constitute a break condition
% 3. Masks
%   - Two for loops go through each flagged pixel and mark it as a white
%   pixel on the matrix of zeros declared earlier. This will be used as the
%   mask
%   - When the for loops finish, the code closes off any white spaces that
%   are not open enough using the 'bwareaopen' command.
% 4. Masking the images
%   - Using dot products, the images are restricted to areas where flesh is
%   detected.
% 5. Showing the output
%   - The final images are showed next to their inputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reading the images
    % Images
    tic;
I1 = im2double(imread('benetton.jpg'));
I2 = im2double(imread('Benetton-2.jpg'));
    % Sizes
h1 = size(I1,1);
w1 = size(I1,2);
h2 = size(I2,1);
w2 = size(I2,2);
    % Masks
mask1 = zeros(h1,w1);
mask2 = zeros(h2,w2);
    % Conversion
I1c = rgb2ycbcr(I1);
I2c = rgb2ycbcr(I2);
    % Variables
cb1 = I1c(:,:,2);
cb2 = I2c(:,:,2);
cr1 = I1c(:,:,3);
cr2 = I2c(:,:,3);

% Detecting Flesh
    % Find command
[x1,y1] = find(cb1>=77/255 & cb1 <=127/255 & cr1>=133/255 & cr1<=173/255);
[x2,y2] = find(cb2>=77/255 & cb2 <=127/255 & cr2>=133/255 & cr2<=173/255);
    % Break conditions
xlim1 = size(x1,1);
xlim2 = size(x2,1);
% Masks
    % For loop 1
for ii = 1:xlim1
    mask1(x1(ii),y1(ii)) = 1;
end
    % For loop 2
for ii = 1:xlim2
    mask2(x2(ii),y2(ii)) = 1;
end
    % Finding larger white spaces
I1out = im2double(bwareaopen(mask1, 3000));
I2out = im2double(bwareaopen(mask2, 3000));

% Masking images
    % Image 1
I1f(:,:,1) = I1out .* I1(:,:,1);
I1f(:,:,2) = I1out .* I1(:,:,2);
I1f(:,:,3) = I1out .* I1(:,:,3);
    % Image 2
I2f(:,:,1) = I2out .* I2(:,:,1);
I2f(:,:,2) = I2out .* I2(:,:,2);
I2f(:,:,3) = I2out .* I2(:,:,3);
% Showing the output
subplot(2,2,1), imshow(I1);
subplot(2,2,3), imshow(I2);
subplot(2,2,2), imshow(I1f);
subplot(2,2,4), imshow(I2f);
    toc;
%%%%%%%%%%%%%%
% Conclusion %
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program is highly efficient, and accurate to most colors of skin. 
% There are some issues with it, however. First is that the range of Cb and
% Cr used to detect flesh also detect skin also detects some colors of
% clothing in the picture that is close to skin tone (e.g. light reds,
% light yellows). Attempts were made to convert the color values to HSV, 
% but adjusting these values had no discernable change on the image.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
