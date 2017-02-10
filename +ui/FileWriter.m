classdef FileWriter < handle
   properties
       OutputPath
       
   end
   
   properties (Hidden)
       Profiles
   end
   
   properties (Constant, Hidden)
       DEFAULT_OUTPUT_PATH = ['FitOutputs' filesep];
   end
   
   
   methods 
       function this = FileWriter(profiles)
       this.Profiles = profiles;
       this.OutputPath = profiles.OutputPath;
       end
   end 
   
   methods
       function printFitOutputs(this, fits)
       %PRINTFILEOUTPUTS prints the results of the fit for each file in a .Fdata, .Fmodel, and the
       %    master .Fmodel file.
       if ~iscell(fits)
           fits = {fits};
       end
       profnum = this.Profiles.getCurrentProfileNumber;
       outpath = [this.OutputPath 'FitData' filesep];
       masterfilename = [outpath fits{1}.FileName '_Master_Profile_' num2str(profnum) '.Fmodel'];
       fidmaster = fopen(masterfilename, 'w');
       this.printFmodelHeader(fits{1}, fidmaster);
       
       for i=1:length(fits)
           filename = [fits{i}.FileName '_Profile_' num2str(profnum)];
           fmodelfilename = [outpath filename '.Fmodel'];
           fidmodel = fopen(fmodelfilename, 'w');
           this.printFmodelHeader(fits{i}, fidmodel);
           this.printFmodelValues(fits{i}, fidmodel);
           fclose(fidmodel);
           
           fdatafilename = [outpath filename '.Fdata'];
           fiddata = fopen(fdatafilename, 'w');
           this.printFdata(fits{i}, fiddata);
           fclose(fiddata);
           
           this.printFmodelValues(fits{i}, fidmaster);
       end
       fclose(fidmaster);
       end
       
       function str = getFullFileName(this, outpath, fitname, varargin)
       % If FILENAME already exists, append it with ' (n)' where n is the number of files with the
       % name FILENAME that already exists.
       %
       %FITNAME is the name of the file that was fitted. 
       %
       %VARARGIN must have at least 1 element, where the last element is the extension to the file.
       profnum = this.Profiles.getCurrentProfileNumber;
       str = [outpath fitname '_Profile_' num2str(profnum)];
       for i=1:length(varargin)-1
           str = [str '_' varargin{i}]; %#ok<AGROW>
       end
       ext = varargin{end};
       n = 1;
       while exist([str ext], 'dir') == 2
           str = [str ' (' num2str(n) ')']; %#ok<AGROW>
           n=n+1;
       end
       str = [str ext];
       end
       
       function filename = saveAsParametersFile(this)
       %SAVEPARAMETERSTOFILE 
       %
       %FILENAME
       
       if ~exist(this.OutputPath, 'dir')
           mkdir(this.OutputPath);
       end
       profiles = this.Profiles;
       fits = profiles.xrd.getFitResults;
       fitted = fits{1};
       
       filename = this.getFileName(['Fit_Parameters_' fitted.FileName], '.txt');
       
       %the name of the file it will write containing the statistics of the fit
       fid = fopen(filename, 'w'); 
       
       
       fprintf(fid, 'Filenames: ');
       fprintf(fid, '%s ', profiles.getFileNames{:});
       fprintf(fid, '\n\n');
       
       fprintf(fid, '2ThetaRange: %f %f\n\n',fitted.TwoTheta(1), fitted.TwoTheta(end));
       fprintf(fid, 'BackgroundModel: %s\n', fitted.BackgroundModel);
       fprintf(fid, 'PolynomialOrder: %i\n', fitted.BackgroundOrder);
       fprintf(fid, 'BackgroundPoints:');
       fprintf(fid, ' %f', fitted.BackgroundPoints);
       
       fprintf(fid,'\n\nFitFunction(s):\n');
       fprintf(fid,'%s; ', fitted.FunctionNames{:});
       fprintf(fid,'\nConstraints:');
       fprintf(fid, ' {''%s''}', fitted.Constraints{:});
       fprintf(fid, '\nPeakPosition(s): ');
       fprintf(fid, '%f ', fitted.PeakPositions);
       
       
       
       fprintf(fid, '\n\n== Initial Fit Parameters ==\n');
       fprintf(fid, '%s ', fitted.CoeffNames{:}); %write coefficient names
       fprintf(fid, '\nSP: ');
       fprintf(fid, '%#.5g ', fitted.FitOptions.StartPoint);
       fprintf(fid, '\nLB: ');
       fprintf(fid, '%#.5g ', fitted.FitOptions.Lower);
       fprintf(fid, '\nUB: ');
       fprintf(fid, '%#.5g ', fitted.FitOptions.Upper);
       
       fclose(fid);
       end
       
   end
   
   methods (Static)
       
       
        
       function printFmodelValues(fitted, fid)
       % print coeffvalues of Fmodel
       fprintf(fid, '%.3f\t', coeffvalues(fitted.Fmodel));
       % print FmodelGOF
       fprintf(fid, '%.3f\t', struct2array(fitted.FmodelGOF));
       
       for i=1:size(fitted.FmodelCI, 2)
           fprintf(fid, '%f\t', fitted.FmodelCI(1,i)); % write lower bound confidence interval
           fprintf(fid, '%f\t', fitted.FmodelCI(2,i)); % write upper bound confidence interval
       end
       fprintf(fid, '\n');
       end
       
       function printFmodelHeader(fitted, fid)
       fprintf(fid, 'This is an output file from a MATLAB routine.\n');
       fprintf(fid, 'The following peaks are all of the type: ');
       fprintf(fid, '%s; ', fitted.FunctionNames{:});      % write function names
       fprintf(fid, '\n\n');
       
       fprintf(fid, '%s\t', fitted.CoeffNames{:});         % write coefficient names
       fields = fieldnames(fitted.FmodelGOF);
       fprintf(fid, '%s\t', fields{:}); % write GOF names
       
       %third output Confidence Intervals (CI)
       for i=1:length(fitted.CoeffNames)
           fprintf(fid, '%s\t', ['LowCI:', fitted.CoeffNames{i}]); %write LB names
           fprintf(fid, '%s\t', ['UppCI:', fitted.CoeffNames{i}]); %write UB names
       end
       fprintf(fid, '\n');
       end
       
       function printFdata(fitted, fid)
       %PRINTFDATAFILES prints the results of the fit specified by FITTED to a file.
       fprintf(fid, 'This is an output file from a MATLAB routine.\n');
       fprintf(fid, 'All single peak data (column 3+) does not include background intensity.\n\n');
       fprintf(fid, '2theta \t IntMeas \t BkgdFit \t Peak1 \t Peak2 \t Etc...\n');
       
       twotheta = fitted.TwoTheta';
       intmeas = fitted.Intensity';
       background = fitted.Background';
       peaks = zeros(length(twotheta), length(fitted.FunctionNames));
       for j=1:length(fitted.FunctionNames)
           peaks(:,j) = fitted.calculatePeakFit(j)';
       end
       for i=1:length(twotheta)
           line = [twotheta(i), intmeas(i), background(i), peaks(i,:)];
           fprintf(fid, '%.3f\t', line(:));
           fprintf(fid, '\n');
       end
       end

       
   end
   
    
end