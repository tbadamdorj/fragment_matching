function [ siftflow_distance, cur_cc_rotated, cropped_template_grayscale, deg] = align_SIFT( new_img, old_img, new_processed)
    %align SIFT with correct orientation by minimizing the shape distance 
    % close all;
    % addpath to SIFTFLOW 
    addpath('/Users/bjmongol/Documents/ML/fragment_matching/SIFTflow/mexDiscreteFlow');
    addpath('/Users/bjmongol/Documents/ML/fragment_matching/SIFTflow/mexDenseSIFT');
    addpath('/Users/bjmongol/Documents/ML/fragment_matching/SIFTflow');

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

    if new_processed == 0
        % process the new image
        template_im = new_img;
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
    else
        cropped_template_grayscale = new_img; 
        cropped_template_bw = cropped_template_grayscale > 0; 
    end

    cur_cc_grayscale = old_img;
    if size(size(cur_cc_grayscale),2) == 3
        cur_cc_grayscale = rgb2gray(cur_cc_grayscale);
    end
    
%     % estimate transform amount
%     tformEstimate = imregcorr(cur_cc_grayscale, cropped_template_grayscale, 'rigid');
%     % rotate image (don't mess with scale) 
%     cur_cc_rotated = imwarp(cur_cc_grayscale,tformEstimate);

    min_shape_distance = 1000; 
    deg = 0; 
    
    for degree=0:10:350
        tmp_cur_cc_grayscale =  imrotate(cur_cc_grayscale, degree);
        % remove 0 padding by getting largest connected component
        [cur_cc_bw, greyy] = choose_biggest_CC(tmp_cur_cc_grayscale);
        
        cur_cc_bw = imresize(cur_cc_bw,size(cropped_template_grayscale));
        % imshow(cur_cc_bw); 
        cur_distance = sum(sum(abs(cropped_template_bw - cur_cc_bw)));
        norm_constant = size(cropped_template_bw,1) * size(cropped_template_bw,2);
        shape_distance = cur_distance/norm_constant;
        
        if shape_distance < min_shape_distance
            min_shape_distance = shape_distance; 
            deg = degree; 
        end
    end
    
    cur_cc_rotated = imrotate(cur_cc_grayscale, deg); 
    [cur_cc_bw, cur_cc_rotated] = choose_biggest_CC(cur_cc_rotated);
    
    imshow(cur_cc_rotated);
    
    K = 100; 

    cropped_template_grayscale2 = double(imresize(cropped_template_grayscale,[K,K]));
    cur_cc_grayscale2 = double(imresize(cur_cc_rotated,[K,K]));

    %         cropped_template_grayscale2 = double(cropped_template_grayscale);
    %         cur_cc_grayscale2 = double(cur_cc_grayscale);
    %
    sift1 = mexDenseSIFT(cropped_template_grayscale2,cellsize,gridspacing,IsBoundary);
    sift2 = mexDenseSIFT(cur_cc_grayscale2,cellsize,gridspacing,IsBoundary);

    % calculate sift from old image to new image
    [vx,vy,energylist]=SIFTflowc2f(sift2,sift1,SIFTflowpara);

    %             figure;imshow(uint8(warpI2));

    g = energylist.data;
    siftflow_distance  = min(g);
    % figure(); imshow([uint8(cropped_template_grayscale2), uint8(cur_cc_grayscale2)]);
end

