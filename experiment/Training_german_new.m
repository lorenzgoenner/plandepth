%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%   TRAINING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Prepare Matlab for experiment
sca;
close all;
clear all;

%initiate random number generator with a random seed
rng('shuffle');

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% PsychTweak('UseGPUIndex', 0);

%% Load everything needed for the experiment
load('experimental_variables.mat')

%makes screen transparent for debugging
%PsychDebugWindowConfiguration();

% Screen('Preference', 'SkipSyncTests', 1);

screen_number = max(Screen('Screens'));

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screen_number);

% Set a blakish background
blackish = white / 20;

% Open an on screen window using PsychImaging and color it grey.
[window, windowRect] = PsychImaging('OpenWindow', screen_number, blackish);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Here we use to a waitframes number greater then 1 to flip at a rate not
% equal to the monitors refreash rate. For this example, once per second,
% to the nearest frame
flipSecs = 1;
waitframes = round(flipSecs / ifi);

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 30);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);


imagePos = [[xCenter-500, yCenter];
            [xCenter-200, yCenter-250];
            [xCenter+200, yCenter-250];
            [xCenter+500, yCenter];
            [xCenter+200, yCenter+250];
            [xCenter-200, yCenter+250]];


jumps = [5 4 5 6 2 2];        
md = .5; %movement duration
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%  INSTRUCTIONS START FROM HERE   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Introductory text
text = ['Hallo Abenteurer!' ...
        '\n\n\n\n Willkommen im Trainingslager'... 
        '\n\n\n\n Heute hast du die Chance an einer Reise durch den Weltraum teilzunehmen.'...
        '\n\n\n\n Um m�glichst viele Punkte zu sammeln, ist es wichtig, dass du deine Reisen immer im Voraus planst.'...        
        '\n\n\n\n Bevor es losgeht, zeige ich dir jedoch wie du im Weltraum �berleben kannst.'];
     
% Draw all the text in one go
DrawFormattedText(window, text, 'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;


%%%%%%%%%%%% INSTRUCTIONS 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%text 
text = ['Du wirst durch verschiedene Planetensysteme reisen.' ...
        '\n\n\n\n Jedes dieser Systeme besteht aus sechs Planeten.' ...
         '\n\n\n\n Dr�cke eine Taste um fortzufahren.'];


% Draw all the text in one go
DrawFormattedText(window, text, 'center', screenYpixels * 0.25, white);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

%%%%%%%%%%%% SHOW PLANETSYSTEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      
planets_img_location = ['planet_1.png'; 'planet_2.png'; 'planet_3.png'; ...
                        'planet_4.png'; 'planet_5.png'];

PlanetsTexture = NaN(1,5);
for i=1:5
  [planet, ~, palpha] = imread(planets_img_location(i, :)); 
  % Add transparency to the background
  planet(:,:,4) = palpha;
  % Make the planets into a texture
  PlanetsTexture(i) = Screen('MakeTexture', window, planet);
end

% Get the size of the planet image
[p1, p2, p3] = size(planet);

planetRect = [0 0 p2 p1];

%generate planet locations
planetsPos = NaN(4, 6);
for i=1:6
    planetsPos(:,i) = CenterRectOnPointd(planetRect, ... 
                            imagePos(i,1), imagePos(i,2));
end
  
% plot planets for the given mini block
planetList = [1, 3, 2, 2, 4, 5];
draw_planets(planetList, window, PlanetsTexture, planetsPos);
    
% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9); 

Screen('flip', window);
 
KbStrokeWait;
% 
% 
% %%%%%%%%%%%% INSTRUCTIONS 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = ['Ein Raumschiff zeigt dir zu jedem Zeitpunkt deine aktuelle Position an'];
        

% Draw all the text in one go
DrawFormattedText(window, text,...
    'center', screenYpixels * 0.1, white);

%%%%%%%%%%%% SHOW PLANETSYSTEM + ROCKET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

draw_planets(planetList, window, PlanetsTexture, planetsPos);
    
rocket_img_location = 'rocket.png';
[rocket, ~, ralpha] = imread(rocket_img_location);

% Add transparency to the background
rocket(:,:,4) = ralpha;

% Get the size of the rocket image
[s1, s2, ~] = size(rocket);

rocketRect = [0 0 s2 s1];

%generate rocket locations
rocketPos = NaN(4, 6);
for i=1:6
    rocketPos(:,i) = CenterRectOnPointd(rocketRect, ...
                                imagePos(i,1), imagePos(i,2));
end

% Make the rocket into a texture
RocketTexture = Screen('MakeTexture', window, rocket);

Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,1)');

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);  

Screen('flip', window);

KbStrokeWait;

 
%%%%%%%%%%%% INSTRUCTIONS 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = ['Um im Weltraum zu �berleben, musst du versuchen soviel Treibstoff wie m�glich zu sammeln.' ... 
        '\n\n\n\n Um Treibstoff zu erhalten, reist du von Planet zu Planet.'...
        '\n\n\n\n Dabei kannst du dich immer zwischen den Kommandos RECHTS und (S)prung entscheiden.'...
        '\n\n\n\n RECHTS kostet dich dabei immer 2 Treibstoffeinheiten, w�hrend (S)prung 5 Treibstoffeinheiten verbraucht.']; 


