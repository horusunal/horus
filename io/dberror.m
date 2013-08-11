function message = dberror(type)
%DBERROR   Retrieve error messages.
%   message = DBERROR(type) retrieves an error message of the type 'type'.
%   The different types can be:
%
%      'insert': Occurs when exporting to database.
%      'delete': Occurs when deleting record from the database.
%      'update': Occurs when modifying a record on database.
%      'select': Occurs when importing data from database.
%      'conn': Occurs when stablishing connection to the database.
%      'args': Occurs when insufficent or wrong arguments are passed to a
%      function.
%
%   'message' contains a customized error message for every type.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/21 15:40 $

try
    
    types = {
        'insert', ...
        'delete', ...
        'update', ...
        'select', ...
        'conn', ...
        'args'
        };
    
    messages = {
        'ERROR ON INSERT: ', ...
        'ERROR ON DELETE: ', ...
        'ERROR ON UPDATE: ', ...
        'ERROR ON SELECT: ', ...
        'ERROR IN CONNECTION: ', ...
        'INVALID ARGUMENTS!'
        };
    
    message = messages{strcmpi(types, type)};
    
catch e
    disp(e.message)
end