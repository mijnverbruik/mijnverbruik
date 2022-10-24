defmodule MijnverbruikWeb.LiveHelpers do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :element, :string, default: "span"
  attr :rest, :global

  slot(:inner_block, required: true)

  def animated_value(assigns) do
    ~H"""
    <%# Unable to call render_slot/2 outside the ~H sigil %>
    <% value = render_slot(@inner_block) %>

    <.dynamic_tag name={@element} id={@id} data-animated-value={value} phx-hook="AnimatedValue" phx-update="ignore" {@rest}>
      <%= value %>
    </.dynamic_tag>
    """
  end
end
