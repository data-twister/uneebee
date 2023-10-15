defmodule UneebeeWeb.Components.Dashboard.LessonSwitch do
  @moduledoc false
  use UneebeeWeb, :live_component

  alias Uneebee.Content
  alias Uneebee.Content.Course
  alias Uneebee.Content.Lesson
  alias Uneebee.Content.LessonStep

  attr :step_count, :integer, required: true
  attr :course, Course, required: true
  attr :lesson, Lesson, required: true
  attr :step, LessonStep, required: true

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <p class="text-gray py-4 text-xs italic"><%= dgettext("orgs", "Drag the steps to change their order:") %></p>

      <nav id="lesson-steps" class="flex flex-wrap gap-2" data-group="lesson-steps" phx-hook="Sortable">
        <.link
          :for={step_order <- 1..@step_count}
          patch={~p"/dashboard/c/#{@course.slug}/l/#{@lesson.id}/s/#{step_order}"}
          class={[
            "h-10 w-10 flex flex-col items-center justify-center rounded-full text-center font-black cursor-grab",
            "drag-ghost:bg-gray-light drag-ghost:cursor-grabbing drag-ghost:border-0 drag-ghost:ring-0",
            "focus-within:drag-item:ring-0 focus-within:drag-item:ring-offset-0",
            step_order != @step.order && "bg-primary-light3x text-primary-dark2x",
            step_order == @step.order && "bg-primary-dark2x text-primary-light3x"
          ]}
        >
          <%= step_order %>
        </.link>

        <button :if={@step_count < 20} class="bg-gray-light3x filtered text-gray-dark2x h-10 w-10 rounded-full text-center font-black" phx-click="add-step" phx-target={@myself}>
          +
        </button>
      </nav>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("add-step", _params, socket) do
    %{lesson: lesson, step_count: step_count} = socket.assigns
    attrs = %{lesson_id: lesson.id, order: step_count + 1, content: dgettext("orgs", "Untitled step")}

    case Content.create_lesson_step(attrs) do
      {:ok, _lesson_step} ->
        notify_parent(socket, step_count + 1)
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash!(socket, :error, dgettext("orgs", "Could not create step!"))}
    end
  end

  defp notify_parent(socket, step_count) do
    send(self(), {__MODULE__, socket.assigns.id, step_count})
    :ok
  end
end