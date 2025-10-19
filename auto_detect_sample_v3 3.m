function [sample_start, sample_end] = ...
    auto_detect_sample_v3(img, top, bottom)



y = round((top + bottom) / 2);
sample_start_offset = 3;

%cropped = images(:,:,:);

%img = squeeze(cropped(big_i, :, :));

y_raw = img((y - 1):(y + 4), :);
y_row = mean(y_raw, 1);
dim = size(img);
y_row_clean = smoothdata(y_row, 'gaussian', 9);
lcv = 1;

% First derivative using central differences
dy_dx = gradient(y_row_clean, 1:dim(2));

dy_dx_smoothed = smoothdata(dy_dx, 'gaussian', 18);

mu = mean(dy_dx_smoothed);        
sigma = std(dy_dx_smoothed);     
z_scores_d_dx = (dy_dx_smoothed - mu) / sigma;

s = smoothdata(z_scores_d_dx, 'movmean', 13);
%sample start

while s(lcv) ~= min(s)
    lcv = lcv + 1;
end

sample_start = lcv - sample_start_offset;

%sample end

while s(lcv) ~= max(s)
    lcv = lcv + 1;
end

sample_end = lcv;


% figure
% imshow(img);
% hold on
% xline([sample_start sample_end], 'Color', 'g')


% figure
% plot(s)
% hold on
% plot(z_scores_d_dx)
% legend("z scores mod", "z scores")


end