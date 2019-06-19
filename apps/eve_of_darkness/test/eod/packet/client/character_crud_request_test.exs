defmodule EOD.Packet.Client.CharacterCrudRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.CharacterCrudRequest, as: CrudReq

  describe "CharacterCrudRequest" do
    test "it works as a struct" do
      req = %CrudReq{}
      assert req.name == ""
      assert req.custom_mode == 0
      assert req.eye_size == 0
      assert req.lip_size == 0
      assert req.eye_color == 0
      assert req.hair_color == 0
      assert req.face_type == 0
      assert req.hair_style == 0
      assert req.mood_type == 0
      assert req.action == :nothing
      assert req.level == 0
      assert req.class == 0
      assert req.realm == 0
      assert req.race == 0
      assert req.gender == 0
      assert req.model == 0
      assert req.region == 0
      assert req.strength == 0
      assert req.dexterity == 0
      assert req.constitution == 0
      assert req.quickness == 0
      assert req.intelligence == 0
      assert req.piety == 0
      assert req.empathy == 0
      assert req.charisma == 0
    end
  end
end
