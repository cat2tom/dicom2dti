% matlab2nii Convert processed Matlab matrixes back into their NIIs
%            NIIs are an input too because most of the time we want to preserve
%            all the remaining information on the NII structure.
%
% TODO:
%	* I'm not really confident of this flips yet... but it works
%
% [b0nii,v1nii] = matlab2nii(b0nii,v1nii,b0,v11,v12,v13)
% 
% AUTHORS:                  Ferran Poveda (ferran.poveda@uab.cat)
% CREATION DATE:            31/01/2013
function [b0nii,v1nii] = matlab2nii(b0nii,v1nii,b0,v11,v12,v13)

b0nii.img = b0;

v1nii.img(:,:,:,1) = v12;
v1nii.img(:,:,:,2) = v11;
v1nii.img(:,:,:,3) = v13;

