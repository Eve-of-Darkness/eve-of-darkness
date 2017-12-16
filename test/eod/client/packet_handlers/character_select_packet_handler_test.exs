defmodule EOD.Client.CharacterSelectPacketHandlerTest do
  use EOD.RepoCase, async: true
  alias EOD.Client
  alias EOD.TestSocket
  alias EOD.Socket
  import EOD.Client.CharacterSelectPacketHandler
  alias EOD.Packet.Server.{AssignSession}
  alias EOD.Packet.Server.CharacterOverviewResponse, as: CharOverviewResp

  setup tags do
    {:ok, socket} = TestSocket.start_link
    account = insert(:account)

    {:ok,
      client: %Client{session_id: tags[:session_id] || 7,
                      tcp_socket: socket,
                      account: account},

      account: account,
      socket: TestSocket.set_role(socket, :client)}
  end

  test "#char_select_request", context do
    assert %Client{} = char_select_request(context.client, %{})
    assert %AssignSession{session_id: 7} = Socket.recv(context.socket) |> ok!
  end

  describe "#character_name_check" do
    setup tags do
      alias EOD.Packet.Client.CharacterNameCheckRequest, as: NameCheckReq
      alias EOD.Packet.Server.CharacterNameCheckReply, as: NameCheckReply

      if tags[:existing_name], do: insert(:character, name: tags[:existing_name])

      packet = %NameCheckReq{character_name: tags[:name]}
      assert %Client{} = character_name_check(tags.client, packet)

      resp = %NameCheckReply{} = Socket.recv(tags.socket) |> ok!

      assert resp.character_name == tags[:name]
      assert resp.username == tags.account.username

      {:ok, msg: resp}
    end

    @tag name: "bb"
    test "name to short is just invalid", %{msg: msg} do
      assert %{status: :invalid} = msg
    end

    @tag name: "benfalk"
    test "right size and not taken is valid", %{msg: msg} do
      assert %{status: :valid} = msg
    end

    @tag name: "mrbig", existing_name: "mrbig"
    test "an already taken name gives out duplicate", %{msg: msg} do
      assert %{status: :duplicate} = msg
    end
  end

  describe "#char_overview_request" do
    alias EOD.Packet.Server.{Realm}
    setup tags do
      alias EOD.Packet.Client.CharacterOverviewRequest, as: CharOverviewReq
      alb = insert(:character, account: tags.account, realm: 1, slot: 0, name: "alb")
      mid = insert(:character, account: tags.account, realm: 2, slot: 0, name: "mid")
      hib = insert(:character, account: tags.account, realm: 3, slot: 0, name: "hib")
      insert(:character, realm: 1, name: "differentowner")

      packet = %CharOverviewReq{realm: tags[:realm]}
      client = %Client{} = char_overview_request(tags.client, packet)
      {:ok,
        alb: alb,
        mid: mid,
        hib: hib,
        client: client}
    end

    @tag realm: :none
    test "no realm is selcted", context do
      assert context.client.characters == []
      assert %Realm{realm: :none} = Socket.recv(context.socket) |> ok!
    end

    @tag realm: :albion
    test ":albion selected returns alb characters", context do
      char_ids = context.client.characters |> Enum.map(& &1.id)
      assert [context.alb.id] == char_ids
      assert %Realm{realm: :albion} = Socket.recv(context.socket) |> ok!
      assert %CharOverviewResp{characters: [char|_]} = resp =
        Socket.recv(context.socket) |> ok!
      assert resp.username == context.account.username
      assert char.name == context.alb.name
    end

    @tag realm: :midgard
    test ":midgard selected returns mid characters", context do
      char_ids = context.client.characters |> Enum.map(& &1.id)
      assert [context.mid.id] == char_ids
      assert %Realm{realm: :midgard} = Socket.recv(context.socket) |> ok!
      assert %CharOverviewResp{characters: [char|_]} = resp =
        Socket.recv(context.socket) |> ok!
      assert resp.username == context.account.username
      assert char.name == context.mid.name
    end

    @tag realm: :hibernia
    test ":hibernia selected returns hib characters", context do
      char_ids = context.client.characters |> Enum.map(& &1.id)
      assert [context.hib.id] == char_ids
      assert %Realm{realm: :hibernia} = Socket.recv(context.socket) |> ok!
      assert %CharOverviewResp{characters: [char|_]} = resp =
        Socket.recv(context.socket) |> ok!
      assert resp.username == context.account.username
      assert char.name == context.hib.name
    end
  end

  describe "#char_crud_request" do
    alias EOD.Packet.Client.CharacterCrudRequest, as: CharCrudReq
    setup tags do
      {:ok, client: %{ tags.client | selected_realm: :albion }}
    end

    test "creating a character", context do
      blanks = 1..9 |> Enum.map(fn _ -> %CharCrudReq.Character{action: :create} end)
      ben =
        params_for(:character, name: "ben")
        |> Enum.reduce(%CharCrudReq.Character{}, fn {k, v}, char -> Map.put(char, k, v) end)
        |> Map.put(:action, :create)

      packet = %CharCrudReq{characters: [ben|blanks]}
      client = %Client{} = char_crud_request(context.client, packet)
      [char] = client.characters
      assert char.name == "ben"
      assert char.slot == 0
    end
  end

  defp ok!({:ok, packet}), do: packet
  defp ok!(_), do: raise "It's not okay!"
end
