function [ all_scores ] = matching_single_fragment( fragment_path, PAM_list, save_file, is_new_frag)
% matching_single_fragment Take path to single fragment, process new image
% and do everything and save the scores to the folder with a *_scores.mat
% file where * is the name of the query fragment
%   PAM_list is a cell of size Nx1 where N is the number of PAMs we would
%   like to search. In each row, we have the name of a PAM we would like
%   to search. If it ends with .jpg we remove the .jpg

    % keep scores for each fragment being run as a query
    % 4 cells -- 
    % 1) name of fragment 
    % 2) name of plate 
    % 3) full directory of the plate 
    % 4) all matches with 
    %   i) fragment name
    %   ii) plate name
    %   iii) full directory to image of fragment
    %   iv) size distance (major axis) 
    %   v) size distance (minor axis)
    %   vi) shape distance (after minimizing shape distance) 
    %   vii) siftflow distance 
    %   viii) degree of rotation
    
    % folder to save results to: 
    SAVE_FOLDER = 'RESULTS'; 
    
    % use the name of the image (without .jpg extension) as the name of our
    % mat file
    score_file_name = strsplit(fragment_path, '/'); 
    score_file_name = score_file_name(end);
    score_file_name = char(score_file_name); 
    score_file_name = strsplit(score_file_name, '.');
    new_frag_name = char(score_file_name(1));
    score_file_name = strcat(new_frag_name,'.mat');
    
    if exist(fullfile(SAVE_FOLDER, score_file_name)) ~= 0
        load(fullfile(SAVE_FOLDER, score_file_name));
    else
        all_scores = {};  
    end

    % list of old plates (for each fragment in each old plate we would like to
    % run it as a query and search through fragments in all new plates) 
    
    old_plate_name_list = PAM_list;

    % process the new image
    template_im = rgb2gray(imread(fragment_path));
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
    if is_new_frag
        cropped_template_grayscale = imresize(cropped_template_grayscale,[size(cropped_template_grayscale,1)*1.4, ...
            size(cropped_template_grayscale,2)*1.4]);

        cropped_template_bw = imresize(cropped_template_bw,[size(cropped_template_bw,1)*1.4, ...
            size(cropped_template_bw,2)*1.4]);
    end

    new_frag_stats = regionprops(cropped_template_bw,'Centroid','Area','PixelIdxList','ConvexHull','Image','MajorAxisLength','MinorAxisLength','Orientation');
    new_frag_major_axis = new_frag_stats.MajorAxisLength; 
    new_frag_minor_axis = new_frag_stats.MinorAxisLength; 


    % figure; 
    % imshow(cropped_template_grayscale); 
    % close all; 

    % data to excel easily (convert from mat file to excel file) 
    all_scores(1,:) = {new_frag_name, fragment_path, fragment_path, {}};
    
    % TODO: add progressbar that shows how many fragments/plates 
    % (??? which one ???) we have yet to go through
    
    numIterations = length(old_plate_name_list);
    % obj = ProgressBar(numIterations, ...
    %    'Title', new_frag_name ...
    %    );

    % obj.setup([], [], []);

    for old_plate_num=1:length(old_plate_name_list)
        % current old plate 
        old_plate_name = old_plate_name_list{old_plate_num};
        fprintf('%d/%d: %s\n', old_plate_num, numIterations, old_plate_name);
	tic;
        OLD_SEG_DIR = fullfile('DATA', 'OLD_SEGMENTED', 'fragment', old_plate_name);

        %going over the old segmented templates
        % list of all old images on the current old plate 
        old_templates_list = dir(fullfile(OLD_SEG_DIR, '*.png'));
        for old_image_ind=1:length(old_templates_list)
            cur_cc_grayscale = imread(fullfile(OLD_SEG_DIR,old_templates_list(old_image_ind).name));
            if size(size(cur_cc_grayscale),2) == 3
                cur_cc_grayscale = rgb2gray(cur_cc_grayscale);
            end
            % fprintf(fullfile(OLD_SEG_DIR,old_templates_list(old_image_ind).name));
            % check minor and major axis length
            
            cur_cc_bw = cur_cc_grayscale > 0; 

            old_frag_stats = regionprops(cur_cc_bw,'Centroid','Area','PixelIdxList','ConvexHull','Image','MajorAxisLength','MinorAxisLength','Orientation');

            % check that we have a connected component
            if isempty(old_frag_stats)
                continue
            end

            old_frag_major_axis = old_frag_stats.MajorAxisLength; 
            old_frag_minor_axis = old_frag_stats.MinorAxisLength; 
            
            major_axis_size_diff = abs(old_frag_major_axis - new_frag_major_axis); 
            minor_axis_size_diff = abs(old_frag_minor_axis - new_frag_minor_axis); 
            
            if major_axis_size_diff > 300 || minor_axis_size_diff > 300 
                continue
            end

            % check ratio 
            new_frag_ratio = new_frag_major_axis/new_frag_minor_axis; 
            old_frag_ratio = old_frag_major_axis/old_frag_minor_axis; 

            if old_frag_ratio < new_frag_ratio - 0.3 || old_frag_ratio > new_frag_ratio + 0.3
                continue
            end

            % do SIFT alignment
            [siftflow_distance, shape_distance, dunno, duncare, rotation_amount] = align_SIFT(cropped_template_grayscale, cur_cc_grayscale, 1);

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
            % find which match number this is and append 
            match_number = size(all_scores{1,4},1) + 1;

            all_scores{1,4}(match_number,:) = ...
                                                {old_templates_list(old_image_ind).name,...
                                                old_plate_name,...
                                                fullfile(OLD_SEG_DIR,old_templates_list(old_image_ind).name),...
                                                major_axis_size_diff,... 
                                                minor_axis_size_diff,...
                                                shape_distance,...
                                                siftflow_distance,...
                                                rotation_amount};

            close all;
        end
        toc
        % obj.step([], [], []);
        % sort by siftflow distance and then save the results after each plate
        if size(all_scores{1,4},1) ~= 0
            all_scores{1,4} = sortrows(all_scores{1,4},7);
        end
        if save_file
            save(fullfile(SAVE_FOLDER, score_file_name), 'all_scores');
        end
    end
    
    % release progressbar object 
    % obj.release();
end

