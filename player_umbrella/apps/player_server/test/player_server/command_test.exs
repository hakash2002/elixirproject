defmodule PlayerServer.CommandTest do
  use ExUnit.Case, async: true

  assert PlayerServer.Command.parse("CREATE Offense") == {:ok,{:create,"Offense"}}
  assert PlayerServer.Command.run("CREATE Offense") == {:ok,"OK\r\n"}

  assert PlayerServer.Command.parse("GET Offense JJ") == {:ok,{:get,"Offense", "JJ"}}
  assert PlayerServer.Command.run("GET Offense JJ") == {:ok,"OK\r\n"}

  assert PlayerServer.Command.parse("PUT Offense JJ 90 90 90") == {:ok,{:put,"Offense", "JJ",[power: 90, speed: 90, agility: 90]}}
  assert PlayerServer.Command.run("PUT Offense JJ 90 90 90") == {:ok,"OK\r\n"}

  assert PlayerServer.Command.parse("DELETE Offense JJ") == {:ok,{:delete,"Offense", "JJ"}}
  assert PlayerServer.Command.run("DELETE Offense JJ") == {:ok,"OK\r\n"}

  end
