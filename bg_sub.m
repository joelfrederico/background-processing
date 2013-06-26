function data=bg_sub(data)
	% Make sure E200_data is on my path.
	addpath('../../../');

	% Loop over images
	image_name_str=fieldnames(data.raw.images);
	for i=1:size(image_name_str)
		% Get image name
		imgname=image_name_str{i};

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
			toc;
			img_proc=cat(3,img_proc,sub);
		end
		img_proc_file=[];
		for j=1:size(img_proc,3)
			UID=data.raw.images.(imgname).UID(j);
			if exist('temp')~=7
				mkdir('temp');
			end
			str=['temp/Background_' imgname '_bg_' num2str(UID) '.mat'];
			img=img_proc(:,:,j);
			save(str,'img');
			img_proc_file=[img_proc_file,{str}];
		end
		imgname_bg=[imgname '_bg'];
		data.processed.images.(imgname_bg) = data.raw.images.(imgname);
		data.processed.images.(imgname_bg).dat=img_proc_file;
		% data.processed.images.(imgname_bg).isfile=zeros(1,size(img_proc,3));
		data.processed.images.(imgname_bg).isfile=ones(1,size(img_proc,3));
	end
end
