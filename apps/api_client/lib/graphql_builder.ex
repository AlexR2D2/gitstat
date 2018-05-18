defmodule GraphQL do

  def build_query(languages, date_beg, date_end) when is_list(languages) do
    searches = Enum.reduce(languages, "", fn language, acc -> 
      acc <> " " <> search(language, date_beg, date_end)      
    end)
    "query {" <> searches <> "}"
  end

  def build_query(%{lang: languageLabel} = language, date_beg, date_end) when is_map(language) do
    "query { search(query: \"language:#{languageLabel} fork:false mirror:false created:#{date_beg}..#{date_end}\" type: REPOSITORY) { repositoryCount } }"
  end

  def build_query(languages, day) when is_list(languages) do
    searches = Enum.reduce(languages, "", fn language, acc -> 
      acc <> " " <> search(language, day)      
    end)
    "query {" <> searches <> "}"
  end

  def build_query(%{lang: language}) do
    "query { search(query: \"language:#{language} fork:false mirror:false\" type: REPOSITORY) { repositoryCount } }"
  end

  defp search(%{key: key, lang: language}, date_beg, date_end) do
    "#{key}: search(query: \"language:#{language} fork:false mirror:false created:#{date_beg}..#{date_end}\", type: REPOSITORY) { repositoryCount }"
  end

  defp search(%{key: key, lang: language}, day) do
    "#{key}: search(query: \"language:#{language} fork:false mirror:false created:#{day}..#{day}\", type: REPOSITORY) { repositoryCount }"
  end

end
