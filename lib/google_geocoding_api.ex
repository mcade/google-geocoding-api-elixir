defmodule GoogleGeocodingApi do
  @moduledoc """
  Provides functions to interact with Google Geocoding API.
  """

  def all_info(address, opts \\ []) do
    result = Poison.decode!(make_request(address, opts).body)

    case result["status"] do
      "ZERO_RESULTS" ->
        {:error, "No results found for that address"}
      "OVER_QUERY_LIMIT" ->
        {:error, "You have reached your query limit"}
      "REQUEST_DENIED" ->
        {:error, "Your request was denied"}
      "INVALID_REQUEST" ->
        {:error, "Your request was invalid"}
      "UNKNOWN_ERROR" ->
        {:error, "Unknown error, this may succeed if you try again"}
      _ ->
        {:ok, result}
    end
  end

  def geometry(address, opts \\ []) do
    case all_info(address, opts) do
      {:ok, result} -> {:ok, List.first(result["results"])["geometry"]}
      {:error, reason} -> {:error, reason}
    end
  end

  def geo_location(address, opts \\ []) do
    case all_info(address, opts) do
      {:ok, result} -> {:ok, List.first(result["results"])["geometry"]["location"]}
      {:error, reason} -> {:error, reason}
    end
  end

  def geo_location_northeast(address, opts \\ []) do
    case all_info(address, opts) do
      {:ok, result} -> {:ok, List.first(result["results"])["geometry"]["viewport"]["northeast"]}
      {:error, reason} -> {:error, reason}
    end
  end

  def geo_location_southwest(address, opts \\ []) do
    case all_info(address, opts) do
      {:ok, result} -> {:ok, List.first(result["results"])["geometry"]["viewport"]["southwest"]}
      {:error, reason} -> {:error, reason}
    end
  end

  def location_type(address, opts \\ []) do
    case all_info(address, opts) do
      {:ok, result} -> {:ok, List.first(result["results"])["geometry"]["location_type"]}
      {:error, reason} -> {:error, reason}
    end
  end

  def formatted_address(address, opts \\ []) do
    case all_info(address, opts) do
      {:ok, result} -> {:ok, List.first(result["results"])["formatted_address"]}
      {:error, reason} -> {:error, reason}
    end
  end

  def place_id(address, opts \\ []) do
    case all_info(address, opts) do
      {:ok, result} -> {:ok, List.first(result["results"])["place_id"]}
      {:error, reason} -> {:error, reason}
    end
  end

  def address_components(address, opts \\ []) do
    case all_info(address, opts) do
      {:ok, result} -> {:ok, List.first(result["results"])["address_components"]}
      {:error, reason} -> {:error, reason}
    end
  end

  def types(address, opts \\ []) do
    case all_info(address, opts) do
      {:ok, result} -> {:ok, List.first(result["results"])["types"]}
      {:error, reason} -> {:error, reason}
    end
  end

  defp make_request(address, opts \\ []) do
    params =
      [address: address, region: Keyword.get(opts, :region, ""), key: key()]
      |> Enum.filter(&(elem(&1, 1) != nil))
      |> Enum.into(%{})

    HTTPoison.start

    params
    |> URI.encode_query
    |> build_url
    |> HTTPoison.get!
  end

  defp build_url(params), do: "https://maps.googleapis.com/maps/api/geocode/json?" <> params

  defp key do
    Application.get_env(:google_geocoding_api, :api_key)
  end
end
