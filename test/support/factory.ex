defmodule EOD.Repo.Factory do
  use ExMachina.Ecto, repo: EOD.Repo
  alias EOD.Repo.{Account, Character, RegionData}

  def account_factory do
    %Account{
      username: sequence(:uname, &"username_#{&1}"),
      password: Comeonin.Pbkdf2.hashpwsalt("test-password")
    }
  end

  def character_factory do
    %Character{
      realm: 1,
      name: "benfalk",
      slot: 0,
      custom_mode: 1,
      eye_size: 128,
      lip_size: 83,
      eye_color: 34,
      hair_color: 12,
      face_type: 48,
      hair_style: 112,
      mood_type: 96,
      level: 1,
      class: 6,
      gender: 0,
      race: 1,
      model: 20954,
      region: 27,
      strength: 60,
      dexterity: 75,
      constitution: 60,
      quickness: 60,
      intelligence: 60,
      piety: 70,
      empathy: 60,
      charisma: 60,
      account: build(:account)
    }
  end

  def region_data_factory do
    %RegionData{
      region_id: 27,
      name: "region027",
      description: "Tutorial",
      enabled: true
    }
  end
end
