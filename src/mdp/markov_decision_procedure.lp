% MARKOV DECISION PROCESS INTERFACE
% Describes abstract knowledge which is valid for all MDP's

% GENERAL MDP DOMAIN ***********************************************************

%	CONSTANTS:
%	T			... describes a point in time. 
%					`T=0` is always the current time ("now").

%	INPUT PREDICATES (added to the domain programmatically):
%	currentState(S(...)) ... describes a part of the current state, where `S(...)` is an 
%							 uninterpreted function with zero or more arguments.
%	currentAction(A(...)) 	... describes an action taken in the current state, 
%								where `A(...)` is an uninterpreted function with zero or
%								more arguments.

%	INTERNAL PREDICATES (used to add problem-specific details, used e.g. by the planner)
%	time(T)			...	defines `T >= 0` to be a point in time.
%	tic(S(...), T)	... desribes a part of the state at time `T`, with `S(...)` being a
%						function just as for `current(S(...))`.
%						Note that `current(S(...))` iff `tic(S(...), 0)`.
%	act(A(...), T)	... desribes an action taken at time `T`, with `A(...)` being a
%						function just as for `action(A(...))`.
%	partialReward(R, T) ... describes part of the reward or punishment `R` received
%							at time `T`. All partial rewards will be summed per time
%							step to end up with a total reward (see `nextReward(R)`)
%	terminal(T)		...	describes that a terminal state has been reached at timestep `T`.


%	OUTPUT PREDICATES (used by the python program to read out information)
%	nextState(S(...))	... describes the state of the world after executing 
%							the current action described by `action(A(...))`.
%							Note that `state(S(...))` iff `tic(S(...), 1)`.
% 	executable(A(...))	... describes actions `A(...)` executable from 
%							the current state or next state (depending on `t`).
%	nextReward(S)		...	describes the total reward `S` to be received at the next time step.


% GENERAL KNOWLEDGE ************************************************************

% For simple (Stateless) MDP behavior, only the current (T=0) and next (T=1)
% time steps are necessary.
time(0).
time(1) :- currentAction(_).

% Current state and action (if any) are happening at timestep zero.
tic(S, 0) :- currentState(S).
act(A, 0) :- currentAction(A).
#defined currentAction/1.

% The next state is reached at time step one (but only if action is given)
nextState(S) :- tic(S,1), currentAction(_).

% Describe which actions are executable in the current and next state.
nextExecutable(A) :- executable(A,1), currentAction(_).
currentExecutable(A) :- executable(A,0).

% Describe the reward for the next time step (but only if action is given)
nextReward(N) :- N = #sum { R : partialReward(R, 1) }, currentAction(_).

% One cannot execute unexecutable actions.
:- act(A, T), not executable(A,T).
