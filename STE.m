%Endpoint Speech Detection
Y1 = awgn(data,50);
energy = STE(Y1,500);
b = averageZCR(Y1,100);
a = size(data);
length = a(1);
[startDet,endDet] = Detection(energy,20000, 0.8);
entropy = spectralEntropy(Y1,fs);

a = size(data);
figure(2)
tiledlayout(2,1)
nexttile
plot(Y1);
title('Signal plus markers')
hold on
plot([startDet; startDet], repmat(ylim',1,size(startDet,2)), '--g')
plot([endDet; endDet], repmat(ylim',1,size(endDet,2)), '--r')
hold off
%middle plot
nexttile
plot(energy)
title('Energy Plot')
hold on
hold off


figure(1)
tiledlayout(4,1)

nexttile
plot(Y1);
title('Signal plus markers')
hold on
plot([startDet; startDet], repmat(ylim',1,size(startDet,2)), '--g')
plot([endDet; endDet], repmat(ylim',1,size(endDet,2)), '--r')
hold off

%middle plot
nexttile
plot(energy)
title('Energy Plot')
hold on
hold off

nexttile
plot(b)
title('ZCR Plot')
hold on
hold off

%bottom plot
nexttile
title('ratio Plot')
hold on
plot(energy/b)
hold off
Estimating the Spectral Energy of a signal

%SHORT TERM ENERGY FUNCTION
function [energy] = STE(data,WindowLength)
a = size(data);
i = a(1);
Y1 = [0];
Y1 = data;
energy= [];
length = 100;%Default value
length = WindowLength;
for k = 1:i
    energy(k) = 0; %Default the value to zero
    for N= 0:length   %Using WindowFunction
        %sanity check, 
        if (k+N)<=i
        energy(k) = Y1(k+N)*Y1(k+N) + energy(k); %Take the square of the current amplitude and adds it onto the sum
        end
    end
end
end

%Zero Crossing Rate
function [zcr] = averageZCR(yi, framelength)
%yi is a vector, framelength is duration. Returns a vector of ZCR
a = size(yi);
length = framelength;
i = a(1);
zcr = 0*(1:i);
for n = 1:i %for the entire signal
    for k =0:length %considering a window size of size k for point n
        if ((k+n)<=i)&& ((n+k-1)>0) %making sure we don't reference non-existant indices
        zcr(n) = abs(sign(yi(n+k))-sign(yi(n+k-1))) + zcr(n);
        end
    end
    %upon exiting above loop
    zcr(n) = zcr(n)/2*length;   %computes the average for that point
end
end

%Detection 
function [Start, End] = Detection(energy, WindowSize, Tolerance)
   a = size(energy);
   i = a(2);
   counter = 1;
   Start = [];
   End= [];
   threshold = 0;
   fs = 16000;
   for k = 1:0.1*fs
       %for the first portion of the clip, which is assumed to be silent
       threshold = threshold + energy(k);       
   end
   threshold = 1.5*threshold/(0.1*fs);
   for n = 1:i

        if (energy(n)> threshold) && counter == 1
          
          PosCount=0; %begin window check for start of signal
          for k = 0:WindowSize%checking 100 samples ahead
              if ((k+n)<=i) %while indices are valid
                if (energy(n+k)> threshold)
                    PosCount= PosCount +1;%increment positive Count
                end
              end
          end
          
          if (PosCount>= Tolerance*WindowSize) %Majority of signal had high energy
          counter = -1;
          Start = [Start,n]; %append position into array
          end
        end
        
       if (energy(n)<= threshold) && counter == -1 %We have a noise
        
          PosCount=0; %begin window check  
          for k = 0:WindowSize %Looking ahead some samples
               if ((k+n)<=i) %while indices are valid
             
                 if (energy(n+k)<= threshold) %if future values are loud
                    PosCount= PosCount +1;%increment positive Count
                 end
                 
               end
                 if ((k+n)>=i) %if we are at end of array
                     PosCount = PosCount +1;
                 end
          end
           
          if (PosCount>=Tolerance*WindowSize) %Upon exiting the for loop
           counter = 1;                         
           End = [End,n];
          end
       end          
   end
end


    
  

