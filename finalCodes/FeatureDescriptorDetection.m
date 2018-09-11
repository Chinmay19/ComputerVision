function [fa,da,imageA] = FeatureDescriptorDetection( imageA,ifVisualize,saveNum)
    %% for computation speed
    reizeScale=1;
    %% read the images
    imageA=imresize(imageA,reizeScale);
    %% do the edge detection to eliminate the feature points in background
    Ia = rgb2gray(imageA);
    boundaryImageA=objectBoundaryDetection(Ia);
    
    %% visualize boundary
    if(ifVisualize)
        figure
        imshow(imageA)
        hold on
        plot(boundaryImageA(:,2),boundaryImageA(:,1),'o','MarkerSize',0.5,...
            'MarkerEdgeColor','red',...
            'MarkerFaceColor',[1 .6 .6])
        saveas(gcf,strcat(num2str(saveNum),'Boundary.png'))
        close(gcf)
    end
    %% find the matched feature points
    Ia = single(rgb2gray(imageA));
    [fa, da] = vl_sift(Ia);
    % filter background noises
    inA = inpolygon(fa(1,:)',fa(2,:)',boundaryImageA(:,2),boundaryImageA(:,1));
    fa=fa(:,logical(inA));
    da=da(:,logical(inA));
end

