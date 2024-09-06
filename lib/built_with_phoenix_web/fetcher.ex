defmodule BuiltWithPhoenixWeb.Fetcher do
  @moduledoc "Fetches a website's details like logo, image, title, and description."

  def fetch_website_details(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{scheme: nil, path: path} when is_binary(path) -> do_fetch_site_details(path)
      %URI{host: host} when is_binary(host) -> do_fetch_site_details(host)
      _invalid_uri -> %{}
    end
  end

  def fetch_website_details(_url), do: %{}

  defp do_fetch_site_details(host) do
    url = "https://#{host}"

    opts = [
      retry: false,
      receive_timeout: 1000,
      headers: [
        user_agent:
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
      ]
    ]

    case Req.get(url, opts) do
      {:ok, %Req.Response{body: body}} -> extract_site_details(body, host)
      _error -> %{}
    end
  end

  defp extract_site_details(body, host) do
    document = Floki.parse_document!(body)

    title = fetch_attribute(document, "meta[property='og:title']", "content")
    description = fetch_attribute(document, "meta[property='og:description']", "content")

    image =
      fetch_attribute(document, "meta[property='og:image']", "content")
      |> maybe_convert_to_url(host)

    logo = fetch_logo(document, host) |> maybe_convert_to_url(host)

    %{
      "name" => title,
      "description" => description,
      "logo" => logo,
      "image" => image
    }
  end

  defp fetch_logo(document, host) do
    with nil <- fetch_attribute(document, "link[rel='icon']", "href"),
         nil <- fetch_attribute(document, "link[rel='apple-touch-icon']", "href"),
         nil <- fetch_attribute(document, "link[rel='shortcut icon']", "href"),
         icon_url <- fall_back_to_duckduckgo(host) do
      icon_url
    end
  end

  defp fetch_attribute(document, identifier, attribute) do
    document
    |> Floki.find(identifier)
    |> Floki.attribute(attribute)
    |> List.first()
  end

  defp fall_back_to_duckduckgo(host) do
    "https://icons.duckduckgo.com/ip3/#{host}.ico"
  end

  defp maybe_convert_to_url(url_or_path, host) when is_binary(url_or_path) do
    case URI.parse(url_or_path) do
      # Some href links are relative, but we need absolute links.
      %URI{host: nil, path: path} ->
        %URI{scheme: "https", host: host, path: path} |> URI.to_string()

      _ ->
        url_or_path
    end
  end

  defp maybe_convert_to_url(url_or_path, _host), do: url_or_path
end
