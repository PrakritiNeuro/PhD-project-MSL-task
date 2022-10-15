# stim_TMR_MSL
Motor sequence learning (MSL) task adopted from the "stim" repo to conduct target memory reactivation (TMR) experiment using sound.
The starting point for the current repo is the branch "prakriti-task" created by Thibault Vlieghe by August 2022 (thibault.vlieghe@mcgill.ca)
More details about the source repo "stim", can be found on GitHub: https://github.com/labdoyon/stim.git

## Installation

1/4 Clone or download stim_TMR_MSL from github
	https://github.com/EllaGab/stim_TMR_MSL.git
	Don't move files around. Respect the structure of the github repository

2/4 Download and install Psychtoolbox
	http://psychtoolbox.org/download
	Note that you will need to install GStreamer as well

3/4 Download and install FFMPEG
	https://ffmpeg.org/
	https://www.wikihow.com/Install-FFmpeg-on-Windows

4/4 Add stim.m experiments/ stimuli/ analysis/ to MATLAB path
	Running stim.m will automatically add all the required files to the MATLAB path

## Auditory Stimuli

The volume levels for the sound are in decibels relative to:
	1) the equipment used for the experiment
	2) the master system volume on the system at the time of the experiment

Advice: Keep master system volume consistent across participants.

## GUI

Use the "Quit" button to close menus. This will ensure proper saving of the data
and releasing computational resources (e.g., memory, processing, etc.)


