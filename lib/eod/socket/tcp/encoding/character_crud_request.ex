defmodule EOD.Socket.TCP.Encoding.CharacterCrudRequest do
  @moduledoc false
  import EOD.Socket.TCP.ClientPacket

  def decode(%{data: <<_raw_acct_name::bytes-size(24), remaining::binary>>}, id) do
    case extract_characters(remaining) do
      :error_reading_chars -> {:error, :char_crud_request}
      chars ->
        action = hd(chars) |> Map.get(:action)
        {:ok, %{id: id, action: action, characters: chars}}
    end
  end
  def decode(_, _), do: {:error, :char_crud_request}

  defp extract_characters(data), do: char_extract(data, 0, [])
  def char_extract(_, 10, chars), do: chars
  def char_extract(data, slot, chars) do
    with <<_::bytes-size(4), # Unknown
           raw_char_name::bytes-size(24),
           custom_mode::8,
           eye_size::8,
           lip_size::8,
           eye_color::8,
           hair_color::8,
           face_type::8,
           hair_style::8,
           _::bytes-size(3), # Unknown
           mood_type::8,
           _::bytes-size(8),
           action::32,
           _::8, # Unknown,
           _::bytes-size(24), # Location String
           _::bytes-size(24), # Class Name
           _::bytes-size(24), # Race Name
           level::8,
           class::8,
           realm::8,
           _start_bit::1,
           first_race_bit::1,
           _::1, # Unknown
           gender::1,
           race_last_four::4,
           model::little-integer-size(16),
           region::8,
           _::8, # 2nd region byte?
           _::bytes-size(4), # Unknown int, last used?
           strength::8,
           dexterity::8,
           constitution::8,
           quickness::8,
           intelligence::8,
           piety::8,
           empathy::8,
           charisma::8,
           _::bytes-size(40), # Equipment
           _::8, # Active Right Slot
           _::8, # Active Left Slot
           _::8, # SI Zone
           _new_constitution::8,
           remaining::binary>> <- data
    do
      <<race::8>> = <<0::3, first_race_bit::1, race_last_four::4>>

      char_extract(remaining, slot+1, [%{
        slot: slot,
        name: read_string(raw_char_name, 24),
        custom_mode: custom_mode,
        eye_size: eye_size,
        lip_size: lip_size,
        eye_color: eye_color,
        hair_color: hair_color,
        face_type: face_type,
        hair_style: hair_style,
        mood_type: mood_type,
        action: action_map(action),
        level: level,
        class: class,
        realm: realm,
        gender: gender,
        race: race,
        model: model,
        region: region,
        strength: strength,
        dexterity: dexterity,
        constitution: constitution,
        quickness: quickness,
        intelligence: intelligence,
        piety: piety,
        empathy: empathy,
        charisma: charisma
      } | chars])
    else
      _ -> :error_reading_chars
    end
  end

  defp action_map(0x12345678), do: :delete
  defp action_map(0x23456789), do: :create
  defp action_map(0x3456789A), do: :update
end
