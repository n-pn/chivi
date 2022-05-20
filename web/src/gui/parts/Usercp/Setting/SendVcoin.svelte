<script lang="ts">
  import { session } from '$app/stores'

  import { call_api } from '$lib/api_call'
  import { SIcon } from '$gui'

  let receiver = ''
  let amount = 10
  let reason = ''

  let as_admin = false

  let res_type: '' | 'ok' | 'err' = ''

  let res_text = ''

  const action_url = '/api/_self/send-vcoin'

  async function submit() {
    res_type = ''
    res_text = ''

    const params = { receiver, amount, reason, as_admin }
    const [status, body] = await call_api(action_url, 'PUT', params, fetch)

    if (status >= 400) {
      res_type = 'err'
      res_text = body as string
    } else {
      res_type = 'ok'
      res_text = `[${body.receiver}] đã nhận được ${amount} vcoin, bạn còn có ${body.remain} vcoin.`

      // $session.vcoin_avail = body.remain
    }
  }
</script>

<form action={action_url} method="POST" on:submit|preventDefault={submit}>
  <form-group>
    <form-field>
      <label class="form-label" for="receiver">Người nhận</label>
      <input
        type="text"
        class="m-input"
        name="receiver"
        placeholder="Tên tài khoản hoặc hòm thư"
        required
        bind:value={receiver} />
    </form-field>
  </form-group>

  <form-group>
    <form-field>
      <label class="form-label" for="receiver">Lý do gửi tặng</label>
      <textarea
        type="text"
        class="m-input"
        name="reason"
        rows="1"
        placeholder="Có thể để trắng"
        bind:value={reason} />
    </form-field>
  </form-group>

  {#if $session.privi > 3}
    <label for="as_admin" class="as_admin">
      <input
        type="checkbox"
        id="as_admin"
        name="as_admin"
        bind:checked={as_admin} />
      Gửi dưới quyền hệ thống
    </label>
  {/if}

  <div class="form-group">
    <label class="form-label" for="amount">Số vcoin muốn tặng</label>

    <radio-group>
      {#each [5, 10, 20, 30, 50] as value}
        <label class="m-radio amount" class:_active={value == amount}>
          <input type="radio" bind:group={amount} {value} />
          {value}
        </label>
      {/each}

      <div>
        <label for="amount">Khác:</label>
        <input class="amount" name="amount" bind:value={amount} />
      </div>
    </radio-group>
  </div>

  {#if res_text}
    <div class="form-message _{res_type}">{res_text}</div>
  {/if}

  <footer class="form-action">
    <button
      type="submit"
      class="m-btn _primary  _fill"
      disabled={!as_admin && $session.vcoin_avail < amount}>
      <span>Gửi tặng</span>
      <SIcon name="coin" />
      {amount}
    </button>
  </footer>
</form>

<style lang="scss">
  .form-label {
    display: block;
  }

  .form-group {
    margin-top: 1rem;
  }

  .amount {
    user-select: none;
    display: inline-block;
    line-height: 2rem;
    text-align: center;
    width: 2rem;
    height: 2rem;
    font-weight: 500;
    @include fgcolor(secd);
    @include border;
    @include bdradi;

    &._active,
    &:focus {
      @include fgcolor(primary, 5);
      @include bdcolor(primary, 5);
      // box-shadow: 0 0 0 1px color(primary, 5, 5) inset;
    }
  }

  label.amount {
    cursor: pointer;
  }

  .as_admin {
    display: block;
    margin-top: 0.75rem;
    font-weight: 500;
    font-size: rem(15px);
  }

  input.amount {
    width: 3.5rem;
    background-color: inherit;
  }

  radio-group {
    display: flex;
    gap: 0.5rem;
    margin-top: 0.5rem;
    margin-bottom: 0.5rem;
  }
</style>
