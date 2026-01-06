function registered = RigidReg(ref, srce, reslice, other, interpol)
    %SPMRESCLICE Summary of this function goes here
    %   Detailed explanation goes here
    if nargin < 3
        other = [];
    end
    if nargin < 4
        interpol = [];
    end

    [refFile, files] = copyFiles(ref, srce, other);

    if ~isempty(interpol)
        if ~isnumeric(interpol) || numel(interpol) ~= numel(other)
            error('The "interpol" argument must be a numeric vector with the same number of elements as "other".');
        end
    end
    N = numel(files);
    inter = zeros(1, N);
    inter(1) = 4;

    if ~isempty(interpol)
        inter(2:end) = 0;
        inter(2:end) = interpol;
    end


    matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(refFile);
    matlabbatch{1}.spm.spatial.coreg.estimate.source = files(1);
    matlabbatch{1}.spm.spatial.coreg.estimate.other = files(2:end);
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi'; % Normalized Mutual Information
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2]; % Optimization steps
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.0200 0.0200 0.0200 0.0010 0.0010 0.0010 0.0100 0.0100 0.0100 0.0010 0.0010 0.0010]; 
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [4 4]; % Gaussian smoothing

    spm_jobman('run', matlabbatch);

    if reslice
        for i = 2:numel(files)
            P = char(refFile, files{i});  % Reference first
            spm_reslice(P, struct('interp', double(inter(i)), 'mask', 0, 'which', 1, 'mean', 0, 'prefix', ''));
        end
    end
    
    registered = files;
end


function [refFile, files] = copyFiles(ref, srce, others)
    [path,~,~] = fileparts(ref);
    path = fullfile(path, 'RigidReg');
    if ~exist(path, 'dir'), mkdir(path) 
    end
    refFile = copyFile(fullfile(ref), path, 'reference.nii');

    files = {};
    files = [files; copyFile(fullfile(srce),path)];
    if ~isempty(others)
        for i = 1:length(others)
            if ~exist(others{i}, 'file'),error('The file %s does not exist.', others{i}); end
           files = [files; copyFile(char(others(i)), path)];
        end
    end


end


function filename = copyFile(root, newpath, rename)
    if nargin < 3
        rename = [];
    end

    [~,name,ext] = fileparts(root);
    if contains(name, '.nii') && strcmp(ext, '.gz')
        if ~exist(newpath, 'dir'), mkdir(newpath); end
        filenames = gunzip(root, newpath);
        filename = filenames{1};
        % Rename if requested
        if ~isempty(rename)
            newFilename = fullfile(newpath, rename);
            movefile(filename, newFilename);
            filename = newFilename;
        end
    elseif strcmp(ext, '.nii')
        if ~isempty(rename)
            filename = fullfile(newpath, rename);
        else
            filename = fullfile(newpath, strcat(name,ext));
        end
        copyfile(root, filename)
    else
        error('The file %s is not a valid NIfTI file.', root);
    end


end