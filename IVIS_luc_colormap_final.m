clc; clear all;
%%Pick which directory to edit (must have lum & pho files with consistent
%%naming structure)

%create loop to iterate through different directories
directory = 'C:\Users\rahil\Box\Files for Rahil\05192022\JSA20220519091713';
dirFiles = dir('C:\Users\rahil\Box\Files for Rahil\05192022');
for i = 3:length(dirFiles)
    folder = dirFiles(i).name;
    file_name = char("C:\Users\rahil\Box\Files for Rahil\05192022\" + convertCharsToStrings(folder));
    
    S = dir(fullfile(file_name,'lum*.TIF')); % pattern to match filenames.
    count = strings(11,numel(S)); %build blank table for data 
    %loop stores luminescent file name, mouse name, timestamps in respective
    %rows (each column = new mouse)

    for k = 1:numel(S)
        %read mouse number from filename
        count(1,k) = {S(k).name};
        lumin_file = fullfile(file_name,S(k).name);  
        stamp=split(lumin_file,"C");
        text=char(stamp(2));
        count(2,k) = text(1:5); %put mouse name in count row2
        count(3,k) = text(7:20);%put timestamp in count row 3
        %read in luminescent file
        lum = imread(lumin_file);
        lum = imresize(lum,[512,512]); %always resize to match photo
        %lum = lum+1000;
        %imshow(lum)
        
        %% set your colorbar
        hi_val=10000; %set max val on colorbar
        lo_val=525; %set lowest val on colorbar
        %%
    %     %get binning factor
    %     fname=split(lumin_file,"-");
    %     binning=string(fname(7));
    %     if binning=="60lb"
    %         %integ=1.94*10^(-18)*integ.^3-1.35*10^(-10)*integ.^2+2540*integ+1160;
    %         lum=lum.*1.2;
    %     elseif binning=="30lb"
    %         lum=lum.*1.05;
    %         %integ=-1.99*10^(-23)*integ.^3+1.61*10^(-10)*integ.^2-0.0164*integ+173000;
    %     end    
       
        %Add size (or brightness?) of tumor to corresponding row (higher row = smaller area)
        %% write to output number of pixels over certain thresholds 
        lum_thresh=lum>1400; %cheate binary of pixels over threshold
        count(5,k) = string(sum(sum(lum_thresh)));%put brightness of tumor as row5
        lum_thresh=lum>1200; %cheate binary of pixels over threshold
        count(6,k) = string(sum(sum(lum_thresh)));%put brightness of tumor as row6
        lum_thresh=lum>1000; %cheate binary of pixels over threshold
        count(7,k) = string(sum(sum(lum_thresh)));%put brightness of tumor as row7
        lum_thresh=lum>800; %cheate binary of pixels over threshold
        count(8,k) = string(sum(sum(lum_thresh)));%put brightness of tumor as row8
        lum_thresh=lum>600; %cheate binary of pixels over threshold
        count(9,k) = string(sum(sum(lum_thresh)));%put brightness of tumor as row9
        lum_thresh=lum>lo_val; %lowest value %binary of pixels over threshold
        count(10,k) = string(sum(sum(lum_thresh)));%put brightness of tumor as row10
        
        lum_masked=(uint16(lum_thresh).*lum);
        lum_quant=sum(sum(lum_masked));
        
        lum_masked(lum_masked>hi_val)=hi_val;
        integ = string(lum_quant);
        count(12,k) = integ; %put integration of values as rowx of count
        
        
        lum_masked(1,1)=hi_val; %set one pixel to max value so low images not to be scaled weird
        
        %% make green colormap%%
        %cmap = hot; %jet, winter, summer, gray, etc
        %cmap = [cmap(:,3),cmap(:,1),cmap(:,2)];
        %cmap(1,3)=0; %set 0 to black no matter what the actual color should be
        
        %% make rainbow colormap%%
        gray_bright=gray*5; %add gray cmap together to get a brighter map
        gray_bright(gray_bright>1)=1; %set all values above 1 to 1 so half all bright
        cmap=jet.*gray_bright;
        rb = grs2rgb(lum_masked,cmap); %convert grayscale to RGB image, function from internet (make sure this function is in the same file)
        %imshow(rb)
    
    
        %Download 
        % open the file
        fid=fullfile(file_name,'AnalyzedClickInfo.txt'); 
        str = extractFileText(fid);
        %Extract Cage Number and Animal Number
        line = extractBetween(str,'Animal Number:','Animal Strain:');
        %Extract Date
        date = extractBetween(str, 'ClickNumber', 'ClickInfoType');
        date = extractBetween(date, 6,13);
        %Clean up extraction
        line = strip(line);
        %Get cage number
        cage_num = extractBefore(line, 'M');
        %Get mouse number
        mouse_num = extractAfter(line, 'M');
        %sscanf(mouse_num, '%d')
        cage_num=cage_num(1);
        mouse_num=mouse_num(1);
    
        %% write colored photo
        photo_file = strrep(lumin_file,'luminescent','photograph');
        pho=imread(photo_file);
        pho = imresize(pho,[512,512]);
        pho=double(cat(3,pho,pho,pho));
        pho=pho/7500;
        combined=pho+rb;
    
        position = [10 10; 10 40];
        data = {num2str(cage_num),num2str(mouse_num)};
        combined_text = insertText(combined,position,data, BoxOpacity= 0,FontSize=18,TextColor="white");
        imshow(combined_text)
        comb_file = strrep(lumin_file,'luminescent',cage_num+'_'+mouse_num+'_'+date);
        imwrite(combined_text,comb_file,'tif');
     
    
    
    end
end
done = 'done';