-module(testxml).
-include_lib("xmerl/include/xmerl.hrl").
-compile(export_all).

%%---------------------------parse xml -----------------------------
do() ->
        ShoppingList = "<shopping> 
                  <item name=\"bread\" quantity=\"3\" price=\"2.50\"/> 
                  <item name=\"milk\" quantity=\"2\" price=\"3.50\"/> 
                </shopping>",

        {XmlElt, _} = xmerl_scan:string(ShoppingList),
        get_total(XmlElt).


do2() ->
        {XmlElt, _} = xmerl_scan:file("C:/app/demo-xml-erlang/test.xml"),
        get_total(XmlElt).


get_total(XmlElt) ->
        Items = xmerl_xpath:string("/shopping/item", XmlElt),

        Total = lists:foldl(
                fun(Item, Tot) ->
                        [#xmlAttribute{value = PriceString}] = xmerl_xpath:string("/item/@price", Item),
                        {Price, _} = string:to_float(PriceString),
                        [#xmlAttribute{value = QuantityString}] = xmerl_xpath:string("/item/@quantity", Item),
                        {Quantity, _} = string:to_integer(QuantityString),
                        Tot + Price*Quantity
                end, 0, Items),

        io:format("$~.2f~n", [Total]).



%%---------------------------build xml -----------------------------
to_xml() ->
        ShoppingList = "bread,3,2.50\nmilk,2,3.50",

        Items = lists:map(fun(L) ->
                        [Name, Quantity, Price] = string:tokens(L, ","),
                        {item, [{name, Name}, {quantity, Quantity}, {price, Price}], []}
                end, string:tokens(ShoppingList, "\n")),

        %% return the whole xml
        %Result = xmerl:export_simple([{shopping, [], Items}], xmerl_xml),
        %Result = xmerl:export_simple([{shopping, Items}], xmerl_xml),

        %% return xml without xml header
        Result = xmerl:export_simple_content([{shopping, [], Items}], xmerl_xml),
        %Result = xmerl:export_simple_element({shopping, [], Items}, xmerl_xml),

        io:format("~s~n", [lists:flatten(Result)]).

to_xml2() ->
	Data1 = {bike, [{attr1, "22"}, {attr2, "mm"}], 
		[
			{engine, ["abc"]},
			{cycle, ["lll"]}
		]},	

	Result1 = xmerl:export_simple_element(Data1, xmerl_xml),
	io:format("~p~n", [lists:flatten(Result1)]),

	Data2 = {bike,  
		[
			{engine, ["abc"]},
			{cycle, ["lll"]}
		]},	

	Result2 = xmerl:export_simple_element(Data2, xmerl_xml),
	io:format("~p~n", [lists:flatten(Result2)]),

	Result3 = xmerl:export_simple_content([Data2], xmerl_xml),
	io:format("~p~n", [lists:flatten(Result3)]),

	Result4 = xmerl:export_simple([Data2], xmerl_xml),
	io:format("~p~n", [lists:flatten(Result4)]),

	ok.

