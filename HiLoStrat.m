classdef HiLoStrat < Strategy
    properties
        runningCount = 0;
        trueCount = 0;
    end
    methods
        function obj = HiLoStrat()
                        
            n = obj.n;
            % 0 = stand
            % 1 = hit
            % 2 = double down
            % Dealer shows:
            %      2 3 4 5 6 7 8 9 T A
            obj.HARD = [ ...
                1   n n n n n n n n n n
                2   1 1 1 1 1 1 1 1 1 1
                3   1 1 1 1 1 1 1 1 1 1
                4   1 1 1 1 1 1 1 1 1 1
                5   1 1 1 1 1 1 1 1 1 1
                6   1 1 1 1 1 1 1 1 1 1
                7   1 1 1 1 1 1 1 1 1 1
                8   1 1 1 1 1 1 1 1 1 1
                9   1 2 2 2 2 1 1 1 1 1
                10   2 2 2 2 2 2 2 2 1 1
                11   2 2 2 2 2 2 2 2 2 1
                12   1 1 0 0 0 1 1 1 1 1
                13   0 0 0 0 0 1 1 1 1 1
                14   0 0 0 0 0 1 1 1 1 1
                15   0 0 0 0 0 1 1 1 1 1
                16   0 0 0 0 0 1 1 1 1 1
                17   0 0 0 0 0 0 0 0 0 0
                18   0 0 0 0 0 0 0 0 0 0
                19   0 0 0 0 0 0 0 0 0 0
                20   0 0 0 0 0 0 0 0 0 0];
            % 0 = stand
            % 1 = hit
            % 2 = double down
            % Dealer shows:
            %      2 3 4 5 6 7 8 9 T A
            obj.SOFT = [ ...
                1   n n n n n n n n n n
                2   1 1 1 1 1 1 1 1 1 1
                3   1 1 1 1 1 1 1 1 1 1
                4   1 1 1 1 1 1 1 1 1 1
                5   1 1 1 1 1 1 1 1 1 1
                6   1 1 1 1 1 1 1 1 1 1
                7   1 1 1 1 1 1 1 1 1 1
                8   0 0 0 0 0 0 0 0 0 0
                9   0 0 0 0 0 0 0 0 0 0];
            
            % 0 = keep pair
            % 1 = split pair
            % 2 = stand
            % 3 = hit
            % 4 = double down
            % Dealer shows:
            %      2 3 4 5 6 7 8 9 T A
            obj.PAIR = [ ...
                1   n n n n n n n n n n
                2   1 1 1 1 1 1 3 3 3 3
                3   1 1 1 1 1 1 3 3 3 3
                4   3 3 3 1 1 3 3 3 3 3
                5   4 4 4 4 4 4 4 4 3 3
                6   1 1 1 1 1 3 3 3 3 3
                7   1 1 1 1 1 1 3 3 3 3
                8   1 1 1 1 1 1 1 1 1 1
                9   1 1 1 1 1 2 1 1 2 2
                10   2 2 2 2 2 2 2 2 2 2
                11   1 1 1 1 1 1 1 1 1 1];
        end
        
        function strat = hard(obj,p,d)
            strat = obj.HARD(p,d);
        end
        
        function strat = soft(obj,p,d)
            n = NaN; % Not possible
            strat = obj.SOFT(p,d);
        end
        
        function strat = pair(obj,p,d)
            n = NaN; % Not possible
            strat = obj.PAIR(p,d);
        end
        
        function str = toString(obj)
            str = 'HiLo Strat';
        end
        
        function [PC,bet1,split] = playhand(obj,hand,P,D,bet,Deck)
            % Play player's hand
            % Split pairs
            strat = 0;
            PC{1} = P;
            split = (PC{1}(1) == PC{1}(2));
            bet1(1) = bet + Deck.trueCount;
            if (bet(1) < 0)
                bet(1) = 10;
            end
            
            if split == 1
                split = obj.pair(obj.value(PC{1}(1)),obj.value(D(1)));
            end
            if split == 1
                PC{2} = PC{1}(2);
                PC{1} = [P(1) deal(Deck)];
                PC{2} = [P(2) deal(Deck)];
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
                        if length(PC(i)) > 2 & strat == 2
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
                            bet1(i) = 2*bet1(i);
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
    end
end