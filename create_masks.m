% create multiple masks by using imopen and imclose at several levels

MASK_FOLDER_DIR = fullfile('DATA','OLD_UNSEGMENTED', 'masks', 'raw');
MASKS_FOLDERS = dir(MASK_FOLDER_DIR);
idx = ismember({MASKS_FOLDERS.name}, {'.', '..', '.DS_Store'});
MASKS_FOLDERS = MASKS_FOLDERS(~idx);

levels = [10]; 

SAVE_FOLDER = fullfile('DATA', 'OLD_UNSEGMENTED', 'masks');

for folder_idx=1:size(MASKS_FOLDERS)
    current_folder = fullfile(MASK_FOLDER_DIR, MASKS_FOLDERS(folder_idx).name);
    imlist = dir(fullfile(current_folder, '*.png'));
    for mask_idx=1:size(imlist,1)
        bw = imread(fullfile(current_folder, imlist(mask_idx).name)); 
        cc = bwconncomp(bw);
        num_objects_org = cc.NumObjects; 
        
        % save unaltered image
        imwrite(bw, fullfile(SAVE_FOLDER, imlist(mask_idx).name));
        for levels_idx=1:size(levels,1)
            % open and close at current level
            opened = imopen(bw, strel('disk', levels(levels_idx))); 
            closed = imclose(bw, strel('disk', levels(levels_idx))); 
            
            plate_name = imlist(mask_idx).name; 
            plate_name = plate_name(1:10);
            
            % heuristic check -- if number of connected components remains
            % the same, don't save it
            cc_opened = bwconncomp(opened);
            if cc_opened.NumObjects ~= num_objects_org
                count = size(dir(fullfile(SAVE_FOLDER, strcat(plate_name, '*.png'))),1); 
                imwrite(opened, fullfile(SAVE_FOLDER, strcat(plate_name,num2str(count+1), '.png')));
            end
            
            % save altered images if heuristic check met 
            cc_closed = bwconncomp(closed); 
            if cc_closed.NumObjects ~= num_objects_org
                count = size(dir(fullfile(SAVE_FOLDER, strcat(plate_name, '*.png'))),1); 
                imwrite(closed, fullfile(SAVE_FOLDER, strcat(plate_name,num2str(count+1), '.png')));
            end
        end
    end
end