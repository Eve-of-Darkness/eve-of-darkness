defmodule EOD.Socket.InspectorTest do
  use ExUnit.Case, async: true

  alias EOD.Socket.Inspector
  alias EOD.TestSubscription

  setup opts do
    {:ok, inspector} =
      Inspector.start_link(
        metadata: opts[:meta_data] || %{},
        id: opts[:inspector_id] || :foobar
      )

    {:ok, subscription} = TestSubscription.start_link()
    :ok = Inspector.subscribe(inspector, subscription)
    TestSubscription.wait_for_subscribtion(subscription, inspector)
    {:ok, inspector: inspector, subscription: subscription}
  end

  @tag meta_data: %{foo: :bar}, inspector_id: :tee_hee
  test "alerts subscription of it's subscription", state do
    [sub] = TestSubscription.get_subscribes(state.subscription)
    assert sub.id == :tee_hee
    assert sub.meta == %{foo: :bar}
  end

  test "inspect_recv/2", state do
    Inspector.inspect_recv(state.inspector, "roflcopters")
    assert [msg] = TestSubscription.get_logs(state.subscription)
    assert msg.meta == %{}
    assert msg.action == :recv
    assert msg.data == "roflcopters"
  end

  test "inspect_send/2", state do
    Inspector.inspect_send(state.inspector, "roflcopters")
    assert [msg] = TestSubscription.get_logs(state.subscription)
    assert msg.meta == %{}
    assert msg.action == :send
    assert msg.data == "roflcopters"
  end

  test "subscribed?/2", state do
    assert Inspector.subscribed?(state.inspector, state.subscription)
  end

  @tag meta_data: %{biz: :buz}, inspector_id: :rofl_copter
  test "unsubscribe/2", %{inspector: inspector, subscription: sub} do
    Inspector.unsubscribe(inspector, sub)
    [unsub] = TestSubscription.get_unsubscribes(sub)
    assert unsub.id == :rofl_copter
    assert unsub.meta == %{biz: :buz}
    refute Inspector.subscribed?(inspector, sub)
  end
end
