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

car = struct('x',{},'y',{},'direction',{},'in',{},'BS',{},'power',{});
%car.x = 0;
%car.y = 0;
%car.direction = 's'

entryX = [750,1500,2250,3000,3000,3000,2250,1500,750,0,0,0];
entryY = [0,0,0,750,1500,2250,3000,3000,3000,2250,1500,750];
entryD = ['s','s','s','w','w','w','n','n','n','e','e','e'];

BSX = [750,2250,2250,750];
BSY = [750,750,2250,2250];

HandoffNum = zeros(1, 864);%00);
for i=1:864%00
    P = ((poisson*1)*exp((-poisson)*1));
    for j=1:12
        Pentry = rand;
        if Pentry <= P  % car enter
            carnum = length(car);
            car(carnum+1).x = entryX(j);
            car(carnum+1).y = entryY(j);
            car(carnum+1).direction = entryD(j);
            car(carnum+1).in = 1;
            
            % choose BS
            % direction to BS
            D_BS1 = ((car(carnum+1).x-BSX(1))^2+(car(carnum+1).y-BSY(1))^2)^(1/2);
            D_BS2 = ((car(carnum+1).x-BSX(2))^2+(car(carnum+1).y-BSY(2))^2)^(1/2);
            D_BS3 = ((car(carnum+1).x-BSX(3))^2+(car(carnum+1).y-BSY(3))^2)^(1/2);
            D_BS4 = ((car(carnum+1).x-BSX(4))^2+(car(carnum+1).y-BSY(4))^2)^(1/2);
            % compare
            if D_BS1<D_BS2 && D_BS1<D_BS3 && D_BS1<D_BS4
                car(carnum+1).BS = 1;
                car(carnum+1).power = Pt-10-20*log10(D_BS1);
            elseif D_BS2<D_BS1 && D_BS2<D_BS3 && D_BS2<D_BS4
                car(carnum+1).BS = 2;
                car(carnum+1).power = Pt-10-20*log10(D_BS2);
            elseif D_BS3<D_BS1 && D_BS3<D_BS2 && D_BS3<D_BS4
                car(carnum+1).BS = 3;
                car(carnum+1).power = Pt-10-20*log10(D_BS3);
            elseif D_BS4<D_BS1 && D_BS4<D_BS2 && D_BS4<D_BS3
                car(carnum+1).BS = 4;
                car(carnum+1).power = Pt-10-20*log10(D_BS4);
            elseif D_BS1==D_BS2 && D_BS1<D_BS3
                if rand>=0.5
                    car(carnum+1).BS = 1;
                else
                    car(carnum+1).BS = 2;
                end
                car(carnum+1).power = Pt-10-20*log10(D_BS1);
            elseif D_BS2==D_BS3 && D_BS2<D_BS4
                if rand>=0.5
                    car(carnum+1).BS = 2;
                else
                    car(carnum+1).BS = 3;
                end
                car(carnum+1).power = Pt-10-20*log10(D_BS2);
            elseif D_BS3==D_BS4 && D_BS3<D_BS2
                if rand>=0.5
                    car(carnum+1).BS = 3;
                else
                    car(carnum+1).BS = 4;
                end
                car(carnum+1).power = Pt-10-20*log10(D_BS3);
            elseif D_BS1==D_BS4 && D_BS1<D_BS2
                if rand>=0.5
                    car(carnum+1).BS = 1;
                else
                    car(carnum+1).BS = 4;
                end
                car(carnum+1).power = Pt-10-20*log10(D_BS4);
            end
            %disp(car(carnum+1).BS);
            %disp(car(carnum+1).power);
        end
    end
    
    for j=1:length(car)
        if car(j).in == 1
            % choose BS
            D_BS1 = ((car(j).x-BSX(1))^2+(car(j).y-BSY(1))^2)^(1/2);
            D_BS2 = ((car(j).x-BSX(2))^2+(car(j).y-BSY(2))^2)^(1/2);
            D_BS3 = ((car(j).x-BSX(3))^2+(car(j).y-BSY(3))^2)^(1/2);
            D_BS4 = ((car(j).x-BSX(4))^2+(car(j).y-BSY(4))^2)^(1/2);
            % power
            P_BS1 = Pt-10-20*log10(D_BS1);
            P_BS2 = Pt-10-20*log10(D_BS2);
            P_BS3 = Pt-10-20*log10(D_BS3);
            P_BS4 = Pt-10-20*log10(D_BS4);
            
            if car(j).BS == 1
                car(j).power = P_BS1;
            elseif car(j).BS == 2
                car(j).power = P_BS2;
            elseif car(j).BS == 3
                car(j).power = P_BS3;
            else
                car(j).power = P_BS4;
            end
            %disp(car(j).power);
            %disp(P_BS1);
            %disp(P_BS2);
            %disp(P_BS3);
            %disp(P_BS4);
            % choose the best one, if Pnew>Pold, choose Pnew
            if P_BS1 > car(j).power
                car(j).BS = 1;
                car(j).power = P_BS1;
                HandoffNum(i) = HandoffNum(i)+1;
            elseif P_BS2 > car(j).power
                car(j).BS = 2;
                car(j).power = P_BS2;
                HandoffNum(i) = HandoffNum(i)+1;
            elseif P_BS3 > car(j).power
                car(j).BS = 3;
                car(j).power = P_BS3;
                HandoffNum(i) = HandoffNum(i)+1;
            elseif P_BS4 > car(j).power
                car(j).BS = 4;
                car(j).power = P_BS4;
                HandoffNum(i) = HandoffNum(i)+1;
            end
            %disp(car(j).power);
        end
    end
    
    for j=1:length(car)
        % decide dierction
        if car(j).direction == 's'
            if car(j).y<3000 && car(j).y+v>=3000
                % car out
                car(j).in = 0;
            elseif car(j).y<2250 && car(j).y+v>=2250
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).x = car(j).x - (v-(2250-car(j).y));
                    car(j).y = 2250;
                elseif direction(d) == 'l'
                    car(j).x = car(j).x + (v-(2250-car(j).y)); 
                    car(j).y = 2250;
                else
                    car(j).y = car(j).y + v;
                end
            elseif car(j).y<1500 && car(j).y+v>=1500
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).x = car(j).x - (v-(1500-car(j).y));
                    car(j).y = 1500;
                elseif direction(d) == 'l'
                    car(j).x = car(j).x + (v-(1500-car(j).y)); 
                    car(j).y = 1500;
                else
                    car(j).y = car(j).y + v;
                end
            elseif car(j).y<750 && car(j).y+v>=750
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).x = car(j).x - (v-(750-car(j).y));
                    car(j).y = 750;
                elseif direction(d) == 'l'
                    car(j).x = car(j).x + (v-(750-car(j).y)); 
                    car(j).y = 750;
                else
                    car(j).y = car(j).y + v;
                end
            else
                car(j).y = car(j).y + v;
            end
        elseif car(j).direction == 'w'
            if car(j).x>0 && car(j).x-v<=0
                % car out
                car(j).in = 0;
            elseif car(j).x>750 && car(j).x-v<=750
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).y = car(j).y - (v-(car(j).x-750));
                    car(j).x = 750;
                elseif direction(d) == 'l'
                    car(j).y = car(j).y + (v-(car(j).x-750));
                    car(j).x = 750;
                else
                    car(j).x = car(j).x - v;
                end
            elseif car(j).x>1500 && car(j).x-v<=1500
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).y = car(j).y - (v-(car(j).x-1500));
                    car(j).x = 1500;
                elseif direction(d) == 'l'
                    car(j).y = car(j).y + (v-(car(j).x-1500));
                    car(j).x = 1500;
                else
                    car(j).x = car(j).x - v;
                end
            elseif car(j).x>2250 && car(j).x-v<=2250
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).y = car(j).y - (v-(car(j).x-2250));
                    car(j).x = 2250;
                elseif direction(d) == 'l'
                    car(j).y = car(j).y + (v-(car(j).x-2250));
                    car(j).x = 2250;
                else
                    car(j).x = car(j).x - v;
                end
            else
                car(j).x = car(j).x - v;
            end
        elseif car(j).direction == 'n'
            if car(j).y>0 && car(j).y-v<=0
                % car out
                car(j).in = 0;
            elseif car(j).y>750 && car(j).y-v<=750
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).x = car(j).x + (v-(car(j).y-750));
                    car(j).y = 750;
                elseif direction(d) == 'l'
                    car(j).x = car(j).x - (v-(car(j).y-750)); 
                    car(j).y = 750;
                else
                    car(j).y = car(j).y - v;
                end
            elseif car(j).y>1500 && car(j).y-v<=1500
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).x = car(j).x + (v-(car(j).y-1500));
                    car(j).y = 1500;
                elseif direction(d) == 'l'
                    car(j).x = car(j).x - (v-(car(j).y-1500)); 
                    car(j).y = 1500;
                else
                    car(j).y = car(j).y - v;
                end
            elseif car(j).y>2250 && car(j).y-v<=2250
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).x = car(j).x - (v-(car(j).y-2250));
                    car(j).y = 2250;
                elseif direction(d) == 'l'
                    car(j).x = car(j).x - (v-(car(j).y-2250)); 
                    car(j).y = 2250;
                else
                    car(j).y = car(j).y - v;
                end
            else
                car(j).y = car(j).y - v;
            end
        elseif car(j).direction == 'e'
            if car(j).x<3000 && car(j).x+v>=3000
                % car out
                car(j).in = 0;
            elseif car(j).x<2250 && car(j).x+v>=2250
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).y = car(j).y + (v-(2250-car(j).x));
                    car(j).x = 2250;
                elseif direction(d) == 'l'
                    car(j).y = car(j).y - (v-(2250-car(j).x));
                    car(j).x = 2250;
                else
                    car(j).x = car(j).x + v;
                end
            elseif car(j).x<1500 && car(j).x+v>=1500
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).y = car(j).y + (v-(1500-car(j).x));
                    car(j).x = 1500;
                elseif direction(d) == 'l'
                    car(j).y = car(j).y - (v-(1500-car(j).x));
                    car(j).x = 1500;
                else
                    car(j).x = car(j).x + v;
                end
            elseif car(j).x<750 && car(j).x+v>=750
                d = randi(6);
                car(j).direction = directionS(d);
                if direction(d) == 'r'
                    car(j).y = car(j).y + (v-(750-car(j).x));
                    car(j).x = 750;
                elseif direction(d) == 'l'
                    car(j).y = car(j).y - (v-(750-car(j).x));
                    car(j).x = 750;
                else
                    car(j).x = car(j).x + v;
                end
            else
                car(j).x = car(j).x + v;
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