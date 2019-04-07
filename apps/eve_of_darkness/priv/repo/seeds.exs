# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
alias EOD.Repo
alias EOD.Repo.Region

Repo.insert! %Region{region_id: 27, name: "region027", description: "Tutorial"}
