defmodule Error do
  defstruct message: "",
            nested_error: nil

  def new(message) when is_binary(message) do
    %Error{
      message: message,
      nested_error: nil
    }
  end

  def new(%Error{} = error) do
    error
  end

  def new(arg) do
    %Error{
      message: inspect(arg),
      nested_error: nil
    }
  end

  def new(message, %Error{} = nested_error) when is_binary(message) do
    %Error{
      message: message,
      nested_error: nested_error
    }
  end

  def new(message, arg) when is_binary(message) and is_binary(arg) do
    %Error{
      message: "#{message}",
      nested_error: new(arg)
    }
  end

  def new(message, arg) when is_binary(message) do
    %Error{
      message: "#{message}: #{inspect(arg)}"
    }
  end

  def new(message, arg) do
    %Error{
      message: inspect(message) <> ": " <> inspect(arg)
    }
  end

  def wrap_in(%Error{} = inner, outer) when is_binary(outer) do
    %Error{
      message: outer,
      nested_error: inner
    }
  end

  def wrap_in(%Error{} = inner, %Error{} = outer) do
    %Error{
      outer
      | nested_error: inner
    }
  end

  def last(%Error{nested_error: nil} = error) do
    error
  end

  def last(%Error{nested_error: error}) do
    last(error)
  end

  def nest(%Error{nested_error: nil} = outer, %Error{} = inner) do
    %Error{
      outer
      | nested_error: inner
    }
  end

  def nest(%Error{nested_error: err} = outer, %Error{} = inner) do
    %Error{
      outer
      | nested_error: nest(err, inner)
    }
  end

  def flatten(nil) do
    []
  end

  def flatten(error) do
    [%Error{message: error.message}] ++ flatten(error.nested_error)
  end

  def text(error) do
    error
    |> flatten()
    |> Enum.map(&Map.get(&1, :message))
    |> Enum.join(": ")
  end
end
