% go through first 20 results of each and label whether it's a match or not
load('scores.mat');
scores = scores_new_as_query;
stats={};
num_results_to_show = 20; 

for i=1:size(scores,1)
    img = imread(scores{i,3});
    imshow(img); 
    movegui('southeast');
    stats(i,1:3) = scores(i,1:3); 
    stats{i,4} = {}; 
    
    for j=1:min(num_results_to_show,size(scores{i,4},1))
        figure(); imshow(scores{i,4}{j,3});
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
        end
        close;
    end
    close all; 
    save('stats.mat', 'stats');
end






















