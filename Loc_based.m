function [score, meanval] = Loc_based(im1,im2)
%close all;
%clear all;
%% parameters
imsize = 160;
spacing  = 8;
num = 13;
pad = 24;
blm = 0.33;
%im1 = 'n4CASIA/0001r/0001_m_r_03.jpg';
%im2 = 'n4CASIA/0001l/0001_m_l_05.jpg';

%% reading images and getting layers
a0 = imread(im1);
a0 = imresize(a0,[imsize,imsize]);
a0pad = imgpadding(a0,pad);
a1 = calc_next(a0);
a1pad = imgpadding(a1,pad);
a2 = calc_next(a1);
[r2,c2] = size(a2);

b0 = imread(im2);
b0 = imresize(b0,[imsize,imsize]);
b0pad = imgpadding(b0,pad);
b1 = calc_next(b0);
b1pad = imgpadding(b1,pad);
b2 = calc_next(b1);




%% getting ref points
x = [1:spacing:num*spacing] + (imsize-spacing*(num-1))/2 - 1;
[pr0,pc0] = meshgrid(x,x);
pr0 = pr0(:);
pc0 = pc0(:);
[point_num,tmp] = size(pr0);

%myplot(a0,pr0,pc0);

pr1 = floor(pr0/2);
pc1 = floor(pc0/2);
pr2 = floor(pr1/2);
pc2 = floor(pc1/2);
%% using BLPOC to find out the final corresponding points stored as [qr0,qc0]
[x2, y2, val2] = displacement(a2,b2,blm);
qr2 = pr2 + x2;
qc2 = pc2 + y2;
for i=1:1:point_num
     if qr2(i) > r2 || qr2(i) < 1
         qr2(i) = nan;
         qc2(i) = nan;
     end
     if qc2(i) > c2 || qc2(i) < 1
         qc2(i) = nan;
         qr2(i) = nan;
     end
end

% layer1
[qr1,qc1,val1] = getqloc(pr1,pc1,qr2,qc2,point_num,a1pad,b1pad,pad,blm);
% layer0
[qr0,qc0,val0] = getqloc(pr0,pc0,qr1,qc1,point_num,a0pad,b0pad,pad,blm);

%myplot(b0,qr0,qc0);
qr0 = reshape(qr0,num,num);
qc0 = reshape(qc0,num,num);

score = dis_score(qr0,qc0);
meanval = nanmean(abs(val0));
end