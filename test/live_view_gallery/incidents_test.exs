defmodule Covid19.IncidentsTest do
  use Covid19.DataCase

  alias Covid19.Incidents

  describe "incidents" do
    alias Covid19.Incidents.Incident

    @valid_attrs %{description: "some description", is_resolved: true, location: "some location", priority: 42}
    @update_attrs %{description: "some updated description", is_resolved: false, location: "some updated location", priority: 43}
    @invalid_attrs %{description: nil, is_resolved: nil, location: nil, priority: nil}

    def incident_fixture(attrs \\ %{}) do
      {:ok, incident} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Incidents.create_incident()

      incident
    end

    test "list_incidents/0 returns all incidents" do
      incident = incident_fixture()
      assert Incidents.list_incidents() == [incident]
    end

    test "get_incident!/1 returns the incident with given id" do
      incident = incident_fixture()
      assert Incidents.get_incident!(incident.id) == incident
    end

    test "create_incident/1 with valid data creates a incident" do
      assert {:ok, %Incident{} = incident} = Incidents.create_incident(@valid_attrs)
      assert incident.description == "some description"
      assert incident.is_resolved == true
      assert incident.location == "some location"
      assert incident.priority == 42
    end

    test "create_incident/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Incidents.create_incident(@invalid_attrs)
    end

    test "update_incident/2 with valid data updates the incident" do
      incident = incident_fixture()
      assert {:ok, %Incident{} = incident} = Incidents.update_incident(incident, @update_attrs)
      assert incident.description == "some updated description"
      assert incident.is_resolved == false
      assert incident.location == "some updated location"
      assert incident.priority == 43
    end

    test "update_incident/2 with invalid data returns error changeset" do
      incident = incident_fixture()
      assert {:error, %Ecto.Changeset{}} = Incidents.update_incident(incident, @invalid_attrs)
      assert incident == Incidents.get_incident!(incident.id)
    end

    test "delete_incident/1 deletes the incident" do
      incident = incident_fixture()
      assert {:ok, %Incident{}} = Incidents.delete_incident(incident)
      assert_raise Ecto.NoResultsError, fn -> Incidents.get_incident!(incident.id) end
    end

    test "change_incident/1 returns a incident changeset" do
      incident = incident_fixture()
      assert %Ecto.Changeset{} = Incidents.change_incident(incident)
    end
  end
end
