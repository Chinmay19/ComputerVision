function [S,M] = SFMEliminateAffineAmbiguity(Points,ifVisualize)
 
% % %Shift the mean of the points to zero using "repmat" command
average=sum(Points,2)/size(Points,2);
Points=Points-repmat(average,1,size(Points,2));
 
% % %singular value decomposition
[U,W,V] = svd(Points);

U = U(:,1:3);
W = W(1:3,1:3);
V = V(:,1:3);

M = U*sqrt(W);
S = sqrt(W)*V';
% figure 
% plot3(S(1,:),S(2,:),S(3,:),'.r');
save('M','M')

% % %solve for affine ambiguity
% A= 
%initialize the L
L0=zeros(3,3);

% Solve for L
L = lsqnonlin(@myfun,L0);
% Recover C
C = chol(L,'lower');
% Update M and S
M = M*C;
S = pinv(C)*S;

end

