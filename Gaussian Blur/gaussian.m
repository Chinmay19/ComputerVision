function [G] = gaussian(sigma)
%Gaussian filter without built in funtions
%   
% prompt = 'input kernel size:';
% k = input(prompt);
X = -3*sigma : 1 : 3*sigma;

G = (1/(sigma*(sqrt(2*pi)))) * exp(-(X.^2)./(2*(sigma^2)));

end

