% Load data
nii_t1 = double(niftiread('data/T1_014_0000.nii.gz'));
nii_t1gd = double(niftiread('data/T1Gd_014_0000.nii.gz'));
nii_mask = niftiread('data/T1_014_label.nii.gz');  % Aneurysm mask

% Apply aneurysm mask to T1 image
masked_img = nii_t1 .* double(nii_mask);

% lumen: dark region
lumen_threshold = 0.3 * max(masked_img(:));  % ~30% of max
lumen_mask = masked_img < lumen_threshold;

% Wall mask = label - lumen
wall_mask = nii_mask & ~lumen_mask;

% Create surface from wall mask
fv = isosurface(wall_mask, 0.5);
fv = smoothpatch(fv, 1, 10);  % Optional smoothing

% Normalize masked T1 by max T1gd in aneurysm
max_t1gd = max(nii_t1gd(nii_mask > 0));
nii_t1_norm = masked_img / max_t1gd;

% Interpolator for normalized T1
[x, y, z] = ndgrid(1:size(nii_t1_norm,1), 1:size(nii_t1_norm,2), 1:size(nii_t1_norm,3));
interpFunc = griddedInterpolant(x, y, z, nii_t1_norm, 'linear', 'nearest');

% Compute normals
normals = isonormals(double(wall_mask), fv.vertices);

% Sample SI along normals
max_sis = zeros(size(fv.vertices, 1), 1);
step = 0.1;
for i = 1:size(fv.vertices, 1)
    vertex = fv.vertices(i,:);
    normal = normals(i,:) / (norm(normals(i,:)) + eps);

    sis = [];
    for t = 0:step:1.2
        sample_point = vertex + t * normal;
        sis(end+1) = interpFunc(sample_point(1), sample_point(2), sample_point(3));
    end
    max_sis(i) = max(sis);
end

% Visualize
figure;
trisurf(fv.faces, fv.vertices(:,1), fv.vertices(:,2), fv.vertices(:,3), ...
    max_sis, ...
    'FaceColor', 'interp', 'EdgeColor', 'none');
colormap parula;
colorbar;
clim([0 1]);  % Adjust range as needed
axis equal;
view(3);
lighting gouraud;
camlight headlight;
material dull;
title('T1 * Mask normalized by max T1GD');
