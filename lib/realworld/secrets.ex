defmodule Realworld.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Realworld.Accounts.User, _opts) do
    Application.fetch_env(:realworld, :token_signing_secret)
  end
end
