function plot_coeffs(r, handles)
	% r = row number
	
	hTable = handles.table_results;
	set(findobj(handles.axes2), 'visible', 'off');
	
	vals = [hTable.Data{r, 2:end}];
	numfiles = length(vals);
	filenames = handles.xrd.Filename;
	assert(numfiles == length(filenames));

	axes(handles.axes1)
	cla
	plot(1:numfiles, vals, '-d', ...
		'MarkerSize', 8, ...
		'MarkerFaceColor', [0 0 0], ...
		'DisplayName', hTable.RowName{r})
	xlim([1 numfiles])
	
	set(handles.axes1, ...
		'XTick', 1:numfiles, ...
		'XTickLabel', 1:numfiles, ...
		'YLimMode', 'auto');
	handles.axes1.XLabel.String = 'File Number';
	
	if strcmpi(handles.uitoggletool5.State,'on')
			legend(hTable.RowName{r})
		end