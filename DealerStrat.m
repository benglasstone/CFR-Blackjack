classdef DealerStrat < Strategy
    methods
        function obj = DealerStrat()
            
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
                9   1 1 1 1 1 1 1 1 1 1
                10   1 1 1 1 1 1 1 1 1 1
                11   1 1 1 1 1 1 1 1 1 1
                12   1 1 1 1 1 1 1 1 1 1
                13   1 1 1 1 1 1 1 1 1 1
                14   1 1 1 1 1 1 1 1 1 1
                15   1 1 1 1 1 1 1 1 1 1
                16   0 0 0 0 0 0 0 0 1 1
                17   0 0 0 0 0 0 0 0 1 1
                18   0 0 0 0 0 0 0 0 1 1
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
                7   0 0 0 0 0 0 0 0 0 0
                8   0 0 0 0 0 0 0 0 0 0
                9   0 0 0 0 0 0 0 0 0 0];
            
            % 0 = keep pair
            % 1 = split pair
            % Dealer shows:
            %      2 3 4 5 6 7 8 9 T A
            obj.PAIR = [ ...
                1   n n n n n n n n n n
                2   0 0 0 0 0 0 0 0 0 0
                3   0 0 0 0 0 0 0 0 0 0
                4   0 0 0 0 0 0 0 0 0 0
                5   0 0 0 0 0 0 0 0 0 0
                6   0 0 0 0 0 0 0 0 0 0
                7   0 0 0 0 0 0 0 0 0 0
                8   0 0 0 0 0 0 0 0 0 0
                9   0 0 0 0 0 0 0 0 0 0
                10   0 0 0 0 0 0 0 0 0 0
                11   0 0 0 0 0 0 0 0 0 0];
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
            strat = 0;
        end
        
        function str = toString(obj)
            str = 'Dealer Strategy';
        end
        

    end
end