%% OR image processing
option.command = 'KaiserAvg'; 
option.Nwin = 20;
option.beta = [ 0.2 8.0];

data = ProcessSpectralInterferogram(4096,option)

datacrop =crop(data, 0, 0, [1.5 6.0]); %crop the data to just the image size I am interested in

bkg = median(datacrop.mag,2); %calculate a backgroung to remove some fixed pattern noise

databkg = datacrop;
databkg.mag = databkg.mag-bkg;
%below 2 lines is just doing some scaling so that the minimum is 1 and the
%max is 10^4. That way when I take the log10 of the data the min is 0 and
%max is 4. 
databkg.mag = databkg.mag-min(databkg.mag,[],'all');
databkg.mag = databkg.mag./max(databkg.mag,[],'all')*9999+1; 

dataflt = databkg; %this is done just so that all of the elements of the databkg structure are included in dataflt
dataflt.mag = medfilt3(databkg.mag,[3 3 7]);

render = dataflt; %I just did this so that in the next section whatever I assigned to render would be rendered.


%% render
ScaleFactor = [render.ImageDimensions(3)/render.ImageDimensions(1),render.ImageDimensions(3)/render.ImageDimensions(2),1];
pixelsize = render.ImageDimensions./double(render.ImageDimensionsPixels);
ScaleFactor = pixelsize/max(pixelsize,[],'all');
figure(1);orthosliceViewer(log10(abs(render.mag)),'ScaleFactors', ScaleFactor);colormap('jet')
