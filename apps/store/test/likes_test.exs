defmodule LikeTest do
  use ExUnit.Case
  alias Store.{FeedRepo, SourceRepo, FeedBuilder, Likes}

  setup_all do
    UserTestHelper.ddl()
    :ok
  end

  test "get likes summary empty" do
    {:ok, event} = create_event()
    preview = GenServer.call(Likes, {:preview, event.id})
    assert preview.count == 0
    assert preview.likers == []
    assert preview.you == false
  end

  test "get not liked 'likes' summary" do
    {:ok, event} = create_event()
    create_likes_for(event)
    preview = GenServer.call(Likes, {:preview, event.id})
    assert preview.count == 11
    assert length(preview.likers) == 3
    assert preview.you == false
  end

  test "get liked 'likes' summary" do
    {:ok, event} = create_event()
    {:ok, like} = List.last(create_likes_for(event))
    preview = GenServer.call(Likes, {:preview, event.id, like.user_id})
    assert preview.count == 11
    assert length(preview.likers) == 3
    assert preview.you == true
  end

  test "get all likers list" do
    {:ok, event} = create_event()
    create_likes_for(event)
    likers = GenServer.call(Likes, {:index, %{event_id: event.id}})
    assert length(likers) == 11
  end

  defp create_event do
    1
    |> FeedTestHelper.create()
    |> List.first()
    |> FeedBuilder.build()
  end

  defp create_likes_for(event) do
    users = FeedTestHelper.create_10_users()

    users
    |> Enum.map(fn user -> create_like(event, user) end)
  end

  defp create_like(event, {user, _, _}) do
    num = :rand.uniform(10)

    GenServer.call(
      Likes,
      {:create,
       %{
         user_id: user,
         event_id: event.id,
         tenant_id: 0
       }}
    )
  end
end
