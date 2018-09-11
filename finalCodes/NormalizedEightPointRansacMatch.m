function [inlierMatches ] = NormalizedEightPointRansacMatch(fa,da,fb,db,ifVisualizeResult,imageA, imageB,saveNum)
disp('Runing Normalized Eight Point Ransac Match...');
%parameters
randomSetNum=8;% choose feature points randomly
distanceThreshold=2;
iterationThreshold=200;

%% compute the match
[matches, scores] = vl_ubcmatch(da, db) ;
matchedPointsA=fa(1:2,matches(1,:)');
matchedPointsB=fb(1:2,matches(2,:)');
%%  compute the fundamental matrix
inlierCount=[];
matchId=[];
FMatrix={};
inliersId={};
for iteration=1:iterationThreshold
    randomId=randperm(size(matchedPointsA,2),randomSetNum);
    matchSetA=matchedPointsA(:,randomId);
    matchSetB=matchedPointsB(:,randomId);
    
    [matchSetNormalizedA T]=pointsNormalization(matchSetA);
    matchSetNormalizedB=[];
    for k=1:size(matchSetB,2)
        normalizedPointTemp=T*[matchSetB(:,k);1];
        matchSetNormalizedB=[matchSetNormalizedB normalizedPointTemp(1:2)];
    end
    matchSetA=matchSetNormalizedA;
    matchSetB=matchSetNormalizedB;
    
%     check the normalization    
%     x=matchSetA(1,:);
%     y=matchSetA(2,:);
%     m=sum(x)/size(matchSetA,2);
%     n=sum(y)/size(matchSetA,2);
%     d=sum(sqrt((x-m).^2+(y-n).^2))/size(matchSetA,2);
    
    %construct n * 9 matrix
    NByNineMatrix=[];
    for i=1:randomSetNum
        x1=matchSetA(1,i); y1=matchSetA(2,i);x2=matchSetB(1,i); y2=matchSetB(2,i);
        tempRaw=[x1*x2 x1*y2 x1 y1*x2 y1*y2 y1 x2 y2 1];
        NByNineMatrix=[NByNineMatrix;tempRaw];
    end

    %% compute the foundamental matrix
    [U,S,V] = svd(NByNineMatrix);
    %find the smallest singular value
    vectorF=V(:,end);
    F=[vectorF(1:3)';vectorF(4:6)';vectorF(7:9)'];
    [UF,SF,VF]=svd(F);
    SF(end,end)=0;
    F=UF*SF*VF';
    F=T'*F*T;
    %% ransac algorithm to filter out the noises
    %Sampson distance
    inlierNum=0;
    inlierIdSingle=zeros(size(matchedPointsA,2),1);
    distanceTemp=[];
    for i=1:size(matchedPointsA,2)
        p1=matchedPointsA(:,i);
        p2=matchedPointsB(:,i);
        p1=[p1;1]';p2=[p2;1];
        tempFp2=F*p2;
        tempFTp2=F'*p2;
        d=(p1*F*p2)^2/(tempFp2(1)^2+tempFp2(2)^2+tempFTp2(1)^2+tempFTp2(2)^2);
%         if(d<500)
%         distanceTemp=[distanceTemp;d];
%         end
        if(d<distanceThreshold)
            inlierNum=inlierNum+1;
            inlierIdSingle(i)=1;
        end
    end
%    figure
%   histogram(distanceTemp,500)
 
inlierCount=[inlierCount;inlierNum];
matchId=[matchId;randomId];
FMatrix{iteration}=F;
inliersId{iteration}=inlierIdSingle;
end

%% get the best estimated fundamental matrix
[maxValue, maxId]=max(inlierCount);
bestSetA=matchedPointsA(:,matchId(maxId,:));
bestSetB=matchedPointsB(:,matchId(maxId,:));
bestF=FMatrix{maxId};
inlierMatches=matches(:,logical(inliersId{maxId}));
inlierPointsA=matchedPointsA(:,logical(inliersId{maxId}));
inlierPointsB=matchedPointsB(:,logical(inliersId{maxId}));

%% find the inliers of the matched points
pointsA=inlierPointsA;
pointsB=inlierPointsB;

%% visualize the result
if(ifVisualizeResult)
    figure
    imshow([imageA imageB])
    hold on
    plot(pointsA(1,:),pointsA(2,:),'o','MarkerSize',2,...
        'MarkerEdgeColor','red',...
        'MarkerFaceColor',[1 .6 .6])
    hold on
    plot(pointsB(1,:)+size(imageA,2),pointsB(2,:),'o','MarkerSize',2,...
        'MarkerEdgeColor','red',...
        'MarkerFaceColor',[1 .6 .6])
end
saveas(gcf,strcat(num2str(saveNum),'.png'))
close(gcf)
end

