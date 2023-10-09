<script lang="ts">
  import type { Writable } from 'svelte/store'
  import { api_call } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let _user: Writable<App.CurrentUser>

  let form = { target: '', reason: '', amount: 10 }

  let as_admin = false
  let res_type: '' | 'ok' | 'err' = ''
  let res_text = ''

  const action = '/_db/vcoins'

  async function submit(evt: Event) {
    evt.preventDefault()

    res_type = res_text = ''

    try {
      const body = { ...form, as_admin }
      const data = await api_call(action, body)
      $_user.vcoin -= form.amount

      res_type = 'ok'
      res_text = `[${data.target}] đã nhận được ${form.amount} vcoin, bạn còn có ${data.remain} vcoin.`
    } catch (ex) {
      res_type = 'err'
      res_text = ex.body?.message
    }
  }
</script>

<form {action} method="POST" on:submit={submit}>
  <form-group>
    <form-field>
      <label class="form-label" for="target">Người nhận</label>
      <input
        type="text"
        class="m-input"
        name="target"
        placeholder="Tên tài khoản hoặc hòm thư"
        required
        bind:value={form.target} />
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
        bind:value={form.reason} />
    </form-field>
  </form-group>

  {#if $_user.privi > 3}
    <label for="as_admin" class="as_admin">
      <input
        type="checkbox"
        id="as_admin"
        name="as_admin"
        disabled={$_user.privi < 4}
        bind:checked={as_admin} />
      <span>Gửi dưới quyền hệ thống</span>
    </label>
  {/if}

  <div class="form-group">
    <label class="form-label" for="amount">Số vcoin muốn tặng</label>

    <radio-group>
      {#each [5, 10, 20, 30, 50] as value}
        <label class="m-radio amount" class:_active={value == form.amount}>
          <input type="radio" bind:group={form.amount} {value} />
          {value}
        </label>
      {/each}

      <div>
        <label for="amount">Khác:</label>
        <input
          class="amount"
          name="amount"
          type="number"
          bind:value={form.amount} />
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
      disabled={!as_admin && $_user.vcoin < form.amount}>
      <span>Gửi tặng</span>
      <span>{form.amount}</span>
      <SIcon iset="icons" name="vcoin" />
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
