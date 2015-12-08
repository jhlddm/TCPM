function my_test(baby_name)

if nargin == 0
    baby_name = '박승춘아기2_02.MP4';
end

desired_im_size = 500000;

addpath ../full_v2/detection
load '../full_v2/cache/multipie_final.mat';

im_dir = ['/home/jongho/Dropbox/Lab/Projects/BabyFace/data/snapshots_v2/' baby_name];
% im_dir = ['/mnt/sdc/babyface/DPM_v2/snapshots/' sprintf('viewpoint_%02d', vp)];
% result_dir = ['/mnt/sdc/babyface/DPM_v2/results/' baby_name];

im_files = dir(fullfile(im_dir, '*.jpg'));

% detection 결과와 소요 시간을 저장하는 변수들
tc_seq = zeros(length(im_files), length(model.components));
bs_seq = cell(length(im_files), 1);

for iidx = 1:length(im_files)
    
    im_name = im_files(iidx).name;
    
    fprintf('%2d/%2d %30s\n', iidx, length(im_files), im_name);
    
    im_path = fullfile(im_dir, im_name);
    im = imread(im_path);
    [h, w, ~] = size(im);
    r = sqrt(desired_im_size/(h*w));
    
    im = imresize(im, r);
    
    % 소요 시간을 저장
    [bs, tc_seq(iidx, :)] = detect_test(im, model, model.thresh);
    
    if ~isempty(bs)
        
        bs = clipboxes(im, bs);
        bs = nms_face(bs,0.3);
        
        % 박스를 저장 (showboxes() 함수에 넣을 때에는 bs(1)로 넣어야 함)
        bs_seq{iidx} = bs;
        
%         close all;
%         showboxes(im, bs(1));
%         showlandmarks(im, bs(1));
%         saveas(gcf, fullfile(result_dir, [im_name(1:end-3) 'jpg']));
        
        fprintf(' done\n');
    else
        
        fprintf(' failed\n');
    end
end

% save(sprintf('record_%s', baby_name), 'tc_seq', 'bs_seq');

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
