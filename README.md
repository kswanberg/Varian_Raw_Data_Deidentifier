# Varian Raw Data Deidentifier

The Varian Raw Data Deidentifier deidentifies the contents of Varian .fid subdirectories inside a user-targeted root directory that contain (or omit) key user-defined phrases. Deidentification proceeds by copying fid and modified procpar files into new directories named by randomized four-digit ID. This tool additionally saves an Excel file matching the new deidentified folder IDs with their original folder names for later re-identification if needed. 


### Inputs
Upon function run the user will be prompted to select a root directory containing subdirectories of Varian scan sessions themselves each containing .fid acquisition folders. Note that .fid folders with identical root paths are assumed to come from the same scan session and are therefore assigned the same ID.

In 'file_key_array' and "file_omit_key_array' the user can type a variable number of keys into a cell array to select only .fid files of a certain type. Note that these arrays must be the same length and may use '' as fillers for conditions not requiring inclusion and/or omission of specific strings. Also note that .fid folders of specified types will be sorted independently from others in the same scan session folders. 


### Outputs
This tool outputs deidentified Varian/Agilent acquisition .fid folders, IDed by path and containing only fid and procpar files deidentified according to the conditions written in the function 'procpar_anon_multi', plus an Excel file key containing deidentified data IDs and the original folder names.


### Citation 

Work that employed code from the Varian Raw Data Deidentifier can cite it as follows: 

Swanberg, K.M. (2023). Varian Raw Data Deidentifier. v. 2.0. Source code. https://github.com/kswanberg/Varian_raw_data_deidentifier.


### Developer

Please send comments and questions to [Kelley Swanberg](mailto:k.swanberg@columbia.edu). 
