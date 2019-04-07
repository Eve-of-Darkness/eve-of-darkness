defprotocol EOD.Socket.Inspector.Subscription do
  @moduledoc """
  An EOD.Socket.Inspector delegates the inspected data it
  receives to subscriptions; which this is an abstract protocol
  meant to define the needed functions of a subscription.
  """

  @doc """
  This is called by the Inspector when data is sent or received,
  the action will be either `:send` or `:receive`, with meta being
  a map of meta information assigned to the Inspector, data can
  be anything and is up to how Inspector is used.  Where at all
  possible, this should be a non-blocking call.
  """
  def notify(subscription, action, id, meta, data)

  @doc """
  Inspectors rely on being able to pull up a subscription via some
  kind of unique id.  Every subscription needs to have some way to
  provide one.
  """
  def id(subscription)

  @doc """
  This is called from the Inspector when it is shutting down.  It
  provides an id and meta data of the inspector that is shutting down.
  """
  def shutting_down(subscription, id, meta)

  @doc "Same as shutting down, but only when unsubscribing instead"
  def unsubscribing(subscription, id, meta)

  @doc """
  Called when a subscription is being added to an inspector, just like
  unsubscribing, it provides the id and meta data of the inspector
  the subscription is being added to
  """
  def subscribing(subscription, id, meta)
end
