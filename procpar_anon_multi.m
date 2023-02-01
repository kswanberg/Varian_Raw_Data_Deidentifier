
function procpar_anon_multi(xfile, yfolder)
% Deidentifies and copies procpar file "xfile" within Varian .fid directories passed by
% Varian_raw_data_deidentifier_main. Writes deidentified file to
% destination folder "yfolder."
%
% Author: Kelley Swanberg (Columbia University, 2023) 
%
% 
% Written for MATLAB 2013b; updated in MATLAB 2018a.
%
% Open procpar file
[fid, msg] = fopen(xfile,'r+');

% Ensure existence of procpar file 
    if ~isempty(msg)
        fprintf('%s\n',msg);
        clear msg;
    end
    
    % Set up array for variables to be anonymized 
    variables= {}; 
    
    variables{1} = sprintf('%sage 1', char(10)); 
    variables{2}= sprintf('%sbirthday 2', char(10)); 
    variables{3}=  sprintf('%sdatname 2', char(10));
    variables{4}= sprintf('%sdataid 2', char(10));
    variables{5}= sprintf('%sheight 1', char(10)); 
    variables{6}= sprintf('%sdate 2', char(10)); 
    variables{7}= sprintf('%sname 2', char(10)); 
    variables{8}= sprintf('%susername', char(10));
    variables{9}= sprintf('%sprescribed', char(10)); 
    variables{10}= sprintf('%sshims', char(10)); 
    variables{11}=  '[^abcdefghijklmnopqrstuvwxyz]time_submitted[^_]';
    variables{12}= sprintf('%stime_complete', char(10));  
    variables{13}= sprintf('%stime_run', char(10)); 
    variables{14}= sprintf('%stime_svfdate', char(10)); 
    variables{15}= sprintf('%stime_submitted_local', char(10)); 
    variables{16}= sprintf('%sfilenameMrsB1Shim', char(10)); 
    variables{17}= sprintf('%sfilenameOvsB1Shim', char(10)); 
    variables{18}= sprintf('%sstudyid', char(10)); 
    variables{19}= sprintf('%stime_processed', char(10)); 
    
    % Read original procpar file into character array 
    C=fileread(xfile);
    
    % Index location of offending parameter name in arrayed procpar 
    for i=1:length(variables)
        start=regexp(C, variables{i});
       % fprintf('%d',start);
        chara=0;
        matcher='a';
        
    if start > 0
         % find next line containing value for offending parameter 
         while  ~strcmp(matcher, sprintf('%s', char(10)))
                chara=chara+1;
                %fprintf('%d',chara);
                  matcher(1)=C(start+chara);
         end 
    
         % Index location to begin writing over offending parameter value 
         startwrite = start+chara+3;
   
         matcher='a'; 
         chara=0; 
         date='"Jan 1 1900"       ';
    
         % Overwrite offending value!
         while ~strcmp(matcher, sprintf('%s', char(10)))
            if i==6
                C(startwrite+chara) = date(chara+1);
            else
                if ~strcmp(matcher, sprintf('%s', char(32)))
                 %C(startwrite+chara) = num2str(randi([1,9]));
                 C(startwrite+chara) = '0';
                end
         end
                 chara=chara+1;
                % fprintf('%d',chara);
                 matcher(1)=C(startwrite+chara);
         end 
    end
    end
        % Close original file 
        fclose('all'); 
        
        % Write new file to input directory 
        filename = sprintf('%s\\procpar', yfolder);
        fileID = fopen(filename,'w');
        fprintf(fileID, C); 
        fclose('all');