function classify_images()

close all;

% Number of viewpoints
num_of_vp = 7;

im_root_dir = '/home/jongho/Dropbox/Lab/Projects/BabyFace/data/snapshots_v2';
im_out_dir = '/mnt/sdc/babyface/DPM_v2';

subfolders = dir(fullfile(im_root_dir, '*.MP4'));

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

im_files = [];

% Make a list of image files.
for fidx = 1:length(subfolders)
    
    subfolder_name = subfolders(fidx).name;
    
    subfolder_dir = fullfile(im_root_dir, subfolder_name);
    sub_im_files = dir(fullfile(subfolder_dir, '*.jpg'));
    for iidx = 1:length(sub_im_files)
        sub_im_files(iidx).subfolder_name = subfolder_name;
    end
    im_files = [im_files; sub_im_files];
end

% Make a list of image files which are already classified.
ex_im_file_names = [];
for vp_num = 1:num_of_vp
    
    subfolder_dir = fullfile(im_out_dir, sprintf('viewpoint_%02d', vp_num));
    sub_im_files = dir(fullfile(subfolder_dir, '*.jpg'));
    
    for iidx = 1:length(sub_im_files)
        ex_im_file_names = [ex_im_file_names; {sub_im_files(iidx).name(1:end-4)}];
    end
end
    
figure;

% Do classification.
for iidx = 1:length(im_files)
        
    im_name = im_files(iidx).name;
    subfolder_dir = fullfile(im_root_dir, im_files(iidx).subfolder_name);
    im_path = fullfile(subfolder_dir, im_name);
    
    if ismember({im_name(1:end-4)}, ex_im_file_names)
        fprintf('[ %s ]: classified\n', im_name(1:end-4));
        continue;
    end
    
    % Read and show the image.
    im = imread(im_path);
    imagesc(im);

    fprintf('[ %s ]\n', im_name(1:end-4));

    % Viewpoint number
    vp_num = -1;
    while ~ismember(vp_num, 0:num_of_vp)
        
        % Viewpoint number
        vp_num = input('  -> ');
    end
    
    % Pass the inappropriate image.
    if vp_num == 0
        continue;
    end

    % Save the image to designated class folder.
    imwrite(im, fullfile(im_out_dir, sprintf('viewpoint_%02d', vp_num), im_name));
end

close all;

quit;