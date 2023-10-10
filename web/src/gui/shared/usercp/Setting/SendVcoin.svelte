<script lang="ts">
  import type { Writable } from 'svelte/store'
  import { api_call } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let _user: Writable<App.CurrentUser>
  export let xform = { target: '', reason: '', amount: 10 }

  let res_type: '' | 'ok' | 'err' = ''
  let res_text = ''

  const action = '/_db/xvcoins/giving'

  async function submit(evt: Event) {
    evt.preventDefault()

    res_type = res_text = ''

    try {
      const data = await api_call(action, xform)
      $_user.vcoin -= xform.amount

      res_type = 'ok'
      res_text = `[${data.target}] đã nhận được ${xform.amount} vcoin, bạn còn có ${data.remain} vcoin.`
    } catch (ex) {
      res_type = 'err'
      res_text = ex.body?.message
    }
  }
</script>

<form class="form" {action} method="POST" on:submit={submit}>
  <form-group>
    <form-field>
      <label class="form-label" for="target">Người nhận</label>
      <input
        type="text"
        class="m-input"
        name="target"
        placeholder="Tên tài khoản hoặc hòm thư"
        required
        bind:value={xform.target} />
    </form-field>
  </form-group>

  <form-group>
    <form-field>
      <label class="form-label" for="target">Lý do gửi tặng</label>
      <textarea
        class="m-input"
        name="reason"
        rows="2"
        placeholder="Có thể để trắng"
        bind:value={xform.reason} />
    </form-field>
  </form-group>

  <div class="form-group">
    <label class="form-label" for="amount">Số vcoin muốn tặng</label>

    <radio-group>
      {#each [5, 10, 20, 30, 50] as value}
        <label class="m-radio amount" class:_active={value == xform.amount}>
          <input type="radio" bind:group={xform.amount} {value} />
          {value}
        </label>
      {/each}

      <div>
        <label for="amount">Khác:</label>
        <input
          class="amount"
          name="amount"
          type="number"
          bind:value={xform.amount} />
      </div>
    </radio-group>
  </div>

  {#if res_text}
    <div class="form-message _{res_type}">{res_text}</div>
  {/if}

  <footer class="form-action">
    <button
      type="submit"
      class="m-btn _primary _fill"
      disabled={$_user.vcoin < xform.amount}>
      <span>Gửi tặng</span>
      <span>{xform.amount}</span>
      <SIcon iset="icons" name="vcoin" />
    </button>
  </footer>
</form>

<style lang="scss">
  .form {
    max-width: 25rem;
    margin: 0 auto;
  }

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

  .form-action {
    @include border(--bd-soft, $loc: top);
    padding-top: 0.75rem;
  }
</style>
