function crop_snapshot_lowerright()

im_root_dir = '/mnt/sdc/babyface/DPM_v2/snapshots_cropped';
im_out_dir = '/mnt/sdc/babyface/DPM_v2/snapshots_cropped';

num_of_vp = 7;

% Make directories which don't exist.
fprintf('Check directories for outputs.\n');
for vpidx = 1:num_of_vp
    if ~exist(fullfile(im_out_dir, sprintf('viewpoint_%02d', vpidx)), 'dir')
        mkdir(fullfile(im_out_dir, sprintf('viewpoint_%02d', vpidx)));
        fprintf('%s: created\n', fullfile(im_out_dir, sprintf('viewpoint_%02d', vpidx)));
    else
        fprintf('%s: existing\n', fullfile(im_out_dir, sprintf('viewpoint_%02d', vpidx)));
    end
end

photo_subfolders = dir(fullfile(im_root_dir, 'viewpoint*'));
subfolder_names = cell(length(photo_subfolders), 1);
for sfidx = 1:length(photo_subfolders)
    subfolder_names(sfidx) = {photo_subfolders(sfidx).name};
end

close all;
figure;

for vpidx = 1:length(subfolder_names)
    
    sf_name = subfolder_names{vpidx};
    sf_dir = fullfile(im_root_dir, sf_name);
    
    fprintf('\n[Class: %s]\n\n', sf_name);
    
    im_files = dir(fullfile(sf_dir, '*_upperleft.jpg'));
    
    for imidx = 1:length(im_files)
        ulc_im_path = fullfile(sf_dir, im_files(imidx).name);
        c_im_path = fullfile(sf_dir, [im_files(imidx).name(1:end-14) '_cropped.jpg']);
        
        % Skip if it is already existing file.
        if exist(c_im_path, 'file')
            fprintf('  %3d/%3d  %-30s already done\n', imidx, length(im_files), im_files(imidx).name);
            continue;
        else
            fprintf('  %3d/%3d  %-30s ', imidx, length(im_files), im_files(imidx).name);
        end
        
        % Show an image.
        im = imread(ulc_im_path);
        imagesc(im);
        axis equal;
        hold on;
        
        [x2, y2] = ginput(1);
        plot(x2, y2, 'b.', 'MarkerSize', 10);
        
        im_cropped = im(1:round(y2), 1:round(x2), :);
        imwrite(im_cropped, c_im_path);
        
        fprintf('cropped\n');
    end
    
    fprintf('\nCompleted!\n');
end

close all;