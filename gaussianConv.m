function imOut = gaussianConv(image_path, sigma_x, sigma_y)
%Function to calculate 2D gaussian filter without built-in matlab functions
%   read image and convert it to grayscale
%   apply 1D gaussian blur on X and Y axix separately.
%   combine two resultant vectors and 
%   do the convolution of input image with resultant 2D vector.
grey_img = im2double(rgb2gray(imread(image_path)));
 
% grey_img = rgb2gray(img);
subplot(2,2,1), imshow(grey_img), title('original image');
G1 = gaussian(sigma_x);
G1 = transpose(G1);
G2 = gaussian(sigma_y);

G = (G1 * G2);

imOut = conv2(grey_img,G);
z = max(max(imOut));
imOut = imOut ./ z ;
subplot(2,2,2), imshow(imOut), title('2D gaussian without inbuilt function');

test = imgaussfilt(grey_img, 5);
imOut = imresize(imOut,[512,512]);
subplot(2,2,3), imshow(test), title('2D gaussian with imgaussfilt');

diff = imsubtract(test, imOut);
subplot(2,2,4), imshow(diff), title('difference image');
end


