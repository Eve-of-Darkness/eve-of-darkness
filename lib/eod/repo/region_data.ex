defmodule EOD.Repo.RegionData do
  @moduledoc """
  This is the general information store for a region as well as helper
  functions around the data.
  """
  use EOD.Repo.Schema

  schema "regions" do
    field :region_id,    :integer
    field :name,         :string
    field :description,  :string
    field :enabled,      :boolean
  end

  @doc """
  Returns a scope for data from all regions that are flagged as enabled in
  the database.  The scope defaults to just `RegionData`; however, it can
  be given any scope that centers around a region data.
  """
  def enabled(query \\ __MODULE__) do
    from(q in query, where: q.enabled == true)
  end
end
