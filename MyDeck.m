classdef MyDeck < handle & matlab.mixin.Copyable
    properties
        deck
        DeckCount
        runningCount
        trueCount
    end
    methods
        function obj = MyDeck(deckCount)
            if nargin == 0
                obj.DeckCount = 1;
            else
                obj.DeckCount = deckCount;
            end
        end
        
        function obj = set.deck(obj,value)
            obj.deck = value;
        end
        
        function d = get.deck(obj)
            d = obj.deck;
        end
        
        function c= deal(obj)
            % deal one card from a deck: Note this is a deck with card counting
            % possible
            c = obj.deck(end);
            obj.deck(end) = [];
            obj.modifyRunningCount(c);
            % Simulate continuous shuffling machine with infinite deck.
            % c = deal returns a random integer between 1 and 13.
            %c = ceil(13*rand);
        end
        
        function createDeck(obj)
            % create a new deck
            raw = [1:52 * obj.DeckCount];
            %shuffle
            shuffled = raw(randperm(length(raw)));
            obj.deck = shuffled;
            obj.trueCount = 0;
            obj.runningCount = 0;
        end
        
        function shuffle(obj)
            raw = obj.deck;
            %shuffle
            shuffled = raw(randperm(length(raw)));
            obj.deck = shuffled;
        end
        
        function modifyRunningCount(obj,card)
            if obj.value(card) < 7
                obj.runningCount = obj.runningCount + 1;
            elseif obj.value(card) < 10
                obj.runningCount = obj.runningCount;
            else
                obj.runningCount = obj.runningCount - 1;
            end
            i = idivide(int32(length(obj.deck)),52,'ceil');
            obj.trueCount = idivide(obj.runningCount, i);
        end
        
        function v = value(obj,X)
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