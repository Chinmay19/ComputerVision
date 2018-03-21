img = imread('image1.jpeg');
imshow(img);
test= imgaussfilt(img, 0.1);
imshow(test);
