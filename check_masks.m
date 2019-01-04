clear; close all;
% check how good masks are -- save good ones

% creates separate image for each fragment on the old plates

% where the masks are 
SEG_DIR = fullfile('DATA', 'OLD_UNSEGMENTED', 'masks', 'raw');
MOD_DIRS = dir(SEG_DIR); 
idx = ismember({MOD_DIRS.name}, {'.', '..', '.DS_Store', 'all_masks', 'good_masks'});
MOD_DIRS = MOD_DIRS(~idx);

% where unsegmented grayscale images are
UNSEG_DIR = fullfile('DATA', 'OLD_UNSEGMENTED', 'plates');

% stores the fragments
RES_DIR = fullfile('DATA', 'OLD_SEGMENTED', 'fragment');

% stores the masks so we can view the location later
RES_DIR_FULLIMAGES = fullfile('DATA', 'OLD_SEGMENTED', 'plate');
    
% get list of all masks
masks = dir(fullfile(SEG_DIR, MOD_DIRS(1).name, '*.png'));

% we keep connected components only if the overlap threshold between it and
% the other connected components is greater than this when we are using the
% hamming distance
overlap_threshold = 0.1; 

% iterate and get the connected components for each plate
for ind=1:size(masks,1)   
    plate_name = masks(ind).name(1:10);
    pname = dir(fullfile(UNSEG_DIR,strcat(plate_name,'*.jpg')));
    plate_name = pname.name(1:end-4);
    % assuming here that the image is uint8 and grayscale
    gray_plate = imread(fullfile(UNSEG_DIR,pname.name));
    
    fprintf('going through mask %s with plate size %d / %d\n', masks(ind).name, size(gray_plate,1), size(gray_plate,2));

    
    if size(gray_plate,3) == 3
        gray_plate = rgb2gray(gray_plate);
    end
    for mod_idx=1:size(MOD_DIRS,1)
        mask = imread(fullfile(SEG_DIR, MOD_DIRS(mod_idx).name, masks(ind).name));
        if size(mask,3) == 3
            mask = rgb2gray(mask);
        end

        figure();
        title(masks(ind).name);
        gray_plate = imresize(gray_plate, size(mask));
        imshow(imfuse(mask, gray_plate));  
        movegui('northeast');
        commandwindow; 
        user_input = input('good?','s'); 
        if strcmp(user_input,'y')
            count = size(dir(fullfile(SEG_DIR, 'good_masks', strcat(plate_name,'*.png'))));
            imwrite(mask, fullfile(SEG_DIR, 'good_masks', strcat(plate_name,num2str(count),'.png')));
        end
        
%         count = size(dir(fullfile(SEG_DIR, 'all_masks', strcat(plate_name,'*.png'))));
%         imwrite(imfuse(mask, gray_plate), fullfile(SEG_DIR, 'all_masks', strcat(plate_name,num2str(count),'.png')));

        close all;
    end
end