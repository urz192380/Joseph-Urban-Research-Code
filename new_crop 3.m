function [imgStack] = new_crop(imgStack)
    img = squeeze(imgStack(1, :, :));
    dim = size(img);
    
    lcv = 1;
    x = dim(1) / 2;
    x_line = img(x, :);
    
    while x_line(lcv) == 0
        lcv = lcv + 1;
    end
    
    boundary1 = lcv;
    imgStack(:, :, 1:boundary1) = 1;
    
    lcv = dim(2);
    x_line = img(x, :);
    
    while x_line(lcv) == 0
        lcv = lcv - 1;
    end
    
    boundary2 = lcv;
    imgStack(:, :, boundary2:end) = 1;
end
