load(fullfile('DATA', 'OLD_QUERY_RESULTS', 'B-279123.mat')) % will be loaded as all_scores

% sort by average score
all_scores = rank_average(all_scores);

% get indices of just rectos 
img_paths = all_scores{1,4}(:,3);
fprintf('img_paths');
size(img_paths)
img_names = all_scores{1,4}(:,1);
fprintf('img_names');
size(img_names)
rectos = regexprep(img_names, '.*-Fg\d*-(\w)-.*', '$1');
rectos_indices = strcmp(rectos, 'R');

img_paths = img_paths(rectos_indices);
img_names = img_names(rectos_indices);

% show 500 top results
fprintf('results will be saved to %s', fullfile('DATA','OLD_QUERY_RESULTS', 'IMG_RESULTS'));

for i=1:500
    copyfile(img_paths{i,1}, fullfile('DATA','OLD_QUERY_RESULTS', 'IMG_RESULTS', ...
    strcat(num2str(i), '_', img_names{i,1}, '.png')));
end
