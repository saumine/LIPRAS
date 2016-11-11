
% Executes on button press in push_fitdata.
function push_fitdata_Callback(hObject, ~, handles)
	handles.xrd.Status='Fitting dataset...';
	set(handles.radio_stopleastsquares, 'enable', 'on');
	
	% Get saved parameter values
	fnames = handles.xrd.PSfxn;
	
	data = handles.table_fitinitial.Data;	% initial parameter values to use
	SP = [];
	UB = [];
	LB = [];
	
	% Save table_coeffvals into SP, LB, and UB variables
	for i = 1 : length(handles.table_fitinitial.RowName)
		SP(i) = data{i,1};
		LB(i) = data{i,2};
		UB(i) = data{i,3};
	end
	
	axes(handles.axes1)
	peakpos = handles.xrd.PeakPositions;			% Initial peak positions guess
	handles.xrd.fitData(peakpos, fnames, SP, UB, LB);	% Function - fit data
	
	if handles.radio_stopleastsquares.Value == 1
		set(handles.radio_stopleastsquares, 'value', 0, 'enable', 'off');
		plotX(handles);
		return
	end
	
	filenum = get(handles.popup_filename, 'Value');		% The current file visible
	handles.xrd.plotFit(filenum);					  % Plot current file
	vals = handles.xrd.fit_parms{filenum};			% The fitted parameter results
	
	handles.table_fitinitial.Data = data;
	guidata(handles.figure1, handles)
	
	
	
	set(handles.menu_save,'Enable','on');
% 	handles.tabgroup.SelectedTab = handles.tab_results;
% 	set(handles.tab_results,'ForegroundColor',[0 0 0]);
% 	set(findobj(handles.tab_results.Children),'visible', 'on');
	
	fill_table_results(handles);
	handles.xrd.Status = 'Fitting dataset... Done.';
	
	FDGUI('uitoggletool5_OnCallback', handles.uitoggletool5, [], guidata(hObject));
	set(handles.radio_stopleastsquares, 'enable', 'off', 'value', 0);
	assignin('base','h',handles)
	guidata(hObject, handles)
	
function handles = fit_data(handles)
	% hObject is push_fitdata
	
	
