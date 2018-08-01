# fragment_matching
Code for fragment matching for the Dead Sea Scrolls

The DATA folder contains all the plates and fragments. 
Put all new fragments as separate images in the DATA/NEW_SEGMENTED folder. 
Put all old plates, and their masks in DATA/OLD_UNSEGMENTED/plates and DATA/OLD_UNSEGMENTED/masks, respectively. Each old plate may have multiple masks. Each mask should have the same name as the old plate up to the first 10 characters.

I have included a few examples in DATA/NEW_SEGMENTED and DATA/OLD_UNSEGMENTED so that you can see how the code runs and how everything should be set up. 

## Instructions for running matching
- Create a 'matches' and 'location' folder in 'RESULTS', create DATA/OLD_SEGMENTED/fragment and DATA/OLD_SEGMENTED/plate 
- Run get_old_fragments.m. Now you have a folder for each plate in DATA/OLD_SEGMENTED/fragment and DATA/OLD_SEGMENTED/plate. Each image in the folders is for a single fragment. 
- Run matching.m. You will now have a scores.mat file that saves the results for each new image ranked by the SIFT-flow distance. 
- Run statistics.m. This will go through the first 20 results. Press 'y' if the result is a match. Now you have a stats.mat file that saves the correct matches. If you only care about the first match, you can uncomment the 'break' command on line 26. 
- Run location.m to generate a folder showing the fragment, the plate which it was found in, and the location of the fragment in the plate. It will be in the RESULTS/location folder. 

