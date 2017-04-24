classdef Lorentzian < model.fit.FitFunctionInterface
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name = 'Lorentzian';
        
        CoeffNames = {'N' 'x' 'f'};
        
        ID
        
    end
    
    
    
    
    methods
        function this = Lorentzian(id, constraints)
        % id          - Peak number
        % constraints - cell array of constrained CoeffNames
        if nargin < 1
            id = 1;
        end
        
        if nargin < 2
            constraints = '';
        end
        
        this@model.fit.FitFunctionInterface(id, constraints);
        
        if ~isempty(find(strcmpi(this.ConstrainedCoeffs, 'w'), 1))
            this = this.constrain('w');
        end
        
        if ~isempty(find(strcmpi(this.ConstrainedCoeffs, 'm'), 1))
            this = this.constrain('m');
        end
        
        end
        
    end
    
    methods
        function str = getEqnStr(this, xval)
        import utils.contains
        coeff = this.getCoeffs;
        Nidx = find(contains(coeff, 'N'), 1);
        xidx = find(contains(coeff, 'x'), 1);
        fidx = find(contains(coeff, 'f'), 1);
        if nargin > 1
           coeff{xidx} = num2str(xval);
        end
        str = [coeff{Nidx} '*1/pi* (0.5*' coeff{fidx} '/((xv-', ...
            coeff{xidx} ')^2+(0.5*' coeff{fidx} ')^2))'];
        end
        
        
        function value = getCoeffs(this)
        this.ConstrainedLogical(4:5) = false;
        value = getCoeffs@model.fit.FitFunctionInterface(this);
        end
        
       
        function output = getDefaultInitialValues(this, data, peakpos)
        value = getDefaultInitialValues@model.fit.FitFunctionInterface(this, data, peakpos);
        output.N = value.N;
        output.x = value.x;
        output.f = value.f;
        end
        
        
        function output = getDefaultLowerBounds(this, data, peakpos)
        value = getDefaultLowerBounds@model.fit.FitFunctionInterface(this, data, peakpos);
        output.N = value.N;
        output.x = value.x;
        output.f = value.f;
        end
        
        
        function output = getDefaultUpperBounds(this, data, peakpos)
        value = getDefaultUpperBounds@model.fit.FitFunctionInterface(this, data, peakpos);
        
        output.N = value.N;
        output.x = value.x;
        output.f = value.f;
        end
        
    end
    
    methods (Static)
        function result = isWConstrained()
        %ISWCONSTRAINED overrides the parent class function to always return false.
        result = false;
        end
        
        
        function result = isMConstrained()
        %ISMCONSTRAINED overrides the parent class function to always return false.
        result = false;
        end
        
        
    end
    
    methods (Access = protected)
        function output = calculate_(this, xdata, coeffvals)
        coeffs = this.getCoeffs;
        
        for i=1:length(coeffs)
           c = coeffs{i}(1);
           if c == 'N'
               N = coeffvals(i);
           elseif c == 'x'
               xv = coeffvals(i);
           elseif c == 'f'
               f = coeffvals(i);
           end
        end
        
        output = N.*1./pi* (0.5.*f./((xdata-xv).^2+(0.5.*f).^2));
        
        end
        
        
    end
end

