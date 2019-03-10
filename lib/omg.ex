defmodule Omg do
  @moduledoc """
  Documentation for Omg.
  """

  @input """
  {
    "orders": [
       {"command": "sell", "price": 100.003, "amount": 2.4},
       {"command": "buy", "price": 90.394, "amount": 3.445},
       {"command": "buy", "price": 89.394, "amount": 4.3},
       {"command": "sell", "price": 100.013, "amount": 2.2},
       {"command": "buy", "price": 90.15, "amount": 1.305},
       {"command": "buy", "price": 90.394, "amount": 1.0},
       {"command": "sell", "price": 90.394, "amount": 2.2},
       {"command": "sell", "price": 90.15, "amount": 3.4},
       {"command": "buy", "price": 91.33, "amount": 1.8},
       {"command": "buy", "price": 100.01, "amount": 4.0},
       {"command": "sell", "price": 100.15, "amount": 3.8}
    ]
  }
  """

  alias Decimal, as: D

  @doc """
  Hello world.

  ## Examples

      iex> Omg.hello()
      :world

  """
  def run(path \\ "./lib/input.json") do
    # @input
    json = path
    |> Path.expand()
    |> File.read!()
    |> Jason.decode!()
    |> Map.get("orders")
    |> Enum.map(&convert_keys_vals(&1))
    |> process_orders()
    |> Jason.encode!()

    case File.write(Path.expand("./lib/output.json"), json) do
      :ok -> IO.puts "File written!"
      {:error, err} -> 
        IO.puts "File not written!"
        IO.inspect err
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

  defp process_orders(list, buy \\ [], sell \\ [])

  defp process_orders([], buy, sell) do
    {buy, sell} = sort(buy, sell)
    %{
      buy: buy,
      sell: sell
    }
  end

  defp process_orders([command | tail], buy, sell) do
    {buy, sell} = sort(buy, sell)

    case command do
      %{command: "sell"} ->
        {:ok, remainder, new_buy} = subtract_from_buy(command, buy)
        {:ok, new_sell} = add_to_list(remainder, sell)
        process_orders(tail, new_buy, new_sell)

      %{command: "buy"} ->
        {:ok, remainder, new_sell} = subtract_from_sell(command, sell)
        {:ok, new_buy} = add_to_list(remainder, buy)
        process_orders(tail, new_buy, new_sell)

      _ ->
        IO.inspect("N/A")
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

  defp subtract_from_buy(command, []), do: {:ok, command, []}
  defp subtract_from_buy(command, [entry | tail]) do
    case price_matched?(command, entry) do
      true ->
        case D.cmp(command[:price], entry[:price]) do
          :gt ->
            IO.inspect "Buy: ++++++++++"
            IO.inspect command
            IO.inspect entry
            case D.cmp(command[:amount], entry[:volume]) do
              :eq ->
                {:ok, command, [entry | tail]}
              :lt ->
                {:ok, command, [entry | tail]}
              :gt ->
                # new_volume = D.sub(command[:amount], entry[:volume])
                # new_command = Map.put(command, :amount, new_volume)
                # {:ok, new_command, tail}
                {:ok, command, [entry | tail]}
            end
          _ ->
            case D.cmp(command[:amount], entry[:volume]) do
              :eq ->
                # IO.inspect "command[:amount]: #{command[:amount]} :eq entry[:volume]: #{entry[:volume]}"
                {:ok, new_entry, new_command} = subtract_from_entry(entry, command)
                {:ok, new_command, [new_entry | tail]}
              :lt ->
                # IO.inspect "command[:amount]: #{command[:amount]} :lt entry[:volume]: #{entry[:volume]}"
                {:ok, new_entry, new_command} = subtract_from_entry(entry, command)
                {:ok, new_command, [new_entry | tail]}
              :gt ->
                # IO.inspect "command[:amount]: #{command[:amount]} :gt entry[:volume]: #{entry[:volume]}"
                new_amount = D.sub(command[:amount], entry[:volume])
                new_command = Map.put(command, :amount, new_amount)
                subtract_from_buy(new_command, tail)
            end
        end
      false ->
        {:ok, command, [entry | tail]}
    end
  end

  defp subtract_from_sell(command, []), do: {:ok, command, []}
  defp subtract_from_sell(command, [entry | tail]) do
    case price_matched?(command, entry) do
      true ->
        case D.cmp(command[:price], entry[:price]) do
          :gt ->
            IO.inspect "Sell: ++++++++++"
            IO.inspect command
            IO.inspect entry
            case D.cmp(command[:amount], entry[:volume]) do
              :eq ->
                {:ok, command, [entry | tail]}
              :lt ->
                {:ok, command, [entry | tail]}
              :gt ->
                new_volume = D.sub(command[:amount], entry[:volume])
                new_command = Map.put(command, :amount, new_volume)
                {:ok, new_command, tail}
            end
          _ ->
            case D.cmp(command[:amount], entry[:volume]) do
              :eq ->
                # IO.inspect "command[:amount]: #{command[:amount]} :eq entry[:volume]: #{entry[:volume]}"
                {:ok, new_entry, new_command} = subtract_from_entry(entry, command)
                {:ok, new_command, [new_entry | tail]}
              :lt ->
                # IO.inspect "command[:amount]: #{command[:amount]} :lt entry[:volume]: #{entry[:volume]}"
                {:ok, new_entry, new_command} = subtract_from_entry(entry, command)
                {:ok, new_command, [new_entry | tail]}
              :gt ->
                # IO.inspect "command[:amount]: #{command[:amount]} :gt entry[:volume]: #{entry[:volume]}"
                new_amount = D.sub(command[:amount], entry[:volume])
                new_command = Map.put(command, :amount, new_amount)
                subtract_from_sell(new_command, tail)
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
