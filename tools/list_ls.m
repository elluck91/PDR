function list_ls = list_ls(rootDir, filt_file) 


switch nargin
    case 2
        Folder  = rootDir;
        jFile   = java.io.File(Folder);         % java file object
        jNames  = jFile.list;                   % java string objects

        % Match   = arrayfun(@(f)f.startsWith('page')&f.endsWith('.sys'),jNames); % boolean
        Match   = arrayfun(@(f)f.endsWith(filt_file),jNames); % boolean
        list_ls = cellstr(char(jNames(Match)));         % cellstr
    case 1
        Folder  = rootDir;
        jFile   = java.io.File(Folder);         % java file object
        jNames  = jFile.list;                   % java string objects

        list_ls = cellstr(char(jNames));         % cellstr
    case 0 
        Folder  = pwd;
        jFile   = java.io.File(Folder);         % java file object
        jNames  = jFile.list;                   % java string objects
     
        list_ls = cellstr(char(jNames));         % cellstr
end

if ~numel(list_ls{1})
    list_ls = [];
end
