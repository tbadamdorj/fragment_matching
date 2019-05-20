function [valid_matches] = rank_average(scores)
    scores_new_as_query = scores;

    % normalize the scores and final score is average of all 
    size1 = cell2mat(scores_new_as_query{1,4}(:,4));
    size2 = cell2mat(scores_new_as_query{1,4}(:,5));
    shape_distance = cell2mat(scores_new_as_query{1,4}(:,6));
    siftflow_distance = cell2mat(scores_new_as_query{1,4}(:,7));

    valid_matches = scores_new_as_query{1,4}(size1 < 300 & size2 < 300 & shape_distance < 0.3, :);

    % normalize all parameters: 
    % 1) subtract the minimum
    % 2) divide by new maximum
    unnormalized = cell2mat(valid_matches(:,4:7)); 

    if size(unnormalized,1) > 1
        % subtract minimum of each column
        minima = min(unnormalized); 

        for gesus=1:4
            unnormalized(:,gesus) = unnormalized(:,gesus) - minima(gesus);
        end

        % divide each row by its maxima
        maxima = max(unnormalized); 

        for mesus=1:4
            unnormalized(:,mesus) = unnormalized(:,mesus)./maxima(mesus);
        end
    end

    normalized = unnormalized;

    valid_matches(:,4:7) = num2cell(normalized);

    % average_scores = mean(cell2mat(valid_matches(:,6:7)),2);
    av = cell2mat(valid_matches(:,4:7));
    average_scores = 0.15*av(:,1) + 0.15*av(:,2) + 0.30*av(:,3) + 0.40*av(:,4); % take weighted average
    % average_scores = min(av,[],2);
    % rerank valid matches according to the mean scores
    average_scores = num2cell(average_scores);
    valid_matches(:,9) = average_scores(:);
    valid_matches = sortrows(valid_matches,9);
    valid_matches = {scores_new_as_query{1,1}, scores_new_as_query{1,2}, scores_new_as_query{1,3}, valid_matches};
end
