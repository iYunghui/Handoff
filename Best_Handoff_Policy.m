clc;

% 參數設定
% BS parameter (dBm)
E = 5;
T = -110;
Pt = -50;
Pmin = -125;
% car parameter
poisson = 1/30;
v = 10 ;% m/s
% direction probability: s-stright, r-right, l-left
direction = ['s','s','s','r','r','l'];
directionS = ['s','s','s','w','w','e'];
directionW = ['w','w','w','n','n','s'];
directionN = ['n','n','n','e','e','w'];
directionE = ['e','e','e','s','s','n'];

%car = struct('x',{},'y',{},'direction',{},'in',{},'BS',{},'power',{});
car_x = zeros(1,2000);
car_y = zeros(1,2000);
car_direction = zeros(1,2000);
car_in = zeros(1,2000);
car_BS = zeros(1,2000);
car_power = zeros(1,2000);

entryX = [750,1500,2250,3000,3000,3000,2250,1500,750,0,0,0];
entryY = [0,0,0,750,1500,2250,3000,3000,3000,2250,1500,750];
entryD = ['s','s','s','w','w','w','n','n','n','e','e','e'];

BSX = [750,2250,2250,750];
BSY = [750,750,2250,2250];

HandoffNum = zeros(1, 86400);%00);
for i=1:86400
    P = ((poisson*1)*exp((-poisson)*1));
    for j=1:12
        Pentry = rand;
        if Pentry <= P  % car enter
            for n=1:length(car_in)
                if car_in(n) == 0
                    carnum = n;
                    break;
                end
            end
            car_x(carnum) = entryX(j);
            car_y(carnum) = entryY(j);
            car_direction(carnum) = entryD(j);
            car_in(carnum) = 1;
            
            % choose BS
            % direction to BS
            D_BS1 = ((car_x(carnum)-BSX(1))^2+(car_y(carnum)-BSY(1))^2)^(1/2);
            D_BS2 = ((car_x(carnum)-BSX(2))^2+(car_y(carnum)-BSY(2))^2)^(1/2);
            D_BS3 = ((car_x(carnum)-BSX(3))^2+(car_y(carnum)-BSY(3))^2)^(1/2);
            D_BS4 = ((car_x(carnum)-BSX(4))^2+(car_y(carnum)-BSY(4))^2)^(1/2);
            % compare
            if D_BS1<D_BS2 && D_BS1<D_BS3 && D_BS1<D_BS4
                car_BS(carnum) = 1;
                car_power(carnum) = Pt-10-20*log10(D_BS1);
            elseif D_BS2<D_BS1 && D_BS2<D_BS3 && D_BS2<D_BS4
                car_BS(carnum) = 2;
                car_power(carnum) = Pt-10-20*log10(D_BS2);
            elseif D_BS3<D_BS1 && D_BS3<D_BS2 && D_BS3<D_BS4
                car_BS(carnum) = 3;
                car_power(carnum) = Pt-10-20*log10(D_BS3);
            elseif D_BS4<D_BS1 && D_BS4<D_BS2 && D_BS4<D_BS3
                car_BS(carnum) = 4;
                car_power(carnum) = Pt-10-20*log10(D_BS4);
            elseif D_BS1==D_BS2 && D_BS1<D_BS3
                if rand>=0.5
                    car_BS(carnum) = 1;
                else
                    car_BS(carnum) = 2;
                end
                car_power(carnum) = Pt-10-20*log10(D_BS1);
            elseif D_BS2==D_BS3 && D_BS2<D_BS4
                if rand>=0.5
                    car_BS(carnum) = 2;
                else
                    car_BS(carnum) = 3;
                end
                car_power(carnum) = Pt-10-20*log10(D_BS2);
            elseif D_BS3==D_BS4 && D_BS3<D_BS2
                if rand>=0.5
                    car_BS(carnum) = 3;
                else
                    car_BS(carnum) = 4;
                end
                car_power(carnum) = Pt-10-20*log10(D_BS3);
            elseif D_BS1==D_BS4 && D_BS1<D_BS2
                if rand>=0.5
                    car_BS(carnum) = 1;
                else
                    car_BS(carnum) = 4;
                end
                car_power(carnum) = Pt-10-20*log10(D_BS4);
            end
            %disp(car(carnum+1).BS);
            %disp(car(carnum+1).power);
        end
    end
    
    for j=1:length(car_in)
        if car_in(j) == 1
            % choose BS
            D_BS1 = ((car_x(j)-BSX(1))^2+(car_y(j)-BSY(1))^2)^(1/2);
            D_BS2 = ((car_x(j)-BSX(2))^2+(car_y(j)-BSY(2))^2)^(1/2);
            D_BS3 = ((car_x(j)-BSX(3))^2+(car_y(j)-BSY(3))^2)^(1/2);
            D_BS4 = ((car_x(j)-BSX(4))^2+(car_y(j)-BSY(4))^2)^(1/2);
            % power
            P_BS1 = Pt-10-20*log10(D_BS1);
            P_BS2 = Pt-10-20*log10(D_BS2);
            P_BS3 = Pt-10-20*log10(D_BS3);
            P_BS4 = Pt-10-20*log10(D_BS4);
            
            if car_BS(j) == 1
                car_power(j) = P_BS1;
            elseif car_BS(j) == 2
                car_power(j) = P_BS2;
            elseif car_BS(j) == 3
                car_power(j) = P_BS3;
            else
                car_power(j) = P_BS4;
            end
            %disp(car(j).power);
            %disp(P_BS1);
            %disp(P_BS2);
            %disp(P_BS3);
            %disp(P_BS4);
            % choose the best one, if Pnew>Pold, choose Pnew
            if P_BS1 > car_power(j)
                car_BS(j) = 1;
                car_power(j) = P_BS1;
                HandoffNum(i) = HandoffNum(i)+1;
            elseif P_BS2 > car_power(j)
                car_BS(j) = 2;
                car_power(j) = P_BS2;
                HandoffNum(i) = HandoffNum(i)+1;
            elseif P_BS3 > car_power(j)
                car_BS(j) = 3;
                car_power(j) = P_BS3;
                HandoffNum(i) = HandoffNum(i)+1;
            elseif P_BS4 > car_power(j)
                car_BS(j) = 4;
                car_power(j) = P_BS4;
                HandoffNum(i) = HandoffNum(i)+1;
            end
            %disp(car(j).power);
        end
    end
    
    for j=1:length(car_in)
        % decide dierction
        if car_direction(j) == 's'
            if car_y(j)<3000 && car_y(j)+v>=3000
                % car out
                car_in(j) = 0;
            elseif car_y(j)<2250 && car_y(j)+v>=2250
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_x(j) = car_x(j) - (v-(2250-car_y(j)));
                    car_y(j) = 2250;
                elseif direction(d) == 'l'
                    car_x(j) = car_x(j) + (v-(2250-car_y(j))); 
                    car_y(j) = 2250;
                else
                    car_y(j) = car_y(j) + v;
                end
            elseif car_y(j)<1500 && car_y(j)+v>=1500
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_x(j) = car_x(j) - (v-(1500-car_y(j)));
                    car_y(j) = 1500;
                elseif direction(d) == 'l'
                    car_x(j) = car_x(j) + (v-(1500-car_y(j))); 
                    car_y(j) = 1500;
                else
                    car_y(j) = car_y(j) + v;
                end
            elseif car_y(j)<750 && car_y(j)+v>=750
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_x(j) = car_x(j) - (v-(750-car_y(j)));
                    car_y(j) = 750;
                elseif direction(d) == 'l'
                    car_x(j) = car_x(j) + (v-(750-car_y(j))); 
                    car_y(j) = 750;
                else
                    car_y(j) = car_y(j) + v;
                end
            else
                car_y(j) = car_y(j) + v;
            end
        elseif car_direction(j) == 'w'
            if car_x(j)>0 && car_x(j)-v<=0
                % car out
                car_in(j) = 0;
            elseif car_x(j)>750 && car_x(j)-v<=750
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_y(j) =car_y(j) - (v-(car_x(j)-750));
                    car_x(j) = 750;
                elseif direction(d) == 'l'
                    car_y(j) = car_y(j) + (v-(car_x(j)-750));
                    car_x(j) = 750;
                else
                    car_x(j) = car_x(j) - v;
                end
            elseif car_x(j)>1500 && car_x(j)-v<=1500
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_y(j) = car_y(j) - (v-(car_x(j)-1500));
                    car_x(j) = 1500;
                elseif direction(d) == 'l'
                    car_y(j) = car_y(j) + (v-(car_x(j)-1500));
                    car_x(j) = 1500;
                else
                    car_x(j) = car_x(j) - v;
                end
            elseif car_x(j)>2250 && car_x(j)-v<=2250
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_y(j) = car_y(j) - (v-(car_y(j)-2250));
                    car_x(j) = 2250;
                elseif direction(d) == 'l'
                    car_y(j) = car_y(j) + (v-(car_y(j)-2250));
                    car_x(j) = 2250;
                else
                    car_x(j) = car_x(j) - v;
                end
            else
                car_x(j) = car_x(j) - v;
            end
        elseif car_direction(j) == 'n'
            if car_y(j)>0 && car_y(j)-v<=0
                % car out
                car_in(j) = 0;
            elseif car_y(j)>750 && car_y(j)-v<=750
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_x(j) = car_x(j) + (v-(car_y(j)-750));
                    car_y(j)= 750;
                elseif direction(d) == 'l'
                    car_x(j) = car_x(j) - (v-(car_y(j)-750)); 
                    car_y(j) = 750;
                else
                    car_y(j) = car_y(j) - v;
                end
            elseif car_y(j)>1500 && car_y(j)-v<=1500
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_x(j) = car_x(j) + (v-(car_y(j)-1500));
                    car_y(j) = 1500;
                elseif direction(d) == 'l'
                    car_x(j) = car_x(j) - (v-(car_y(j)-1500)); 
                    car_y(j) = 1500;
                else
                    car_y(j) = car_y(j) - v;
                end
            elseif car_y(j)>2250 && car_y(j)-v<=2250
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_x(j) = car_x(j) - (v-(car_y(j)-2250));
                    car_y(j) = 2250;
                elseif direction(d) == 'l'
                    car_x(j) = car_x(j) - (v-(car_y(j)-2250)); 
                    car_y(j) = 2250;
                else
                    car_y(j) = car_y(j) - v;
                end
            else
                car_y(j) = car_y(j) - v;
            end
        elseif car_direction(j) == 'e'
            if car_x(j)<3000 && car_x(j)+v>=3000
                % car out
                car_in(j) = 0;
            elseif car_x(j)<2250 && car_x(j)+v>=2250
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_y(j) = car_y(j) + (v-(2250-car_x(j)));
                    car_x(j) = 2250;
                elseif direction(d) == 'l'
                    car_y(j) = car_y(j) - (v-(2250-car_x(j)));
                    car_x(j) = 2250;
                else
                    car_x(j) = car_x(j) + v;
                end
            elseif car_x(j)<1500 && car_x(j)+v>=1500
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_y(j) = car_y(j) + (v-(1500-car_x(j)));
                    car_x(j) = 1500;
                elseif direction(d) == 'l'
                    car_y(j) = car_y(j) - (v-(1500-car_x(j)));
                    car_x(j) = 1500;
                else
                    car_x(j) = car_x(j) + v;
                end
            elseif car_x(j)<750 && car_x(j)+v>=750
                d = randi(6);
                car_direction(j) = directionS(d);
                if direction(d) == 'r'
                    car_y(j) = car_y(j) + (v-(750-car_x(j)));
                    car_x(j) = 750;
                elseif direction(d) == 'l'
                    car_y(j) = car_y(j) - (v-(750-car_x(j)));
                    car_x(j) = 750;
                else
                    car_x(j) = car_x(j) + v;
                end
            else
                car_x(j) = car_x(j) + v;
            end
        end
    end
    
    %for j=1:length(car)
    %    if car(j).in==0
    %        car(j) = [];
    %    end
    %end
    %disp(car(1).x);
    %disp(car(1).y);
    %fprintf('%d %d %c\n',car(5).x, car(5).y, car(5).direction);
    
    if i>1
        HandoffNum(i) =  HandoffNum(i)+HandoffNum(i-1);
    end
    disp(HandoffNum(i));
end

bar(HandoffNum)