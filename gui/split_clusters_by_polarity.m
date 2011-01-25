function [grp]=split_clusters_by_polarity(grp,pol)
%SPLIT_CLUSTERS_BY_POLARITY    Split clusters by relative polarity
%
%    Usage:    grp=split_clusters_by_polarity(grp,pol)
%
%    Description:
%     GRP=SPLIT_CLUSTERS_BY_POLARITY(GRP,POL) splits clusters in struct GRP
%     (generated by USERCLUSTER) further by record polarities given in POL.
%     This is useful for forcing clusters to be divided by focal sphere
%     (that way measurements between members of a cluster do not cross
%     nodal planes).
%
%    Notes:
%     - GRP.T & POL must have the same number of elements.
%     - GRP.good is reset based on GRP.popcut.
%     - GRP.color is amended for the new clusters.
%
%    Examples:
%     % Does almost nothing (resets GRP.good by GRP.popcut):
%     grp=split_clusters_by_polarity(grp,1);
%
%    See also: USERCLUSTER, ADJUSTCLUSTERS

%     Version History:
%        Dec. 12, 2010 - initial version
%        Dec. 17, 2010 - update .color too (split clusters retain original
%                        coloring)
%        Jan. 12, 2011 - fix indexing bug, 1/2 color brightness on split
%        Jan. 16, 2011 - fix urows indexing bug
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Jan. 16, 2011 at 13:35 GMT

% todo:

% check nargin
error(nargchk(2,2,nargin));

% check grp
if(~isstruct(grp) || any(~ismember({'T' 'color' 'good' 'popcut'},...
        fieldnames(grp))) || ~isequal([max(grp.T) 3],size(grp.color)))
    error('seizmo:split_clusters_by_polarity:badInput',...
        'GRP must be a struct with fields T, color, good & popcut!');
end

% number of records
nrecs=numel(grp.T);

% check polarity vector
if(~isreal(pol) || ~any(numel(pol)==[1 nrecs]) || any(abs(pol)~=1))
    error('seizmo:adjustclusters:badInput',...
        'POL must be a vector of 1s & -1s!');
end

% fix polarity vector
if(isscalar(pol)); pol(1:nrecs,1)=pol; end
pol=pol(:);

% use unique to find clusters to be split
urows=unique([grp.T pol],'rows');

% loop over groups
for a=1:max(grp.T)
    % only need to split if 2
    if(sum(urows(:,1)==a)==2)
        % get index of second polarity (ALWAYS POSITIVE)
        idx=find(urows(:,1)==a,1,'last');
        
        % find records to reassign
        rec=grp.T==urows(idx,1) & pol==urows(idx,2);
        
        % set color (1/2 brightness)
        grp.color(max(grp.T)+1,:)=grp.color(a,:)/2;
        
        % reassign
        grp.T(rec)=max(grp.T)+1;
    end
end

% reset "good" clusters
grp.pop=histc(grp.T,1:max(grp.T));
grp.good=grp.pop>=grp.popcut;

end