% Draw all the text in one go
DrawFormattedText(window, text,...
    'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

%%%%%%%%%%%%% INTRODUCE FUEL TANK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% INSTRUCTIONS 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% text
text = ['Deinen aktuellen Treibstofflevel kannst du am oberen Bildschirmrand ablesen.'];


% Draw all the text in one go
DrawFormattedText(window, text,...
    'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.8); 

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;                

%%%%%%%%%%%% Bar in the middle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

planets = Practise;
       
% Initial point and planet specific rewards
points = 990;
% points bar
bar = [0, 0, 100, 1000];

% draw point bar
draw_point_bar(points, window, xCenter, screenYpixels);
    
% Draw planets
draw_planets(planets, window, PlanetsTexture, planetsPos);
    
start = 1;
% Draw the rocket at the starting position 
Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
    
% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

vbl = Screen('flip', window);
    
KbStrokeWait;       

 
% %%%%%%%%%%%% PRACTISE JUMPING LEFT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
text = ['Zuerst schauen wir uns an, was passiert, wenn du RECHTS w�hlst.' ...
        '\n\n\n\n RECHTS erm�glicht es dir im Uhrzeigersinn zum n�chsten' ...
        '\n\n benachbarten Planeten zu reisen.' ...
        '\n\n\n\n Du kannst dies nun ein paar Mal ausprobieren.']; 


% Draw all the text in one go
DrawFormattedText(window, text,...
    'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9); 

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

NoMiniBlocks = 1;
NoTrials = 1;  %change to 12
points = 990;
start = 1;
for t = 1:NoTrials
    while(true)

        % draw fuel tank
        draw_point_bar(points, window, xCenter, screenYpixels);
   
        % plot planets for the given mini block
        draw_planets(Practise, window, PlanetsTexture, planetsPos);

        % Draw the rocket at the starting position 
        Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
        vbl = Screen('flip', window);

        % Wait for a key press
        [secs, keyCode, deltaSecs] = KbPressWait;

        if strcmp(KbName(keyCode), 'RightArrow')
            p = state_transition_matrix(1, start, :);
            next = find(cumsum(p)>=rand,1);

            % move the rocket
            time = 0;
            locStart = imagePos(start, :);
            locEnd = imagePos(next, :);
            while time < md

                % Position of the square on this frame
                xpos = locStart(1) + time/md*(locEnd(1) - locStart(1));
                ypos = locStart(2) + time/md*(locEnd(2) - locStart(2));

                % Center the rectangle on the centre of the screen
                cRect = CenterRectOnPointd(rocketRect, xpos, ypos);

                % draw fuel tank
                draw_point_bar(points, window, xCenter, screenYpixels);

                % draw planets            
                draw_planets(Practise, window, PlanetsTexture, planetsPos);
                Screen('DrawTexture', window, RocketTexture, [], cRect);
                
                DrawFormattedText(window, '-2', 'center', yCenter-100, white);
                
                % Flip to the screen
                vbl  = Screen('Flip', window, vbl + 0.5*ifi);

                % Increment the time
                time = time + ifi;

            end
            points = points + actionCost(1);
            % set start to a new location
            start = next;

            % draw fuel tank
            draw_point_bar(points, window, xCenter, screenYpixels);

            % draw planets
            draw_planets(Practise, window, PlanetsTexture, planetsPos);

            % draw_buttons(window, ButtonsTexture, buttonsPos);
            Screen('DrawTexture', window, RocketTexture, [], cRect);

            Screen('Flip', window);
            break;
        else
              DrawFormattedText(window, 'Bitte RECHTS dr�cken',...
                                        'center', 'center', white);
              Screen('Flip', window);
              WaitSecs(1.);
        end
    end
end

%%%%%%% SHORT BREAK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DrawFormattedText(window, 'Als n�chstes zeige ich dir was beim Kommando (S)prung passiert.',...
                  'center', 'center', white);
                                
Screen('flip', window);

WaitSecs(3.);

% %%%%%%%%%%%% PRACTISE JUMPING Right %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = [' Wenn du (S)prung wahlst, reist dein Raumschiff zu einem nicht benachbarten Planeten.' ... 
        '\n\n\n\n Als n�chstes kannst du ausprobieren was an jeder Planetenposition passiert, wenn du (S)prung w�hlst.'...
        '\n\n\n\n Es ist wichtig, dass du dir das gezeigte Flugmuster gut einpr�sgst.']; 


% Draw all the text in one go
DrawFormattedText(window, text,'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

points = 990;

for n = 1:NoMiniBlocks
    for t = 1:NoTrials
        while(true)
            if t < 7
                start = t;
            else
                start = t-6;
            end
            
            % draw fuel tank
            draw_point_bar(points, window, xCenter, screenYpixels);
            
            % plot planets for the given mini block
            planetList = Practise;
            draw_planets(planetList, window, PlanetsTexture, planetsPos);

            % Draw the rocket at the starting position 
            Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
            vbl = Screen('flip', window);

            % Wait for a key press
            [secs, keyCode, deltaSecs] = KbPressWait;

            if strcmp(KbName(keyCode), 's')
                p = state_transition_matrix(2, start, :);
                next = find(cumsum(p)>=rand,1);

                % move the rocket
                time = 0;
                locStart = imagePos(start, :);
                locEnd = imagePos(next, :);
                poinst = points + actionCost(2);
                while time < md

                    % Position of the square on this frame
                    xpos = locStart(1) + time/md*(locEnd(1) - locStart(1));
                    ypos = locStart(2) + time/md*(locEnd(2) - locStart(2));

                    % Center the rectangle on the centre of the screen
                    cRect = CenterRectOnPointd(rocketRect, xpos, ypos);
                    
                    % draw fuel tank
                    draw_point_bar(points, window, xCenter, screenYpixels);
                    
                    % draw planets
                    draw_planets(planetList, window, PlanetsTexture, planetsPos);

                    % Draw the rect to the screen
                    Screen('DrawTexture', window, RocketTexture, [], cRect);
                    % Flip to the screen

                    DrawFormattedText(window, '-5', 'center', yCenter-100, white);
                   
                    vbl  = Screen('Flip', window, vbl + 0.5*ifi);


                    % Increment the time
                    time = time + ifi;
               end
               points = points + actionCost(2);
                
               WaitSecs(1);
               Screen('Flip', window);
               WaitSecs(1);
               break;
            else 
                  DrawFormattedText(window, 'Bitte S dr�cken', 'center', 'center', white);
                  Screen('Flip', window); 
                  WaitSecs(1);                   
            end
        end
    end
end

% %%%%%%%%%%%% SHOW REISEMUSTER FOR  JUMPING Right %%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = [' Hier siehst du das Flugmuster nocheinmal im Ganzen' ... 
        '\n\n\n\n ']; 

    
Reisemuster= imread ('Reisemuster_Vorlage_2.jpg');
ReiseTexture= Screen('MakeTexture', window, Reisemuster);
Screen('DrawTexture', window, ReiseTexture);


% Draw all the text in one go
DrawFormattedText(window, text,'center', screenYpixels * 0.10, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

Screen('flip', window);

KbStrokeWait;



% %%%%%%%%%%%% PRACTISE TRAVEL PATTERN  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = [' Um dir zu helfen das Muster noch mehr zu verinnerlichen, spielen wir jetzt ein kleines Spiel.' ... 
        '\n\n\n\n Ich zeige dir verschiedene Startposition und du kannst mit den Tasten 1-6 sagen'...
        '\n\n\n auf welchem Zielplaneten du landest, wenn du (S)prung w�hlst.'...
        '\n\n\n\n Anschlie�end bekommst du ein Feedback ob du richtig geantwortet hast.']; 


% Draw all the text in one go
DrawFormattedText(window, text,'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%   Training_S_Test %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NoTrials=1; %change to 18

points = 990;
TestStarts= [1,2,3,4,5,6,2,5,1,6,3,4,3,6,4,1,5,2];
RightAnswer=[5,4,5,6,2,2,4,2,5,2,5,6,5,2,6,5,2,4];


for n = 1:NoMiniBlocks
    
     
    for t = 1:NoTrials

            start=TestStarts(t);
            
            % draw fuel tank
            draw_point_bar(points, window, xCenter, screenYpixels);
            
            % plot planets for the given mini block
            planetList = Practise;
            draw_planets(planetList, window, PlanetsTexture, planetsPos);
            

            
            % Draw numbers
            DrawFormattedText(window, '1', xCenter-520, yCenter+30);
            DrawFormattedText(window, '2', xCenter-220, yCenter-220);
            DrawFormattedText(window, '3', xCenter+180, yCenter-220);
            DrawFormattedText(window, '4', xCenter+480, yCenter+30);
            DrawFormattedText(window, '5', xCenter+180, yCenter+280);
            DrawFormattedText(window, '6', xCenter-220, yCenter+280);


            % Draw the rocket at the starting position 
            Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
            vbl = Screen('flip', window);

            % Wait for a key press
            [secs, keyCode, deltaSecs] = KbPressWait;
            
            Resp= KbName(keyCode);
            Resp = str2double(Resp(1));
            
            % draw fuel tank
            draw_point_bar(points, window, xCenter, screenYpixels);
            
            % plot planets for the given mini block
            planetList = Practise;
            draw_planets(planetList, window, PlanetsTexture, planetsPos);
            

            
            % Draw numbers
            DrawFormattedText(window, '1', xCenter-520, yCenter+30);
            DrawFormattedText(window, '2', xCenter-220, yCenter-220);
            DrawFormattedText(window, '3', xCenter+180, yCenter-220);
            DrawFormattedText(window, '4', xCenter+480, yCenter+30);
            DrawFormattedText(window, '5', xCenter+180, yCenter+280);
            DrawFormattedText(window, '6', xCenter-220, yCenter+280);


            % Draw the rocket at the starting position 
            Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');

            if Resp == RightAnswer(t)
               
                DrawFormattedText(window, 'Richtig', 'center', 'center', white)
                vbl = Screen('flip', window);
                WaitSecs(0.5);

                
            else
                DrawFormattedText(window, 'Falsch, schau dir die richtige Antwort an!', 'center', 'center', white);
                
                vbl = Screen('flip', window);
                
                WaitSecs(2);
                
            end  
                p = state_transition_matrix(2, start, :);
                next = find(cumsum(p)>=rand,1);

                % move the rocket
                time = 0;
                locStart = imagePos(start, :);
                locEnd = imagePos(next, :);
                poinst = points + actionCost(2);
                while time < md

                    % Position of the square on this frame
                    xpos = locStart(1) + time/md*(locEnd(1) - locStart(1));
                    ypos = locStart(2) + time/md*(locEnd(2) - locStart(2));

                    % Center the rectangle on the centre of the screen
                    cRect = CenterRectOnPointd(rocketRect, xpos, ypos);
                    
                    % draw fuel tank
                    draw_point_bar(points, window, xCenter, screenYpixels);
                    
                    % draw planets
                    draw_planets(planetList, window, PlanetsTexture, planetsPos);
            
                    % draw number        
                     DrawFormattedText(window, '1', xCenter-520, yCenter+30);
                     DrawFormattedText(window, '2', xCenter-220, yCenter-230);
                     DrawFormattedText(window, '3', xCenter+180, yCenter-230);
                     DrawFormattedText(window, '4', xCenter+480, yCenter+30);
                     DrawFormattedText(window, '5', xCenter+180, yCenter+280);
                     DrawFormattedText(window, '6', xCenter-220, yCenter+280);

                    % Draw the rect to the screen
                    Screen('DrawTexture', window, RocketTexture, [], cRect);
                    % Flip to the screen

                    DrawFormattedText(window, '-5', 'center', yCenter-100, white);
                   
                    vbl  = Screen('Flip', window, vbl + 0.5*ifi);


                    % Increment the time
                    time = time + ifi;
               end
               points = points + actionCost(2);
                
               WaitSecs(1);
               Screen('Flip', window);
               WaitSecs(1);

    end 
 end
    



%%%%%%% SHORT BREAK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DrawFormattedText(window, 'Als n�chstes zeige ich dir eine Besonderheit des Kommandos (S)prung.',...
                  'center', 'center', white);
                                
Screen('flip', window);

WaitSecs(3.);


% %%%%%%%%%%%% PRACTISE RIGHT ACTION IN LOW NOISE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = ['Im richtigen Experiment, kann es passieren, dass deine Reise nach (S)prung unzuverl�ssig ist'...
          '\n\n\n\n In solchen F�llen verfehlt das Raumschiff den Zielplaneten'...
          '\n\n und landet stattdessen auf einem Nachbarplaneten des Zielplaneten.'];

      
% Draw all the text in one go
DrawFormattedText(window, text, 'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;


% %%%%%%%%%%%% PRACTISE RIGHT ACTION IN LOW NOISE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = ['Das Bild soll dir nocheinmal verdeutlichen was das bedeutet.'...
        '\n\n Die durchgezogene rote Linie zeigt den Sprung zum erwarteten Zielplaneten, '...
          '\n\n die gestrichelten Linien zeigen dir wo dein Raumschiff landen kann, wenn es den Zielplaneten verfehlt'];

          
Reisemuster= imread ('Reisemuster_Vorlage_3.jpg');
ReiseTexture= Screen('MakeTexture', window, Reisemuster);
Screen('DrawTexture', window, ReiseTexture);
       
% Draw all the text in one go
DrawFormattedText(window, text, 'center', screenYpixels * 0.1, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.95);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%% SHOW REISEMUSTER FOR  JUMPING Right %%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = [' Um dir ein Gef�hl daf�r zu geben, simuliere ich dies im n�chsten Schritt.'...
           '\n\n\n\n Beachte, dass das Reisemuster dabei gleich bleibt und'...
           '\n\n nur weniger zuverl�ssig ist.']; 




% Draw all the text in one go
DrawFormattedText(window, text,'center', screenYpixels * 0.10, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

Screen('flip', window);

KbStrokeWait;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


NoTrials = 1; %change to 12
points = 990;
for n = 1:NoMiniBlocks
    for t = 1:NoTrials
        while(true)
            if t < 7
                start = t;
            else
                start = t-6;
            end
            
            % draw fuel tank
            draw_point_bar(points, window, xCenter, screenYpixels);

            % plot planets for the given mini block
            planetList = Practise;
            draw_planets(planetList, window, PlanetsTexture, planetsPos);

            % Draw the rocket at the starting position 
            Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
            vbl = Screen('flip', window);

            % Wait for a key press
            [secs, keyCode, deltaSecs] = KbPressWait;

            if strcmp(KbName(keyCode), 's')
                p = state_transition_matrix(3, start, :);
                next = find(cumsum(p)>=rand,1);
                if next ~= jumps(start)
                    missed = 1;
                else
                    missed = 0;
                end
                
                if missed
                    % draw fuel tank
                    draw_point_bar(points, window, xCenter, screenYpixels);

                    % plot planets for the given mini block
                    planetList = Practise;
                    draw_planets(planetList, window, PlanetsTexture, planetsPos);

                    % Draw the rocket at the starting position 
                    Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
                    DrawFormattedText(window, 'Zielplanet verfehlt', 'center', 'center', [1 0 0]);
                    vbl = Screen('Flip', window); 
                    WaitSecs(1);  
                end     
                    
                
                points = points + actionCost(2);
                % move the rocket
                time = 0;
                locStart = imagePos(start, :);
                locEnd = imagePos(next, :);
                while time < md

                    % Position of the square on this frame
                    xpos = locStart(1) + time/md*(locEnd(1) - locStart(1));
                    ypos = locStart(2) + time/md*(locEnd(2) - locStart(2));

                    % Center the rectangle on the centre of the screen
                    cRect = CenterRectOnPointd(rocketRect, xpos, ypos);
                    
                    % draw fuel tank
                    draw_point_bar(points, window, xCenter, screenYpixels);

                    % draw planets
                    draw_planets(planetList, window, PlanetsTexture, planetsPos);

                    % Draw the rect to the screen
                    Screen('DrawTexture', window, RocketTexture, [], cRect);
                    % Flip to the screen
                    
                    DrawFormattedText(window, '-5', 'center', yCenter-100, white);

                    vbl  = Screen('Flip', window, vbl + 0.5*ifi);

                    % Increment the time
                    time = time + ifi;
               end
               points = points + actionCost(2);
               
               WaitSecs(1);
               Screen('Flip', window);
               WaitSecs(1);
               break;
            else
               DrawFormattedText(window, 'Bitte S dr�cken', 'center', 'center', white);
               Screen('Flip', window); 
               WaitSecs(1);                   
            end
        end
    end
end

%%%%%%% SHORT BREAK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
text= ['Als n�chstes zeige ich dir was bei Kommando (S)prung passiert, ' ...
    '\n\n wenn sich Asteroiden im Planetensystem befinden.'];

DrawFormattedText(window, text, 'center', 'center', white);
                                
Screen('flip', window);

WaitSecs(3.);
 
% %%%%%%%%%%%% PRACTISE RIGHT ACTION IN HIGH NOISE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = ['In manchen Planetensystemen befinden sich au�er den Planeten Asteroiden.'...
        '\n\n\n\n Ob du dich in einem Planetensystem mit Asteroiden befindest,'...
        '\n\n kannst du immer am Hintergrund erkennen'...
        '\n\n\n\n Unter diesen Bedingungen ist das Kommando (S)prung  hochgradig unzuverl�ssig.' ... 
        '\n\n\n\n Damit dir auch hierf�r ein Gef�hl zu geben,'...
        '\n\n simuliere ich auch dies im n�chsten Schritt.'...
        '\n\n\n\n Beachte dass auch hier das Reisemuster das gleiche bleibt,'...
        '\n\n aber dass es wahrscheinlicher wird, dass du den Zielplaneten verfehlst.']; 


% Draw all the text in one go
DrawFormattedText(window, text, 'center', screenYpixels * 0.15, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

debrisLoc = 'debris.png';

[debris, ~, dalpha] = imread(debrisLoc);

% Add transparency to the background
debris(:,:,4) = dalpha;

% Get the size of the debris image
[d1, d2, ~] = size(debris);

debrisRect = [0 0 d2 d1];

%generate debris locations
debrisPos = CenterRectOnPointd(debrisRect, xCenter, yCenter);

% Make the debris into a texture
DebrisTexture = Screen('MakeTexture', window, debris);

points = 990;
 
NoTrials = 1;  %% change to 12 
for t = 1:NoTrials
    while(true)
        if t < 7
            start = t;
        else
            start = t-6;
        end
        % Draw debris
        Screen('DrawTexture', window, DebrisTexture, [], debrisPos)
        
        % draw fuel tank
        draw_point_bar(points, window, xCenter, screenYpixels);

        % Draw planets for the given mini block
        planetList = Practise;
        draw_planets(planetList, window, PlanetsTexture, planetsPos);

        % Draw the rocket at the starting position 
        Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
        
        vbl = Screen('flip', window);

        % Wait for a key press
        [secs, keyCode, deltaSecs] = KbPressWait;

        if strcmp(KbName(keyCode), 's')
            p = state_transition_matrix(4, start, :);
            next = find(cumsum(p)>=rand,1);
            
                if next ~= jumps(start)
                    missed = 1;
                else
                    missed = 0;
                end
                
                if missed                    
                    % Draw debris
                    Screen('DrawTexture', window, DebrisTexture, [], debrisPos)
        
                    % draw fuel tank
                    draw_point_bar(points, window, xCenter, screenYpixels);

                    % Draw planets for the given mini block
                    planetList = Practise;
                    draw_planets(planetList, window, PlanetsTexture, planetsPos);

                    % Draw the rocket at the starting position 
                    Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
                    
                    DrawFormattedText(window, 'Zielplanet verfehlt', 'center', 'center', [1 0 0 ]);
                    vbl= Screen('Flip', window); 
                    WaitSecs(1);  
                end     

            % Move the rocket
            time = 0;
            locStart = imagePos(start, :);
            locEnd = imagePos(next, :);
            while time < md

                % Position of the square on this frame
                xpos = locStart(1) + time/md*(locEnd(1) - locStart(1));
                ypos = locStart(2) + time/md*(locEnd(2) - locStart(2));

                % Center the rectangle on the centre of the screen
                cRect = CenterRectOnPointd(rocketRect, xpos, ypos);

                % Draw debris
                Screen('DrawTexture', window, DebrisTexture, [], debrisPos)
                
                % draw fuel tank
                draw_point_bar(points, window, xCenter, screenYpixels);
                
                draw_planets(planetList, window, PlanetsTexture, planetsPos);

                % Draw the rect to the screen
                Screen('DrawTexture', window, RocketTexture, [], cRect);
                % Flip to the screen
                
                DrawFormattedText(window, '-5', 'center', yCenter-100, white);

                vbl  = Screen('Flip', window, vbl + 0.5*ifi);


                % Increment the time
                time = time + ifi;

            end
           points = points + actionCost(2);

           WaitSecs(1);
           Screen('Flip', window);
           WaitSecs(1);
           break;
        else 
              DrawFormattedText(window, 'Bitte S dr�cken', 'center', 'center', white);
              Screen('Flip', window); 
              WaitSecs(1);                   
        end
    end
end

%%%%%%%%%%%% INSTRUCTIONS 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% text
text = ['Zus�tzlich zu dem Treibstoff, der dich das Reisen kostet,' ...
        '\n\n kann dich die Landung auf einem Planeten auch Treibstoff kosten,'...
        '\n\n aber du kannst dort auch Treibstoff finden.'...
        '\n\n\n\n Ob und wieviel du gewinnst oder verlierst h�ngt davon ab auf was f�r einem Zielplaneten du landest.'...
        '\n\n\n\n Um zu �berleben ist es wichtig, dass du versuchst soviel Treibstoff wie m�glich zu sammeln.'...
        '\n\n\n\n Damit du das kannst, zeige ich dir im n�chsten Schritt' ...
        '\n\n welche Planeten gute und welche schlechte Treibstoffquellen sind.'];

% Draw all the text in one go
DrawFormattedText(window, text,...
    'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);
              
% Flip to the screen
Screen('Flip', window);

KbStrokeWait;        

%%%%%%%%%%%% INSTRUCTIONS 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Position of Planets
Rew_Pos =[[xCenter-600, yCenter]
          [xCenter-300, yCenter]
          [xCenter, yCenter]
          [xCenter+300, yCenter]
          [xCenter+600, yCenter]];

      
% Create planet Position
rewPlanetsPos = NaN(4, 5);
for i=1:5
    rewPlanetsPos(:,i) = CenterRectOnPointd(planetRect, Rew_Pos(i,1), Rew_Pos(i,2));
end

planetList = Rew_Planets;
draw_planets(planetList, window, PlanetsTexture, rewPlanetsPos);   
    
% Show Rewards
          
Screen('DrawText', window, ...
    '-20', xCenter-625, yCenter+150); 

Screen('DrawText', window, ...
    '-10', xCenter-325, yCenter+150); 

Screen('DrawText', window, ...
    '0', xCenter, yCenter+150); 

Screen('DrawText', window, ...
    '+10', xCenter+275, yCenter+150); 

Screen('DrawText', window, ...
    '+20', xCenter+575, yCenter+150); 
    
DrawFormattedText(window, 'Bitte merke dir die Treibstoffbelohnung f�r jeden Planeten: ', ...
                  'center',  screenYpixels*0.25, white); 

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.8); 

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;  
                
%%%%%%%%%%%% INSTRUCTIONS 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% text
text = ['Wennn du in einem neuen Planetensystem ankommst hast du' ...
         '\n\n 2 oder 3 Reisen um soviel Treibstoff wie m�glich zu sammeln.'...
         '\n\n Bevor du zum n�chsten Planetensystem gehen kannst, musst du alle Reisen verwenden.' ...
         '\n\n\n\n Die Anzahl an gr�nen Quadraten zeigt dir an wieviele Reisen du �brig hast' ...
         '\n\n bevor du zum n�chsten Planetensystem geschickt wirst.'];


% Draw all the text in one go
DrawFormattedText(window, text,...
    'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.8); 

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;                

%%%%%%%%%%%% Action points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Variables

% Specify number of MiniBlocks

planets = Practise;
NoTrials = 3;

       
% Initial point and planet specific rewards
points = 990;
% points bar
bar = [0, 0, 100, 1000];

% buttons_img_location = ['button1.png'; 'button2.png'];
% 
% ButtonsTexture = NaN(2);
% for i=1:2
%   [button, ~, balpha] = imread(buttons_img_location(i, :)); 
%   % Add transparency to the background
%   button(:,:,4) = balpha;
%   % Make the planets into a texture
%   ButtonsTexture(i) = Screen('MakeTexture', window, button);
% end
% 
% % Get the size of the button image
% [b1, b2, ~] = size(button);
% 
% buttonRect = [0 0 b2 b1];
% 
% %generate buttons locations
% buttonsPos = NaN(4, 2);
% xPos = [-800, 800];
% for i=1:2
%     buttonsPos(:,i) = CenterRectOnPointd(buttonRect, xCenter + xPos(i), yCenter+300);
% end

% draw point bar
draw_point_bar(points, window, xCenter, screenYpixels);
    
% draw remaining action counter
draw_remaining_actions(window, 1, NoTrials, xCenter, yCenter);
    
    % draw buttons
%     draw_buttons(window, ButtonsTexture, buttonsPos);
    
% Draw planets
draw_planets(planets, window, PlanetsTexture, planetsPos);
    
start = 1;
% Draw the rocket at the starting position 
Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
    
% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

vbl = Screen('flip', window);
    
KbStrokeWait;       

%%%%%%%%%%% SUMMARY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Summary text
text = ['Ich fasse noch einmal alles f�r dich zusammen:' ...
        '\n\n\n\n Deine Aufgabe ist es m�glichst viel Treibstoff zu sammeln indem du von Planet zu Planet reist.'... 
        '\n\n Du kannst immer entweder einen Planeten nach Rechts reisen, das kostet dich 2 Treibstoffeinheiten'...
        '\n\n oder f�r 5 Treibstoffeinheiten Springen. Je nachdem auf was f�r einem Planeten du landest,'...
        '\n\n gewinnst oder verlierst du Treibstoff.'... 
        '\n\n\n\n Der blaue Balken am oberen Rand zeigt dir deinen aktuellen Treibstoffstand.'...     
        '\n\n\n\n Manchmal passiert es beim Springen, das du, statt auf dem erwarteten Zielplaneten,'...
        '\n\n auf einem seiner Nachparplaneten landest. Das passiert besonders h�ufig in Planetensystemen'...
        '\n\n mit Asteroiden, kann aber auch (selten)in den anderen Planetensystemen passieren.'];
     
% Draw all the text in one go
DrawFormattedText(window, text, 'center', screenYpixels * 0.1, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;


%%%%%%%%%%% TIPP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Introductory text
text = ['Hier noch ein kleiner Tipp:' ...
        '\n\n Es hilft dir bei der Aufgabe wenn du mehrere Schritte im Voraus planst'... 
        '\n\n Ich zeige dir das an einem Beispiel:'...
        '\n\n\n\n '];
     
% Draw all the text in one go
DrawFormattedText(window, text, 'center', screenYpixels * 0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;

%%%%%%%%%%% TIPP 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = [' Wenn du nur einen Schritt voraus planst, w�rdest du wahrscheinlich direkt zum blauen Planeten springen' ...
        '\n\n Danach w�rst du jedoch gezwungen auf einen der roten Planeten zu springen'...
        'n\n Insgesamt w�rdest du so mindestens 17 Treibstoffeinheiten verlieren (-5 +10 -2 -20)'...
        '\n\n\n\n ']; 

    
Tip= imread ('Tipp_1.jpg');
ReiseTexture= Screen('MakeTexture', window, Tip);
Screen('DrawTexture', window, ReiseTexture);


% Draw all the text in one go
DrawFormattedText(window, text,'center', screenYpixels * 0.10, white);


% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;


%%%%%%%%%%% TIPP 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text = [' In diesem Planetensystem w�re es also besser gewesen, erst wenige Punkte zu verlieren,' ...
        '\n\n um erst danach zum blauen Planeten zu reisen'...
        'n\n Insgesamt h�ttest du so nur 4 Treibstoffeinheiten verloren (-2 -10 +10 -2)'...
        '\n\n\n\n ']; 

    
Tip= imread ('Tipp_2.jpg');
ReiseTexture= Screen('MakeTexture', window, Tip);
Screen('DrawTexture', window, ReiseTexture);


% Draw all the text in one go
DrawFormattedText(window, text,'center', screenYpixels * 0.10, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.9);


% Flip to the screen
Screen('Flip', window);

KbStrokeWait;


%%%%%%%%%%% INSTRUCTIONS 6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% text
text = ['Du kannst die Aufgabe nun ein paar Mal �ben'...
        '\n\n versuche dabei so voraus zu planen, dass du insgesamt den bestm�glichen Reiseweg nimmst'];


% Draw all the text in one go
DrawFormattedText(window, text,...
    'center', screenYpixels*0.25, white);

% Press Key to continue  
DrawFormattedText(window, 'Dr�cke eine Taste um fortzufahren.', ...
                  'center', screenYpixels*0.8);

% Flip to the screen
Screen('Flip', window);

KbStrokeWait;      


%%%%%%%%%%%% PRACTISE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Variables

% Specify number of MiniBlocks

NoMiniBlocks = 4;
planets = Planet_Feedback;
starts = conditionsFeedback.starts;

correctResponses = [[0 1 0]; [0 1 0]; [1 0 1]; [0 0 1]];

for n = 1:NoMiniBlocks
    while true
        text = ['In K�rze erreichst du ein neues Planetensystem...'];
    
        % Draw all the text in one go
        DrawFormattedText(window, text,...
                      'center', screenYpixels * 0.25, white);

        % Flip to the screen
        Screen('Flip', window);
        WaitSecs(1.5);
    
        cond = conditionsFeedback.noise{n};
        NoTrials = conditionsFeedback.notrials(n);
    
        if strcmp(cond, 'high')
            % Draw debris
            Screen('DrawTexture', window, DebrisTexture, [], debrisPos)
        end
    
        % draw point bar
        draw_point_bar(points, window, xCenter, yCenter);
    
        % draw remaining action counter
        draw_remaining_actions(window, 1, NoTrials, xCenter, yCenter);
      
        % plot planets for the given mini block
        planetList = planets(n,:);
        draw_planets(planetList, window, PlanetsTexture, planetsPos);
    
        start = starts(n);
        % Draw the rocket at the starting position 
        Screen('DrawTexture', window, RocketTexture, [], rocketPos(:,start)');
        vbl = Screen('flip', window);
        
        TestKey = zeros(1,3);
        for t = 1:NoTrials
            % Wait for a key press
            while true
                [secs, keyCode, deltaSecs] = KbPressWait;
                Key = KbName(keyCode);
                if strcmp(Key, 'RightArrow') || strcmp(Key, 's')
                    break;
                end
            end
        
            if strcmp(Key, 'RightArrow')
                p = state_transition_matrix(1, start, :);
                next = find(cumsum(p)>=rand,1);
                ac = actionCost(1);
                points = min(points + ac, 1000);
                TestKey(t) = 1;
            elseif strcmp(Key, 's')
                if strcmp(cond, 'low')
                    p = state_transition_matrix(3, start, :);
                else
                    p = state_transition_matrix(4, start, :);
                end
                next = find(cumsum(p)>=rand,1);
                ac = actionCost(2);
                points = min(points + ac, 1000);
                TestKey(t) = 0;
            end

            % move the rocket
            md = .5; %movement duration
            time = 0;
            locStart = imagePos(start, :);
            locEnd = imagePos(next, :);
            while time < md
                if strcmp(cond, 'high')
                    % Draw debris
                    Screen('DrawTexture', window, DebrisTexture, [], debrisPos)
                end
                draw_point_bar(points, window, xCenter, yCenter);
                draw_remaining_actions(window, t, NoTrials, xCenter, yCenter);
    %             draw_buttons(window, ButtonsTexture, buttonsPos);
                draw_planets(planetList, window, PlanetsTexture, planetsPos);

                % Position of the square on this frame
                xpos = locStart(1) + time/md*(locEnd(1) - locStart(1));
                ypos = locStart(2) + time/md*(locEnd(2) - locStart(2));

                % Center the rectangle on the centre of the screen
                cRect = CenterRectOnPointd(rocketRect, xpos, ypos);

                % Draw the rect to the screen
                Screen('DrawTexture', window, RocketTexture, [], cRect);

                DrawFormattedText(window, int2str(ac), 'center', yCenter-100, white);

                % Flip to the screen
                vbl  = Screen('Flip', window, vbl + 0.5*ifi);

                % Increment the time
                time = time + ifi;
            end

            % set start to a new location
            start = next;
            reward = planetRewards(planetList(next));
            points = min(points + reward, 1000);

            if reward > 0
                s = strcat('+', int2str(reward));
            else
                s = int2str(reward);
            end

            if strcmp(cond, 'high')
               % Draw debris
               Screen('DrawTexture', window, DebrisTexture, [], debrisPos)
            end
            DrawFormattedText(window, s, 'center', yCenter - 100, white);
            draw_point_bar(points, window, xCenter, yCenter);
            draw_remaining_actions(window, t+1, NoTrials, xCenter, yCenter);
            draw_planets(planetList, window, PlanetsTexture, planetsPos);
    %         draw_buttons(window, ButtonsTexture, buttonsPos);
            Screen('DrawTexture', window, RocketTexture, [], cRect);

            vbl = Screen('Flip', window);                  
        end
    
        %% TEST FOR OPTIMAL TRAVEL PATH AND CREATE FEEDBACK %%
        if all(TestKey == correctResponses(n,:))
            text = ['Sehr gut, du hast den optimalen Reiseweg gew�hlt'];
            correct = 1;
        else
            text = ['Guter Versuch, allerdings gibt es noch einen besseren Weg, versuch es noch einmal...'];
            correct = 0;
        end
        
        % Draw all the text in one go
        DrawFormattedText(window, text,...
                          'center', screenYpixels*0.25, white);

        Screen('Flip', window);

        WaitSecs(2);
        if correct
            break;
        end
    end
end
  


%%%%%%%%%%%% END INSTRUCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% text
text = ['Gl�ckwunsch! Du hast jetzt alles gelernt was du f�r dein Weltraumabenteuer wissen musst' ... 
         '\n\n Bitte gib dem Versuchleiter Bescheid.'];


% Draw all the text in one go
DrawFormattedText(window, text,...
    'center', screenYpixels * 0.25, white);

% Flip to the screen
Screen('Flip', window);

WaitSecs(5);

sca