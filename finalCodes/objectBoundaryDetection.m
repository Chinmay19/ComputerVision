function [boundary] = objectBoundaryDetection(image)
% tic
% debug image
% imageFilePath='./TeddyBear/';
% reizeScale=0.3;
% imageA = imread(strcat(imageFilePath,'obj02_001.jpg'));
% imageA=imresize(imageA,reizeScale);
% image = rgb2gray(imageA);
imageWidth=size(image,2);
imageHeight=size(image,1);
ROIFactor=0.15;
ROI=[imageWidth*ROIFactor, imageHeight*ROIFactor imageWidth*0.8, imageHeight*0.8];
image=imcrop(image,ROI);
scale=1;
disp('erosion and dilation, this may take some time...')
image=imresize(image,scale);
 
IaEdge= edge(image,'Canny');

imageProcessed=IaEdge;

se = strel('sphere',4);
imageProcessed=imdilate(imageProcessed, se);
imshow(imageProcessed);
 

se =strel('rectangle',[20 5]);
imageProcessed=imerode(imageProcessed, se);
imshow(imageProcessed);

se =strel('rectangle',[20 20]);
imageProcessed=imdilate(imageProcessed, se);
imshow(imageProcessed);
se =strel('rectangle',[10 10]);
imageProcessed=imdilate(imageProcessed, se);
imshow(imageProcessed);

se =strel('rectangle',[15 15]);
imageProcessed=imerode(imageProcessed, se);
imshow(imageProcessed);

imageProcessed=imfill(imageProcessed,'holes');
imshow(imageProcessed);

imshow(imageProcessed);
se =strel('rectangle',[5 5]);
imageProcessed=imdilate(imageProcessed, se);
imshow(imageProcessed);

% se = strel('sphere',8);
% imageProcessed=imdilate(IaEdge, se);s
% imshow(imageProcessed);

% stats = regionprops('table',bw,'Area');
% find contours and eliminate the background noises

A=regionprops(imageProcessed,'Area','ConvexImage','BoundingBox');
boundaryArea=[];
for k = 1:length(A)
   boundaryArea = [boundaryArea,A(k).Area];
 
end
[sortedArea sortedId]=sort(boundaryArea,'descend');

maxROI= A(sortedId(1)).BoundingBox;
 
imageProcessed=imcrop(imageProcessed,maxROI);

imshow(imageProcessed);
%detect boundary
[B,L] = bwboundaries(imageProcessed,'noholes');
boundarySize=[];
for k = 1:length(B)
   boundarySize = [boundarySize,size(B{k},1)];
end
[sortedSize sortedId]=sort(boundarySize,'descend');
boundary=B{sortedId(1)};
boundary(:,2)=boundary(:,2)+maxROI(1);
boundary(:,1)=boundary(:,1)+maxROI(2);

boundary=boundary *(1/scale);
 
boundary(:,2)=boundary(:,2)+imageWidth*ROIFactor;
boundary(:,1)=boundary(:,1)+imageHeight*ROIFactor;

end

