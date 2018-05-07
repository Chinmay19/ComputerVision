clear all;
close all;

P = 3;

img_left = single(rgb2gray(imread('left.jpg')));
img_right = single(rgb2gray(imread('right.jpg')));
[frames_left, desc_left] = vl_sift(img_left);
[frames_right, desc_right] = vl_sift(img_right);

[matches, scores] = vl_ubcmatch(desc_left, desc_right);
count = [];
x1 = length(matches(1,:));
seed=randperm(x1,50);
perm=randperm(50,P);

for iteration = 1:1:20
    x_left = frames_left(1, matches(1,seed(perm)));
    y_left = frames_left(2, matches(1,seed(perm)));
    x_right = frames_right(1,matches(2,seed(perm)));
    y_right = frames_right(2,matches(2,seed(perm)));

    % create a matrix A and  to find affine transformation parameters 

    A = zeros(6);
    for i=1:2:6
        A(i,:)=[x_left((i+1)/2),y_left((i+1)/2),0,0,1,0];
        A(i+1,:)=[0,0,x_left((i+1)/2),y_left((i+1)/2),0,1];
    end

    

    % create vector b
    b = [];
    for i = 1:1:3
        b = [b;x_right(i);y_right(i)];
%         b = [b;temp];
    end
    %fit the model
    x(:,iteration) = pinv(A)* b;
    
%   transforming paramters for all points
    x_left_trans = frames_left(1, matches(1,seed));
    y_left_trans = frames_left(2, matches(1,seed));
    A_trans = zeros(50,6);
    for i = 1:2:100
        A_trans(i,:)=[x_left_trans((i+1)/2),y_left_trans((i+1)/2),0,0,1,0];
        A_trans(i+1,:)=[0,0,x_left_trans((i+1)/2),y_left_trans((i+1)/2),0,1];
    end
%   calculating new b vector points
    b_calculated = [];
    b_calculated = A_trans*x(:,iteration);
    for i = 1:2:100
        x_right_calculated((i+1)/2) = b_calculated(i);
        y_right_calculated((i+1)/2) = b_calculated(i+1);
    end
    
    b_actual = [];
    x_right_actual = frames_right(1, matches(2,seed));
    y_right_actual = frames_right(2, matches(2,seed));
    for i = 1:50
        b_actual = [b_actual;x_right_actual(i);y_right_actual(i)];
    end
    
    calculated = [x_right_calculated;y_right_calculated;ones(1, size(x_left_trans,2))];
    actual = [x_right_actual;y_right_actual;ones(1, size(x_left_trans,2))];
    
    threshold = 10;
    inliers = find(sqrt(sum((calculated - actual).^2)) < threshold);

    count(iteration) = size(inliers, 2);
    
end

[val, index] = max(count);
Tr = x(:,index);

T = [Tr(1) Tr(2) Tr(5);...
    Tr(3) Tr(4) Tr(6);...
    0 0 1];
transform = maketform('affine', T');
img_left_transformed = imtransform(img_left, transform, 'bicubic');

transform = maketform('affine', inv(T)');
[img_right_transformed,xdata,ydata] = imtransform(img_right, transform, 'bicubic');
figure;
subplot(2,2,1), imshow(img_left,[]), title('left');
subplot(2,2,2), imshow(img_right,[]), title('right');
subplot(2,2,3), imshow(img_left_transformed,[]), title('Transformed left');
subplot(2,2,4), imshow(img_right_transformed,[]), title('Transformed right');

B = imtransform(img_right,transform,'XData',[1 (size(img_right,2)+size(img_left,2))],...
   'YData',[1 max(size(img_left,1),size(img_right,1))]);
% figure;imshow(B,[]);
[Bi,Bj]=size(B);
B(1:size(img_left,1),1:size(img_left,2))=B(1:size(img_left,1),1:size(img_left,2))+img_left(1:size(img_left,1),1:size(img_left,2)).*(B(1:size(img_left,1),1:size(img_left,2))==0);
figure; imshow(B,[]);
    
    
    
    
    
%     img = appendimages(img_left, img_right);
%     figure('Position', [100 100 size(img,2) size(img,1)]);
%     imagesc(img);
%     hold on;
%     cols1 = size(img_left,2);
%     line([(x_left(1,1) y_left(1,1)) ((b_dash(1,1)+cols1) C(b_dash(1,1)+cols1))], 'Color', 'black');
%     % line(x_left(1,1) y_left(1,1), x_right(1,1) y_right(1,1);
%     hold off;
    














