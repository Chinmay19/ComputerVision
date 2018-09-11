function [ normalizedPoints, T ] = pointsNormalization( points )
    %normalize the points
    x=points(1,:);
    y=points(2,:);
    m=sum(x)/size(points,2);
    n=sum(y)/size(points,2);
    d=sum(sqrt((x-m).^2+(y-n).^2))/size(points,2);
    T=[sqrt(2)/d    0           -m*sqrt(2)/d;
        0       sqrt(2)/d       -n*sqrt(2)/d;
        0           0               1];
    normalizedPoints=[];
    for i=1:size(points,2)
        normalizedPointTemp=T*[points(:,i);1];
        normalizedPoints=[normalizedPoints normalizedPointTemp(1:2)];
    end

end

