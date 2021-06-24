function [params] = readAudioParams(tmpDir)    

        rootDir = '.';
        
        if nargin<1
            tmpDir = rootDir;
        end
        
        params = [];
        
        %% Audio parameters
        fname = strcat(tmpDir, '/AudioParams.txt');
        
        if exist(fname)
            fid = fopen(fname, 'r');
            freq_txt = fgetl(fid); 
            freq_txt = freq_txt(4:end);
            amp_txt = fgetl(fid);
            amp_txt = amp_txt(4:end);
            fclose(fid);

            % Get frequencies
            idx = 1;
            freq = [];
            [numStr, cnt, err, idx] = sscanf(freq_txt, '%s', 1);
            k = 0;
            while(~isempty(numStr) && k < 1000)
                mult = 1;
                if(numStr(end) == 'k')
                    numStr = numStr(1:end-1);
                    mult = 1e3;
                end
                freq = [freq mult*str2double(numStr)];
                freq_txt = freq_txt(idx:end);
                [numStr, cnt, err, idx] = sscanf(freq_txt, '%s', 1);
                k = k + 1;
            end
            freq=freq(2:end)*1000;
            numFreq=length(freq);

            % Get amplitudes
            idx = 1;
            amp = [];
            [numStr, cnt, err, idx] = sscanf(amp_txt, '%s', 1);
            k = 0;
            while(~isempty(numStr) && k < 1000) 
                amp = [amp str2double(numStr)];
                amp_txt = amp_txt(idx:end);
                [numStr, cnt, err, idx] = sscanf(amp_txt, '%s', 1);
                k = k + 1;
            end
            amp=amp(2:end);
            numAmp=length(amp);


            % Stimulus/trial duration
            stimDurTxt = 'stimDuration= ';
            trialDurTxt = 'trialDuration= ';
            spkrSelTxt = 'speakerSel';
            fid = fopen(fname);
            aa = fscanf(fid,'%c',Inf);
            durIdx1 = strfind(aa,stimDurTxt);
            durIdx2 = strfind(aa,trialDurTxt);
            durIdx3 = strfind(aa,spkrSelTxt);
            stimDur = aa(durIdx1+length(stimDurTxt):durIdx2-1); %disp(stimDur);
            stimDur = str2num(stimDur); % stimulus duration in ms
            trialDur = aa(durIdx2+length(trialDurTxt):durIdx3-1); 
            trialDur = str2num(trialDur);

            % Stimulus offset
            stimOffTxt = 'stimOffset= ';
            stimEnvTxt = 'stimEnvelope = ';
            fid = fopen(fname);
            aa = fscanf(fid,'%c',Inf);
            durIdx1 = strfind(aa,stimOffTxt);
            durIdx2 = strfind(aa,stimEnvTxt);
            stimOff = aa(durIdx1+length(stimOffTxt):durIdx2-1); %
            stimOff = str2num(stimOff); % stimulus offest in ms     
            
            stimEnv = aa(durIdx2+length(stimEnvTxt):durIdx2+length(stimEnvTxt)+5); %
            stimEnv = str2num(stimEnv); % stimulus offest in ms  

            % Number of trials
            numTrialsTxt = 'numTrials= ';
            downsampleTxt = 'downsample= ';
            numTrialsIdx1 = strfind(aa,numTrialsTxt);
            numTrialsIdx2 = strfind(aa,downsampleTxt);
            numTrials = aa(numTrialsIdx1+length(numTrialsTxt):numTrialsIdx2-1);
            numTrials = str2num(numTrials); % number of trial
            
            % Custom script
            customTxt = 'customScript= ';
            phaseCorrTxt = 'phaseCorrection= ';
            customIdx1 = strfind(aa,customTxt);
            customIdx2 = strfind(aa,phaseCorrTxt);
            customScript = aa(customIdx1+length(customTxt):customIdx2-3);
            fclose(fid);

            %% Save
            params.freq = freq; 
            params.amp = amp;
            params.trialDur = trialDur;
            params.stimDur = stimDur;
            params.stimOffset = stimOff;
            params.stimEnv = stimEnv;            
            params.trialN = numTrials;
            params.customScript = customScript;
        else
            disp('No audioParams.txt file found.');
        end
end