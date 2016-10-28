% ABANDONED can't hack it to make publish() work as desired.
% No saving, just rotate all open figures by alpha.

function rotatePotentialPlot(alpha,vector)

figHandles = findobj('Type','figure');
for f = 1 : length(figHandles)
    % Set current figure.
    hfig = figHandles(f);
    set(0, 'currentfigure', hfig);
    
    %
    %>> Actually rotate it.
    % Selects lines, scatter and text on the plot.
    %         alpha = 15; % For testing axis of rotation.
    plotTypes = {'line','scatter','text'};%,'hggroup','patch'};
    for p = plotTypes
        handles = findobj(gca,'type',p{:});
        if ~isempty(handles)
            % Modified rotate.m function to do the same work for
            % scatter plots as well (originally only accepted line,
            % text etc but not scatter).
            rotateEdL(handles,vector,alpha)
        end
    end
end