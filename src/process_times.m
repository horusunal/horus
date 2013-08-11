function process_times(station)

%PROCESS_TIMES Plots the process times of a specific station.
%
%   Input:
%   station: Name of the station.
%
%   Output:
%
%   Example:
%   process_times('CARTAGENA');
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/12/06 14:02 $

try
    
    try
        conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    % obtains information from the database
    data  = load_all_automatic_params(conn, station);
    
    if isempty(data)
        warndlg('You must first save processes configuration into the database!', 'Failure')
        return
    end
    
    hour_init = [];
    minute_init = [];
    hour_final = [];
    minute_final = [];
    step_process = [];
    duration_process = [];
    types = [];
    R = [];
    G = [];
    B = [];
    num_images = [];
    
    % order the types to be shown in figure
    for i = 1:size(data,1)
        if strcmp(cell2mat(data(i,2)),'image')
            hour_init(1) = cell2mat(data(i,3));
            minute_init(1) = cell2mat(data(i,4));
            hour_final(1) = cell2mat(data(i,5));
            minute_final(1) = cell2mat(data(i,6));
            step_process(1) = cell2mat(data(i,7));
            if cell2mat(data(i,8)) > 0
                duration_process(1) = 3*cell2mat(data(i,8));
            else
                duration_process(1) = 60;
            end
            
            num_images = cell2mat(data(i,9));
            types{1} = 'capture';
            R(1) = 33;
            G(1) = 127;
            B(1) = 190;
            break;
        end
        
    end
    
    if isempty(num_images)
        warndlg('You must first configure capture!', 'Failure')
        return
    end
    
    for i = 1:size(data,1)
        if strcmp(cell2mat(data(i,2)),'transfer')
            hour_init(2) = cell2mat(data(i,3));
            minute_init(2) = cell2mat(data(i,4));
            hour_final(2) = cell2mat(data(i,5));
            minute_final(2) = cell2mat(data(i,6));
            step_process(2) = cell2mat(data(i,7));
            duration_process(2) = 25*num_images;
            types{2} = cell2mat(data(i,2));
            R(2) = 22;
            G(2) = 170;
            B(2) = 76;
            break;
        end
    end
    
    for i = 1:size(data,1)
        if strcmp(cell2mat(data(i,2)),'stack')
            hour_init(end+1) = cell2mat(data(i,3));
            minute_init(end+1) = cell2mat(data(i,4));
            hour_final(end+1) = cell2mat(data(i,5));
            minute_final(end+1) = cell2mat(data(i,6));
            step_process(end+1) = cell2mat(data(i,7));
            duration_process(end+1) = 1.4*cell2mat(data(i,8));
            types{end+1} = [cell2mat(data(i,2)) ' ' num2str(cell2mat(data(i,10)))];
            R(end+1) = 90;
            G(end+1) = 102;
            B(end+1) = 151;
        end
    end
    
    
    for i = 1:size(data,1)
        if strcmp(cell2mat(data(i,2)),'process')
            hour_init(end+1) = cell2mat(data(i,3));
            minute_init(end+1) = cell2mat(data(i,4));
            hour_final(end+1) = cell2mat(data(i,5));
            minute_final(end+1) = cell2mat(data(i,6));
            step_process(end+1) = cell2mat(data(i,7));
            duration_process(end+1) = 1.4*((29*num_images)+210);
            types{end+1} = cell2mat(data(i,2));
            R(end+1) = 80;
            G(end+1) = 190;
            B(end+1) = 180;
            break;
        end
    end
    
    for i = 1:size(data,1)
        if strcmp(cell2mat(data(i,2)),'sync')
            hour_init(end+1) = cell2mat(data(i,3));
            minute_init(end+1) = cell2mat(data(i,4));
            hour_final(end+1) = cell2mat(data(i,5));
            minute_final(end+1) = cell2mat(data(i,6));
            step_process(end+1) = cell2mat(data(i,7));
            duration_process(end+1) = 180*num_images; %% CAMBIAR!!!!!!!
            types{end+1} = cell2mat(data(i,2));
            R(end+1) = 180;
            G(end+1) = 200;
            B(end+1) = 80;
            break;
        end
    end
    
    % converts the time to minutes
    time_init_min=(hour_init*60)+minute_init;
    time_final_min=(hour_final*60)+minute_final;
    
    duration_process_min=duration_process/60;
    minimum_time=min(time_init_min); % minimum time
    [maximum_time index_max]=max(time_final_min); % maximum time
    total_time = (maximum_time+duration_process_min(index_max)-minimum_time)+1;
    time = time_final_min - time_init_min;
    width_process = total_time;
    % One minute equals how many pixels, it is said that the ratio is 1:1
    minute_pixel = 1;
    step_pixel=round(step_process*minute_pixel); % when is the step in pixels
    height_picture= 40;
    height_line = 8;
    height_lineprocess =3;
    number_process=floor((time./step_process)+1);
    width_line = ceil(total_time*minute_pixel)+4;
    width_start=136;
    height_start=21;
    width_image=ceil(width_process+width_start+30);
    space_process = 30;
    height_image = ((size(hour_init,2)+1)*(height_picture+space_process))+(2*height_start);
    line_picture=zeros(height_line,width_line);
    width_linetime=4;
    height_linetime = 20;
    line_time=zeros(height_linetime,width_linetime);
    imageR=ones(height_image,width_image)*255;
    imageG=ones(height_image,width_image)*255;
    imageB=ones(height_image,width_image)*255;
    
    % is the difference between the initial time and the minimum time
    time_init_min2 = time_init_min - minimum_time;
    time_init_min2 = time_init_min2*minute_pixel; %  converts the time to pixels
    pos_minprocess =[];
    % show the lines and picture in the image
    for i=1:size(hour_init,2)
        
        start_line=height_start+ceil((height_picture/2)-(height_line/2));
        start_lineV(i)=start_line;
        imageR(start_line:start_line+height_line-1,width_start:width_start+width_line-1) = line_picture;
        imageG(start_line:start_line+height_line-1,width_start:width_start+width_line-1) = line_picture;
        imageB(start_line:start_line+height_line-1,width_start:width_start+width_line-1) = line_picture;
        
        width_picture = ceil(duration_process_min(i)*minute_pixel);
        pictureR=ones(height_picture,width_picture)*R(i);
        pictureG=ones(height_picture,width_picture)*G(i);
        pictureB=ones(height_picture,width_picture)*B(i);
        
        
        
        picture_start=width_start+time_init_min2(i);
        picture_start=round(picture_start);
        for j=1:number_process(i)
            imageR(height_start:height_start+height_picture-1,picture_start:picture_start+width_picture-1) = pictureR;
            imageG(height_start:height_start+height_picture-1,picture_start:picture_start+width_picture-1) = pictureG;
            imageB(height_start:height_start+height_picture-1,picture_start:picture_start+width_picture-1) = pictureB;
            picture_start = picture_start + step_pixel(i);
        end
        
        line_process = zeros(height_lineprocess,width_picture);
        
        line_processstart=width_start+time_init_min2(i);
        line_processstart=round(line_processstart);
        
        imageR(height_start+height_picture+2:height_start+height_picture+height_lineprocess+1,...
            line_processstart:line_processstart+width_picture-1) = line_process;
        imageG(height_start+height_picture+2:height_start+height_picture+height_lineprocess+1,...
            line_processstart:line_processstart+width_picture-1) = line_process;
        imageB(height_start+height_picture+2:height_start+height_picture+height_lineprocess+1,...
            line_processstart:line_processstart+width_picture-1) = line_process;
        
        pos_minprocess(i,1) = height_start+height_picture+height_lineprocess+10; % position of the row
        pos_minprocess(i,2) = line_processstart + ceil((width_picture/4)); % position of the col
        pos_minprocess(i,3) = duration_process_min(i);% time in minutes
        
        height_start = height_start+height_picture+space_process;
    end
    
    % sets the end of the time axis
    
    start_line=height_start+ceil((height_linetime/2)-(height_line/2));
    
    imageR(start_line:start_line+height_line-1,width_start:width_start+width_line-1) = line_picture;
    imageG(start_line:start_line+height_line-1,width_start:width_start+width_line-1) = line_picture;
    imageB(start_line:start_line+height_line-1,width_start:width_start+width_line-1) = line_picture;
    
    
    
    minimum_hour=floor(minimum_time/60); % get the start hour
    minimum_minute = mod(minimum_time,60); % get the start minute
    difference_minute = 0;
    if minimum_minute > 0
        minimum_hour = minimum_hour + 1;
        difference_minute = 60-minimum_minute;
    end
    maximum_hour=floor((maximum_time+duration_process_min(index_max))/60); % get the finish hour
    start_linetime=width_start+(difference_minute*minute_pixel);
    start_linetime=round(start_linetime);
    for j=minimum_hour:maximum_hour
        imageR(height_start:height_start+height_linetime-1,start_linetime:start_linetime+width_linetime-1) = line_time;
        imageG(height_start:height_start+height_linetime-1,start_linetime:start_linetime+width_linetime-1) = line_time;
        imageB(height_start:height_start+height_linetime-1,start_linetime:start_linetime+width_linetime-1) = line_time;
        start_linetime = start_linetime + (60*minute_pixel);
    end
    
    image(:,:,1) = imageR;
    image(:,:,2) = imageG;
    image(:,:,3) = imageB;
    image=uint8(image);
    if height_image >= 540 || width_image >= 1050
        fontsize = 9;
    else
        fontsize = 12;
    end
    figure
    imshow(image)
    
    for i = 1:size(hour_init,2)
        text(1,start_lineV(i)+2,texlabel(cell2mat(types(i)),'literal'),'FontSize',fontsize)
    end
    
    text(1,start_line+2,texlabel('time','literal'),'FontSize',fontsize)
    start_linetime=width_start+(difference_minute*minute_pixel);
    start_linetime=round(start_linetime);
    for j=minimum_hour:maximum_hour
        text(start_linetime-4,height_start+height_linetime+8,texlabel([num2str(mod(j,24)) 'h'],'literal'),'FontSize',fontsize)
        start_linetime = start_linetime + (60*minute_pixel);
    end
    
    for n = 1: size(pos_minprocess,1)
        text(pos_minprocess(n,2),pos_minprocess(n,1),texlabel([num2str(pos_minprocess(n,3),'%10.1f') 'min'],'literal'),'FontSize',fontsize)
    end
    
catch e
    disp(e.message)
end