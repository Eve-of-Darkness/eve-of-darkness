defmodule EOD.Packet.Server.CharacterPointsUpdate do
  @moduledoc """
  This packet is sent to the client to inform the client of the
  character "experience" metrics, such as RPs, Exp, Master Level, etc.

  It should be noted that the `level_progress` and `champion_level_progress`
  fields are integers between 0..1000; every 100 is one bubble.
  """
  use EOD.Packet do
    code 0x91

    field :realm_points, :integer, size: [bytes: 4]
    field :level_progress, :integer, size: [bytes: 2]
    field :free_skill_points, :integer, size: [bytes: 2]
    field :bounty_points, :integer, size: [bytes: 4]
    field :realm_skill_points, :integer, size: [bytes: 2]
    field :champion_level_progress, :integer, size: [bytes: 2]
    field :experience, :little_int, size: [bytes: 8]
    field :exp_to_next_lvl, :little_int, size: [bytes: 8]
    field :champ_exp, :little_int, size: [bytes: 8]
    field :champ_exp_to_next_lvl, :little_int, size: [bytes: 8]
  end
end
