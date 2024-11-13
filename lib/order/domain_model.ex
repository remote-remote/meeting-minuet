defmodule Order.DomainModel do
  defmacro __using__(opts) do
    db_module = Keyword.fetch!(opts, :db_module)

    quote do
      @behaviour Order.DomainModel

      @db_module unquote(db_module)

      # Define callbacks dynamically with the current module as the domain module
      @callback to_db(domain_model :: %__MODULE__{}) :: %unquote(db_module){}
      @callback from_db(
                  db_model :: %unquote(db_module){},
                  user :: %Order.Accounts.User{}
                ) :: %__MODULE__{}
    end
  end

  # Define the callback specs as a general reference
  @callback to_db(any) :: any
  @callback from_db(any) :: any
end
