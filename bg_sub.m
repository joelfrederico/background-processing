function data=bg_sub()
	% Make sure E200_data is on my path.
	addpath('../../../');

	% Path to the dataset I want.
	% Note that it doesn't need the prefix to the location of /nas anymore!
	% path='/nas/nas-li20-pm01/E200/2013/20130428/E200_10794';
	path='/nas/nas-li20-pm01/E200/2013/20130428/E200_10836';
	% path='nas/nas-li20-pm01/E200/2013/20130514/E200_11159';
	
	% Load this data.
	data=E200_load_data(path);
	
	% Loop over images
	image_name_str=fieldnames(data.raw.images)
	for i=1:size(image_name_str)
		% Get image name
		imgname=image_name_str{i};
		display(imgname);

		% Loop over steps
		steps=unique(data.raw.scalars.step_num.dat);
		imgstruct=data.raw.images.(imgname);
			
		img_proc=[];
		for j=steps
			bool= (data.raw.scalars.step_num.dat==j);
			wanted_UIDs = data.raw.scalars.step_num.UID(bool);
			wanted_UIDs = intersect(wanted_UIDs,imgstruct.UID);
			display(['Loading ' num2str(2*size(wanted_UIDs,2)) ' images ...']);
			tic;
			[img,bg]=E200_load_images(imgstruct,wanted_UIDs,data);
			img_num=size(img,2);
			[xres,yres]=size(img{1});
			img=cell2mat(img);
			bg=cell2mat(bg);
			sub=reshape(img-uint16(bg),xres,yres,img_num);
			size(sub)
			toc;
			img_proc=cat(3,img_proc,sub);
		end
		data.processed.images.(imgname) = data.raw.images.(imgname);
		data.processed.images.(imgname).dat=img_proc;
		data.processed.images.(imgname).isfile=zeros(1,size(img_proc,3));
	end
end

function data=add_processed(data,varargin)
	% data.processed.images.(name).
end

function old()
	% I want to load data from YAG.
	imgstruct=data.raw.images.YAG;

	% I want to load only images from the 2nd step
	bool1=(data.raw.scalars.step_num.dat==1);

	% I want the UIDs of the 2nd step
	wanted_UIDs = data.raw.images.YAG.UID(bool1);

	% Load those images
	% Note: The third argument, data, is optional.
	%	But including it allows E200_load_images
	%	to determine if the images are saved
	%	remotely or locally.
	display(['Loading ' num2str(2*size(wanted_UIDs,2)) ' images ...']);
	tic;
	[img,bg]=E200_load_images(imgstruct,wanted_UIDs,data);
	toc;
	display(sprintf('\n'));
	
	% Loop over my images
	% Note: only show first 5.
	display('Click on the image to continue.');
	for i=1:5
		display(['Image ' num2str(i) '...']);
		% Plot the image
		imagesc(img{i}-uint16(bg{i}));
		% Wait for the user to press a key
		waitforbuttonpress;
	end

	% Close the figures.
	close('all');
end
