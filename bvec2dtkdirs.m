function [output_file,max_bval] = bvec2dtkdirs(path,filename)
 
bvecs = load([path filesep filename '.bvec']);
bvals = load([path filesep filename '.bval']);

output_file = [path filesep filename '_bvec_dtk.txt'];
fid =  fopen(output_file,'w+');
if fid < 0
	error(['Cannot open "' output_file '" to write!']);
end

for i=1:size(bvecs,2)
	fprintf(fid,'%.6f, %.6f, %.6f\n',bvecs(1,i),bvecs(2,i),bvecs(3,i));
end
fclose(fid);

max_bval = max(bvals);
