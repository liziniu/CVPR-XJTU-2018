function [edge] = non_maximum_suppression(magnitude, angle, edge)
   [h,w] = size(edge);
   for i = 1: w
       for j = 1: h
           if angle(i,j) == 0
               try
                   if magnitude(i,j) > magnitude(i-1, j) && magnitude(i,j) > magnitude(i+1, j)
                       edge(i, j) = 1;
                   else
                       edge(i, j) = 0;
                   end
               end
               edge(i, j) = 1;
           end
           if angle(i,j) == pi/4
               try
                   if magnitude(i,j) > magnitude(i+1, j-1) && magnitude(i,j) > magnitude(i-1, j+1)
                       edge(i, j) = 1;
                   else
                       edge(i, j) = 0;
                   end
               end
               edge(i, j) = 1;
           end
           if angle(i,j) == pi/2
               try
                   if magnitude(i,j) > magnitude(i, j-1) && magnitude(i,j) > magnitude(i, j+1)
                       edge(i, j) = 1;
                   else
                       edge(i, j) = 0;
                   end
               end
               edge(i, j) = 1;
           end
           if angle(i,j) == 3*pi/4
               try
                   if magnitude(i,j) > magnitude(i-1, j-1) && magnitude(i,j) > magnitude(i+1, j+1)
                       edge(i, j) = 1;
                   else
                       edge(i, j) = 0;
                   end
               end
               edge(i, j) = 1;
           end
       end
   end
end
                   
                   