%% -------------------------------------------------------------------
%%
%% Copyright <2013-2019> <
%%  Technische Universität Kaiserslautern, Germany
%%  Université Pierre et Marie Curie / Sorbonne-Université, France
%%  Universidade NOVA de Lisboa, Portugal
%%  Université catholique de Louvain (UCL), Belgique
%%  INESC TEC, Portugal
%% >
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either expressed or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% List of the contributors to the development of Antidote: see AUTHORS file.
%% Description and complete License: see LICENSE file.
%% -------------------------------------------------------------------
-module(basic_server).
-include_lib("antidote_channel.hrl").

-behaviour(gen_server).

%% API
-export([start/0, start_link/0, stop/1, init/1, handle_call/3, handle_cast/2, handle_info/2]).

-record(state, {msg_buffer = [] :: list(), channel}).

-define(LOG_INFO(X, Y), logger:info(X, Y)).
-define(LOG_INFO(X), logger:info(X)).

start() ->
  gen_server:start(?MODULE, [], []).

start_link() ->
  gen_server:start_link(?MODULE, [], []).

stop(Pid) ->
  gen_server:call(Pid, terminate).

init([]) -> {ok, #state{}}.

handle_call(_, _, State) -> {stop, ok, State}.

handle_info({chan_started, #{channel := Channel}}, #state{} = State) ->
  {noreply, State#state{channel = Channel}};

%%TODO: document the accepted replies
handle_info(#rpc_msg{request_id = RId, request_payload = foo}, #state{channel = Channel} = State) ->
  antidote_channel:reply(Channel, RId, bar),
  {noreply, State};

handle_info(#rpc_msg{request_id = RId, request_payload = <<131, 100, 0, 3, 102, 111, 111>>}, #state{channel = Channel} = State) ->
  antidote_channel:reply(Channel, RId, term_to_binary(bar)),
  {noreply, State};

handle_info(_Msg, State) ->
  {noreply, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.
