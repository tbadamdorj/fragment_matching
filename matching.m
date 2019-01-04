clc; clear; close all;
% matching for the verification task

% matching with extra thing that keeps track of when each fragment was
% added

% addpath to SIFTFLOW 
addpath('/Users/bjmongol/Documents/ML/fragment_matching/SIFTflow/mexDiscreteFlow');
addpath('/Users/bjmongol/Documents/ML/fragment_matching/SIFTflow/mexDenseSIFT');
addpath('/Users/bjmongol/Documents/ML/fragment_matching/SIFTflow');

% keep scores for each fragment being run as a query
% 4 cells -- 
% 1) name of fragment 
% 2) name of plate 
% 3) full directory of the plate 
% 4) all matches with 
%   i) fragment name
%   ii) plate name
%   iii) full directory to image of fragment
%   iv) size distance (x axis) 
%   v) size distance (y axis)
%   vi) shape distance 
%   vii) siftflow distance 
%   viii) how many fragments we have searched through (useful for testing
%   robustness... just ignore this number!!!)
score_file_name = 'scores_show_adiel.mat'; 
if exist(score_file_name) ~= 0
    load(score_file_name);
else
    scores_new_as_query = {};  
end

rankings = {};

% list of old plates (for each fragment in each old plate we would like to
% run it as a query and search through fragments in all new plates) 
old_folders = dir(fullfile('DATA', 'OLD_SEGMENTED', 'fragment'));
idx = ismember({old_folders.name}, {'.', '..', '.DS_Store'});
old_plate_name_list = old_folders(~idx);
old_plate_name_list = {old_plate_name_list.name};
old_plate_name_list = transpose(old_plate_name_list);

% list of new plates (for each fragment in each old plate we would like to
% run it as a query and search through fragments in all new plates) 
% if we are running multiple 
% new_folders = dir(fullfile('DATA', 'NEW_SEGMENTED'));
% idx = ismember({new_folders.name}, {'.', '..', '.DS_Store'});
% new_plate_name_list = new_folders(~idx);
% new_plate_name_list = {new_plate_name_list.name};
% new_plate_name_list = transpose(new_plate_name_list);

new_plate_name_list = {'P387'};


% iterate over new plates 
for new_plate_num=1:length(new_plate_name_list)
    % current new plate 
    new_plate_name = new_plate_name_list{new_plate_num};
    DATA_DIR = fullfile('DATA','NEW_SEGMENTED', new_plate_name);
    % 'matching' pairs are stored here
    RES_DIR = fullfile('RESULTS','matches');
    
    % list of all images on the current new plate 
    new_templates_list = dir(fullfile(DATA_DIR, '*.png')); 
    
    % TODO: change this!!!! to 1 
    for new_image_ind=1:length(new_templates_list)
        total_num_fragments = 0; 
        new_im_name = new_templates_list(new_image_ind).name;
        
        % make a new entry for the template to store the matches that
        % we get 
        sze = size(scores_new_as_query); 
        num_queries = sze(1) + 1; %number of queries that we've run

        % process the new image
        template_im = rgb2gray(imread(fullfile(DATA_DIR, new_im_name)));
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
            M = length(a);
            for index=1:M
                cropped_template_grayscale(a2(index),b2(index)) =  template_im(a(index),b(index));
            end
        end


        % resize the new fragment so that it is on a similar scale to
        % the old fragment
        cropped_template_grayscale = imresize(cropped_template_grayscale,[size(cropped_template_grayscale,1)*1.4, ...
            size(cropped_template_grayscale,2)*1.4]);

        cropped_template_bw = imresize(cropped_template_bw,[size(cropped_template_bw,1)*1.4, ...
            size(cropped_template_bw,2)*1.4]);
        
        new_frag_stats = regionprops(cropped_template_bw,'Centroid','Area','PixelIdxList','ConvexHull','Image','MajorAxisLength','MinorAxisLength','Orientation');
        new_frag_major_axis = new_frag_stats.MajorAxisLength; 
        new_frag_minor_axis = new_frag_stats.MinorAxisLength; 
        
        
        figure; 
        imshow(cropped_template_grayscale); 
        close all; 
        
        scores_new_as_query(num_queries,:) = {new_im_name, new_plate_name, fullfile(DATA_DIR,new_im_name), {}};
        for old_plate_num=1:length(old_plate_name_list)
            % current old plate 
            old_plate_name = old_plate_name_list{old_plate_num};

            OLD_SEG_DIR = fullfile('DATA', 'OLD_SEGMENTED', 'fragment', old_plate_name);
            
            fprintf('query %d/%d from %s to %s\n', new_image_ind, length(new_templates_list), new_plate_name, old_plate_name);

            % SIFT-flow parameters
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

            %going over the old segmented templates
            % list of all old images on the current old plate 
            old_templates_list = dir(fullfile(OLD_SEG_DIR, '*.png'));
            for old_image_ind=1:length(old_templates_list)
                total_num_fragments = total_num_fragments + 1; 
                cur_cc_grayscale = imread(fullfile(OLD_SEG_DIR,old_templates_list(old_image_ind).name));
                if size(size(cur_cc_grayscale),2) == 3
                    cur_cc_grayscale = rgb2gray(cur_cc_grayscale);
                end
                
                tic;
