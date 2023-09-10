<script lang="ts">
  import { get_user } from '$lib/stores'
  import { api_call } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  const _user = get_user()

  let form = data.form || {
    target: '',
    reason: '',
    amount: 10,
  }

  let res_type: '' | 'ok' | 'err' = ''
  let res_text = ''

  const action = '/_db/vcoins'

  async function submit(evt: Event) {
    evt.preventDefault()

    res_type = ''
    res_text = ''

    try {
      const data = await api_call(action, form, 'POST')
      $_user.vcoin -= form.amount
      res_type = 'ok'
      res_text = `[${data.target}] đã nhận được ${form.amount} vcoin, bạn còn có ${data.remain} vcoin.`
    } catch (ex) {
      res_type = 'err'
      res_text = ex.body?.message
    }
  }
</script>

<article class="article island">
  <h1>Gửi tặng Vcoin</h1>

  <form class="form" {action} method="POST" on:submit={submit}>
    <form-group>
      <form-field>
        <label class="form-label" for="receiver">Người nhận</label>
        <input
          type="text"
          class="m-input"
          name="receiver"
          placeholder="Tên tài khoản hoặc hòm thư"
          required
          bind:value={form.target} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="receiver">Lý do gửi tặng</label>
        <textarea
          class="m-input"
          name="reason"
          rows="2"
          placeholder="Có thể để trắng"
          bind:value={form.reason} />
      </form-field>
    </form-group>

    <div class="form-group">
      <label class="form-label" for="amount">Số vcoin muốn tặng</label>

      <radio-group class="amount-flex">
        {#each [5, 10, 20, 30, 50, 100] as value}
          <label class="m-radio amount" class:_active={value == form.amount}>
            <input type="radio" bind:group={form.amount} {value} />
            {value}
          </label>
        {/each}

        <div class="flex">
          <label for="amount">Số khác:</label>
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
        disabled={$_user.vcoin < form.amount}>
        <span>Gửi tặng</span>
        <span>{form.amount}</span>
        <SIcon iset="extra" name="vcoin" />
      </button>
    </footer>
  </form>
</article>

<style lang="scss">
  .article {
    margin-top: 0.75rem;
  }

  h1,
  .form {
    display: block;
    max-width: 24rem;
    margin: 0 auto;
  }

  .form-label {
    display: block;
  }

  .form-group {
    margin-top: 1rem;
  }

  .amount-flex {
    display: flex;
    flex-flow: row wrap;
  }

  .flex {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    margin-left: auto;
  }

  .amount {
    user-select: none;
    display: inline-block;
    line-height: 2rem;
    text-align: center;
    // width: 2.25rem;
    padding: 0 0.375rem;
    min-width: 2rem;
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
    margin: 1.5rem 0 1rem;
  }
</style>
