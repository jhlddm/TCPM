function my_test_seq(baby_name)

if nargin == 0
    baby_name = '\n김현정아기1_02.MP4';
end

desired_im_size = 500000;

addpath ../full_v2/detection
load '../full_v2/cache/multipie_final.mat';

im_dir = ['/home/jongho/Dropbox/Lab/Projects/BabyFace/data/snapshots_v2/' baby_name];
% im_dir = ['/mnt/sdc/babyface/DPM_v2/snapshots/' sprintf('viewpoint_%02d', vp)];
result_dir = '/mnt/sdc/babyface/DPM_v2/results/';

im_files = dir(fullfile(im_dir, '*.jpg'));

% detection 결과와 소요 시간을 저장하는 변수들
tc_seq = zeros(length(im_files), length(model.components));
bs_seq = cell(length(im_files), 1);

p_level = 0;

for iidx = 1:length(im_files)
    
    im_name = im_files(iidx).name;
    
    fprintf('%2d/%2d %30s\n', iidx, length(im_files), im_name);
    
    im_path = fullfile(im_dir, im_name);
    im = imread(im_path);
    [h, w, ~] = size(im);
    r = sqrt(desired_im_size/(h*w));
    
    im = imresize(im, r);
    
    if p_level == 0
        [bs, tc_seq(iidx, :)] = detect_test_seq(im, model, model.thresh);
        p_level = bs(1).level;
    else
        [bs, tc_seq(iidx, :)] = detect_test_seq(im, model, model.thresh, p_level);
    end
    
    if ~isempty(bs)
        
        bs = clipboxes(im, bs);
        bs = nms_face(bs,0.3);
        
        showboxes(im, bs(1));
        
        % 박스를 저장 (showboxes() 함수에 넣을 때에는 bs(1)로 넣어야 함)
        bs_seq{iidx} = bs;
    else
        
        fprintf('failed\n');
    end
end

save(fullfile(result_dir, sprintf('record_%s_seq.mat', baby_name)), 'tc_seq', 'bs_seq');

function boxes = clipboxes(im, boxes)
% Clips boxes to image boundary.
imy = size(im,1);
imx = size(im,2);
for i = 1:length(boxes),
    b = boxes(i).xy;
    b(:,1) = max(b(:,1), 1);
    b(:,2) = max(b(:,2), 1);
    b(:,3) = min(b(:,3), imx);
    b(:,4) = min(b(:,4), imy);
    boxes(i).xy = b;
end
