<script lang="ts">
  import { session } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let tab = 'setting'
  let old_pass = ''
  let new_pass = ''
  let confirm_pass = ''

  let cpass_error = ''
  let privi_error = ''

  let privi = $session.privi < 3 ? $session.privi + 1 : 3
  let tspan = 1

  async function update_passwd() {
    cpass_error = ''
    const res = await fetch('/api/user/passwd', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ old_pass, new_pass, confirm_pass }),
    })

    if (res.ok) tab = 'replied'
    else cpass_error = await res.text()
  }

  async function logout() {
    await fetch('/api/user/logout')
    window.location.reload()
  }

  async function upgrade_privi() {
    privi_error = ''
    const res = await fetch('/api/_self/upgrade', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ privi, tspan }),
    })

    if (res.ok) {
      $session = await res.json()
      tab = 'replied'
    } else {
      privi_error = await res.text()
    }
  }

  const tspans = ['2 tuần', '1 tháng', '2 tháng', '3 tháng']

  const costs = [
    [0, 0, 0, 0],
    [10, 20, 35, 50],
    [30, 50, 90, 130],
    [50, 100, 175, 250],
  ]

  $: vcoin = costs[privi][tspan]
</script>

<h3>Nâng quyền hạn</h3>
<div class="form">
  <div class="field">
    <label class="label" for="privi">Chọn quyền hạn:</label>
    <div class="radio-group">
      {#each [1, 2, 3] as value}
        <label class="m-label _{value}" class:_active={value == privi}>
          <input type="radio" bind:group={privi} {value} />
          <span class="icon"><SIcon name="crown" /></span>Q.hạn {value}
        </label>
      {/each}
    </div>
  </div>

  <div class="field">
    <label class="label" for="privi">Chọn thời gian:</label>
    <div class="radio-group">
      {#each [0, 1, 2, 3] as value}
        <label class="m-label _1" class:_active={value == tspan}>
          <input type="radio" bind:group={tspan} {value} />
          <SIcon name="clock" />{tspans[value]}
        </label>
      {/each}
    </div>
  </div>

  {#if privi_error}
    <div class="error">{privi_error}</div>
  {/if}

  <footer class="action _vcoin">
    <button
      type="submit"
      class="m-btn _success  _fill"
      disabled={vcoin > $session.vcoin}
      on:click|preventDefault={upgrade_privi}>
      <span>Nâng cấp</span>
      <SIcon name="coin" />{vcoin}
    </button>
  </footer>
</div>

<h3>Đổi mật khẩu</h3>

<div class="form">
  <div class="field">
    <label class="label" for="upass">Mật khẩu cũ</label>
    <input
      type="password"
      class="m-input"
      name="upass"
      placeholder="Mật khẩu cũ"
      required
      bind:value={old_pass} />
  </div>

  <div class="field">
    <label class="label" for="new_upass">Mật khẩu mới</label>
    <input
      type="password"
      class="m-input"
      name="new_upass"
      placeholder="Mật khẩu mới"
      required
      bind:value={new_pass} />
  </div>

  <div class="field">
    <label class="label" for="confirm_upass">Nhập lại mật khẩu</label>
    <input
      type="password"
      class="m-input"
      name="confirm_upass"
      placeholder="Nhập lại mật khẩu"
      required
      bind:value={confirm_pass} />
  </div>

  {#if cpass_error}
    <div class="error">{cpass_error}</div>
  {/if}

  <footer class="action">
    <button
      type="submit"
      class="m-btn _harmful  _fill"
      on:click|preventDefault={update_passwd}>
      <span>Đổi mật khẩu</span>
    </button>
  </footer>
</div>

<div class="action _logout">
  <button class="m-btn btn-back umami--click--logout" on:click={logout}>
    <SIcon name="logout" />
    <span>Đăng xuất</span>
  </button>
</div>

<style lang="scss">
  .form {
    margin: 0.75rem;

    padding-bottom: 0.75rem;
    @include border($loc: bottom);
  }

  h3 {
    margin: 0.75rem;
    font-weight: 500;
    @include ftsize(md);
    // @include fgcolor(tert);
  }

  .radio-group {
    @include flex-ca($gap: 0.5rem);
  }

  label.m-label {
    @include flex-ca($gap: 0.125rem);
    height: 1.75rem;

    padding: 0 0.5rem;
    @include bps(font-size, rem(12px), rem(13px), rem(14px));

    .icon > :global(svg) {
      width: 1.125rem;
      height: 1.125rem;
      margin-top: -0.125rem;
    }

    &._active {
      background: var(--color);
      box-shadow: none;
      color: #fff;
    }
  }

  input[type='radio'] {
    display: none;
  }

  .field {
    margin: 0.75rem 0;

    > input {
      width: 100%;
    }
  }

  .label {
    display: block;
    // text-transform: uppercase;
    font-weight: 500;
    line-height: 1.5rem;
    margin-bottom: 0.25rem;
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  .error {
    text-align: center;
    @include fgcolor(harmful, 5);
    @include ftsize(md);
  }

  .action {
    @include flex-cx;
    padding: 0.25rem 0;

    &._vcoin {
      padding-top: 0.75rem;
    }
  }
</style>
