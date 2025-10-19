close all
clear
clc

alpha_bar = zeros(1, 6);
aBarIndex = 0;


for file = ["PEEK_85kV.mat" "PEEK_95kV.mat" "PEEK_105kV.mat" "REES_85kV.mat" "REES_95kV.mat" "REES_105kV.mat"]
load(file)

aBarIndex = aBarIndex + 1;

if file == "PEEK_105kV.mat" | file == "PEEK_95kV.mat" | file == "PEEK_85kV.mat"
    collar_start = 217;
    collar_end = 357;
    collar_top = 263;
    collar_bottom = 306;
    background_l = 364;
    background_r = 437;
    background_t = 310;
    background_b = 485;
    background = images(:, background_l:background_r, background_t:background_b);
else
    collar_start = 219;
    collar_end = 362;
    collar_top = 263;
    collar_bottom = 335;
    background_l = 375;
    background_t = 318;
    background_r = 438;
    background_b = 468;
    background = images(:, background_l:background_r, background_t:background_b);
end

r = 6;
r_0 = 5;
dim = size(images);
d = ([0:(collar_end - collar_start)] .* ((r * 2) / (collar_end - collar_start))) - 6;   %x value in relation to center of the sample
L_model = zeros(1, length(d));
frames = randperm(dim(1), 40);    % row vector of 50 random integers between 1 and 20
frames = sort(frames, 'ascend');
alpha = zeros(collar_bottom - collar_top + 1, collar_end - collar_start + 1, length(frames));

if mod(aBarIndex, 3) == 0
figure
imshow(squeeze(images(1,:,:)))
hold on
xline([collar_start collar_end], 'r-', LineWidth=1)
yline([collar_top collar_bottom], 'r-', LineWidth=1)
xline([background_l background_r], 'm--')
yline([background_t background_b], 'm--')
title(file)
end

I_0 = mean(background, 'all');

%calculation and graph of the theoretical path length through the collar

for i = 1:length(d)
    if abs(d(i)) >= r_0
        L_model(i) = (2 * sqrt(r^2 - d(i)^2));
    else
        L_model(i) = 2 * (sqrt(r^2 - d(i)^2) - sqrt(r_0^2 - d(i)^2));
    end
end

%solving for alpha bar

i = 0;

for i = 1:length(frames)
    a = frames(i);
    current_frame = squeeze(images(a, :, :));
    for r = collar_top:collar_bottom
        for c = collar_start:collar_end
            I = current_frame(r, c);
            alpha(r - collar_top + 1, c - collar_start + 1, i) = ...
                    log(I / I_0) / L_model(c - collar_start + 1);
        end
    end
end

alpha_bar(aBarIndex) = mean(alpha(:, 2:(end - 1), :), 'all');

%graph
figure
plot(d, L_model, 'Color', 'k')
hold on

%using alpha bar to re-calulate and plot path length

plot_frames = randperm(dim(1), 3);

for f = plot_frames
frame1 = squeeze(images(f, :, :));
I_line = mean(frame1(collar_top:collar_bottom, collar_start:collar_end), 1);
L_calculated = log(abs(I_line ./ I_0)) ./ alpha_bar(aBarIndex);

plot(d, L_calculated)
end
grid on
title("Path Lengths for " + file)
legend("Theoretical Path Length", "image" + num2str(plot_frames(1)), "image" + num2str(plot_frames(2)), "image" + num2str(plot_frames(3)), 'Location', 'north')

fprintf("\n\nThe average alpha value for the collar in " + file + " is: %f", alpha_bar(aBarIndex));
fprintf("\nThe background intensity for " + file + " is: %f", I_0);

end

fprintf("\n\nPEEK Alpha Bar: %f", (mean(alpha_bar(1:3), 'all')))
fprintf("\nREES Alpha Bar: %f\n", (mean(alpha_bar(4:end), 'all')))