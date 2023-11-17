<script lang="ts">
  import type { Writable } from 'svelte/store'
  import { api_call } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let _user: Writable<App.CurrentUser>

  let dform = { target: '', reason: '', amount: 10 }

  let res_type: '' | 'ok' | 'err' = ''
  let res_text = ''

  const action = '/_db/xvcoins/donate'

  async function submit(evt: Event) {
    evt.preventDefault()
    res_type = res_text = ''

    try {
      const { target, amount } = await api_call(action, dform)
      res_type = 'ok'
      res_text = `[${target}] đã nhận được ${dform.amount} vcoin, tổng sở hữu: ${amount} vcoin.`
    } catch (ex) {
      res_type = 'err'
      res_text = ex.body?.message
    }
  }

  const reasons = [
    'Ủng hộ Chivi qua Techcombank',
    'Ủng hộ Chivi qua Vietcombank',
    'Ủng hộ Chivi qua Ví Momo',
    'Ủng hộ Chivi qua Paypal',
    'Ủng hộ Chivi qua Ko-fi',
  ]
</script>

<form {action} method="POST" on:submit={submit}>
  <div class="field">
    <label class="form-label" for="target">Người ủng hộ</label>
    <input
      type="text"
      class="m-input"
      name="target"
      placeholder="Tên tài khoản hoặc ID"
      required
      bind:value={dform.target} />
  </div>

  <div class="field">
    <label class="form-label" for="amount">Số tiền ủng hộ bằng Vcoin</label>

    <radio-group>
      {#each [10, 20, 30, 50, 100] as value}
        <label class="m-radio value" class:_active={value == dform.amount}>
          <input type="radio" bind:group={dform.amount} {value} />
          {value}
        </label>
      {/each}

      <strong class="u-fg-tert">Khác:</strong>

      <input
        class="value"
        name="amount"
        type="number"
        bind:value={dform.amount} />
    </radio-group>
  </div>

  <div class="field">
    <label class="form-label" for="target">Phương thức ủng hộ</label>

    {#each reasons as reason}
      <label class="radio" class:_active={reason == dform.reason}>
        <input type="radio" bind:group={dform.reason} value={reason} />
        {reason}
      </label>
    {/each}
  </div>

  {#if res_text}<div class="form-msg _{res_type}">{res_text}</div>{/if}

  <footer class="form-action">
    <button
      type="submit"
      class="m-btn _harmful _fill"
      disabled={$_user.privi < 3}>
      <span>Chuyển giao</span>
      <span>{dform.amount}</span>
      <SIcon iset="icons" name="vcoin" />
    </button>
  </footer>
</form>

<style lang="scss">
  .field {
    margin-top: 0.75rem;
    .m-input {
      display: block;
      width: 100%;
    }
  }

  .form-label {
    display: block;
  }

  .value {
    cursor: pointer;
    display: inline-flex;
    user-select: none;
    height: 2rem;
    text-align: center;
    padding: 0 0.355rem;
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

  input.value {
    width: 3rem;
    background-color: inherit;
  }

  radio-group {
    @include flex-cy;
    gap: 0.5rem;
    line-height: 2rem;

    margin-top: 0.25rem;
    margin-bottom: 0.5rem;
    > * {
      height: 2rem;
    }
  }

  .radio {
    display: block;
    line-height: 2rem;

    @include ftsize(sm);
    cursor: pointer;

    &._active {
      @include fgcolor(primary, 5);
    }
  }
</style>
