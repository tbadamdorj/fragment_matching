% go through first 20 results of each and label whether it's a match or not
close all; 
load('scores_bigger_ratio_margin.mat');
stat_file_name = 'stats_big_ratio_margin.mat';
if exist(stat_file_name) ~= 0
    load(stat_file_name);
else
    stats = {}; 
end

scores = scores_new_as_query;
num_results_to_show = 10; 

for i=8:size(scores,1)
    img = imread(scores{i,3});
    imshow(img); 
    movegui('southeast');
    stats(i,1:3) = scores(i,1:3); 
    stats{i,4} = {}; 
    
    for j=1:min(num_results_to_show,size(scores{i,4},1))
        figure(); img = imread(scores{i,4}{j,3}); 
        % rotate by rotation amount given in the 8th column
        imshow(imrotate(img, scores{i,4}{j,9}));
        movegui('northeast');
        commandwindow; 
        user_input = input('match?','s'); 
        % if it is a match, enter 'y' and the match will be saved in the
        % stats.mat file
        if strcmp(user_input,'y')
            % the last index saves the ranking the result was given
            stats{i,4}(size(stats{i,4},1)+1,:) = [scores{i,4}(j,:),j];
            % can keep the following 'break' command if we only care about
            % the first match that we get 
            % break;
        elseif strcmp(user_input, 'c')
            close;
            break
        end
        close;
    end
    close all; 
    save(stat_file_name, 'stats');
end






















