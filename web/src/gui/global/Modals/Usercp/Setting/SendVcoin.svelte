<script lang="ts">
  import { page } from '$app/stores'
  $: session = $page.data._user

  import { api_call } from '$lib/api_call'
  import { SIcon } from '$gui'

  let sendee = ''
  let amount = 10
  let reason = ''

  let as_admin = false

  let res_type: '' | 'ok' | 'err' = ''

  let res_text = ''

  const action_url = '/api/_self/send-vcoin'

  async function submit() {
    res_type = ''
    res_text = ''

    try {
      const body = { sendee, amount, reason, as_admin }
      const data = await api_call(action_url, body, 'PUT')
      res_type = 'ok'
      res_text = `[${data.sendee}] đã nhận được ${amount} vcoin, bạn còn có ${data.remain} vcoin.`
    } catch (ex) {
      res_type = 'err'
      res_text = ex.message
    }
  }
</script>

<form action={action_url} method="POST" on:submit|preventDefault={submit}>
  <form-group>
    <form-field>
      <label class="form-label" for="sendee">Người nhận</label>
      <input
        type="text"
        class="m-input"
        name="sendee"
        placeholder="Tên tài khoản hoặc hòm thư"
        required
        bind:value={sendee} />
    </form-field>
  </form-group>

  <form-group>
    <form-field>
      <label class="form-label" for="sendee">Lý do gửi tặng</label>
      <textarea
        type="text"
        class="m-input"
        name="reason"
        rows="1"
        placeholder="Có thể để trắng"
        bind:value={reason} />
    </form-field>
  </form-group>

  <label for="as_admin" class="as_admin">
    <input
      type="checkbox"
      id="as_admin"
      name="as_admin"
      disabled={session.privi < 4}
      bind:checked={as_admin} />
    <span>Gửi dưới quyền hệ thống</span>
  </label>

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
      disabled={!as_admin && session.vcoin_avail < amount}>
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
