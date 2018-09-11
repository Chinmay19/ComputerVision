function [ pointViewMatrix,featurePoints, images] = PointViewMatrix( imageFilePath, ifVisualize)
disp('Construct point view matrix...')
imagesId=1:19;
featurePoints={};
descriptors={};
matches={};
images={};
pointViewMatrix=[];
%% Initialize the point View matrix for the first frame
disp('Initialize the point view matrix...')
for i=1:2
    disp(strcat('Read image 8ADT',num2str(8585+imagesId(i))))
    singleImagePath=strcat(imageFilePath,num2str(8585+imagesId(i)));
    imageData = imread(strcat(singleImagePath,'.JPG'));
    [fp,des,imageData]=FeatureDescriptorDetection(imageData,1,i);
    
    images{i}=imageData;
    featurePoints{i}=fp;
    descriptors{i}=des;
end
% initialize the first two rows of pointViewMatrix   
imageA=images{1};
imageB=images{2};
fa=featurePoints{1};
da=descriptors{1};
fb=featurePoints{2};
db=descriptors{2};
[newMatches]=NormalizedEightPointRansacMatch(fa,da,fb,db,1,imageA, imageB,1);
pointViewMatrix(1,1:size(newMatches,2))= newMatches(1,:);
pointViewMatrix(2,1:size(newMatches,2))= newMatches(2,:);
pairMatches{1}=newMatches;
%% construct the point view matrix for following frames
for i=3:19
    tic
    disp(strcat('Read image 8ADT',num2str(8585+imagesId(i))))
    singleImagePath=strcat(imageFilePath,num2str(8585+imagesId(i)));
    imageData = imread(strcat(singleImagePath,'.JPG'));
    [fp,des,imageData]=FeatureDescriptorDetection(imageData,1,i);
    images{i}=imageData;
    featurePoints{i}=fp;
    descriptors{i}=des;     
    %% find matches for next frame
    imageA=images{i-1};
    imageB=images{i};
    fa=featurePoints{i-1};
    da=descriptors{i-1};
    fb=featurePoints{i};
    db=descriptors{i};
    [currentMatches]=NormalizedEightPointRansacMatch(fa,da,fb,db,1,imageA, imageB,i);
    pairMatches{i-1}=currentMatches;
    % previous pari match
    previousMatches=pairMatches{i-2};
    % find matches that are not in previous matches
    notPreviousMatches=setdiff(currentMatches(1,:),previousMatches(2,:));
    pointViewMatrix(i-1,size(pointViewMatrix,2)+(1:length(notPreviousMatches)))=notPreviousMatches;

    % find the intersection of feature points
    [C, IA, IB] = intersect(currentMatches(1,:),pointViewMatrix(i-1,:));
    pointViewMatrix(i,IB) = currentMatches(2,IA);    
    toc
end
%% construct the point view matrix for last frame
imageA=images{1};
imageB=images{19};
fa=featurePoints{1};
da=descriptors{19};
fb=featurePoints{1};
db=descriptors{19};
[currentMatches]=NormalizedEightPointRansacMatch(fa,da,fb,db,1,imageA, imageB,19);
pairMatches{19}=currentMatches;
% previous pari match
previousMatches=pairMatches{18};
% find matches that are not in previous matches
notPreviousMatches=setdiff(currentMatches(1,:),previousMatches(2,:));
pointViewMatrix(19,size(pointViewMatrix,2)+(1:length(notPreviousMatches)))=notPreviousMatches;
% find the intersection of feature points
[C, IA, IB] = intersect(currentMatches(1,:),pointViewMatrix(1,:));
pointViewMatrix(1,IB) = currentMatches(2,IA);     

%% visulization for checking
if(ifVisualize)
    for k=2:2
        imageA=images{k};
        imageB=images{k+1};
        imageC=images{k+2};
        fa=featurePoints{k};
        fb=featurePoints{k+1};
        fc=featurePoints{k+2};
        pointsInA=pointViewMatrix(k,:);
        pointsInB=pointViewMatrix(k+1,:);
        pointsInC=pointViewMatrix(k+2,:);

        pointsBothInAB=pointsInB(find(pointsInA~=0));
        pointsOnlyInB=pointsInB(find(pointsInA==0));

        pointsInA=pointsInA(find(pointsInA~=0));
        pointsOnlyInB=pointsOnlyInB(find(pointsOnlyInB~=0));
        pointsBothInAB=pointsBothInAB(find(pointsBothInAB~=0));
        pointsInC=pointsInC(find(pointsInC~=0));

        pointsA=fa(1:2,pointsInA);
        pointsB1=fb(1:2,pointsBothInAB);
        pointsB2=fb(1:2,pointsOnlyInB);
        pointsC=fc(1:2,pointsInC);
        imshow([imageA imageB imageC])
        hold on
        plot(pointsA(1,:),pointsA(2,:),'o','MarkerSize',10,...
            'MarkerEdgeColor','red',...
            'MarkerFaceColor',[1 .6 .6])
        hold on
        plot(pointsB1(1,:)+size(imageA,2),pointsB1(2,:),'o','MarkerSize',10,...
            'MarkerEdgeColor','red',...
            'MarkerFaceColor',[1 0 0])
            hold on
        plot(pointsB2(1,:)+size(imageA,2),pointsB2(2,:),'o','MarkerSize',10,...
            'MarkerEdgeColor','red',...
            'MarkerFaceColor',[0 1 0])
                hold on
        plot(pointsC(1,:)+2*size(imageA,2),pointsC(2,:),'o','MarkerSize',10,...
            'MarkerEdgeColor','red',...
            'MarkerFaceColor',[1 .6 .6])
    end
end
end

