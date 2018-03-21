function Gd = gaussianDer(sigma)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
G = gaussian(sigma);
X = -3*sigma : 1 : 3*sigma;
Gd = -(X .* (G / (sigma^2)));
end

