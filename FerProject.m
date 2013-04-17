function pproj=FerProject(point,axis)

naxis=axis/norm(axis);
proj=[naxis(1)*naxis(1), naxis(1)*naxis(2), naxis(1)*naxis(3); ...
      naxis(2)*naxis(1), naxis(2)*naxis(2), naxis(2)*naxis(3); ...
      naxis(3)*naxis(1), naxis(3)*naxis(2), naxis(3)*naxis(3)];
pproj=point*proj;

end
