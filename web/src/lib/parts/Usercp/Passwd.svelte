<script>
  export let tab

  let old_pass = ''
  let new_pass = ''
  let confirm_pass = ''

  let error = ''

  async function save_pass() {
    error = ''
    const res = await fetch('/api/user/passwd', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ old_pass, new_pass, confirm_pass }),
    })

    if (res.ok) tab = 'main'
    else error = await res.text()
  }
</script>

<div class="form">
  <header class="h3">Đổi mật khẩu</header>

  <div class="input">
    <label for="cpass">Mật khẩu cũ</label>
    <input
      type="password"
      class="m-input"
      name="upass"
      placeholder="Mật khẩu cũ"
      required
      bind:value={old_pass} />
  </div>

  <div class="input">
    <label for="cpass">Mật khẩu mới</label>
    <input
      type="password"
      class="m-input"
      name="new_upass"
      placeholder="Mật khẩu mới"
      required
      bind:value={new_pass} />
  </div>

  <div class="input">
    <label for="cpass">Nhập lại mật khẩu</label>
    <input
      type="password"
      class="m-input"
      name="confirm_upass"
      placeholder="Nhập lại mật khẩu"
      required
      bind:value={confirm_pass} />
  </div>

  {#if error}
    <div class="error">{error}</div>
  {/if}

  <footer class="pfoot">
    <button class="m-button _primary  _fill" on:click={save_pass}
      >Cập nhật</button>
  </footer>
</div>

<style lang="scss">
  .form {
    @include bgcolor(tert);
    @include shadow();
    @include bdradi();
    padding: 0.75rem;
    margin: 0.75rem;
  }

  .h3 {
    padding: 0 0.75rem;
  }

  .input {
    margin: 0.75rem;

    > input {
      width: 100%;
    }

    > label {
      display: block;
      // text-transform: uppercase;
      font-weight: 500;
      line-height: 1.5rem;
      margin-bottom: 0.25rem;
      @include ftsize(md);
      @include fgcolor(tert);
    }
  }

  .pfoot {
    display: flex;
    justify-content: right;
    margin: 1rem 0.75rem;
  }

  .error {
    @include fgcolor(harmful, 5);
    text-align: center;
    @include ftsize(md);
  }
</style>
