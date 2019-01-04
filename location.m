% create folders and save all fragments 1) fused with its parent and 2)
% just the plate itself -- this shows us the location of the fragments
% must first run statistics.m and have a stats.mat file with the correct
% matches in it 

% addpath to SIFTFLOW 
addpath('/Users/bjmongol/Documents/ML/fragment_matching/SIFTflow/mexDiscreteFlow');
addpath('/Users/bjmongol/Documents/ML/fragment_matching/SIFTflow/mexDenseSIFT');
addpath('/Users/bjmongol/Documents/ML/fragment_matching/SIFTflow');

RES_FOLDER = fullfile('RESULTS','location'); 

load('stats_for_387_fig33toend.mat'); 

for i=1:size(stats,1)
    % create directory to save results for each new image    
    new_img_name = stats{i,1}(1:end-4); 
    fprintf('matches for %s\n', new_img_name);
    SPECIFIC_RESULTS_FOLDER = fullfile(RES_FOLDER, new_img_name); 
    
    % if there aren't any matches, go to next fragment
    if size(stats{i,4}) == 0
        continue;
    end
    
    if exist(SPECIFIC_RESULTS_FOLDER, 'dir') ~= 7
        mkdir(SPECIFIC_RESULTS_FOLDER);
    end

    cellsize=[1,3];
    gridspacing=1;
    IsBoundary = true;

    SIFTflowpara.alpha=2*255;
    SIFTflowpara.d=40*255;
    SIFTflowpara.gamma=0.005*255;
    SIFTflowpara.nlevels=4;
    SIFTflowpara.wsize=2;
    SIFTflowpara.topwsize=10;
    SIFTflowpara.nTopIterations = 60;
    SIFTflowpara.nIterations= 30;

    % save the new image of fragment 
    new_img = imread(stats{i,3});
    imwrite(new_img, fullfile(SPECIFIC_RESULTS_FOLDER, stats{i,1})); 
    
    % get new image using CC 
    template_im = rgb2gray(new_img);
    template_bw = template_im > 0; 

    template_stats = regionprops(template_bw,'Centroid','Area','PixelIdxList','ConvexHull','Image','MajorAxisLength','MinorAxisLength','Orientation');

    template_correct_cc_ind=0;
    max_area = 0;
    for cc_ind=1:length(template_stats)
        if template_stats(cc_ind).Area>max_area
            template_correct_cc_ind = cc_ind;
            max_area = template_stats(cc_ind).Area;
        end
    end

    cropped_template_bw = template_bw;
    cropped_template_grayscale = template_im;

    if template_correct_cc_ind ~= 0
        cropped_template_bw = template_stats(template_correct_cc_ind).Image;

        [a,b]  = ind2sub(size(template_im),template_stats(template_correct_cc_ind).PixelIdxList);
        a2 = a - min(a) + 1; b2 = b - min(b) + 1;
        cropped_template_grayscale = uint8(zeros(size(cropped_template_bw)));
        cropped_template_color = uint8(zeros([size(cropped_template_bw),3]));
        M = length(a);
        for index=1:M
            cropped_template_grayscale(a2(index),b2(index)) =  template_im(a(index),b(index));
            cropped_template_color(a2(index),b2(index),:) = new_img(a(index),b(index),:);
        end
    end
    
    % save cropped_image of fragment 
    imwrite(cropped_template_color, fullfile(SPECIFIC_RESULTS_FOLDER, strcat(new_img_name, '_cropped.png')));
    
    for j=1:size(stats{i,4})
        match_dir = fullfile(SPECIFIC_RESULTS_FOLDER, num2str(j)); 
        
        if exist(match_dir, 'dir') ~= 7
            mkdir(match_dir);
        end
        
        % save image of old fragment 
        old_frag = imread(stats{i,4}{j,3}); 
        old_frag = imrotate(old_frag, stats{i,4}{j,9});
        [old_frag_bw, old_frag] = choose_biggest_CC(old_frag);
        imwrite(old_frag, fullfile(match_dir, stats{i,4}{j,1})); 
        
        % save the old image of the fragment for each match
        plate_name = stats{i,4}{j,2};
        % check if we have matches from the exact same plate
        if size(dir(fullfile(match_dir,strcat(plate_name,'_result.png')))) > 0
            continue
        end
        plate_img = imread(fullfile('DATA', 'OLD_UNSEGMENTED', 'plates' ,strcat(plate_name,'.jpg')));
        imwrite(plate_img, fullfile(match_dir, strcat(plate_name,'.jpg')));
        
        % for each result, overlay the mask on the PAM and save the result
        mask = imread(fullfile('DATA', 'OLD_SEGMENTED','plate',plate_name,stats{i,4}{j,1}));
        overlaid = cat(3, plate_img, mask + plate_img, plate_img);
        imwrite(mask, fullfile(match_dir, strcat(plate_name, '_mask.png')));
        imwrite(overlaid, fullfile(match_dir, strcat(plate_name,'_result.png')));
        
        % include registration results 
        % save registered image
        % save vx, vy
        % SIFT-flow parameters       
        old_frag = imresize(old_frag, size(cropped_template_grayscale));
        
        sift1 = mexDenseSIFT(cropped_template_grayscale,cellsize,gridspacing,IsBoundary);
        sift2 = mexDenseSIFT(old_frag,cellsize,gridspacing,IsBoundary);

        fprintf('calculating flow...\n');
        
        % align old image to new image
        tic;[vx,vy,energylist]=SIFTflowc2f(sift1,sift2,SIFTflowpara);toc

        warpI2=warpImage(double(old_frag),vx,vy);
        imwrite(uint8(warpI2), fullfile(match_dir, 'registered.png')); 
        save(fullfile(match_dir,'vx.mat'), 'vx'); save(fullfile(match_dir,'vy.mat'), 'vy');
    end
end