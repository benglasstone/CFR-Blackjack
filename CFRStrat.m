
classdef CFRStrat < Strategy
    properties
        trainNumber
        chanceSampledNumber
        learningRate
        HARDProbabilitiesMutex
        SOFTProbabilitiesMutex
        HARDPossibilities
        SOFTPossibilities
        PAIRPossibilities
        HARDProbabilities
        SOFTProbabilities
        PAIRProbabilities
    end
    methods
        function obj = CFRStrat(trainNumber,chanceSampledNumber, learningRate)
            % Non-CFR Specific Stuff
            % Initial Values - might try initializing to 1/3 each
            % ----------------------
            % 0 = stand
            % 1 = hit
            % 2 = double down
            % Dealer shows:
            %      2 3 4 5 6 7 8 9 T A
            n = NaN;

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
            % Dealer shows:
            %      2 3 4 5 6 7 8 9 T A
            obj.PAIR = [ ...
                1   n n n n n n n n n n
                2   1 1 1 1 1 1 0 0 0 0
                3   1 1 1 1 1 1 0 0 0 0
                4   0 0 0 1 0 0 0 0 0 0
                5   0 0 0 0 0 0 0 0 0 0
                6   1 1 1 1 1 1 0 0 0 0
                7   1 1 1 1 1 1 1 0 0 0
                8   1 1 1 1 1 1 1 1 1 1
                9   1 1 1 1 1 0 1 1 0 0
                10   0 0 0 0 0 0 0 0 0 0
                11   1 1 1 1 1 1 1 1 1 1];
            % ----------------------

            % 0 = stand
            % 1 = hit
            % 2 = double down
            obj.HARDPossibilities = [0, 1, 2];
            k = rand(1,3);
            k = k / sum(k);
            dim = size(obj.HARD);
            for j = obj.HARDPossibilities
                prob = zeros(size(obj.HARD));
                for i = 2:dim(1)
                    prob(i,:) = k(j+1);%(1/length(obj.HARDPossibilities));
                end
                prob(1,:) = obj.HARD(1,:);
                prob(:,1) = obj.HARD(:,1);
                obj.HARDProbabilities{j+1} = prob;
            end
            
            % 0 = stand
            % 1 = hit
            % 2 = double down
            obj.SOFTPossibilities = [0, 1, 2];
            dim = size(obj.SOFT);
            k = rand(1,3);
            k = k / sum(k);
            for j = obj.SOFTPossibilities
                prob = zeros(size(obj.SOFT));
                for i = 2:dim(1)
                    prob(i,:) = k(j+1);%(obj.SOFT(i,:) == j);
                end
                prob(1,:) = obj.SOFT(1,:);
                prob(:,1) = obj.SOFT(:,1);
                obj.SOFTProbabilities{j+1} = prob;
            end
            
            % 0 = keep pair
            % 1 = split pair
            obj.PAIRPossibilities = [0,1];
            dim = size(obj.PAIR);
            
            for j = obj.PAIRPossibilities
                prob = zeros(size(obj.PAIR));
                for i = 2:dim(1)
                    prob(i,:) = (1/length(obj.PAIRPossibilities));
                end
                prob(1,:) = obj.PAIR(1,:);
                prob(:,1) = obj.PAIR(:,1);
                obj.PAIRProbabilities{j+1} = prob;
            end
            
            obj.HARDProbabilitiesMutex = 0;
            obj.SOFTProbabilitiesMutex = 0;
            
            if nargin == 0 % don't train all defaults
                obj.trainNumber = 0;
                obj.chanceSampledNumber = 5; % default to 5;
                obj.learningRate = 0.1;
                %I = obj.generateInformationSets();
                %obj.trainI(I);
            elseif nargin == 1 % update strats by doing n tests
                obj.trainNumber = trainNumber;
                obj.chanceSampledNumber = 5; % default to 5;
                obj.learningRate = 0.01;
                I = obj.generateInformationSets();
                obj.trainI(I);
            elseif nargin == 2
                obj.trainNumber = trainNumber;
                obj.chanceSampledNumber = chanceSampledNumber;
                obj.learningRate = 0.01;
                I = obj.generateInformationSets();
                obj.trainI(I);
            elseif nargin == 3
                obj.trainNumber = trainNumber;
                obj.chanceSampledNumber = chanceSampledNumber;
                obj.learningRate = learningRate;
                tic
                delete(gcp('nocreate'))
                parpool
                toc
                tic
                for i = 1:trainNumber
                    if mod(i,100) == 0
                        i
                    end
                    I = obj.generateInformationSets();
                    obj.trainI(I);
                end
                toc
            end
        end
        
        %% Function to actually play the CFR hand
        function [PC,bet1,split] = playhand(obj,hand,P,D,bet,Deck)
            bet1(1) = bet + Deck.trueCount;
            if (bet(1) < 0)
                bet(1) = 1;
            end
            while obj.value(P) < 21
                if (obj.trainNumber < 1)
                    Deck1 = copy(Deck);
                    I = {P ; D(1); Deck1};
                    FCV0 = max(obj.counterFactualRegret(I,0),0);
                    FCV1 = max(obj.counterFactualRegret(I,1),0);
                    update = FCV0 + FCV1;
                else
                    update = -1;
                end
                if (update > 0)
                    p0 = (FCV0)/(update);
                    p1 = (FCV1)/(update);
                    p2 = (FCV2)/(update);
                    strat = possibilities(obj,p0,p1);
                else
                    if any(mod(P,13)==1) & obj.valuehard(P)<=10
                        strat = obj.soft(obj.value(P)-11,obj.value(D(1)));
                    else
                        strat = obj.hard(obj.value(P),obj.value(D(1)));
                    end
                    if length(P) > 2 & strat == 2
                        strat = 1;
                    end
                end
                switch strat
                    case 0
                        break
                    case 1
                        P = [P deal(Deck)];
                        break;
                    case 2
                        % Double down.
                        % Double bet and get one more card
                        bet1(1) = 2*bet1(1);
                        P = [P deal(Deck)];
                        break
                    otherwise
                        break
                end
            end
            PC{1} = P;
            split = 0;
            bet1(1) = bet;
        end
        
        %% CFR Specific Training funtions
        function sets = generateInformationSets(obj)
            % generateAllSets
            sets = {};
            for i = 1:10
                D = [i];
                % generate hands with ace and all other possibilities
                % will be the soft vals
                for j = 2:9
                    P = [1,j];
                    sets{25*(i-1) + j-1} = {P,D,MyDeck};
                end
                
                % generate 1 hand for all other values
                for k = 4:20
                    P = obj.generateHandForValN(k);
                    while (any(P == 1) && ~any(P > 10))
                        P = obj.generateHandForValN(k);
                    end
                    sets{25*(i-1) + 8 + (k-3)} = {P,D,MyDeck};
                end
            end
        end
        
        function P = generateHandForValN(obj,N)
            m=1:N;
            a=m(sort(randperm(min(N,10),2)));
            P=diff(a);
            P2 = N - sum(P);
            if (P2 > 10)
                P(end) = P(end) + (P2-10);
                P2 = N - sum(P);
            end
            P(end+1)=N-sum(P);
            sum(P);
        end
        
        function trainI(obj,I)
            for i = length(I):-1:1
                Icurr = I{i};
                
                Pi = Icurr{1};
                Di = Icurr{2};
                
                FCV = zeros(1,3);
                
                H{1} = 0;
                H{2} = Icurr{3};
                H{3} = 0;
                H{4}{1} = Icurr{1};
                H{4}{2} = Icurr{2};
                D = Icurr{2};
                H{5} = 0;
                H{6} = 1;
                action1 = getActionFromH(obj,H);
                H{1} = action1;
                maxDepth = 4 * Icurr{3}.DeckCount;
                terminalNodes = obj.getTerminalNodes(H,{},1,maxDepth);
                
                parfor i = 1:3
                    if i == (action1 - 1)
                        FCV(i) = 0;
                    elseif i == 1
                        FCV(i) = max(obj.counterFactualRegret(Icurr,0,terminalNodes),0);
                    elseif i ==2
                        FCV(i) = max(obj.counterFactualRegret(Icurr,1,terminalNodes),0);
                    elseif i == 3
                        FCV(i) = max(obj.counterFactualRegret(Icurr,2,terminalNodes),0);
                    end
                end
                FCV0 = FCV(1);
                FCV1 = FCV(2);
                FCV2 = FCV(3);
                obj.updateStrat(FCV0,FCV1,FCV2,Pi,Di);
            end
        end
        
        function train(obj,trainNumber)
            % Play player's hand
            % Split pairs
            % delete(gcp('nocreate'))
            % parpool
            tic
            for i = 1:trainNumber
                Deck = MyDeck(1);
                Deck.createDeck();
                
                P = deal(Deck);          % Player's hand
                D = deal(Deck);          % Dealer's hand
                P = [P deal(Deck)];      % Deal a second card to player
                D = [D -deal(Deck)];     % Hide dealer's hole card
                Pi = P;
                Di = D(1);
                
                I = {P ; D(1); Deck};
                FCV0 = max(obj.counterFactualRegret(I,D),0);
                FCV1 = max(obj.counterFactualRegret(I,D),0);
                FCV2 = max(obj.counterFactualRegret(I,D),0);
                obj.updateStrat(FCV0,FCV1,Pi,Di);
            end
            toc
        end
         
        function updateStrat(obj,FCV0,FCV1,FCV2,Pi,Di)
            Update = FCV0 + FCV1 + FCV2;
            if Update <= 0
                return
            end
            p0Update = (FCV0)/(Update);
            p1Update = (FCV1)/(Update);
            p2Update = (FCV2)/(Update);
            p = obj.value(Pi);
            d = obj.value(Di);
            if (p >= 21)
                return
            end
            if any(mod(Pi,13)==1) & obj.valuehard(Pi)<=10
                while(obj.SOFTProbabilitiesMutex == 1)
                    pause(0.02);
                end
                obj.SOFTProbabilitiesMutex = 1;
                % update soft strat
                p0 = obj.SOFTProbabilities{1}(p-11,d); %prob of stay
                p1 = obj.SOFTProbabilities{2}(p-11,d); % prob of hit
                p2 = obj.SOFTProbabilities{3}(p-11,d); % prob of double
                if (isnan(p0) || isnan(p1) || isnan(p2))
                    return;
                end
                p0 = max(min(p0 + 2*obj.learningRate*p0Update - obj.learningRate*p1Update - obj.learningRate*p2Update,1),0);
                p1 = max(min(p1 + 2*obj.learningRate*p1Update - obj.learningRate*p0Update - obj.learningRate*p2Update,1),0);
                p2 = max(min(p2 + 2*obj.learningRate*p2Update - obj.learningRate*p1Update - obj.learningRate*p0Update,1),0);

                %normalize values to below 1
                sumP = p0 + p1 + p2; 
                obj.SOFTProbabilities{1}(p-11,d) = p0/sumP;
                obj.SOFTProbabilities{2}(p-11,d) = p1/sumP;
                obj.SOFTProbabilities{3}(p-11,d) = p2/sumP;
                obj.SOFTProbabilitiesMutex = 0;
            else
                while(obj.HARDProbabilitiesMutex == 1)
                    pause(0.02);
                end
                obj.HARDProbabilitiesMutex = 1;
                % update hard strat
                p0 = obj.HARDProbabilities{1}(p,d); %prob of stay
                p1 = obj.HARDProbabilities{2}(p,d); % prob of hit
                p2 = obj.HARDProbabilities{3}(p,d); % prob of double
                if (isnan(p0) || isnan(p1) || isnan(p2))
                    return;
                end
                p0 = max(min(p0 + 2*obj.learningRate*p0Update - obj.learningRate*p1Update - obj.learningRate*p2Update,1),0);
                p1 = max(min(p1 + 2*obj.learningRate*p1Update - obj.learningRate*p0Update - obj.learningRate*p2Update,1),0);
                p2 = max(min(p2 + 2*obj.learningRate*p2Update - obj.learningRate*p0Update - obj.learningRate*p1Update,1),0);
                
                %normalize values to below 1
                sumP = p0 + p1 + p2;
                obj.HARDProbabilities{1}(p,d) = p0/sumP;
                obj.HARDProbabilities{2}(p,d) = p1/sumP;
                obj.HARDProbabilities{3}(p,d) = p2/sumP;

                obj.HARDProbabilitiesMutex = 0;
            end
        end
        
        
        %% CFR Specific utility functions
        function [prob, chance] = probHistoryH(obj,History,HistoryPrefix)
            action = History{1};
            Deck = History{2};
            soft = History{3};
            P = HistoryPrefix{4}{1};
            D = HistoryPrefix{4}{2};
            valP = obj.value(P);
            valD = obj.value(D);
            hits = History{5};
            prob = History{6};
            probCard = 1;
            % need to figure out how to handle the 3 face cards
            chance = (1/(Deck.DeckCount * 13))^hits; % there are only 13 options for card so prob = 1/(13*decks)
            if (hits == 0)
                chance = 1;
            end
            prob = chance * prob;
        end

        function [action,soft,prob] = getActionFromH(obj,H)
            action = H{1};
            Deck = H{2};
            soft = H{3};
            P = H{4}{1};
            D = H{4}{2};
            hits = H{5};
            if obj.value(P) < 21
                % 0 = stand
                % 1 = hit
                % 2 = double down
                if any(mod(P,13)==1) & obj.valuehard(P)<=10
                    soft = 1;
                    strat = obj.soft(obj.value(P)-11,obj.value(D(1)));
                    prob = obj.SOFTProbabilities{strat+1}(obj.value(P)-11,obj.value(D(1)));
                else
                    soft = 0;
                    strat = obj.hard(obj.value(P),obj.value(D(1)));
                    prob = obj.HARDProbabilities{strat+1}(obj.value(P),obj.value(D(1)));
                end
                if length(P) > 2 & strat == 2
                    strat = 1;
                end
                action = strat;
            else
                prob = 1;
                action = 0;
            end
        end
        
        function FCV=counterFactualRegret(obj,I,action, terminalNodes)
            H{1} = 0;
            H{2} = I{3};
            H{3} = 0;
            H{4}{1} = I{1};
            H{4}{2} = I{2};
            D = I{2};
            H{5} = 0;
            H{6} = 1;
            action1 = getActionFromH(obj,H);
            H{1} = action1;
            maxDepth = 4 * I{3}.DeckCount;
            terminalNodes1 = obj.getTerminalNodes(H,{},1,maxDepth,action);

            % Play dealer's hand
            % Maybe the weird data is coming from this?
            % How can I make this find all possible dealer values instead
            % of just 100 ranodm ones?
            finalDealer = obj.getDealerNodes(D,{},1,maxDepth);
            %{
            for i = 1:100
                Deck = copy(I{3});
                Deck.shuffle();
                finalDealer{i}{1} = [D deal(Deck)];
                count = 1;
                while obj.value(finalDealer{i}{1}) <= 16
                    count = count + 1;
                    finalDealer{i}{1} = [finalDealer{i}{1} deal(Deck)];
                end
                finalDealer{i}{2} = (1/(I{3}.DeckCount * 13))^count; % there are only 13 options for card so prob = 1/(13*decks)
            end
            %}
            FCV = 0;
            bet = 1;
            if (action == 2)
                bet = 2;
            end
            for i = 1:length(terminalNodes1)
                for k = 1:length(finalDealer)
                    [prob,chance] = probHistoryH(obj,terminalNodes1{i},H);
                    payoffU = obj.payoff(terminalNodes1{i}{4}{1},finalDealer{k}{1},0,bet);
                    FCV  = FCV + (payoffU*prob*finalDealer{k}{2})/(chance + finalDealer{k}{2});
                end
            end
            for i = 1:length(terminalNodes)
                for k = 1:length(finalDealer)
                    [prob,chance] = probHistoryH(obj,terminalNodes{i},H);
                    payoffU = obj.payoff(terminalNodes{i}{4}{1},finalDealer{k}{1},0,bet);
                    FCV  = FCV - (payoffU*prob*finalDealer{k}{2})/(chance + finalDealer{k}{2});
                end
            end
        end
        
        function dealerNodes = getDealerNodes(obj,D,dealerNodes1,depth,maxDepth)
            dealerNodes = dealerNodes1;
            if (depth > maxDepth)
                dealerNodes = dealerNodes1;
                return;
            end
            if obj.value(D) < 17
                nextNodes = obj.getAllDealerOptionsHit(D);
                for i = 1:length(nextNodes)
                    dealerNodes = obj.getDealerNodes(nextNodes{i}, dealerNodes,depth + 1, maxDepth);
                end
            else
                if (length(dealerNodes) == 0)
                    dealerNodes{1}{1} = D;
                    dealerNodes{1}{2} = (1/13)^(depth-1);
                else
                    index = length(dealerNodes) + 1;
                    dealerNodes{index}{1} = D;
                    dealerNodes{index}{2} = (1/13)^(depth-1);
                end
            end
        end
        
        function terminalNodes = getTerminalNodes(obj,H,terminalNodes1,depth,maxDepth,action)
            prob = 1;
            if (depth > maxDepth)
                terminalNodes = terminalNodes1;
                return;
            end
            if nargin == 5
                [action,soft,prob] = obj.getActionFromH(H);
            end
            count = 0;
            terminalNodes = terminalNodes1;
            H{6} = H{6} * prob;
            if (action == 1)
                H{5} = H{5} + 1;
                nextNodes = obj.getOptionsHit(H,obj.chanceSampledNumber);
                for i = 1:length(nextNodes)
                    if length(terminalNodes) == 0 && i==1
                        terminalNodes = obj.getTerminalNodes(nextNodes{i},terminalNodes,depth+1,maxDepth);
                    else
                        terminalNodes = obj.getTerminalNodes(nextNodes{i},terminalNodes,depth+1,maxDepth);
                    end
                end
            elseif (action == 2)
                H{5} = H{5} + 1;
                nextNodes = obj.getOptionsHit(H,obj.chanceSampledNumber);
                for i = 1:length(nextNodes)
                    if length(terminalNodes) == 0 && i==1
                        terminalNodes{1} = nextNodes{i};
                    else
                        terminalNodes{end+1} = nextNodes{i};
                    end
                end
            elseif (action == 0)
                if length(terminalNodes) == 0
                    terminalNodes{1} = H;
                else
                    terminalNodes{end+1} = H;
                end
            end
        end
        
        function nextNodes = getOptionsHit(obj,H,N)
            if nargin == 3 && N ~= 0
                nextNodes = getNOptionsHit(obj,H,N);
            else
                nextNodes = getAllOptionsHit(obj,H);
            end
        end
        
        function nextNodes = getNOptionsHit(obj,H,N)
            nextNodes = cell(1,N);
            j = randperm(13,N);
            for i = 1:length(j)
                Deck = copy(H{2});
                nextNodes{i} = H;
                nextNodes{i}{2} = Deck;
                nextNodes{i}{4}{1} = [H{4}{1} j(i)];
            end
        end
        
        function nextNodes = getAllOptionsHit(obj,H)
            nextNodes = cell(1,13);
            for i = 1:13
                nextNodes{i} = H;
                nextNodes{i}{4}{1} = [H{4}{1} i];
            end
        end
        
        function nextNodes = getAllDealerOptionsHit(obj,D)
            nextNodes = cell(1,obj.chanceSampledNumber);
            j = randperm(13,obj.chanceSampledNumber);
            for i = 1:length(j)
                nextNodes{i} = D;
                nextNodes{i} = [D j(i)];
            end
        end
        
        %% Functions to return strat
        function strat = possibilities(obj,p0,p1,p2)
            stratRand = rand(1);
            if (nargin == 3) 
                if (stratRand < p0)
                    strat = 0;
                elseif (stratRand < (p1+p0))
                    strat = 1;
                else
                    strat = 0; % got dealt an Ace after splitting -- need to figure something out here
                end
            else
                if (stratRand < p0)
                    strat = 0;
                elseif (stratRand < (p1+p0))
                    strat = 1;
                elseif (stratRand < (p2+p1+p0))
                    strat = 2;
                else
                    strat = 0; % got dealt an Ace after splitting -- need to figure something out here
                end
            end
        end
        
        function strat = hard(obj,p,d)
            p0 = obj.HARDProbabilities{1}(p,d); %prob of stay
            p1 = obj.HARDProbabilities{2}(p,d) + p0; % prob of hit
            if (size(obj.HARDProbabilities,2) == 3)
                p2 = obj.HARDProbabilities{3}(p,d) + p1; % prob of double
            else
                p2 = 0;
            end
            stratRand = rand(1);
            if (stratRand < p0)
                strat = 0;
            elseif (stratRand < p1)
                strat = 1;
            elseif (stratRand < p2)
                strat = 2;
            else
                strat = 0; % got dealt an Ace after splitting -- need to figure something out here
            end
        end
        
        function strat = soft(obj,p,d)
            p0 = obj.SOFTProbabilities{1}(p,d); %prob of stay
            p1 = obj.SOFTProbabilities{2}(p,d) + p0; % prob of hit
            if (size(obj.SOFTProbabilities,2) == 3)
                p2 = obj.SOFTProbabilities{3}(p,d) + p1; % prob of double
            else
                p2 = 0;
            end
            stratRand = rand(1);
            if (stratRand < p0)
                strat = 0;
            elseif (stratRand < p1)
                strat = 1;
            elseif (stratRand < p2)
               strat = 2;
            else
                strat = 0; % got dealt an Ace after splitting -- need to figure something out here
            end
        end
        
        function strat = pair(obj,p,d)
            p0 = obj.PAIRProbabilities{1}(p,d); %prob of stay
            p1 = obj.PAIRProbabilities{2}(p,d) + p0; % prob of hit
            stratRand = rand(1);
            if (stratRand < p0)
                strat = 0;
            elseif (stratRand < p1)
                strat = 1;
            else
                'Why am I here?'
            end
        end
        
        
        %% utility functions
        
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
        
        function str = toString(obj)
            tN = num2str(obj.trainNumber);
            lR = num2str(obj.learningRate);
            cS = num2str(obj.chanceSampledNumber);
            str = ['CFR Strat', ' Train Number = ' tN, ' Learning Rate = ' lR, ' Chance Sampled = ', cS];
        end
        
        function str = toName(obj)
            lR = num2str(obj.learningRate);
            lR(lR=='.') = '';
            tN = num2str(obj.trainNumber);
            cS = num2str(obj.chanceSampledNumber);
            str = ['CFRStrat', tN, '_', lR, '_', cS];
        end
        
        function s = payoff(obj,P,D,split,bet)
            % Payoff
            fs = 20;
            s = 0;
            valP = obj.value(P);
            valD = obj.value(D);
            if valP == 21 & length(P) == 2 & ...
                    ~(valD == 21 & length(D) == 2) & ~split
                s = s + 1.5*bet;
            elseif valP > 21
                s = s-1.25 * bet;
            elseif valD > 21
                s = s+ 0.75*bet;
                str = ['WIN: +' int2str(s)];
            elseif valD > valP
                s = s-bet;
            elseif valD < valP
                s = s + bet;
            else
                s = s;
            end
            %{
            if s < 0
                s = 2*s;
            end
            %}
        end
        
        
    end
end
    