%% create dataset  for neural network training
% train_x: array with all scans
% train_y: binary array with condition 1 = face, 0 = scrambled 
function createDataset()
addpath('');% spm
% get randint 
testsubject = randi([1,16],1); % ended up being subject 15 

trainsubjects  =  [1:16];
trainsubjects(trainsubjects==testsubject)=[];

%not full 208 scans are needed as a lot of data data got excluded
train_x =  zeros(150*15*3,79,95,79,'single');
train_y = zeros(150*15*3,1,'uint8');


% test_x = zeros(208*9,79,95,79,'single');
% test_y = zeros(208*9,1,'uint8');

% 
% train_x = [];
% train_y = [];
% 
% test_x = [];
% test_y = [];
% 
% 

index=0;
for subject = trainsubjects 
    fprintf('Subject %02d \n',subject);
    scanpth = sprintf('',subject); %scans 
    allscans = cellstr(spm_select('FPList',scanpth)); 
%     train_x = zeros(length(allscans),79,95,79);
%     train_y = zeros(length(allscans),1);  
    for scan = 1:length(allscans) 
   
        if 1%contains(allscans{scan,1},'run_01') || contains(allscans{scan,1},'run_02') %||contains(allscans{scan,1},'run_03') 
            index = index + 1;

            % load scan 
            volume = spm_vol(allscans{scan,1});
            % get intensity and coordinates of scan 
            [intensities ,coordinates]=spm_read_vols(volume);
            intensities = single(intensities);

            train_x(index,:,:,:)=intensities;
            %face =1 ,scrambled = 0
            if contains(allscans{scan,1},'famous') || contains(allscans{scan,1},'unfamiliar') 
                train_y(index)=1;
            else
                train_y(index)=0;
            end 
        end
    end
    %a for slice correction
%     train_x=[train_x,single(current_train_x)];
%     train_y=[train_y,uint8(current_train_y)];
end
% 
train_y = train_y(1:index,:,:,:);
train_x = train_x(1:index,:,:,:);



savepth= '';   


index2=1;

for subject = testsubject
    fprintf('Testsubject %02d',subject);
    scanpth = sprintf('',subject);
    allscans = cellstr(spm_select('FPList',scanpth)); 
   	test_x = zeros(length(allscans),79,95,79,'single');
    test_y = zeros(length(allscans),1,'uint8'); 
    for scan = 1:length(allscans)
        
        % possibility to only use first 3 runs
        if 1% contains(allscans{scan,1},'run_01') || contains(allscans{scan,1},'run_02')% ||contains(allscans{scan,1},'run_03') 

            index2=index2+1;
            % load scan 
            volume = spm_vol(allscans{scan,1});
            % get intensity and coordinates of scan 
            [intensities ,coordinates]=spm_read_vols(volume);
            intensities=single(intensities);

            test_x(index2,:,:,:)=intensities;
            %face =1 ,scrambled = 0
            if contains(allscans{scan,1},'famous') || contains(allscans{scan,1},'unfamiliar') 
                test_y(index2)=1;
            else
                test_y(index2)=0;
            end 
        end
    end
    test_y= uint8(test_y); %to keep size small
end


test_y = train_y(1:index2,:,:,:);
test_x = train_x(1:index2,:,:,:);
savepth= '';

filename = fullfile( savepth,'');
save( filename, 'train_x','train_y', 'test_x', 'test_y','trainsubjects','testsubject','-v7.3'); %need new version as otherwise the file is to big     

end
