clc;
clear all;
close all;

% G = gaussian(5)
% gaussianConv('image1.jpeg', 5,5);

% Gd = gaussianDer(G, 5);
test_img = im2double(rgb2gray(imread('image1.jpeg')));
[grad_mag, grad_orient] = imgradient(test_img);
subplot(2,1,1),imshow (grad_mag);
subplot(2,1,2), imshow(grad_orient, [-pi, pi]);
colormap (hsv);
colorbar;