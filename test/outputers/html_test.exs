defmodule WhiteBread.Outputers.HTMLTests do
	use ExUnit.Case
  alias WhiteBread.Outputers.HTML
  alias WhiteBread.Gherkin.Elements.Scenario

  @console WhiteBread.Outputers.Console

  test "default outputer is for the console" do
     assert @console = Application.fetch_env! :white_bread, :outputer
  end

  test "success result stored with the scenario name" do
    assert {:noreply, [{:ok, "X"}]} ==
      HTML.handle_cast {:scenario_result, {:ok, "ignore"}, %Scenario{name: "X"}}, []
  end

  test "write file on termaination" do
    HTML.terminate :normal, [{:ok, "X"}]
    p = Path.expand("~/report.html")
    s = File.stat! p
    assert File.exists? p
    assert s.size > 0
  end
end
