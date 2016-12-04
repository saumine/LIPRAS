function [SP, LB, UB] = getDefaultStartingBounds(Stro, fcn, position, constraints)

SP = []; UB = []; LB = [];
data = Stro.getRawData(1, Stro.fitrange);
x = data(1,:);
y = data(2,:);

if nargin < 4
    constraints = Stro.Constrains;
end

if nargin < 3
	position = Stro.PeakPositions;
end

if nargin < 2
	fcn = Stro.PSfxn;
end 

xIsConstrained = ~isempty(find(constraints(:,2), 1));
if xIsConstrained
    nPeaks = length(find(~constraints(:,2))) + 1;
    xConstrainedIndices = find(constraints(:,2));
else
    nPeaks = length(fcn);
end

% if nPeaks < length(position)
% 	position = position(1:length(fcn));
% end

coeff = Stro.getCoeff(fcn, constraints);

for i=1:length(coeff)
		cname = coeff{i};
        pos = getPeakPosition(cname, position, constraints(:,2));
		
		posX = Stro.Find2theta(x, pos);
		xl = Stro.Find2theta(x, pos-0.05);
		xr = Stro.Find2theta(x,pos+0.05);
		ni = trapz(x(xl:xr),y(xl:xr));
		fi = ni/y(posX);
		
		if cname(1) == 'N'
				SP = [SP, ni];
				UB = [UB, 5*ni];
				LB = [LB, 0];
				
		elseif cname(1) == 'x'
				SP = [SP, pos];
				UB = [UB, pos+.02];
				LB = [LB, pos-.02];
				
		elseif cname(1) == 'f'
				SP = [SP, fi];
				UB = [UB, fi*2];
				LB = [LB, 0];
		elseif cname(1) == 'w'
				SP = [SP, .5];
				UB = [UB, 1];
				LB = [LB, 0];
				
		elseif cname(1) == 'm'
				SP = [SP, 2];
				UB = [UB, 20];
				LB = [LB, .1];
        end
		
end



function position = getPeakPosition(thisCoeff, peakPositions, xConstraints)
% If not a constrained coeff
if length(thisCoeff) > 1 
    peakIndex = str2double(thisCoeff(2));
    xIsConstrained = ~isempty(find(xConstraints, 1));
    thisPeakHasConstrainedX = ~isempty(find(find(xConstraints)==peakIndex, 1));
    uniqueXIndices = find(~xConstraints); % indices of x coefficient not constrained
    
    if xIsConstrained && thisPeakHasConstrainedX
        position = peakPositions(1);
        
    elseif xIsConstrained
        position = peakPositions(find(uniqueXIndices == peakIndex,1)+1);
        
    else
        position = peakPositions(peakIndex);
    end
else % If it is a constrained coefficient
    
    position = peakPositions(1);
end


