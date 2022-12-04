defmodule Election do
  defstruct(
    name: "",
    candidates: [],
    next_id: 0
  )

  @doc """
  Updates ElectionStruct, based on provided command

  ## Parameters

  - election: ElectionStruct
  - cmd: String based command. Each command can be shorthanded to what's shown
    in parenthesis.
    - (n)ame command updated the election name
      - example: "n Mayor"
    - (a)dd command adds a new candidated
      - example: "a will Ferrell"
    - (v)ote command increments the vote counr for candidate
      - example: "v 1"
    - (q)uit command return a quit atom
      - example: "q"

  Return `Election` Struct

  ## Examples

      iex> %Election{} |> Election.update("n Mayor")
      %Election{name: "Mayor"}

      iex> %Election{} |> Election.update("add Tina Fay")
      %Election{
        candidates: [ %Candidate{ id: 0, name: "Tina Fay", votes: 0 } ],
        name: "",
        next_id: 1
      }

      iex> %Election{candidates: [Candidate.new(1, "Will Ferrel")]} |> Election.update("v 1")
      %Election{candidates: [%Candidate{id: 1, name: "Will Ferrel", votes: 1}]}

      iex> %Election{} |> Election.update("q")
      :quit
  """

  def run() do
    %Election{} |> run()
  end

  def run(election = %Election{}) do
    [IO.ANSI.clear(), IO.ANSI.cursor(0, 0)]
    |> IO.write()

    election
    |> view
    |> IO.write()

    command = IO.gets(">")

    election
    |> update(command)
    |> run()
  end

  def run(:quit), do: :quit

  def update(election, cmd) when is_binary(cmd) do
    update(election, String.split(cmd))
  end

  def update(_election, ["q" <> _]), do: :quit

  def update(election, ["a" <> _ | args]) do
    name = Enum.join(args, " ")
    candidate = Candidate.new(election.next_id, name)
    candidates = [candidate | election.candidates]

    # election
    # |> Map.put(:candidates, candidates)
    # |> Map.put(:next_id, election.next_id + 1)

    %{election | candidates: candidates, next_id: election.next_id + 1}
  end

  def update(election, ["v" <> _, id]) do
    vote(election, Integer.parse(id))
  end

  defp vote(election, {id, ""}) do
    candidates = Enum.map(election.candidates, &maybe_inc_vote(&1, id))
    Map.put(election, :candidates, candidates)
  end

  defp maybe_inc_vote(candidate, id) when is_integer(id) do
    maybe_inc_vote(candidate, candidate.id == id)
  end

  defp maybe_inc_vote(candidate, _inc_vote = false), do: candidate

  defp maybe_inc_vote(candidate, _inc_vote = true) do
    Map.update!(candidate, :votes, &(&1 + 1))
  end

  defp vote(election, _errors), do: election

  def update(election, ["n" <> _ | args]) do
    name = Enum.join(args, " ")
    Map.put(election, :name, name)
  end

  def view_header(election) do
    [
      "Election for: #{election.name}\n"
    ]
  end

  def view_footer() do
    [
      "\n",
      "commands: (n)ame <election>, (a)dd <candidate>, (v)ote <id>, (q)uite\n"
    ]
  end

  def view(election) do
    [view_header(election), view_body(election), view_footer()]
  end

  def view_body(election) do
    election.candidates
    |> sort_candidates_by_votes_desc()
    |> candidates_to_string()
    |> prepend_candidates_header()
  end

  defp prepend_candidates_header(candidates) do
    [
      "ID\tVotes\tName\n",
      "-----------------------------------\n"
      | candidates
    ]
  end

  defp candidates_to_string(candidates) do
    candidates
    |> Enum.map(fn %{id: id, name: name, votes: votes} ->
      "#{id}\t#{votes}\t#{name}\n"
    end)
  end

  defp sort_candidates_by_votes_desc(candidates) do
    candidates
    |> Enum.sort(&(&1.votes >= &2.votes))
  end
end
