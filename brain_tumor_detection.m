%%%%%%%%%%%%%%%%%image_inputut-image%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Taking image as image_input. . . . . . ");
s=imread('F:\semester projects\semester 5\tumor1.jpg');
figure;
imshow(s);
title('\bf Input image','FontSize',20,'color','black');
 
%%%%%%%%%%%%%%%%%RGB & resizing%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("converting to RGB. . . . . .");
disp("resizing image. . . . . . .");
s=imresize(s,[256,256]);
%s=label2rgb(im2gray(s));
figure;
imshow(label2rgb(im2gray(s)));
title('\bf RGB','FontSize',20,'color','black');
 
%%%%%%%%%%%%%%%%%Applying filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%ANISTROPIC DIFUSSION%%%%%%%%%%%%%%%%%%%%%%%
disp("Aplying the filter. . . . . . .");
image_input = imdiffusefilt(s);%%anidtropic diffusion filter
disp("Anistropic diffusion applied. . . . . . .");
image_input = uint8(image_input);%just reapplying uint-8, incase there is no unit-8, therefore%0-255==2^8//dealing in grayscale
%css=size(image_input,3);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TASK-3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if size(image_input,3)>1%double checking that should not be RGB
    image_input=rgb2gray(image_input);
end
%thresholding
css=image_input(:);%css=256*256
sout=image_input;
 
%getting maximum value from the 256*256
mx_value=max(image_input(:));%max(css)//max returns the maximum color intensity present in image as parameter
%getting minimum value from the 256*256
mn_value=min(image_input(:));
%getting average value from the obtained data
Avrg=(mx_value+mn_value)./2;%(.) or without (.)
%applying threshold value, it is changed with respect to hit&Trial technique
threshHold=Avrg+45;
 
sizeCheck=size(image_input,2);%%2 for y and 1 for x that's why we have taken image_input,2
%getting the size value first, from first dimension and it will be 256,
%as we resized the image earlier, then performing nested loop
for x=1:1:size(image_input,1)
    for y=1:1:size(image_input,2)
        if image_input(x,y)>threshHold
            %if size will be greater than our threshold, then we put as 1
            sout(x,y)=1;
        else
%if size will be lesser than our threshold, then we put as 0
            sout(x,y)=0;
        end
    end
end
%regionprop() will get the properties of image, which we required
%logical(sout) returns the total size which is 256*256
%Soldidity=area's pixels from the input image
%Area=area from the image_inputut image
%BoundingBox=position and its size from the input image w.r.t(areaTotal) 
stats=regionprops(logical(sout),'Solidity','Area','BoundingBox');
%Getting density
Image_density=[stats.Solidity];
%Getting Area
Image_area=[stats.Area];
%Applying pre-processing before actual processes
Image_high_dense_area=Image_density>0.6;
%seperating the area which is more dense
mx_area=max(Image_area(Image_high_dense_area));
%apply labeling
tumor_label=find(Image_area==mx_area);
%converting the image in BlacknWhite of size 256*256
label=bwlabel(sout);
%returning true(1,1) values of ismember(a,b) in tumor
tumor=ismember(label,tumor_label);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if mx_area>100%%%puttiing another threshold
   figure;
   imshow(tumor)
   title('tumor alone','FontSize',20);
else
    
    %disp('no tumor');
    BW1 = edge(image_input,'Canny');
    figure;imshowpair(BW1,mx_area)
    title('canny FILTER','FontSize',20);
    h = msgbox('No Tumor!!','status');
    return;
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Eroded Image 
range = 5;
rad = floor(range);
[p,q] = size(tumor);
filledImage = imfill(tumor, 'holes');%%neglecting blckish region inside hole
for i=1:p
   for j=1:q
       x_1=i-rad;
       x_2=i+rad;
       y_1=j-rad;
       y_2=j+rad;
       if x_1<1
           x_1=1;
       end
       if x_2>p
           x_2=p;
       end
       if y_1<1
           y_1=1;
       end
       if y_2>q
           y_2=q;
       end
       ErodedPart(i,j) = min(min(filledImage(x_1:x_2,y_1:y_2)));
   end
end
figure
imshow(ErodedPart);
title('eroded image','FontSize',20);
tumorOutline=tumor;
tumorOutline(ErodedPart)=0;
figure;  
imshow(tumorOutline);
title('Tumor Outline','FontSize',20);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Tumor Outline
rgb = image_input(:,:,[1 1 1]);
R = rgb(:,:,1);
R(tumorOutline)=255;
G = rgb(:,:,2);
G(tumorOutline)=0;
B = rgb(:,:,3);
B(tumorOutline)=0;
OutlineInsertedTumor(:,:,1) = R; 
OutlineInsertedTumor(:,:,2) = G; 
OutlineInsertedTumor(:,:,3) = B; 
figure;
imshow(OutlineInsertedTumor);
title('Detected Tumer','FontSize',20);


BW1 = edge(image_input,'Canny');
figure;imshowpair(BW1,tumor)
title('canny FILTER','FontSize',20);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BW2 = edge(image_input,'Prewitt');%%%%%%Prewitt filter is used for detecting edge
figure;imshowpair(BW2,tumor)
title('PREWIT FILTER','FontSize',20);
BW2 = edge(image_input,'Prewitt');
figure;imshowpair(BW2,tumor)
title('PREWIT FILTER','FontSize',20);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%making box on image, after pre-processing
 
%getting bounding box around high dense area~(detected tumor)
box = stats(tumor_label);
%making boundary box area size of max area(pre-processing)
wantedBox = box.BoundingBox;
%%%%%%%%%%%%%%%%%%%DONE task#1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(241);imshow(s);title('Input image','FontSize',20);
subplot(242);imshow(image_input);title('Filtered image','FontSize',20);
subplot(243);imshow(s);title('Bounding Box','FontSize',20);hold on;rectangle('Position',wantedBox,'EdgeColor','yellow');hold off;
subplot(244);imshow(tumor);title('Tumor alone','FontSize',20);
subplot(245);imshow(tumorOutline);title('Tumor Outline','FontSize',20);
subplot(246);imshow(OutlineInsertedTumor);title('Dectected','FontSize',20);
subplot(247);imshowpair(BW1,tumor);title('CANNY FILTER','FontSize',20);
subplot(248);imshow(label2rgb(im2gray(s)));title('RGB image','FontSize',20);