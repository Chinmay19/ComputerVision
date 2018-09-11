clear all
close all
clc
%% read the images
imageFilePath='./model_castle/8ADT';
[ pointViewMatrix,featurePoints, images] = PointViewMatrix( imageFilePath, 0);
save('deugData-2.mat');
%% get 3D point cloud
clear all
clc
load('deugData.mat')
imageSetNum=3;
pointsCloudSet={};
pointsVisibleId={};
% size(pointViewMatrix,1)
ifVisualize=1;
for i=1:2
    % compute the measurement matrix
    subBlock=pointViewMatrix(i:i+imageSetNum-1,:);
    subFeaturePoints=featurePoints(i:i+imageSetNum-1); 
    %% get the measurement matrix
    %get the points that are visible for all views
    visiblePointsId=ones(1,size(subBlock,2));
    for k=1:size(subBlock,1)
        tempId=subBlock(k,:)>0;
        visiblePointsId=visiblePointsId&tempId;
    end
    
    measurementMatrix=[];
    for k=1:size(subBlock,1)
        featurePointId=subBlock(k,visiblePointsId);
        measurementMatrix=[measurementMatrix;subFeaturePoints{k}(1:2,featurePointId);];
    end
    pointsVisibleId{i}=visiblePointsId;
    [S,M] = SFMEliminateAffineAmbiguity(measurementMatrix,1);
    pointsCloudSet{i}=S;
    if(ifVisualize)
    hold on
    plot3(S(1,:),S(2,:),S(3,:),'.','MarkerSize',10,...
            'MarkerEdgeColor',rand(1,3),...
            'MarkerFaceColor',rand(1,3))
    end
end
%% stitch 3D points
figure
pointSetA=pointsCloudSet{1};
plot3(pointSetA(1,:),pointSetA(2,:),pointSetA(3,:),'.','MarkerSize',5,...
            'MarkerEdgeColor',[0 0 1])
% hold on
% pointSetB=pointsCloudSet{2};
% plot3(pointSetB(1,:),pointSetB(2,:),pointSetB(3,:),'.','MarkerSize',10,...
%             'MarkerEdgeColor',[1 0 0])
for i=1:length(pointsCloudSet)-1
    pointSetA=pointsCloudSet{i};
    pointSetB=pointsCloudSet{i+1};
    pointSetAId=int8(pointsVisibleId{i});
    pointSetBId=int8(pointsVisibleId{i+1});
    %find the common 3D points
    commonId=pointsVisibleId{i}&pointsVisibleId{i+1};
    %get the common 3D points of setA and setB
    commonPointSetA=pointsVisibleId{i}&commonId;
    pointSetAId(commonPointSetA)=2;
    setAId1=pointSetAId(find(pointSetAId>0));
    setAId2=find(setAId1==2);
    
    commonPointSetB=pointsVisibleId{i+1}&commonId;
    pointSetBId(commonPointSetB)=2;
    setBId1=pointSetBId(find(pointSetBId>0));
    setBId2=find(setBId1==2);
    commonPointSetA= pointSetA(:,setAId2);
    commonPointSetB= pointSetB(:,setBId2);

    [d,Z,transform] = procrustes(commonPointSetA',commonPointSetB');
    Z=Z';
    transformedSetB=commonPointSetB'*transform.b*transform.T+transform.c;
    transformedSetB=transformedSetB';
%     plot3(commonPointSetA(1,:),commonPointSetA(2,:),commonPointSetA(3,:),'.','MarkerSize',10,...
%             'MarkerEdgeColor',[1 0 0])
%     hold on
%     plot3(commonPointSetB(1,:),commonPointSetB(2,:),commonPointSetB(3,:),'.','MarkerSize',10,...
%            'MarkerEdgeColor',[0 1 0])
%     hold on
%     plot3(Z(1,:),Z(2,:),Z(3,:),'.','MarkerSize',10,...
%            'MarkerEdgeColor',[0 0 1])
       
      hold on
      plot3(transformedSetB(1,:),transformedSetB(2,:),transformedSetB(3,:),'.','MarkerSize',5,...
            'MarkerEdgeColor',[0 0 1])
end


  