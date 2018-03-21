clc;
clear all;
close all;

im = imread('landscape-a.jpg');
im = im2double(rgb2gray(im));

%imshow (im)
harris(im, 5);