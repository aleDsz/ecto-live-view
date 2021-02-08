defmodule EctoLiveViewWeb.Helpers.EctoViewHelper do
  @moduledoc """
  Ecto schema helper for LiveViews
  """
  import Phoenix.HTML.Form
  import Phoenix.HTML.Tag

  defmodule InputField do
    defstruct [:id, :schema, :name, :type, :values]
  end

  @number_types ~w(integer float decimal)a

  alias Ecto.Changeset
  alias __MODULE__.InputField
  alias Phoenix.HTML
  alias Phoenix.HTML.Form

  @doc """

  """
  @spec ecto_form(Ecto.Schema.t() | struct(), binary(), keyword()) :: list(binary())
  def ecto_form(schema, action \\ "#", opts \\ []) do
    schema = get_schema(schema)
    fields = get_fields(schema)

    schema
    |> generate_inputs(fields)
    |> generate_html(action, opts)
  end

  defp get_schema(%{__meta__: _, __struct__: schema}), do: schema
  defp get_schema(schema) when is_atom(schema), do: schema

  defp get_fields(schema) do
    fields = get_schema_fields(schema)
    autogenerate_fields = get_autogenerate_fields(schema)
    {id_field, _, _} = get_id(schema)

    date_fields =
      Enum.reduce(autogenerate_fields, [], fn
        {fields, {_, _, _}}, acc ->
          acc ++ fields
      end)

    removable_fileds = [id_field | date_fields]

    Enum.reject(fields, fn field ->
      field in removable_fileds
    end)
  end

  defp get_id(schema), do: schema.__schema__(:autogenerate_id)
  defp get_schema_fields(schema), do: schema.__schema__(:fields)
  defp get_autogenerate_fields(schema), do: schema.__schema__(:autogenerate)

  defp generate_inputs(schema, fields) do
    Enum.reduce(fields, [], fn field, acc ->
      input_field = build_input_field(schema, field)
      [input_field | acc]
    end)
    |> Enum.reverse()
  end

  defp build_input_field(schema, field) do
    type = get_field_type(schema, field)

    %InputField{
      id: field,
      schema: schema,
      name: field,
      type: type
    }
    |> get_field_values()
    |> get_input_types()
  end

  defp get_field_type(schema, field), do: schema.__schema__(:type, field)

  defp get_field_values(input_field = %InputField{type: :boolean}),
    do: %{input_field | values: [true, false]}

  defp get_field_values(input_field = %InputField{schema: schema, name: field}) do
    function_name = :"allowed_#{field}"

    if function_exported?(schema, function_name, 0) do
      values = apply(schema, function_name, [])
      %{input_field | values: values}
    else
      %{input_field | values: []}
    end
  end

  defp get_input_types(input_field = %InputField{type: :boolean}),
    do: %{input_field | type: :radio}

  defp get_input_types(input_field = %InputField{type: :string, values: [_ | _]}),
    do: %{input_field | type: :select}

  defp get_input_types(input_field = %InputField{type: :string, values: []}),
    do: %{input_field | type: :text}

  defp get_input_types(input_field = %InputField{type: type}) when type in @number_types,
    do: %{input_field | type: :number}

  defp get_input_types(input_field = %InputField{}), do: input_field

  defp generate_html(input_fields = [%InputField{schema: schema} | _], action, opts) do
    changeset = init_changeset(schema)
    form = form_for(changeset, action, opts)

    html =
      form
      |> build_inputs(input_fields)
      |> build_html()

    form_html = build_form(form)

    submit_button =
      submit("Submit")
      |> HTML.safe_to_string()

    [form_html] ++ html ++ [submit_button, "</form>"]
  end

  defp init_changeset(schema) do
    schema
    |> struct!()
    |> schema.changeset(%{})
  end

  defp build_inputs(form, input_fields = [%InputField{} | _]) do
    Enum.map(input_fields, &build_input(form, &1))
  end

  defp build_input(form = %Form{}, input_field = %InputField{type: :select}) do
    select(form, input_field.name, input_field.values)
  end

  defp build_input(form = %Form{}, %InputField{name: field, type: :text}) do
    text_input(form, field)
  end

  defp build_input(form = %Form{}, %InputField{name: field, type: :date}) do
    date_input(form, field)
  end

  defp build_input(form = %Form{}, %InputField{name: field, type: :radio, values: values}) do
    Enum.map(values, &radio_button(form, field, &1))
  end

  defp build_input(form = %Form{}, %InputField{name: field, type: :number}) do
    number_input(form, field)
  end

  defp build_html(inputs = [_ | _]) do
    Enum.map(inputs, fn
      value = {:safe, _} ->
        HTML.safe_to_string(value)

      values = [_ | _] ->
        Enum.map(values, &HTML.safe_to_string/1)
    end)
  end

  defp build_form(%Form{action: action, options: options}) do
    action
    |> form_tag(options)
    |> HTML.safe_to_string()
  end
end
