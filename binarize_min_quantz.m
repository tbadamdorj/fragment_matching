function [ bw, coloredLabelsImage] = binarize_min_quantz( color_img_name, color_img, num_classes, min_cc_size, save_dir)
%for binarizing DSS fragments

    % quantize into num_classes number of bins using 
    % minimum variance quantization (explanation in MATLAB documentation)
    % each pixel is assigned a class with an index
    % I found using higher number of classes is better 
    [quantized_img, map] = rgb2ind(color_img, num_classes);

    % lowest class is usually letters (darkest parts of text)
    bw = quantized_img == 1; 
    bw1 = quantized_img == 1; 
    bw2 = quantized_img == 1; 
    bw3 = quantized_img == 1; 

    bw = bw + bw1 + bw2 + bw3;

    % get rid of small blobs 
    bw = bwareaopen(bw, min_cc_size, 4); 

    % label different connected components with color
    [labeledImage, numberOfBlobs] = bwlabel(bw, 8);
    coloredLabelsImage = label2rgb(labeledImage, 'hsv', 'k', 'shuffle');
    
    imwrite([color_img, cat(3,im2uint8(bw),im2uint8(bw),im2uint8(bw)), coloredLabelsImage], fullfile(save_dir, color_img_name));
end

