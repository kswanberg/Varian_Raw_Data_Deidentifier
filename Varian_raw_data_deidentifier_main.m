function Varian_raw_data_deidentifier_main() 
%
% Deidentifies contents of Varian .fid subdirectories inside an identified root 
% that contain (or omit) key user-defined phrases by copying fid and
% modified procpar files into new directories named by randomized
% four-digit ID. Saves an Excel file matching randomized IDs with original
% folder names. 
%
% Inputs: Upon function run the user will be prompted to select a root 
% directory containing subdirectories of Varian scan sessions
% themselves each containing .fid acquisition folders. Note that .fid 
% folders with identical root paths are assumed to
% come from the same scan session and are therefore assigned the same ID.
% 
% In 'file_key_array' and "file_omit_key_array' the user can type a
% variable number of keys into a cell array to select only .fid files of a certain type. 
% Note that these arrays must be the same
% length and may use '' as fillers for conditions not requiring inclusion
% and/or omission of specific strings. Also note that .fid files of
% specified types will be sorted independently from others in the same scan
% session folders. 
% 
% Outputs: Varian/Agilent acquisition .fid folders, IDed by path and containing only fid and procpar
% files deidentified according to the conditions written in the function 'procpar_anon_multi', plus an
% Excel file key containing deidentified data IDs and the original folder names
% 
% Author: Kelley Swanberg (Columbia University, 2023) 
%
% PowerShell syntax for updating file timestamps borrowed from https://www.mathworks.com/matlabcentral/answers/514140-
% how-to-change-timestamp-for-multiple-files-folders-via-powershell#comment_921856
% 
% Written for MATLAB 2013b; updated in MATLAB 2018a.
%
% Prompt user for target directory of Varian acquisition directories with fids to be anonymized
target_dir = uigetdir();

% Create file structures for data storage 
combined_table = []; 
row_names = {};

% Define file key string 
file_key_array = {'GSH', 'STEAM', 'GABA'}; % User can input variable number of strings that targeted .fid folder names must include to pull out specific types of .fid folders
file_omit_key_array = {'', '', ''}; % User can input variable number of strings that targeted .fid folder names must omit to pull out specific types of .fid folders; must be same size as file_key_array

length_key_array= length(file_key_array); 

list_of_all_cases_struct = dir(fullfile(target_dir, '**\*.*'));
list_of_all_cases_struct_clean = list_of_all_cases_struct(~ismember({list_of_all_cases_struct.name},{'.','..'}));
list_of_all_cases_names = {list_of_all_cases_struct_clean.name}'; 
list_of_all_cases_paths = {list_of_all_cases_struct_clean.folder}';

num_all_cases = length(list_of_all_cases_names);
numretained = zeros(num_all_cases, 1); 
subnum = 1; 

foldkeyarray = {}; 

for key_index=1:length_key_array

i = 1;

numretained = zeros(num_all_cases, 1); 

file_key = file_key_array{key_index}; 
file_omit_key = file_omit_key_array{key_index}; 

