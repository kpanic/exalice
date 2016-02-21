defmodule ExAlice.StreamRunner do
  use GenServer
  defstruct workers: %{}, cont: nil, capacity: 4, fun: nil, reply_to: nil

  @moduledoc """
  Concurrently work through a stream.

  See the docs for run/3 for usage
  """

  def start_link(capacity, opts) do
    GenServer.start_link(__MODULE__, capacity, opts)
  end

  @doc """
  Run a stream with a given function.

  The specified GenServer process will successively go through a stream, handing
  each item off to a worker, which executes the function on the item.

  It cannot process more than one stream at a time, so calling run/3 again prior
  to its completion will abandon the prior stream and associated workers.

  To wait until the stream is done, use await/2
  """
  def run(name, stream, fun) do
    GenServer.call(name, {:run, stream, fun})
  end

  @doc """
  Will block until the stream finishes, or the timeout is reached
  """
  def await(name, timeout \\ :infinity) do
    GenServer.call(name, :await, timeout)
  end

  def init(capacity) do
    {:ok, %__MODULE__{capacity: capacity}}
  end

  def handle_call({:run, stream, fun}, _, state) do
    # This places the stream in a suspended state
    # where we can choose to take additional items from it or not.
    # We'll take $capacity from it initially, and then one after each
    # task finishes.
    #
    # Ideally each task gets a big enough chunk that the task starting / stopping isn't
    # bottleneck.
    {:suspended, nil, cont} = Enumerable.reduce(stream, {:suspend, nil}, fn(v, _) -> {:suspend, v} end)
    state = start_workers(%{state | fun: fun, cont: cont, workers: %{}})

    {:reply, :started, state}
  end

  def handle_call(:await, from, state) do
    {:noreply, %{state | reply_to: from}}
  end

  def handle_info({:DOWN, ref, _, proc, reason}, %{workers: workers} = state) do
    state = case Map.has_key?(workers, ref) do
      true ->
        start_workers(%{state | workers: Map.delete(workers, ref)})
      false ->
        state
    end
    {:noreply, state}
  end

  def start_workers(%{cont: nil} = state), do: state |> reply_to
  def start_workers(%{workers: workers, capacity: capacity, cont: cont, fun: fun} = state) when map_size(workers) < capacity do
    case cont.({:cont, nil}) do
      {:suspended, item, cont} ->
        {:ok, pid} = Task.start_link(fn -> fun.(item) end)
        ref = Process.monitor(pid)
        workers = Map.put(workers, ref, pid)

        start_workers %{state | workers: workers, cont: cont}

      _ ->
        %{state | cont: nil, fun: nil}
    end
  end
  def start_workers(state), do: state

  def reply_to(%{reply_to: nil} = state), do: state
  def reply_to(%{reply_to: pid} = state) do
    GenServer.reply(pid, :done)
    state
  end

end
