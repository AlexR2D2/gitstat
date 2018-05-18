defmodule HttpClient do
  use HTTPoison.Base


  # behaviour


  @callback post_ql(String.t) :: {:ok, term, term} | {:error, term}
    

  # user interface 
      

  def process_url(url) do
    "https://api.github.com" <> url
  end

  defp process_request_headers(headers) when is_map(headers) do
    Enum.into(headers, [])
  end
  
  defp process_request_headers(headers) when is_list(headers) do
    token = Application.get_env(:api_client, :api_token)
    ["Authorization": "Bearer #{token}", "Accept": "Application/json; Charset=utf-8"] ++ headers
  end

  defp process_request_options(options) do
    [ssl: [{:versions, [:'tlsv1.2']}], timeout: 60 * 1000, recv_timeout: 60 * 1000] ++ options
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), map_key_to_atom(v)} end)    
  end
  
  def map_key_to_atom(m) when is_map(m), do: Enum.into(m, %{}, fn {k, v} -> {String.to_atom(k), map_key_to_atom(v)} end)
  def map_key_to_atom(v), do: v

  #client 

  def post_ql(graphql_query) do
    query = Poison.encode!(%{ "query" => graphql_query })

    case HttpClient.post("/graphql", query) do
      {:error, %HTTPoison.Error{ reason: reason }} ->
        {:error, reason}
      
      {:ok, %HTTPoison.Response{ status_code: code, body: %{documentation_url: url, message: message} }} when code >= 400 ->
        {:error, message}

      {:ok, %HTTPoison.Response{ status_code: 200, body: %{errors: errors} }} ->
        {:error, errors}
    
      {:ok, %HTTPoison.Response{ status_code: 200, body: %{data: data} }} ->
        {:ok, data}
    end
  end

end
