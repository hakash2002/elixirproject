defmodule PlayerServer.Command do
  def run({:create, bucket}, pid) do
    Player.Api.create(pid, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:create, bucket}) do
    case Player.Router.route(bucket, Player.Api, :create, [Player.Api, bucket]) do
      pid when is_pid(pid) -> {:ok, "OK\r\n"}
      _ -> {:error, "FAILED TO CREATE BUCKET"}
    end
  end

  def run({:get, bucket, key}) do
    lookup(bucket, fn pid ->
      value = Player.Bucket.get(pid, key)
      if value do
        {:ok,"Player stats: Power: #{Keyword.get(value, :power)} Speed: #{Keyword.get(value, :speed)} Agility: #{Keyword.get(value, :agility)}\r\n"}
      else
        {:ok,"No value found\r\n"}
      end

    end)
  end

  def run({:put, bucket, key, value}) do
    lookup(bucket, fn pid ->
      Player.Bucket.put(pid, key, value)
      {:ok, "Updated\r\n"}
    end)
  end

  def run({:delete, bucket, key}) do
      Player.Api.delete(Player.Api,bucket, key)
      {:ok, "Deleted\r\n"}
  end

  def run({:delete, bucket}) do
    lookup(bucket, fn pid ->
      Player.Api.delete(Player.Api,pid)
      {:ok, "Deleted\r\n"}
    end)
  end

  def run(_command) do
    {:ok, "OK\r\n"}
  end

  defp lookup(bucket, callback) do
    case Player.Router.route(bucket, Player.Api, :get, [Player.Api, bucket]) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end

  def parse(line) do
    case String.split(line) do
      ["CREATE", position] ->
        {:ok, {:create, position}}

      ["GET", position | rest] ->
        {:ok, {:get, position, Enum.join(rest, " ")}}

      ["PUT" | rest] ->
        {:ok,
         {:put, Enum.slice(rest, 0, 1) |> Enum.join(),
          Enum.slice(rest, 1, length(rest) - 4) |> Enum.join(" "),
          [
            power:
              Enum.at(rest, length(rest) - 3)
              |> String.to_integer(),
            speed:
              Enum.at(rest, length(rest) - 2)
              |> String.to_integer(),
            agility:
              Enum.at(rest, length(rest) - 1)
              |> String.to_integer()
          ]}}

      ["DELETE", position] ->
        {:ok, {:delete, position}}

      ["DELETE", position | rest] ->
        {:ok, {:delete, position, Enum.join(rest," ")}}

      _ ->
        {:error, :unknown_command}
    end
  end
end
