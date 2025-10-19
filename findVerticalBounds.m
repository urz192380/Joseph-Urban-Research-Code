function [ytop, ybot, ymaxmid, yminmid] = findVerticalBounds(img, collar_start, collar_end)

    smooth_win = 15;         %smoothing window size
    smooth_bounds = 15;      %final smoothing
    window_half_height = 10; %restrict edge search to ±10 pixels around midpoint edges

    xmid = round((collar_start + collar_end) / 2);
    y_line_mid = mean(img(:, xmid - 5:xmid + 5), 2);
    y_line_mid_smooth = smoothdata(y_line_mid, 'gaussian', smooth_win);
    dy_mid = diff(y_line_mid_smooth);

    [~, ymaxmid] = max(dy_mid);
    [~, yminmid] = min(dy_mid);

    xvals = max(1, collar_start) : min(size(img,2), collar_end);
    num_x = length(xvals);

    ytop = zeros(1, num_x);
    ybot = zeros(1, num_x);

    for i = 1:num_x
        x = xvals(i);
        y_line = img(:, x);
        y_line_smooth = smoothdata(y_line, 'gaussian', smooth_win);
        dy = diff(y_line_smooth);

        top_range = max(1, ymaxmid - window_half_height) : min(length(dy), ymaxmid + window_half_height);
        bot_range = max(1, yminmid - window_half_height) : min(length(dy), yminmid + window_half_height);

        [~, local_max_idx] = max(dy(top_range));
        [~, local_min_idx] = min(dy(bot_range));

        ytop(i) = top_range(local_max_idx);
        ybot(i) = bot_range(local_min_idx);
    end

    ymaxmid = max(ytop(10:end - 10));
    yminmid = min(ybot(10:end - 10));

    ytop = smoothdata(ytop, 'gaussian', smooth_bounds);
    ytop = ytop + 1;
    ybot = smoothdata(ybot, 'gaussian', smooth_bounds);
end
