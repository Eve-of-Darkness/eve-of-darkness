defmodule EOD.Repo.Migrations.ExpandCharacterAttributes do
  use Ecto.Migration

  def change do
    alter table("characters") do
      add :slot, :integer
      add :custom_mode, :integer
      add :eye_size, :integer
      add :lip_size, :integer
      add :eye_color, :integer
      add :hair_color, :integer
      add :face_type, :integer
      add :hair_style, :integer
      add :mood_type, :integer
      add :action, :integer
      add :level, :integer
      add :class, :integer
      add :gender, :integer
      add :race, :integer
      add :model, :integer
      add :region, :integer
      add :strength, :integer
      add :dexterity, :integer
      add :constitution, :integer
      add :quickness, :integer
      add :intelligence, :integer
      add :piety, :integer
      add :empathy, :integer
      add :charisma, :integer
    end
  end
end
