defmodule EOD.Client.CharacterSelectPacketHandlerTest do
  use EOD.PacketHandlerCase, async: true
  alias Packet.Server.{AssignSession}
  alias Packet.Server.CharacterOverviewResponse, as: CharOverviewResp

  setup _ do
    {:ok, handler: EOD.Client.CharacterSelectPacketHandler}
  end

  describe "#char_select_request" do
    setup tags do
      alias Packet.Client.CharacterSelectRequest, as: CharSelReq

      chars = [
        insert(:character, name: "Ben", slot: 0),
        insert(:character, name: "Seb", slot: 5)
      ]

      packet = %CharSelReq{char_name: tags[:selected_name]}
      client = tags |> update_client(characters: chars) |> handle_packet(packet)
      assert %AssignSession{session_id: 7} = received_packet(tags)

      {:ok, client: client}
    end

    test "character special flag of `noname` sets character to `none`", context do
      assert context.client.selected_character == :none
    end

    @tag selected_name: "Seb"
    test "a correct character name sets selected character", context do
      assert context.client.selected_character.name == "Seb"
    end

    @tag selected_name: "Roflcopters"
    test "an unknown name sets selected_character to none", context do
      assert context.client.selected_character == :none
    end
  end

  describe "#character_name_check" do
    setup tags do
      alias EOD.Packet.Client.CharacterNameCheckRequest, as: NameCheckReq
      alias EOD.Packet.Server.CharacterNameCheckReply, as: NameCheckReply

      if tags[:existing_name], do: insert(:character, name: tags[:existing_name])

      packet = %NameCheckReq{character_name: tags[:name]}
      handle_packet(tags, packet)

      resp = %NameCheckReply{} = received_packet(tags)

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

      client = handle_packet(tags, %CharOverviewReq{realm: tags[:realm]})
      {:ok, alb: alb, mid: mid, hib: hib, client: client}
    end

    @tag realm: :none
    test "no realm is selcted", context do
      assert context.client.characters == []
      assert %Realm{realm: :none} = received_packet(context)
    end

    @tag realm: :albion
    test ":albion selected returns alb characters", context do
      char_ids = context.client.characters |> Enum.map(& &1.id)
      assert [context.alb.id] == char_ids
      assert %Realm{realm: :albion} = received_packet(context)
      assert %CharOverviewResp{characters: [char | _]} = received_packet(context)
      assert char.name == context.alb.name
    end

    @tag realm: :midgard
    test ":midgard selected returns mid characters", context do
      char_ids = context.client.characters |> Enum.map(& &1.id)
      assert [context.mid.id] == char_ids
      assert %Realm{realm: :midgard} = received_packet(context)
      assert %CharOverviewResp{characters: [char | _]} = received_packet(context)
      assert char.name == context.mid.name
    end

    @tag realm: :hibernia
    test ":hibernia selected returns hib characters", context do
      char_ids = context.client.characters |> Enum.map(& &1.id)
      assert [context.hib.id] == char_ids
      assert %Realm{realm: :hibernia} = received_packet(context)
      assert %CharOverviewResp{characters: [char | _]} = received_packet(context)
      assert char.name == context.hib.name
    end
  end

  describe "#char_crud_request" do
    alias EOD.Packet.Client.CharacterCrudRequest, as: CharCrudReq

    setup tags do
      if tags[:character] do
        insert(:character, Keyword.merge([account: tags.client.account], tags[:character]))
      end

      {:ok, client: %{tags.client | selected_realm: tags[:realm] || :albion}}
    end

    @tag realm: :albion
    test "creating a character in albion", context do
      packet = %CharCrudReq{action: :create, name: "ben", slot: 0, realm: 1}
      client = handle_packet(context, packet)
      [char] = client.characters
      assert char.name == "ben"
      assert char.slot == 0
    end

    @tag realm: :midgard
    test "creating a character in midgard", context do
      packet = %CharCrudReq{action: :create, name: "ben", slot: 12, realm: 2}
      client = handle_packet(context, packet)
      [char] = client.characters
      assert char.name == "ben"
      assert char.slot == 2
    end

    @tag realm: :hibernia
    test "creating a character in hibernia", context do
      packet = %CharCrudReq{action: :create, name: "ben", slot: 20, realm: 3}
      client = handle_packet(context, packet)
      [char] = client.characters
      assert char.name == "ben"
      assert char.slot == 0
    end
  end
end
