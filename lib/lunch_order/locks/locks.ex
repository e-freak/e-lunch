defmodule LunchOrder.Locks do
  @moduledoc """
  The Locks context.
  """

  import Ecto.Query, warn: false
  alias LunchOrder.Repo

  alias LunchOrder.Locks.Lock
  alias LunchOrder.Users.User

  # ロック対象の連続ログイン失敗回数
  @lock_count 5
  # ログイン失敗のカウント対象時間
  @lock_count_time 600
  # ロック時間
  @lock_time 600


  @spec check_lock(any()) :: {:error, nil} | {:ok, atom() | %{fail_time_list: any()}}
  def check_lock(email) do
    lock = Repo.get_by(Lock, email: email)
    if lock do
      if is_locked?(lock), do: {:error, nil}, else: {:ok, lock}
    else
      {:ok, nil}
    end
  end

  defp is_locked?(lock) do
    fail_count = Enum.count(lock.fail_time_list)
    if (fail_count >= @lock_count) do
      # 最後のログイン失敗から10分(600秒)以内ならロックする
      last_time = List.first(lock.fail_time_list)
      DateTime.diff(DateTime.utc_now, last_time) < @lock_time
    else
      false
    end
  end

  def reset_lock(lock) do
    if !is_nil(lock) do
      Lock.changeset(lock, %{fail_time_list: []})
      |> Repo.update()
    end
  end

  # ロックデータを新規作成
  def update_lock(email, lock) when is_nil(lock) do
    user = Repo.get_by(User, email: email)
    if !is_nil(user) do
      %Lock{}
      |> Lock.changeset(%{email: email, fail_time_list: [DateTime.utc_now]})
      |> Repo.insert()
    end
  end

  # ロックデータを更新
  def update_lock(email, lock) do
    # 現在時間から10分(600秒)以内のデータのみ残す
    now = DateTime.utc_now
    filtered_list = Enum.filter(lock.fail_time_list, fn datetime ->
      DateTime.diff(now, datetime) < @lock_count_time
    end)

    list = [now | filtered_list]
    Lock.changeset(lock, %{fail_time_list: list})
    |> Repo.update()

    if (Enum.count(list) >= @lock_count) do
      # メール通知
      from = Application.get_env(:lunch_order, :from_address)
      cc = Application.get_env(:lunch_order, :admin_address)
      bcc = Application.get_env(:lunch_order, :bcc_address)
      user = Repo.get_by(User, email: email)
      subject = "#{user.name} さんのアカウントがロックされました"
      body = "ログインに複数回失敗したため、アカウントを10分間ロックします。\n\n" <>
             "パスワードを忘れた場合は、管理者にメールでパスワードリセットの依頼をしてください。\n" <>
             "管理者は本メールの[Cc]のメンバーです。"
      LunchOrder.Email.send_email(from, email, cc, bcc, subject, body)
    end
  end

end