%% Loop through file key and omit key elements 
% Create index for keyed elements in all files 
for k=1:num_all_cases
    name = list_of_all_cases_names{k};
    pathstr = list_of_all_cases_paths{k};
    pathstr = strrep(pathstr, '\', '\\');
    if ~isempty(regexpi(pathstr,file_key)) & ~isempty(regexpi(pathstr,'.fid')) & isempty(regexpi(pathstr,file_omit_key))
        numretained(i) = k; 
        i = i + 1; 
        if mod(i, 10)==0
            fprintf('Data folder %d indexed!\n', i);
        end
    end      
end

% Create anonymized folders for grouped elements containing keys
foldkey = randi([1000,9999]);

if i>1
% Copy anonymized selected elements to coded folders
for j=1:num_all_cases
    
curindex = numretained(j); % Find next folder containing files with key 
previndex = 0; % Reset previous 

if curindex > 0 % Do not iterate past meaningful array elements 
 
% Parse out needed elements of filenames with keys  
name = list_of_all_cases_names{curindex};
pathstr = list_of_all_cases_paths{curindex};
    
cutoff = findstr(pathstr, '\data\');
curpath = 'a';

for a=1:cutoff
    curpath(a)=pathstr(a);
end

remainlength = length(pathstr)-cutoff; 
remain='a'; 

for a=1:remainlength
    remain(a)=pathstr(cutoff+a);
end

%[curpath, remain] = strtok(pathstr, 'data');
curpath = regexprep(curpath, '\\', '_'); 

% Not really needed anymore since all elements in loop now have keys 
    if ~isempty(regexpi(pathstr,file_key)) & isempty(regexpi(pathstr,file_omit_key))

    % Separate out FID files 
        if ~isempty(strfind(name, 'fid'))
   
            % First case will always need a new directory 
             if j ==1 
                dirName = sprintf('%s_deidentified_%d_%s', file_key, foldkey, remain);
                mkdir(target_dir, dirName);  
                folder = sprintf('%s\\%s',target_dir,dirName);
                name_with_path = sprintf('%s\\%s', list_of_all_cases_paths{curindex}, list_of_all_cases_names{curindex});
                copyfile(name_with_path, folder); 
                destination_dir = folder; 
                destination_file = 'fid';
                system(['powershell $(Get-Item ' destination_dir '\' destination_file ').lastwritetime=$(Get-Date)']);
                procpar_name_with_path = sprintf('%s\\%s', list_of_all_cases_paths{curindex+2}, list_of_all_cases_names{curindex+2});
                procpar_anon_multi(procpar_name_with_path, folder); %Use FID location to copy anonymized procpar files
                fprintf('%s: Data target %d located, deidentified, and copied!\n', file_key, curindex);
                foldkeyarray_key = sprintf('%s%s', curpath, file_key);
                foldkeyarray{subnum, 1} = foldkeyarray_key;
                foldkeyarray{subnum, 2}= foldkey; 
                subnum = subnum + 1; 
              
               % Subsequent cases need to match new with previous directory path 
             else if j >1
                 previndex = numretained(j-1);
                 name_pre = list_of_all_cases_names{previndex};
                 pathstr_pre = list_of_all_cases_paths{previndex};
                 
                 cutoff = findstr(pathstr_pre, '\data\');
                 prevpath = 'a';
                 for a=1:cutoff
                     prevpath(a)=pathstr_pre(a);
                 end
                 prevpath = regexprep(prevpath, '\\', '_'); 
                 end
            
                 % If same path as previous make directory for new files  
                 if strcmp(prevpath, curpath) == 1
                    dirName = sprintf('%s_deidentified_%d_%s', file_key, foldkey, remain);
                    mkdir(target_dir, dirName);  
                    folder = sprintf('%s\\%s',target_dir,dirName);
                    name_with_path = sprintf('%s\\%s', list_of_all_cases_paths{curindex}, list_of_all_cases_names{curindex});
                    copyfile(name_with_path, folder); 
                    destination_dir = folder; 
                    destination_file = 'fid';
                    system(['powershell $(Get-Item ' destination_dir '\' destination_file ').lastwritetime=$(Get-Date)']);
                    procpar_name_with_path = sprintf('%s\\%s', list_of_all_cases_paths{curindex+2}, list_of_all_cases_names{curindex+2});
                    procpar_anon_multi(procpar_name_with_path, folder); %Use FID location to copy anonymized procpar files
                    fprintf('%s: Data target %d located, deidentified, and copied!\n', file_key, curindex);
                 else 
                    foldkey=randi([1000,9999]);
              
                % Prevent duplication of folder keys 
                    if subnum > 1
                        rng shuffle; 
                        foldkey=randi([1000,9999]);
                    end
                    
                    foldkeyarray_key = sprintf('%s%s', curpath, file_key);
                    foldkeyarray{subnum, 1} = foldkeyarray_key;
                    foldkeyarray{subnum, 2}= foldkey; 
                    subnum = subnum + 1; 
                    dirName = sprintf('%s_deidentified_%d_%s', file_key, foldkey, remain);
                    mkdir(target_dir, dirName);  
                    folder = sprintf('%s\\%s',target_dir,dirName);
                    name_with_path = sprintf('%s\\%s', list_of_all_cases_paths{curindex}, list_of_all_cases_names{curindex});
                    copyfile(name_with_path, folder); 
                    destination_dir = folder; 
                    destination_file = 'fid';
                    system(['powershell $(Get-Item ' destination_dir '\' destination_file ').lastwritetime=$(Get-Date)']);
                    procpar_name_with_path = sprintf('%s\\%s', list_of_all_cases_paths{curindex+2}, list_of_all_cases_names{curindex+2});
                    procpar_anon_multi(procpar_name_with_path, folder); %Use FID location to copy anonymized procpar files
                    fprintf('%s: Data target %d located, deidentified, and copied!\n', file_key, curindex);
                    end 
                 end
            end
    end 
end
end
end
end

% Correct for subnum change in last iteration of loop 
subnum = subnum - 1; 

% Print key array to Excel file 
t=datestr(now); 
t=regexprep(t, ':', '_'); 
fileID=sprintf('key%s.xlsx', t);
    xlswrite(fileID, foldkeyarray, 1, 'A1');
fclose('all');

end