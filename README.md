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



## Instructions for single fragment matching -- THIS IS THE IMPORTANT BIT 

- matching_single_fragment.m is the function for searching for the given image through the PAMs. The documentation at the top of the function specifies the format in which search results are saved in the mat file 
- matching_single_old_fragment.m is the function for searching for the given image through the new fragments. The image must be placed in the appropriate DATA/OLD_QUERY folder, and then specified as an argument with its jpg extension e.g by calling matching_single_old_fragment('B-124242.png'). This can be run from the matlab command line or within a script
- show_results_NEW_search.m is a demo file showing how to display the results of searching through the new images. It only shows the recto files (lines 7-14) 
- show_results_PAM_search.m is a demo file showing how to display the results of searching through the PAMs.
- demo_search_new is a small demo showing how to search through the PAMs using a new fragment 
- demo_search_old is a small demo showing how to search through the PAMs using an OLD fragment. 
- align_SIFT.m finds the 1) correct orientation between the query and candidate 2) finds the shape distance between them (the hamming distance and 3) finds the SIFTflow distance between them 
- the SIFTflow folder contains the SIFTflow code as a mex file (compiled for mac, windows, and ubuntu) 
- rank_average.m is just a function doing the reranking using the average of the size, shape, and SIFTflow distances.


## Some notes: 

- images are resized to 250x250 when attempting to align them in align_SIFT.m --> this was a heuristic choice that showed that we can achieve fast search while still maintaining good results (this was shown on a smaller tagged dataset --> Look at "Matching and Searching the Dead Sea Scrolls by Taivanbat Badamdorj, Adiel Ben-Shalom, and Nachum Dershowitz). 
- the only difference between demo_search_new and demo_search_old is specifying 'is_new_frag' in the call to matching_single_fragment (1 for new fragment, 0 for old fragment). This is because if it is an old image, we don't need to resize while searching through the PAMs. If it's a new image, we need to resize it
- both show_results_NEW/PAM_search.m take the .mat file with all the results, and rerank using the average of all the distances, as this was shown to give more stable results (ranking only by SIFTflow distance is not good for fragments that are mostly uniform with no distinguishing characteristics) 
- the location of the PAM images should not change ever, since the fully segmented versions are in the fragment_matching/DATA folder 
- the location of the new images may change however if we are not running on rack-nachum1. We can change this in the matching_single_ol_fragment.m function
