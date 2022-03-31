%%--------------------------------------------------------------------
%% Copyright (c) 2020 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_plugin_template).

-include("emqx.hrl").

-export([ load/1
        , unload/0
        ]).

%% Client Lifecircle Hooks
-export([ on_client_connect/3
        , on_client_authenticate/3
        , on_client_check_acl/5
        ]).


%% Called when the plugin application start
load(Env) ->
    emqx:hook('client.connect',      {?MODULE, on_client_connect, [Env]}),
    emqx:hook('client.authenticate', {?MODULE, on_client_authenticate, [Env]}),
    emqx:hook('client.check_acl',    {?MODULE, on_client_check_acl, [Env]}).

%%--------------------------------------------------------------------
%% Client Lifecircle Hooks
%%--------------------------------------------------------------------

on_client_connect(ConnInfo = #{clientid := ClientId}, Props, _Env) ->
    io:format("#### Client(~s) connect, Call IPC GetClientDeviceAuthToken with ConnInfo: ~p~n",
              [ClientId, ConnInfo]),
    {ok, Props}.


on_client_authenticate(_ClientInfo = #{clientid := ClientId, username := Username, password := Password}, Result, _Env) ->
        io:format("~n#### Client(~s) authenticate: Call IPC GetClientDeviceAuthToken if needed for ThingName: ~s, Username: ~s, Password: ~s ~n",
                  [ClientId, ClientId, Username, Password]),
        {ok, Result}.


on_client_check_acl(_ClientInfo = #{clientid := ClientId}, Topic, PubSub, Result, _Env) ->
    io:format("~n#### Client(~s) check_acl: Call IPC CheckClientDeviceAuthorization with: ClientId: ~s, Action: mqtt:~s, Resource: ~s~n",
              [ClientId, ClientId, PubSub, Topic]),
    {ok, Result}.


%% Called when the plugin application stop
unload() ->
    emqx:unhook('client.connect',      {?MODULE, on_client_connect}),
    emqx:unhook('client.authenticate', {?MODULE, on_client_authenticate}),
    emqx:unhook('client.check_acl',    {?MODULE, on_client_check_acl}).
