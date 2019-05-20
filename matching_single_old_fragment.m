function [ all_scores ] = matching_single_old_fragment(old_fragment_name)
% for looking for new fragments using image of old fragment 
% old_fragment name is the name of the old_fragment within the DATA/OLD_QUERY folder 
% e.g. 'B-123456.png' 
% save set to 1 if we would like to save
% we don't want to save (otherwise we would have a bunch of small files
% saved with the name of each and every single new fragment that we
% compared to -- which is useless

% turn off the freaking warnings
warning('off', 'all');

RESULTS_DIR = fullfile('RESULTS');

old_fragment_path = fullfile('DATA', 'OLD_QUERY', old_fragment_name);
old_img = imread(old_fragment_path);
old_plate_name = regexprep(old_fragment_name, '(.*).png', '$1'); % define here by just getting the name of the image without the extension

% create a new "PAM" just with the name of the old image

OLD_SEG_DIR = fullfile('DATA', 'OLD_SEGMENTED', 'fragment', old_plate_name);
mkdir(OLD_SEG_DIR); 

% save to new 'fake PAM' 
imwrite(old_img, fullfile(OLD_SEG_DIR, strcat(old_plate_name, '.png'))); 

if exist(fullfile(RESULTS_DIR, strcat(old_plate_name, '.mat'))) ~= 0
    fprintf('loading previously saved file\n')
    load(fullfile(RESULTS_DIR, strcat(old_plate_name, '.mat')))
else
    all_scores = {old_fragment_name, old_plate_name, fullfile(OLD_SEG_DIR, strcat(old_plate_name, '.png')), {}};
end

PAM_list = {old_plate_name}; 

% get list of all new plates
% directory with new fragments 
NEW_SEG_DIR = '/specific/disk1/home/nachumd/DSS/DSS_Fragments/fragments_nojp'; 
new_plates = dir(NEW_SEG_DIR);
unwanted_idx = ismember({new_plates.name}, {'.', '..', '.DS_Store'});
new_plates = new_plates(~unwanted_idx);

% for each new image in each new plate, compare using the
% matching_single_fragment function, and concatenate to our existing
% results
for i=1:size(new_plates, 1)
    fprintf('%d/%d\n', i, size(new_plates,1)); 
    image_names = dir(fullfile(NEW_SEG_DIR, new_plates(i).name, '*.png'));
    for j=1:size(image_names, 1)
        % if it's a hidden file, skip it -- I don't know why but some images are hidden files
        if strcmp(image_names(j).name(1),'.')
            continue
        end
        new_fragment_path = fullfile(NEW_SEG_DIR, new_plates(i).name, image_names(j).name);
        
        % 0 --> we don't save the file 
        % 1 --> running new fragment (want to resize to similar scale as old fragment) 
        score = matching_single_fragment(new_fragment_path, PAM_list, 0, 1); % this will be in inner loop

        % alter returned score file 
        % instead of {name of new frag, name of new frag plate, full dir of new plate, [old frag matches in specified format]} 
        % it would be {name of old frag, name of old frag plate, full dir of old plate, [new frag matches in specified format]}
        % first three columns of inner cell and outer cell will be switched 
        
        if size(score{1,4},1)~=0
            % append to all scores if we have some sort of a match
            score{1,4}(1,1:3) = {score{1,1}, score{1,2}, score{1,3}};
            num_match = size(all_scores{1,4},1) + 1; 
            all_scores{1,4}(num_match,:) = score{1,4};
        end        
    end

    % sort scores if there are any to sort
    if size(all_scores{1,4},1) ~= 0
        all_scores{1,4} = sortrows(all_scores{1,4},7);
    end

    if ~exist(RESULTS_DIR, 'dir')
        mkdir(RESULTS_DIR)
    end

    % save scores in RESULTS directory
    save(fullfile(RESULTS_DIR, strcat(old_plate_name, '.mat')), 'all_scores');
end 
end
