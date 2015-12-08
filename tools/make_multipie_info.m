function make_multipie_info()

im_root_dir = '/mnt/sdc/babyface/DPM_v2/snapshots_cropped';
num_of_vp = 7;

% multipie를 가져온다. 없으면 새로 생성함.
try
    load my_multipie;
catch
    multipie = struct('images', cell(num_of_vp, 1), 'nlandmark', cell(num_of_vp, 1));
end

% 어느 viewpoint에 대해 사진 리스트를 작성할 것인지 입력함.
target_vp = 0;
while ~ismember(target_vp, 1:num_of_vp)
    target_vp = input('\nTarget viewpoint: ');
end

% subfolder name
sf_name = sprintf('viewpoint_%02d', target_vp);

im_files = dir(fullfile(im_root_dir, sf_name, '*_cropped.jpg'));

% 사진 한장씩 보여주면서 learning set에 넣을지 선택하도록 함.
photos_in_use = cell(0, 1);

close all;
figure;
for imidx = 1:length(im_files)
    
    im_path = fullfile(im_root_dir, sf_name, im_files(imidx).name);
    im = imread(im_path);
    imagesc(im);
    axis equal;
    fprintf('%3d/%3d [%s] -> ', imidx, length(im_files), im_files(imidx).name(1:end-4));
    
    % 오른쪽 -> O, 왼쪽 -> X
    [x, ~] = ginput(1);
    if x > size(im, 2) || x < 0
        confirm = input('\nConfirm (0 or 1): ');
        if confirm
            fprintf('Exit!\n');
            break;
        else
            continue;
        end
    elseif x >= size(im, 2)/2
        photos_in_use(end+1, 1) = {im_files(imidx).name(1:end-4)};
        fprintf('IN (%d)\n', length(photos_in_use));
    else
        fprintf('OUT\n');
    end
end

if size(photos_in_use, 1)
    multipie(target_vp).images = photos_in_use;
    fprintf('\nSet of viewpoint %d updated\n', target_vp);
else
    fprintf('\nNothing changed updated\n');
end

% nlandmark는 모두 68로 채워넣는다.
for imidx = 1:length(photos_in_use)
    multipie(imidx).nlandmark = 68;
end

save('my_multipie.mat', 'multipie');

fprintf('Completed! (%d photos are selected)\n\n', length(photos_in_use));

close all;