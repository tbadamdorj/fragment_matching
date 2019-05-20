% old_plate_name list just includes names of plates
% img_path is path to the new image 
% then search is run using matching_single_fragment function
% results are saved in RESULTS directory

old_folders = dir(fullfile('DATA', 'OLD_SEGMENTED', 'fragment'));
idx = ismember({old_folders.name}, {'.', '..', '.DS_Store'});
old_plate_name_list = old_folders(~idx);
old_plate_name_list = {old_plate_name_list.name};
old_plate_name_list = transpose(old_plate_name_list);

img_path = 'B-505776_IR.png';
is_new_frag = 1; % since this is a new fragment 

all_scores = matching_single_fragment(img_path, old_plate_name_list, 1, is_new_frag);
