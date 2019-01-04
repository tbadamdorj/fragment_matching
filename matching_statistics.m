% match statistics

load('stats_big_ratio_margin.mat');

% save images that don't have matches 
% save how many images are small (less than 200*200) 

num_small = 0;
num_big = 0; 
num_small_matches = 0; 
num_matches = 0; 
num_big_matches = 0; 


for i=1:size(stats, 1)
    img = imread(stats{i,3}); 
    gray_img = rgb2gray(img);
    [bw, gray, area] = choose_biggest_CC(gray_img);

    area_thresh = 200*200;
    
    if area < area_thresh 
        num_small = num_small + 1; 
        close; 
        figure(); imshow(gray);
    else
        num_big = num_big + 1; 
    end
    
    if ~isempty(stats{i,4})
        num_matches = num_matches + 1; 
        if area < area_thresh
            num_small_matches = num_small_matches + 1; 
        else 
            num_big_matches = num_big_matches + 1;
        end
    else 
        if area < area_thresh
            imwrite(img, fullfile('RESULTS', 'NO_MATCHES', 'small', stats{i,1}))
        else 
            imwrite(img, fullfile('RESULTS', 'NO_MATCHES', 'big', stats{i,1}))
        end
    end
end

fprintf('total matches: %d\n', num_matches); 
fprintf('num_small: %d\n', num_small); 
fprintf('num_small_matches: %d\n', num_small_matches); 
fprintf('num big: %d\n', num_big); 
fprintf('num big matches: %d\n', num_big_matches); 
