% test binarization for 4Q57 fragments

DATA_DIR = fullfile('DATA', 'TEST_BINARIZATION'); 
TEST_DIR = fullfile(DATA_DIR, 'TESTS');

SAVE_DIR = fullfile(DATA_DIR, 'RESULTS');

img_names = dir(fullfile(TEST_DIR, '*.png')); 

num_classes = 7; 
min_cc_size = 50; 

for i=1:size(img_names)
    color_img_name = img_names(i).name;
    color_img = imread(fullfile(TEST_DIR, color_img_name));
    [ bw, coloredLabelsImage] = binarize_min_quantz( color_img_name, color_img, num_classes, min_cc_size, SAVE_DIR);
end