defmodule EOD.Packet.Server.CharacterOverviewResponse do
  @moduledoc """
  This is sent to the client when they are on the character select
  screen and contains the information for all slots regardless of
  if there is a character for that slot or not.
  """
  use EOD.Packet do
    code 0xFD

    structure Character do
      blank               using: 0x00,  size: [bytes: 4]
      field :name,           :c_string, size: [bytes: 24]
      field :custom_mode,    :integer,  size: [bytes: 1]
      field :eye_size,       :integer,  size: [bytes: 1]
      field :lip_size,       :integer,  size: [bytes: 1]
      field :eye_color,      :integer,  size: [bytes: 1]
      field :hair_color,     :integer,  size: [bytes: 1]
      field :face_type,      :integer,  size: [bytes: 1]
      field :hair_style,     :integer,  size: [bytes: 1]

      # TODO Boots and Gloves
      blank               using: 0x00,  size: [bytes: 1]
      # TODO Torso and Cloak
      blank               using: 0x00,  size: [bytes: 1]

      # TODO Custom Mode - Understand what this does
      blank               using: 0x02,  size: [bytes: 1]
      field :mood_type,      :integer,  size: [bytes: 1]
      blank               using: 0x00,  size: [bytes: 13]
      field :location,       :c_string, size: [bytes: 24]
      field :class_name,     :c_string, size: [bytes: 24]
      field :race_name,      :c_string, size: [bytes: 24]
      field :level,          :integer,  size: [bytes: 1]
      field :class,          :integer,  size: [bytes: 1]
      field :realm,          :integer,  size: [bytes: 1]

      compound :race_and_gender, :integer, size: [bytes: 1] do
        field :race, default: 0
        field :gender, default: 0
      end

      field :model,        :little_int, size: [bytes: 2]
      field :region,       :integer,    size: [bytes: 1]
      blank               using: 0x00,  size: [bytes: 5]
      field :strength,     :integer,    size: [bytes: 1]
      field :dexterity,    :integer,    size: [bytes: 1]
      field :constitution, :integer,    size: [bytes: 1]
      field :quickness,    :integer,    size: [bytes: 1]
      field :intelligence, :integer,    size: [bytes: 1]
      field :piety,        :integer,    size: [bytes: 1]
      field :empathy,      :integer,    size: [bytes: 1]
      field :charisma,     :integer,    size: [bytes: 1]
      field :helmet,       :little_int, size: [bytes: 2]
      field :gloves,       :little_int, size: [bytes: 2]
      field :boots,        :little_int, size: [bytes: 2]
      field :right_hand_color, :little_int, size: [bytes: 2]
      field :torso,        :little_int, size: [bytes: 2]
      field :cloak,        :little_int, size: [bytes: 2]
      field :legs,         :little_int, size: [bytes: 2]
      field :arms,         :little_int, size: [bytes: 2]
      field :helmet_color, :little_int, size: [bytes: 2]
      field :gloves_color, :little_int, size: [bytes: 2]
      field :boots_color,  :little_int, size: [bytes: 2]
      field :left_hand_color,  :little_int, size: [bytes: 2]
      field :torso_color,  :little_int, size: [bytes: 2]
      field :cloak_color,  :little_int, size: [bytes: 2]
      field :legs_color,   :little_int, size: [bytes: 2]
      field :arms_color,   :little_int, size: [bytes: 2]
      field :right_hand_model, :little_int, size: [bytes: 2]
      field :left_hand_model,  :little_int, size: [bytes: 2]
      field :two_hand_model,   :little_int, size: [bytes: 2]
      field :ranged_model,     :little_int, size: [bytes: 2]

      # TODO: Selected Weapon
      blank          using: 0xFF, size: [bytes: 1]
      blank          using: 0xFF, size: [bytes: 1]

      # Old SI Zone Check & Constitution
      blank          using: 0x00, size: [bytes: 2]

      # race and gender are woven together in a single byte, this untangles
      # them from each other and splices them back together
      defp compound(:from_binary, :race_and_gender, int) do
        <<_::1, first_race_bit::1, _::1, gender::1, race_last_four::4>> = <<int::8>>
        <<race::8>> = <<0::3, first_race_bit::1, race_last_four::4>>
        %{race: race, gender: gender}
      end
      defp compound(:to_binary, :race_and_gender, %{race: race, gender: gender}) do
        <<0::3, first_race_bit::1, race_last_four::4>> = <<race::8>>
        <<num::8>> = <<0::1, first_race_bit::1, 0::1, gender::1, race_last_four::4>>
        num
      end
    end

    field :username, :c_string, size: [bytes: 24]
    list :characters, Character, size: 10
    blank          using: 0x00, size: [bytes: 94]
  end
end
