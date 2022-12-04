defmodule ElectionTest do
  use ExUnit.Case
  doctest Election

  # setup do
  #   %{election: %Election{}}
  # end

  setup_all do
    %{election: %Election{}}
  end

  test "updating election name from a command", ctx do
    command = "name Will Ferrell"
    election = Election.update(ctx.election, command)
    assert election == %Election{name: "Will Ferrell"}
  end

  test "adding a new candidate from a command", ctx do
    command = "add Will Ferrell"
    election = Election.update(ctx.election, command)

    assert election == %Election{
             candidates: [%Candidate{id: 0, name: "Will Ferrell", votes: 0}],
             name: "",
             next_id: 1
           }
  end

  test "voting for a candidate from a command", ctx do
    command = "add Will Ferrell"
    election = Election.update(ctx.election, command)
    vote = Election.update(election, "vote 0")

    assert vote == %Election{
             candidates: [%Candidate{id: 0, name: "Will Ferrell", votes: 1}],
             name: "",
             next_id: 1
           }
  end

  # test "invalid command", ctx do
  #   command = "Invalid command"
  #   election = Election.update(ctx.election, command)
  # end

  test "quitting the app" do
    command = :quit
    assert Election.run(command) == :quit
  end
end
