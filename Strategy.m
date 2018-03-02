classdef Strategy < matlab.mixin.Heterogeneous & handle
    properties
        HARD
        SOFT
        PAIR
        n = NaN
    end
    methods(Abstract)
        % Strategy for hands without aces.
        % strategy = hard(player's_total,dealer's_upcard)
        strat = hard(obj,p,d)
        % Strategy array for hands with aces.
        % strategy = soft(player's_total,dealer's_upcard)
        strat = soft(obj,p,d)
        % Strategy for splitting pairs
        strat = pair(obj,p,d)
        str = toString(obj);
    end
    methods        
        function [PC,bet1,split] = playhand(obj,hand,P,D,bet,Deck)
            % Play player's hand
            % Split pairs
            strat = 0;
            PC{1} = P;
            bet1(1) = bet;
            split = (PC{1}(1) == PC{1}(2));
            if split == 1
                split = obj.pair(obj.value(PC{1}(1)),obj.value(D(1)));
            end
            if split == 1
                PC{1} = [PC{1}(1) deal(Deck)];
                PC{2} = [PC{1}(2) deal(Deck)];
                bet1(2) = bet;
            end
            if (split ~= 0 & split ~= 1) % Don't split or split. Do something else 
                strat = split - 2;
                split = 0;
            end
            for i = 1:(split+1)
                while obj.value(PC{i}) < 21
                    % 0 = stand
                    % 1 = hit
                    % 2 = double down
                    if (strat == 0) 
                        if any(mod(PC{i},13)==1) & obj.valuehard(PC{i})<=10
                            strat = obj.soft(obj.value(PC{i})-11,obj.value(D(1)));
                        else
                            strat = obj.hard(obj.value(PC{i}),obj.value(D(1)));
                        end
                        if length(PC{i}) > 2 & strat == 2
                            strat = 1;
                        end
                    end
                    switch strat
                        case 0
                            break
                        case 1
                            PC{i} = [PC{i} deal(Deck)];
                            break;
                        case 2
                            % Double down.
                            % Double bet and get one more card
                            bet1(i) = 2*bet;
                            PC{i} = [PC{i} deal(Deck)];
                            break
                        otherwise
                            break
                    end
                end
            end
        end
        
        function v = valuehard(obj,X)
            % Evaluate hand
            X = min(mod(X-1,13)+1,10);
            v = sum(X);
        end
        
        function v = value(obj,X)
            x= X;
            % Evaluate hand
            X = min(mod(X-1,13)+1,10);
            v = sum(X);
            % Promote soft ace
            if any(X==1) & v<=11
                v = v + 10;
            end
        end
        
        function str = toName(obj)
            str = class(obj);
        end
        
    end
end
