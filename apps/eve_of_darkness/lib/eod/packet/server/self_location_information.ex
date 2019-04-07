defmodule EOD.Packet.Server.SelfLocationInformation do
  @moduledoc """
  This is sent by the server to the client to notify it of where the player's
  character is in the world.  This packet appears to be sent extremely sparingly;
  only on on loading into a zone.
  """

  use EOD.Packet do
    code(0x20)

    field(:x_loc, :little_float, size: [bytes: 4])
    field(:y_loc, :little_float, size: [bytes: 4])
    field(:z_loc, :little_float, size: [bytes: 4])
    field(:object_id, :integer, size: [bytes: 2])
    field(:heading, :integer, size: [bytes: 2])

    # These may not be offsets, they are always zero in the logs
    # and this is a guess based on what I see looking at DOL source
    # code
    field(:x_offset, :integer, size: [bytes: 2])
    field(:y_offset, :integer, size: [bytes: 2])

    field(:region, :integer, size: [bytes: 2])

    # Not sure what this is, but it's normally 0, maybe this is
    # where the diving flag went? : Setting it to `0x80` for now
    # as this is what I see for region 27 loading.
    blank(using: 0x80, size: [bytes: 1])

    field(:server_name, :pascal_string, size: [bytes: 1])

    # Not sure what this is
    blank(using: 0x00, size: [bytes: 1])
    blank(using: 0x05, size: [bytes: 1])
    blank(using: 0x00, size: [bytes: 2])
  end
end
