defmodule Realworld.Articles.Article.Preparations.FilterSortFeed do
  use Ash.Resource.Preparation
  require Ash.Query

  @impl Ash.Resource.Preparation
  def prepare(query, _, %{actor: nil}) do
    query
    |> filter_by_tag()
    |> filter_by_author()
    |> filter_by_favourited()
    |> Ash.Query.sort([created_at: :desc], prepend?: true)
    |> Ash.Query.load([:user, :tags, :favorites_count])
  end

  def prepare(query, _, %{actor: actor}) do
    query
    |> filter_by_tag()
    |> filter_by_author()
    |> filter_by_favourited()
    |> filter_followed(actor)
    |> Ash.Query.sort([created_at: :desc], prepend?: true)
    |> Ash.Query.load(
      [
        :user,
        :tags,
        :favorites_count,
        :is_favorited
      ],
      actor: actor
    )
  end

  defp filter_followed(query, actor) do
    if query.arguments.private_feed? do
      Ash.Query.filter(query, exists(user.followers, user_id == ^actor.id))
    else
      query
    end
  end

  defp filter_by_tag(query) do
    case Ash.Query.get_argument(query, :filter) do
      %{tag: tag} ->
        Ash.Query.filter(query, exists(tags, name == ^tag))

      _ ->
        query
    end
  end

  defp filter_by_author(query) do
    case Ash.Query.get_argument(query, :filter) do
      %{author: author} ->
        Ash.Query.filter(query, exists(user, id == ^author))

      _ ->
        query
    end
  end

  defp filter_by_favourited(query) do
    case Ash.Query.get_argument(query, :filter) do
      %{favourited: favourited} ->
        Ash.Query.filter(query, exists(favorites, id == ^favourited))

      _ ->
        query
    end
  end
end
