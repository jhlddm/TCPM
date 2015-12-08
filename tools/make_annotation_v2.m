% my_multipie에 있는 이미지 리스트들에 대해 annotation을 생성한다.

function make_annotation_v2()

im_root_dir = '/mnt/sdc/babyface/DPM_v2/snapshots_cropped';
anno_dir = '/mnt/sdc/babyface/DPM_v2/annotations';

num_of_annotations = 30;
num_of_landmarks = 68;

% 이미지 파일 리스트 로딩
load my_multipie;

close all;
figure;

for vpidx = 1:length(multipie)
    
    fprintf('\nViewpoint # %d\n\n', vpidx);
    
    sf_name = sprintf('viewpoint_%02d', vpidx);
    sf_dir = fullfile(im_root_dir, sf_name);
    
    for imidx = 1:length(multipie(vpidx).images)
        
        if imidx > num_of_annotations
            break;
        end
        
        im_name = multipie(vpidx).images{imidx};
        im_path = fullfile(sf_dir, [im_name '.jpg']);
        
        fprintf('%3d/%3d [%s] ', imidx, length(multipie(vpidx).images), im_name);
        
        anno_path = fullfile(anno_dir, [im_name '_lm.mat']);
        if exist(anno_path, 'file')
            fprintf('already labeled\n');
            continue;
        end
        
        im = imread(im_path);
        
        imagesc(im);
        axis equal;
        hold on;
        
        pts = zeros(num_of_landmarks, 2);
        
        for lmidx = 1:num_of_landmarks
            [pts(lmidx, 1), pts(lmidx, 2)] = ginput(1);
            plot(pts(lmidx, 1), pts(lmidx, 2), 'y.', 'MarkerSize', 10);
        end
        
        save(anno_path, 'pts');
        
        fprintf('done\n');
    end
end

close all;

photo_subfolders = dir(fullfile(im_root_dir, 'viewpoint*'));
subfolder_names = cell(length(photo_subfolders), 1);
for sfidx = 1:length(photo_subfolders)
    subfolder_names(sfidx) = {photo_subfolders(sfidx).name};
end

close all;