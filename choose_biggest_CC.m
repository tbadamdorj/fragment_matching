function [bw, gray, max_area] = choose_biggest_CC( grayscale_img )
% Threshold grayscale image at > 0, and return biggest connected component
    bw = grayscale_img > 0; 
    
    template_stats = regionprops(bw,'Centroid','Area','PixelIdxList','ConvexHull','Image','MajorAxisLength','MinorAxisLength','Orientation');

    template_correct_cc_ind=0;
    max_area = 0;
    for cc_ind=1:length(template_stats)
        if template_stats(cc_ind).Area>max_area
            template_correct_cc_ind = cc_ind;
            max_area = template_stats(cc_ind).Area;
        end
    end
    tmp = grayscale_img; 
    bw = template_stats(template_correct_cc_ind).Image;
    
    [a,b]  = ind2sub(size(grayscale_img),template_stats(template_correct_cc_ind).PixelIdxList);
    a2 = a - min(a) + 1; b2 = b - min(b) + 1;
    gray = uint8(zeros(size(bw)));
    M = length(a);
    for index=1:M
        gray(a2(index),b2(index)) =  tmp(a(index),b(index));
    end

end

