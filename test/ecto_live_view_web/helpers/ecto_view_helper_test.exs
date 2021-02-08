defmodule EctoLiveViewWeb.Helpers.EctoViewHelperTest do
  use EctoLiveViewWeb.ConnCase

  alias EctoLiveView.Users.User
  alias EctoLiveViewWeb.Helpers.EctoViewHelper

  describe "ecto_form/3" do
    test "returns a form with fields from Schema" do
      EctoViewHelper.ecto_form(User, "#", id: "test-form")
      |> IO.inspect(label: "ecto_form/3")

      assert true
    end
  end
end
