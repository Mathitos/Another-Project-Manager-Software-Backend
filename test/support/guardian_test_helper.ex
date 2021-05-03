defmodule Apms.GuardianTestHelper do
  @spec add_auth_header(Plug.Conn.t(), Apms.Accounts.User.t()) :: Plug.Conn.t()
  def add_auth_header(conn, user) do
    {:ok, jwt, _claims} = ApmsWeb.Guardian.encode_and_sign(user)
    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{jwt}")
  end
end
