defmodule EOD.Client.CharacterSelectPacketHandlerTest do
  use EOD.RepoCase, async: true
  alias EOD.Client
  alias EOD.TestSocket
  alias EOD.Socket
  import EOD.Client.CharacterSelectPacketHandler

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
    assert %{id: :session_id, session_id: 7} = Socket.recv(context.socket) |> ok!
  end

  describe "#character_name_check" do
    setup tags do
      if tags[:existing_name], do: insert(:character, name: tags[:existing_name])

      assert %Client{} =
        character_name_check(tags.client, %{character_name: tags[:name]})

      msg = Socket.recv(tags.socket) |> ok!

      assert msg[:id] == :character_name_check_reply
      assert msg[:character_name] == tags[:name]
      assert msg[:username] == tags.account.username

      {:ok, msg: msg}
    end

    @tag name: "bb"
    test "name to short is just invalid", %{msg: msg} do
      assert %{status: :invalid} = msg
    end

    @tag name: "benfalk"
    test "right size and not taken is valid", %{msg: msg} do
      assert %{status: :ok} = msg
    end

    @tag name: "mrbig", existing_name: "mrbig"
    test "an already taken name gives out duplicate", %{msg: msg} do
      assert %{status: :duplicate} = msg
    end
  end

  describe "#char_overview_request" do
    setup tags do
      alb = insert(:character, account: tags.account, realm: 1, slot: 0, name: "alb")
      mid = insert(:character, account: tags.account, realm: 2, slot: 0, name: "mid")
      hib = insert(:character, account: tags.account, realm: 3, slot: 0, name: "hib")
      insert(:character, realm: 1, name: "differentowner")

      client = %Client{} = char_overview_request(tags.client, %{realm: tags[:realm]})
      {:ok,
        alb: alb,
        mid: mid,
        hib: hib,
        client: client}
    end

    @tag realm: :none
    test "no realm is selcted", context do
      assert context.client.characters == []
      assert %{id: :realm, realm: :none} = Socket.recv(context.socket) |> ok!
    end

    @tag realm: :albion
    test ":albion selected returns alb characters", context do
      char_ids = context.client.characters |> Enum.map(& &1.id)
      assert [context.alb.id] == char_ids
      assert %{id: :realm, realm: :albion} = Socket.recv(context.socket) |> ok!
      assert %{id: :char_overview, characters: [char]} = msg =
        Socket.recv(context.socket) |> ok!
      assert msg[:username] == context.account.username
      assert char.id == context.alb.id
    end

    @tag realm: :midgard
    test ":midgard selected returns mid characters", context do
      char_ids = context.client.characters |> Enum.map(& &1.id)
      assert [context.mid.id] == char_ids
      assert %{id: :realm, realm: :midgard} = Socket.recv(context.socket) |> ok!
      assert %{id: :char_overview, characters: [char]} = msg =
        Socket.recv(context.socket) |> ok!
      assert msg[:username] == context.account.username
      assert char.id == context.mid.id
    end

    @tag realm: :hibernia
    test ":hibernia selected returns hib characters", context do
      char_ids = context.client.characters |> Enum.map(& &1.id)
      assert [context.hib.id] == char_ids
      assert %{id: :realm, realm: :hibernia} = Socket.recv(context.socket) |> ok!
      assert %{id: :char_overview, characters: [char]} = msg =
        Socket.recv(context.socket) |> ok!
      assert msg[:username] == context.account.username
      assert char.id == context.hib.id
    end
  end

  describe "#char_crud_request" do
    setup tags do
      {:ok, client: %{ tags.client | selected_realm: :albion }}
    end

    test "creating a character", context do
      packet = %{action: :create, characters: [params_for(:character, name: "ben")]}
      client = %Client{} = char_crud_request(context.client, packet)
      [char] = client.characters
      assert char.name == "ben"
    end
  end

  defp ok!({:ok, packet}), do: packet
  defp ok!(_), do: raise "It's not okay!"
end
