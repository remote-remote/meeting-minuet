defmodule OrderWeb.OrgMemberAuth do
  import Plug.Conn
  alias Order.Organizations

  def fetch_membership(
        %{
          assigns: %{current_user: current_user},
          params: %{"organization_id" => organization_id}
        } = conn,
        _opts
      ) do
    membership = Organizations.get_member!(organization_id, current_user.id)
    assign(conn, :current_membership, membership)
  end
end
