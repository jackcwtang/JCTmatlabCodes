%%  RegStackTform.m
%   Takes volume data (XYZ) and uses imregtform to register the stack with
%   the first frame (Y=1).
function [regstack] = RegStackTform(stack)
    regstack = zeros(size(stack));
    regstack(:,1,:) = stack(:,1,:);
    [optimizer, metric] = imregconfig('monomodal');
    optimizer.MaximumIterations = 500;
    message = sprintf('Registering %d frames',size(stack,2));
    h = waitbar(0,message); % opens waitbar to show progress
    for i=2:size(stack,2)
        tform = imregtform(squeeze(stack(:,i,:)),squeeze(stack(:,1,:)),'translation',optimizer,metric);
        regstack(:,i,:) = imwarp(squeeze(stack(:,i,:)),tform,'OutputView',imref2d(size(squeeze(stack(:,1,:)))));
        waitbar(i/size(stack,2),h,message); % update waitbar to show progress
    end
    close(h)
    load('handel.mat')
    sound(y(1:16000),Fs)
end