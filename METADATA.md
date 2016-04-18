# Dataset description

## Title 
Analysing change in music therapy interactions of children with communication difficulties 

## Free description 
This dataset is from the paper "Analysing change in music therapy interactions of children with communication difficulties" by Neta Spiro and Tommi Himberg. (http://dx.doi.org/10.1098/rstb.2015.0374)

This data set contains timings and labels of 5 pairs of annotation files. Each pair of files contains annotations of pairs of videos of 1-to-1 music therapy sessions recorded at the Nordoff Robbins London Centre. The annotations and co-rater annotations were made by two qualified Nordoff Robbins Music Therapists with experience in research Sarah Boyce and Camilla Farrant, working in the Research Team, Nordoff Robbins, London Centre, UK. The annotators watched the videos and listened to the soundtrack through headphones independently and inserted annotations in the software ELAN (Wittenburg P, Brugman H, Russel A, Klassmann A, Sloetjes H. 2006. ELAN: A professional framework for multimodality research. In: Proceedings of LREC. 5. Available from: http://tla.mpi.nl/tools/tla-tools/elan/). 

## Languages
English

## Keywords 
music therapy, interaction, communication, video analysis, annotation, MATLAB, ELAN, ELAN-MATLAB, Nordoff-Robbins, Aalto University 

## Disciplines 
music therapy

## Authors 
Dr. Neta Spiro, director of research, Nordoff-Robbins, London UK 
Dr. Tommi Himberg, post-doctoral researcher, Aalto University, Espoo, Finland

## Contributors 
Camilla Farrant 
Sarah Boyce

## Distributor 
Nordoff-Robbins Research

## Project 
Analysing change and interaction in Music therapy

## Access info 
Dataset stored in tijh.github.io/ELAN-MATLAB, along with MATLAB tools to process, analyse and visualise them. 

Research article (open access) available online at http://dx.doi.org/10.1098/rstb.2015.0374 Overview of the annotation protocol used to generate these annotations from video data are in the Supplementary data at http://dx.doi.org/10.1098/rstb.2015.0374

## License 
CC-BY 4.0

## Copyright notice 
When using the data or the toolbox, please cite Spiro N, Himberg T. 2016 Analysing change in music therapy interactions of children with communication difficulties. Phil. Trans. R. Soc. B 371: 20150374.

# Data structures and annotation codes
Zipped file containing 10 MAT-files (MATLAB. Mathworks Ltd.).

The data are in MATLAB data structures (.mat). Overview of the annotation protocol, annotation tiers and annotation values is in the supplementary materials of the research article. More information about the data structure can be found also in the help files of the ELAN-MATLAB toolbox. 

Each .mat file contains annotations from one music therapy session. Video recordings of the sessions were annotated by music therapy experts using a set protocol. (The original video data can unfortunately not be shared openly due to privacy issues.) These annotations were originally made using ELAN, annotating software, and these files were then transferred to MATLAB and analysed using the ELAN-MATLAB toolbox.  

## Data structure

In the annotation protocol, each behaviour is annotated separately, using a separate annotation tier in ELAN. Thus, for example the occurrences of the Client (C) facing the music therapist (MT) are annotated on one tier, C_Facing_MT. The annotations are time windows, with a start time (seconds.milliseconds elapsed from the beginning of the recording), end time, duration, and annotation value. The annotation value describes the behaviour, e.g. F = facing, NF = not facing (full list of annotation values and keys below). 

When the data is read into MATLAB, a hierarchical data structure is generated. Top level has two fields, 'tiers' and 'range'. The range tells the overall timespan of the annotations (begin of the first annotation (on any tier) and the end of the last annotation (on any tier)). The field 'tiers' contains all of the tiers in separate fields (e.g. EC_early.tiers.C_Facing_MT), and these in turn contain the individual annotations, their start times, end times, durations, and values. For example, the annotation value of the 12th annotation on the client facing the therapist tier is at EC_early.tiers.C_Facing_MT(12).value.  

## Data 

This dataset contains annotations from 10 trials from five client–therapist pairs. Each trial has 10 annotation tiers: C_Pulse (client's pulse type), MT_Pulse (therapist's pulse type), Shared_Pulse (linear combination of the two pulse tiers), C_Facing_MT (whether the client faces the therapist or not), MT_Facing_C (vice versa), Mutual_Facing (linear combination of the facing tiers), C_Travelling (whether the client is moving or not), MT_Travelling (same for the therapist), Both_Travelling (linear combination of the travelling tiers), Musictype (what type of music is being played). 

## Annotation values

Details of how each behaviour and value were characterised and demarcated from each other can be found in the supplementary materials of the journal article. 

#### Individual pulse tiers
R = regular pulse 
IR = irregular pulse 
NPM = non-pulsed musical sounds 
NMS = non-musical sounds 
S = silence 

#### Shared_Pulse 
Y = yes 
N = no

#### Individual facing tiers 
CF = client is facing the therapist 
CNF = client not facing the therapist 
CO = client out of view 
MtF = therapist is facing the client
MtNF = therapist not facing the client 
MtO = therapist out of view 

#### Mutual_Facing 
- for each timepoint, a linear combination of the previous was calculated. If the therapist and client share the same state, the annotation value is simply F = facing, NF = not facing and O = out of view. If the two have different states, the annotation value is a concatenation of the two values occurring at the moment, for example 
CFMtNF = client is facing the therapist but the therapist is not facing the client 
COMtF = client is out of view, therapist is facing the client 

#### Individual travelling tiers
CT = client is travelling (moving around in the room) 
CNT = client is still 
CO = client out of view 
MtT, MtNT, MtO = same for the therapist 

#### Both Travelling 
- this tier is generated, and the values named like in Mutual_Facing, for simple values T = Travelling, NT = Not travelling, and for non-matching states for example CTMtNT = client is moving, therapist is still 

#### Musictype 
- what type of music is being played/sang; whether it is an existing song or a rhyme, or whether it is free improvisation. The songs are further divided into different types, as some of them (such as the "hello song" and "goodbye song") repeat from session to session and also across therapists and clients.  
HS = hello song 
GS = goodbye song 
NR = nursery rhyme 
INS = instrumental
FI = free improvisation 
