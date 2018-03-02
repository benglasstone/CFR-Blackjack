function blackjacksim(n)
    %BLACKJACKSIM  Simulate blackjack.
    % S = blackjacksim(n)
    % Play n hands of blackjack.
    % Returns an n-by-1 vector of cumulative stake.
    clc; clear global;
    global GDeck totalStrats stratArray iterations;
    %load('CFR_Strat10_CFR.mat');
    %load('CFR_StratMod_CFR.mat');
    load('CFR_StratBack.mat');
    %load('CFT_StratMod50.mat');
    load('CFR_Strat100.mat');
    load('CFRStrat200_005_5.mat');
    load('CFRStrat400_0005_5.mat');
    load('CFRStrat500_0005_5.mat');
    stratArray = [CFRStrat200_005_5, CFRStrat400_0005_5, CFRStrat500_0005_5, DealerStrat(), BasicStrat3()];
    newlyTrained = [8]
    %stratArray = [CFRStrat()];%, CFRStrat(1) ,BasicStrat3()];%[BasicStrat(), BasicStrat2(), BasicStrat3(), DealerStrat(), HiLoStrat()];%, CFRStrat()];
    totalStrats = length(stratArray);
    tic
    totalRuns = 1000
    gainArray = zeros(totalRuns, totalStrats);
    for (k = 1:totalRuns)
        if mod(k,100) == 0
            k
        end
        if nargin == 0
            n = 1000;
        end
        GDeck = MyDeck(1);
        output = arrayfun(@blackjack_hand,zeros(n,1),'UniformOutput',false);
        for j = 1:n
            outputArray(:,j) = output{j};
        end
        %figure
        S = cumsum(outputArray,2);
        hold on;
        %plot([1,n],[0,0]);
        for i = 1:totalStrats
            gainArray(k,i) = 10*((S(i,n))/n);
        end
        %str = arrayfun(@toString,stratArray,'UniformOutput',false);
        %str = ['ZeroPoint', str];

        %print('-dpng', strName);
        hold off;
    end
    toc
    dateStr = sprintf('sims%s', datestr(now,'mm-dd-HH-MM'));
    mkdir(dateStr);
    for i = totalStrats:-1:1
        hold on;
        h = figure('pos',[10,10, 950, 600]);
        set(h, 'Visible', 'off');
        stratArray(i).toName
        averageValue = mean(gainArray(:,i))
        hist(gainArray(:,i),100)
        str = [stratArray(i).toString(),' Gain % = ', num2str(averageValue)];
        title(str);
        strName = [dateStr '/' stratArray(i).toName '.png'];
        saveas(h, strName);
        if strcmp(class(stratArray(i)),'CFRStrat') && ismember(i,newlyTrained)
            eval(['', stratArray(i).toName ' = stratArray(i)']);
            str = ['save(''',stratArray(i).toName,''',''' stratArray(i).toName ''')']
            eval(str);
        end
        pause(5)
        hold off;
    end
end

function s = blackjack_hand(varargin)
    %BLACKJACK_HAND  Play one hand of blackjack.
    %   s = blackjack_hand returns payoff from one hand.
    bet = 10;
    global GDeck totalStrats stratArray iterations;
    iterations = iterations + 1;
    if (mod(iterations, 1000) == 0)
        iterations
    end
    if (length(GDeck.deck) < 15)
        createDeck(GDeck);
    end
    for i = 1:totalStrats
        currDeck(i) = copy(GDeck);
    end
    s = zeros(totalStrats,1);
    for i = 1:totalStrats
        P = deal(currDeck(i));         % Player's hand
        D = deal(currDeck(i));         % Dealer's hand
        P = [P deal(currDeck(i))];      % Deal a second card to player
        D = [D -deal(currDeck(i))];    % Hide dealer's hole card
        
        % Play player's hand(s)
        [P,bet1,split] = stratArray(i).playhand('',P,D,bet,currDeck(i));
        
        % Play dealer's hand
        D(2) = -D(2);     % Reveal dealer's hole card
        while value(D) <= 16
            D = [D deal(currDeck(i))];
        end
        % Payoff
        s(i,1) = payoff(P,D,split,bet1);
    end
    GDeck = copy(currDeck(1));
end

function v = valuehard(X)
    % Evaluate hand
    X = min(mod(X-1,13)+1,10);
    v = sum(X);
end

function v = value(X)
    x= X;
    % Evaluate hand
    X = min(mod(X-1,13)+1,10);
    v = sum(X);
    % Promote soft ace
    if any(X==1) & v<=11
        v = v + 10;
    end
end

% ------------------------

function s = payoff(P,D,split,bet)
    % Payoff
    fs = 20;
    s = 0;
    for i = 1:(split+1)
        valP = value(P{i});
        valD = value(D);
        if valP == 21 & length(P{i}) == 2 & ...
                ~(valD == 21 & length(D) == 2) & ~split
            s = s + 1.5*bet(i);
        elseif valP > 21
            s = s-bet(i);
        elseif valD > 21
            s = s+bet(i);
            str = ['WIN: +' int2str(s)];
        elseif valD > valP
            s = s-bet(i);
        elseif valD < valP
            s = s + bet(i);
        else
            s = s;
        end
    end
end

% ------------------------