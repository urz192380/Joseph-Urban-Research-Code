function [image_sequence] = maskNew(image_sequence, I0avg)

%status variable 1 = bw, 2 = color, 3 = uv
%I0avg = 0.97

x_sample_buffer = 10;   %buffer on the right/ left of the smaple (pixels) to adjust
y_sample_buffer = 2;    %buffer on the top/bttom of sample, this value should be good

%explosion box dimensions
exL = 191;
exR = 476;
exT = 90;
exB = 170;

image_sequence = new_crop(image_sequence);  %crops the image stack

%this find the upper and lower boundaries for image 1 - only used as
%intital values
img = squeeze(image_sequence(1, :, :));
x = 331;
y_line = img(:, x);
y_line_smoothed = smoothdata(y_line, 'gaussian', 13);
lcv = 1;

while y_line_smoothed(lcv) < 0.3
    lcv = lcv + 1;
end
sample_top = lcv;
while y_line_smoothed(lcv) > 0.3
    lcv = lcv + 1;
end
sample_bottom = lcv - 1;

[sample_start, sample_end] = ...
    auto_detect_sample_v3(img, sample_top, sample_bottom);

sample_start = sample_start - x_sample_buffer;
sample_end = sample_end + x_sample_buffer;
sample_top = sample_top + y_sample_buffer;
sample_bottom = sample_bottom - y_sample_buffer;

%compression frame (TAMPER WITH GAUSSIAN SMOOTHING OF ENTROPY DATA TO TUNE)
%(works best with bw tmx video)
compressFrame = detectCollapse(image_sequence, sample_start, sample_end, sample_top, sample_bottom); 

%finding the pin (for post-compression)
x_pin = sample_top - 17;
x_pin_line = img(x_pin, :);
x_pin_line_smoothed = smoothdata(x_pin_line, 'gaussian', 13);

lcv = 1;
while x_pin_line_smoothed(lcv) > 0.3
    lcv = lcv + 1;
end
pinL = lcv - 10;
while x_pin_line_smoothed(lcv) < 0.3
    lcv = lcv + 1;
end
pinR = lcv + 2;
pinFrame = compressFrame - 13;

figure

for big = 1:size(image_sequence, 1)
        
    img = squeeze(image_sequence(big, :, :));       %update image
    [ytop, ybot, handleTop, handleBot] = findVerticalBounds(img, pinL, pinR);      %this find the upper and lower boundaries
    
    if abs(handleBot - handleTop) < 3  %when collision occours this will terminate detection
        fprintf("\nPIN COLLISION AT FRAME: %d", big)
        fprintf("\n...")
        break
    elseif big <= pinFrame
        [sample_start, sample_end] = ...
            auto_detect_sample_v3(img, handleTop, handleBot);
    else
        sample_start = pinL;
        sample_end = pinR;
    end
    
    if big <= pinFrame
        sample_start = sample_start - x_sample_buffer;
        sample_end = sample_end + x_sample_buffer;
    end
    
    cla;
    imshow(img)
    hold on
    xline([sample_start sample_end], 'm--')
    yline([handleTop handleBot], 'g--')
    plot(pinL:1:pinR, ytop, 'b');
    plot((pinL:1:pinR), ybot, 'r');
    title("MASKING PROGRESS: FRAME " + num2str(big))
    drawnow;

    if big <= compressFrame
        for i = 1:size(img, 2)
            if (i < sample_start) || (i > sample_end)
                img(:, i) = I0avg;
            else
                ytoplim = ceil(ytop(i - sample_start + 1));
                ybotlim = floor(ybot(i - sample_start + 1));
                img(1:ytoplim, i) = I0avg;
                img(ybotlim:end, i) = I0avg;
            end
        end
    else
        for i = 1:size(img, 2)
            if (i < exL) || (i > exR)
                img(:, i) = I0avg;
            elseif (i < sample_start && i >= exL) || ((i > sample_end && i <= exR))
                ytoplim = exT;
                ybotlim = exB;
                img(1:ytoplim, i) = I0avg;
                img(ybotlim:end, i) = I0avg;
            else
                ytoplim = ceil(ytop(i - sample_start + 1));
                ybotlim = floor(ybot(i - sample_start + 1));
                img(1:ytoplim, i) = I0avg;
                img(ybotlim:end, i) = I0avg;
            end
        end
    end

    image_sequence(big, :, :) = img;

end

for lcv = big:size(image_sequence, 1)
    image_sequence(lcv, :, :) = I0avg;
end

fprintf("\nMASKING COMPLETE")
fprintf("\n===================================")

end

