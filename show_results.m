DATA_DIR = fullfile('DATA');
PAM_DIR = fullfile(DATA_DIR, 'all_PAMs_resized_quarter'); 

load(fullfile('RESULTS', 'B-279123.mat'));

SAVE_DIR = fullfile('RESULTS', 'B-279123');

if ~exist(SAVE_DIR)
    mkdir(SAVE_DIR) 
end

i=1;

%% normalize the scores and final score is average of all 
size1 = cell2mat(all_scores{i,4}(:,4));
size2 = cell2mat(all_scores{i,4}(:,5));
shape_distance = cell2mat(all_scores{i,4}(:,6));
siftflow_distance = cell2mat(all_scores{i,4}(:,7));

% heuristic bounds on valid_matches
valid_matches = all_scores{i,4}(size1 < 400 & size2 < 400 & shape_distance < 0.3, :);

% normalize all parameters: 
% 1) subtract the minimum
% 2) divide by new maximum
unnormalized = cell2mat(valid_matches(:,4:7)); 

if size(unnormalized,1) > 1
    % subtract minimum of each column
    minima = min(unnormalized); 

    for gesus=1:4
        unnormalized(:,gesus) = unnormalized(:,gesus) - minima(gesus);
    end

    % divide each row by its maxima
    maxima = max(unnormalized); 

    for mesus=1:4
        unnormalized(:,mesus) = unnormalized(:,mesus)./maxima(mesus);
    end
end

normalized = unnormalized;

valid_matches(:,4:7) = num2cell(normalized);

average_scores = mean(cell2mat(valid_matches(:,4:7)),2);

% rerank valid matches according to the mean scores
average_scores = num2cell(average_scores);
valid_matches(:,8) = average_scores(:);
valid_matches = sortrows(valid_matches,8);
size(valid_matches)



%% copy results to folder
num_results_to_show = 500; 

for i=1:num_results_to_show
    fprintf('%d/%d\n', i, num_results_to_show);

    mask_name = fullfile(DATA_DIR, 'OLD_SEGMENTED', 'plate',...
        valid_matches{i,2}, valid_matches{i,1});
    
    plate = imread(fullfile(PAM_DIR, strcat(valid_matches{i,2}, '.jpg')));
    
    mask = imread(mask_name);
    mask = imresize(mask, size(plate));
    mask_l = logical(mask);
    
    fragment = imread(valid_matches{i,3});    

    fused = cat(3, plate, mask + plate, plate);
    
    % imshow(fused);
    
    imwrite(fragment, fullfile(SAVE_DIR, 'fragment', strcat(num2str(i), '_' ,valid_matches{i,2},'.jpg')));
    imwrite(fused, fullfile(SAVE_DIR, 'location', strcat(num2str(i), '_' ,valid_matches{i,2},'.jpg')));
end
