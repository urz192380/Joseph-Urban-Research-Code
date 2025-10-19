function [collapseFrame] = detectCollapse(imageSequence, sample_start, sample_end, sample_top, sample_bottom)
    

    collarBuffer = 36;
    windowSize = 9;             % Size of neighborhood for entropy filter

    for k = 1:size(imageSequence, 1)
        blurred = imgaussfilt(squeeze(imageSequence(k, ...
           sample_top:round((sample_top + sample_bottom) / 2), (sample_start - collarBuffer):(sample_end + collarBuffer))), 1);  % Denoise slightly

        % Compute local entropy
        entropyMap = entropyfilt(blurred, true(windowSize));
        avgEntropy(k) = mean(entropyMap(:));

        %fprintf("\nframe: %d", k)

        % subplot(1,2,1); imshow(gray); title("Grayscale Frame");
        % subplot(1,2,2); imshow(mat2gray(entropyMap)); title("Entropy Map");
        % drawnow;

    end

    smoothEntropy = smoothdata(avgEntropy, "gaussian", 7);

    lcv = 1;
    while smoothEntropy(lcv) ~= max(smoothEntropy)
        lcv = lcv + 1;
    end

    min_status = 0;

    while min_status == 0
        lcv = lcv - 1;
        if smoothEntropy(lcv - 1) > smoothEntropy(lcv) && smoothEntropy(lcv + 1) > smoothEntropy(lcv)
            min_status = 1;
        end
    end

    %First derivative using central differences
    dy_dx = gradient(smoothEntropy);
    
    dy_dx_smoothed = smoothdata(dy_dx, 'gaussian', 18);
    
    mu = mean(dy_dx_smoothed);        
    sigma = std(dy_dx_smoothed);     
    z_scores_d_dx = (dy_dx_smoothed - mu) / sigma;
    
    s = smoothdata(z_scores_d_dx, 'movmean', 13);
 
    % figure
    % plot(smoothEntropy, 'm-')
    % hold on
    % plot(avgEntropy, 'g-')
    % plot(s)

    lcv = 1;
    while s(lcv) ~= max(s)
        lcv = lcv + 1;
    end

    collapseFrame = lcv;
    fprintf("\n===================================")
    fprintf("\nSAMPLE COMPRESSION AT %dTH FRAME", collapseFrame)
    fprintf("\n...")
end