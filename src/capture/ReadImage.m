function [metadata I]=ReadImage(name)

% [metadata I]=ReadImage(name)
% This function reads a given image, where name is the file name or the
% complete filename with folder directory. Also read any metadata within
% the image file.
%
% Inputs:
%   name: image file name or complete directory route.
% Outputs:
%   metadata: structure with the readed metadata info.
%   I: image variable
%
%   Developed by Juan camilo Pérez Muñoz (2012) for the HORUS project.

try
    
    ImInfo=imfinfo(name);
    
    Meta=ImInfo.Comment;
    OtherData={};
    k=0; %Counter for other metadata
    id=0; % Identifier for data already readed
    if iscell(Meta)
        for i=1:length(Meta)
            if id==1
                id=0;
                continue
            end
            if strcmpi(Meta{i},'Capture frequency (Hz)')
                metadata.Frequency=eval(Meta{i+1});
                id=1;
            elseif strcmpi(Meta{i},'Number of Frames used')
                metadata.TotalFrames=eval(Meta{i+1});
                id=1;
            else
                k=k+1;
                OtherData{k}=Meta{i};
            end
        end
        metadata.OtherData=OtherData;
    else
        metadata.OtherData=Meta;
    end
    
    I=imread(name);
    
catch e
    disp(e.message)
end