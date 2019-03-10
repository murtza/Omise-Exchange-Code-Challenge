defmodule Omg do
  alias Decimal, as: D

  def run(path \\ "./lib/input.json") do
    json =
      path
      |> Path.expand()
      |> File.read!()
      |> Jason.decode!()
      |> Map.get("orders")
      |> Enum.map(&convert_keys_vals(&1))
      |> process_orders()
      # |> IO.inspect()
      |> Jason.encode!()

    case File.write(Path.expand("./lib/output.json"), json) do
      :ok ->
        IO.puts("File written!")

      {:error, err} ->
        IO.inspect(err)
    end
  end

  defp convert_keys_vals(map) do
    map
    |> Enum.map(fn {k, v} ->
      v = if is_number(v), do: D.from_float(v), else: v
      {String.to_atom(k), v}
    end)
    |> Enum.into(%{})
  end

  defp convert_vals_to_floats(map) do
    map
    |> Enum.map(fn {k, v} ->
      v =
        v
        |> Decimal.to_string()
        |> String.to_float()

      {k, v}
    end)
    |> Enum.into(%{})
  end

  defp process_orders(list, buy \\ [], sell \\ [])

  defp process_orders([], buy, sell) do
    {buy, sell} = sort(buy, sell)
    buy = buy |> Enum.map(&convert_vals_to_floats(&1))
    sell = sell |> Enum.map(&convert_vals_to_floats(&1))

    %{
      buy: buy,
      sell: sell
    }
  end

  defp process_orders([command | tail], buy, sell) do
    {buy, sell} = sort(buy, sell)

    case command do
      %{command: "sell"} ->
        {:ok, remainder, new_buy} = subtract_from_list(command, buy)
        {:ok, new_sell} = add_to_list(remainder, sell)
        process_orders(tail, new_buy, new_sell)

      %{command: "buy"} ->
        {:ok, remainder, new_sell} = subtract_from_list(command, sell)
        {:ok, new_buy} = add_to_list(remainder, buy)
        process_orders(tail, new_buy, new_sell)

      command ->
        IO.inspect("Error: command does not match")
        IO.inspect(command)
        process_orders(tail, buy, sell)
    end
  end

  defp add_to_list(nil, list), do: {:ok, list}

  defp add_to_list(remainder, list) do
    case is_price_exist_in_list(remainder, list) do
      nil ->
        entry = %{
          price: remainder.price,
          volume: remainder.amount
        }

        {:ok, [entry | list]}

      entry ->
        list = List.delete(list, entry)
        volume = D.add(entry[:volume], remainder[:amount])
        entry = Map.put(entry, :volume, volume)
        new_list = [entry | list]
        {:ok, new_list}
    end
  end

  defp is_price_exist_in_list(command, list) do
    Enum.find(list, fn x ->
      D.cmp(x.price, command.price) == :eq
    end)
  end

  defp subtract_from_entry(entry, command) do
    volume = D.sub(entry[:volume], command[:amount])
    entry = Map.put(entry, :volume, volume)

    {:ok, entry, nil}
  end

  defp subtract_from_list(command, []), do: {:ok, command, []}

  defp subtract_from_list(command, [entry | tail]) do
    case price_matched?(command, entry) do
      true ->
        case D.cmp(command[:price], entry[:price]) do
          :gt ->
            case D.cmp(command[:amount], entry[:volume]) do
              :eq ->
                {:ok, command, [entry | tail]}

              :lt ->
                {:ok, command, [entry | tail]}

              :gt ->
                case command do
                  %{command: "buy"} ->
                    new_volume = D.sub(command[:amount], entry[:volume])
                    new_command = Map.put(command, :amount, new_volume)
                    {:ok, new_command, tail}

                  _ ->
                    {:ok, command, [entry | tail]}
                end
            end

          _ ->
            case D.cmp(command[:amount], entry[:volume]) do
              :eq ->
                {:ok, new_entry, new_command} = subtract_from_entry(entry, command)
                {:ok, new_command, [new_entry | tail]}

              :lt ->
                {:ok, new_entry, new_command} = subtract_from_entry(entry, command)
                {:ok, new_command, [new_entry | tail]}

              :gt ->
                new_amount = D.sub(command[:amount], entry[:volume])
                new_command = Map.put(command, :amount, new_amount)
                subtract_from_list(new_command, tail)
            end
        end

      false ->
        {:ok, command, [entry | tail]}
    end
  end

  defp price_matched?(command, entry) do
    command_price = to_int(command[:price])
    entry_price = to_int(entry[:price])

    command_price == entry_price
  end

  defp to_int(dec) do
    dec
    |> Decimal.to_string()
    |> Integer.parse()
    |> elem(0)
  end

  defp sort(buy, sell) do
    buy =
      buy
      |> sort_list(false)

    sell =
      sell
      |> sort_list(true)

    {buy, sell}
  end

  defp sort_list(list, bool) do
    list
    |> Enum.sort(fn a, b ->
      case D.cmp(a.price, b.price) do
        :lt -> bool
        _ -> !bool
      end
    end)
  end
end
