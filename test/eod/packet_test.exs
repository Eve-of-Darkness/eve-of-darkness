defmodule EOD.PacketTest do
  use ExUnit.Case, async: true

  describe "the first packet" do
    defmodule HandShakeRequest do
      use EOD.Packet do
        code 0xF4

        field :addons, :integer, size: [bits: 4]
        field :type,   :integer, size: [bits: 4]
        field :major,  :integer, size: [bytes: 1]
        field :minor,  :integer, size: [bytes: 1]
        field :patch,  :integer, size: [bytes: 1]
        field :rev,    :integer, size: [bytes: 1]
        field :build,  :integer, size: [bytes: 2]
      end
    end

    test "it has a code" do
      assert HandShakeRequest.code == 0xF4
    end

    test "it is a struct" do
      keys = %HandShakeRequest{} |> Map.keys
      assert :addons in keys
      assert :type in keys
      assert :major in keys
      assert :patch in keys
      assert :rev in keys
      assert :build in keys
    end

    test "integers default to zero" do
      req = %HandShakeRequest{}
      assert req.addons == 0
      assert req.type == 0
      assert req.major == 0
      assert req.patch == 0
      assert req.rev == 0
      assert req.build == 0
    end

    test "it can read from a binary" do
      {:ok, request} =
        <<5::4, 6::4, 1, 1, 24, 6, 1982::16>>
        |> HandShakeRequest.from_binary

      assert request.addons == 5
      assert request.type == 6
      assert request.major == 1
      assert request.minor == 1
      assert request.patch == 24
      assert request.rev == 6
      assert request.build == 1982
    end

    test "it can create a binary" do
      {:ok, bin} =
        %HandShakeRequest{type: 6, major: 1, minor: 1, patch: 24}
        |> HandShakeRequest.to_binary

      assert bin == <<6, 1, 1, 24, 0, 0, 0>>
    end
  end

  describe "the second packet" do
    defmodule HandshakeResponse do
      use EOD.Packet do
        code 0x22

        field :type,      :integer, size: [bytes: 1]
        blank using: 0x00,          size: [bytes: 1]
        field :version,   :string,  size: [bytes: 5]
        field :rev,       :integer, size: [bytes: 1]
        field :build,     :integer, size: [bytes: 2]
      end
    end

    test "it has a code" do
      assert HandshakeResponse.code == 0x22
    end

    test "it works as a struct" do
      resp = %HandshakeResponse{}
      assert resp.type == 0
      assert resp.version == ""
      assert resp.rev == 0
      assert resp.build == 0
    end

    test "it can build a binary" do
      {:ok, bin} =
        %HandshakeResponse{type: 6, version: "1.124", rev: 67}
        |> HandshakeResponse.to_binary
      
      assert bin == <<6, 0, 49, 46, 49, 50, 52, 67, 0, 0>>
    end

    test "it can be built from a binary" do
      {:ok, resp} =
        <<4, 0, 49, 46, 49, 50, 53, 67, 0, 190>>
        |> HandshakeResponse.from_binary

      assert resp.type == 4
      assert resp.version == "1.125"
      assert resp.rev == 67
      assert resp.build == 190
    end
  end
end
