defmodule Covid19Web.CovidLive do
  use Phoenix.LiveView

  @refresh_interval :timer.minutes(60)

  def mount(_params, _session, socket) do
    send(self(), :fetch)

    if connected?(socket), do: schedule_refresh()

    {:ok,
     assign(socket,
       global_stats: nil,
       regional_stats: [],
       matches: nil,
       loading: true,
       q: nil
     )}
  end

  def render(assigns) do
    ~L"""
    <%= if @loading do %>
      <div class="loader"></div>
    <% end %>

    <div class="wrapper <%= if @loading, do: "hidden" %>">
      <div class="stats">
        <div class="stat">
          <span>
            <%= get_in(@global_stats, ["confirmed", "value"]) %>
          </span>
          <h3>Confirmed</h3>
        </div>
        <div class="stat">
          <span>
            <%= get_in(@global_stats, ["deaths", "value"]) %>
          </span>
          <h3>Deaths</h3>
        </div>
        <div class="stat">
          <span>
            <%= get_in(@global_stats, ["recovered", "value"]) %>
          </span>
          <h3>Recovered</h3>
        </div>
      </div>

      <form phx-change="filter">
        <div class="icon">
          <img src="images/search.svg">
        </div>
        <input type="text" name="q" value="<%= @q %>" />
      </form>

      <table>
        <thead>
          <tr>
            <th class="left">
              Country/Region
            </th>
            <th class="left">
              Province/State
            </th>
            <th>
              Confirmed
            </th>
            <th>
              Deaths
            </th>
            <th>
              Recovered
            </th>
          </tr>
        </thead>
        <tbody>
          <%= for stat <- @matches || @regional_stats do %>
            <tr>
              <td class="left">
                <%= Map.get(stat, "countryRegion") %>
              </td>
              <td class="left">
                <%= Map.get(stat, "provinceState") %>
              </td>
              <td>
                <%= Map.get(stat, "confirmed") %>
              </td>
              <td>
                <%= Map.get(stat, "deaths") %>
              </td>
              <td>
                <%= Map.get(stat, "recovered") %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def handle_info(:fetch, socket) do
    {:noreply,
     assign(socket,
       global_stats: fetch("https://covid19.mathdro.id/api"),
       regional_stats: fetch("https://covid19.mathdro.id/api/confirmed"),
       loading: false
     )}
  end

  def handle_event("filter", %{"q" => q}, socket) do
    matches = filter(socket.assigns.regional_stats, q)
    {:noreply, assign(socket, matches: matches)}
  end

  defp fetch(url) do
    {:ok, %{status_code: 200, body: body}} = HTTPoison.get(url)
    # :timer.sleep(1000)
    Jason.decode!(body)
  end

  defp schedule_refresh do
    :timer.send_interval(@refresh_interval, self(), :fetch)
  end

  defp filter(stats, q) do
    Enum.filter(stats, &(matches?(&1, q)))
  end

  defp matches?(%{"countryRegion" => region, "provinceState" => state}, q) do
    matches?(region, q) || matches?(state, q)
  end

  defp matches?(value, q) when is_binary(value) do
    String.starts_with?(String.downcase(value), String.downcase(q))
  end

  defp matches?(nil, _q), do: false
end
