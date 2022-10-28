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

The volume levels for the sound are between 0 and 1, which indicate proportion of the
volume levels of the active device. The device volume depends on:
	1) the equipment used for the experiment
	2) the master system volume on the system at the time of the experiment

Advice: For meaningful inferences about the volume levels, use the same equipment and
keep master system volume consistent throughout all phases of the experiment and
across all participants.

## GUI

Use the "Quit" button to close menus. This will ensure proper saving of the data
and releasing computational resources (e.g., memory, processing, etc.)

Press 'Escape' to interrupt the session.

Press '5' start the task. This is the TTL key that is expected from the scanner
to start the scanning session.

If STIM crashed or was interrupted unexpectedly, the keyboard input to Matlab
may be disabled. To enable it, press CTRL+C. It is the same as ListenChar(0).

## ADDITIONAL RESOURSES FOR PROGRAMMERS

Demos to start coding with Psychtoolbox are provided together with the Psychtoolbox
under PsychDemos directory.
More demos and tutorials can be found on https://peterscarfe.com/ptbtutorials.html