%                 rotation_amount = rotation_idx*90;
%                 cur_cc_rotated = imrotate(cur_cc_grayscale, rotation_amount); 

                % size distance
                % this is scale test part
%                 size1_distance = abs(size(cropped_template_grayscale,1) - size(cur_cc_rotated,1));
%                 size2_distance = abs(size(cropped_template_grayscale,2) - size(cur_cc_rotated,2));
% 
%                 if (size1_distance > 500) % 300
%                     continue
%                 end
% 
%                 if (size2_distance > 500) %300
%                     continue
%                 end
                
                % check minor and major axis length
                
                cur_cc_bw = cur_cc_grayscale > 0; 
                old_frag_stats = regionprops(cur_cc_bw,'Centroid','Area','PixelIdxList','ConvexHull','Image','MajorAxisLength','MinorAxisLength','Orientation');
                
                old_frag_major_axis = old_frag_stats.MajorAxisLength; 
                old_frag_minor_axis = old_frag_stats.MinorAxisLength; 
                
                if abs(old_frag_major_axis - new_frag_major_axis) > 200 || abs(old_frag_minor_axis - new_frag_minor_axis) > 200 
                    continue
                end
                
                % check ratio 
                new_frag_ratio = new_frag_major_axis/new_frag_minor_axis; 
                old_frag_ratio = old_frag_major_axis/old_frag_minor_axis; 
                                
                if old_frag_ratio < new_frag_ratio - 0.3 || old_frag_ratio > new_frag_ratio + 0.3
                    continue
                end
                
                % do SIFT alignment
                
                [siftflow_distance, dunno, duncare, rotation_amount] = align_SIFT(cropped_template_grayscale, cur_cc_grayscale, 1);
                
                % save the scores
                % keep scores for each fragment being run as a query
                % 4 cells -- 
                % 1) name of fragment 
                % 2) name of plate 
                % 3) full directory of the plate 
                % 4) all matches with 
                %   i) name
                %   ii) plate
                %   iii) full directory
                %   iv) size distance 
                %   v) shape distance 
                %   vi) siftflow distance 

                % query number
                query_number = size(scores_new_as_query,1);

                % find which match number this is and append 
                match_number = size(scores_new_as_query{query_number,4},1) + 1;

                scores_new_as_query{query_number,4}(match_number,:) = ...
                                                    {old_templates_list(old_image_ind).name,...
                                                    old_plate_name,...
                                                    fullfile(OLD_SEG_DIR,old_templates_list(old_image_ind).name),...
                                                    0, 0,...
                                                    0,...
                                                    siftflow_distance,...
                                                    total_num_fragments,...
                                                    rotation_amount};

                % we sort by the siftflow distance
                scores_new_as_query{query_number,4} = sortrows(scores_new_as_query{query_number,4},7);
                toc
                close all;
            end         
        end
    % save the result
    save(score_file_name, 'scores_new_as_query');
    end
end