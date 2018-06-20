function [linked_edge] = hysteresis_thresholding(threshold_low, threshold_high, linked_edge, edge, angle)
    [h,w] = size(edge);
    bin = zeros(h, w);
    bin(edge >= threshold_high) = 1;
    count = sum(bin);
    while(1)
        for i = 1: w
            for j = 1:h
                 if bin(i, j) == 1               % must be edge
                   linked_edge(i, j) = edge(i, j);
                   if angle(i,j) == 0
                       try
                           if edge(i, j-1) >= threshold_low 
                               linked_edge(i, j-1) = edge(i, j-1);
                               bin(i, j-1) = 1;
                           end
                           if edge(i, j+1) >= threshold_low
                               linked_edge(i, j+1) = edge(i, j+1);
                               bin(i, j+1) = 1;
                           end       
                       end
                   end
                   if angle(i,j) == pi/4
                       try
                           if edge(i+1, j+1) >= threshold_low 
                               linked_edge(i+1, j+1) = edge(i+1, j+1);
                               bin(i+1, j+1) = 1;
                           end
                           if edge(i-1, j-1) >= threshold_low
                               linked_edge(i-1, j-1) = edge(i-1, j-1);
                               bin(i-1, j+1) = 1;
                           end
                       end
                   end
                   if angle(i,j) == pi/2
                       try
                           if edge(i-1, j) >= threshold_low 
                               linked_edge(i-1, j) = edge(i-1, j);
                               bin(i-1, j) = 1;
                           end
                           if edge(i+1, j) >= threshold_low
                               linked_edge(i+1, j) = edge(i+1, j);
                               bin(i+1, j) = 1;
                           end
                       end
                   end
                   if angle(i,j) == 3*pi/4
                       try
                           if edge(i+1, j-1) >= threshold_low 
                               linked_edge(i+1, j-1) = edge(i+1, j-1);
                               bin(i+1, j-1) = 1;
                           end
                           if edge(i-1, j+1) >= threshold_low
                               linked_edge(i-1, j+1) = edge(i-1, j+1);
                               bin(i-1, j+1) = 1;
                           end
                       end
                   end
                 end
            end
        end
        % if there is little difference in two iterations, stop it!
        count_ = sum(bin);
        if count_ - count <= 5
            break;
        else
            count = count_;
        end
    end
end
