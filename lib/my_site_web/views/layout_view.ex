defmodule MySiteWeb.LayoutView do
  use MySiteWeb, :view

  def show_flash_by_val(css_class, flash_key, conn) do
    flash_val = get_flash(conn, flash_key)

    if flash_val do
      content_tag(:p, flash_val, class: css_class)
    else
      ""
    end
  end
end
