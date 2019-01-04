% create multiple masks by using imopen and imclose at several levels

MASK_FOLDER_DIR = fullfile('DATA','OLD_UNSEGMENTED', 'masks', 'raw');
MASKS_FOLDERS = dir(MASK_FOLDER_DIR);
idx = ismember({MASKS_FOLDERS.name}, {'.', '..', '.DS_Store'});
MASKS_FOLDERS = MASKS_FOLDERS(~idx);

levels = [10, 15]; 

SAVE_FOLDER = fullfile('DATA', 'OLD_UNSEGMENTED', 'masks');

current_folder = fullfile(MASK_FOLDER_DIR, MASKS_FOLDERS(1).name);
imlist = dir(fullfile(current_folder, '*.png'));

for mask_idx=1:size(imlist,1)
    first_img = imread(fullfile(current_folder, imlist(mask_idx).name));
    bw = zeros(size(first_img)); 
    bw = im2double(bw); 
    for folder_idx=1:size(MASKS_FOLDERS,1)
        current_folder = fullfile(MASK_FOLDER_DIR, MASKS_FOLDERS(folder_idx).name);
        img = imread(fullfile(current_folder, imlist(mask_idx).name));
        img = im2double(img); 
        bw = bw + img; 
    end
    
    % make representative mask
    bw = bw/8;
    representative = bw > 0.6;
    representative = imfill(representative, 'holes'); 
    representative = bwareaopen(representative, 2500);
    opened = imopen(representative, strel('disk', levels(1))); 
    
    plate_name = imlist(mask_idx).name; 
    plate_name = plate_name(1:end-4);

    count = size(dir(fullfile(SAVE_FOLDER, strcat(plate_name, '*.png'))),1); 
    imwrite(representative, fullfile(SAVE_FOLDER, strcat(plate_name,num2str(count+1), '.png')));
    imwrite(opened, fullfile(SAVE_FOLDER, strcat(plate_name,num2str(count+2), '.png')));
end