<script context="module">
  const ranges = ['2 tuần', '1 tháng', '2 tháng', '3 tháng']

  const costs = [
    [0, 0, 0, 0],
    [10, 20, 35, 50],
    [30, 50, 90, 130],
    [50, 100, 175, 250],
  ]

  const ranges_days = [14, 30, 60, 90]
</script>

<script lang="ts">
  import type { Writable } from 'svelte/store'
  import { api_call } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let _user: Writable<App.CurrentUser>

  let form = { privi: $_user.privi < 3 ? $_user.privi + 1 : 3, range: 1 }
  let error = ''
  let _onload = false

  $: cost = costs[form.privi][form.range]

  const action = '/_db/_self/upgrade-privi'

  async function submit(evt: Event) {
    evt.preventDefault()

    error = ''
    _onload = true

    try {
      $_user = await api_call(action, form, 'PUT')
    } catch (ex) {
      error = ex.body.message
    }

    _onload = false
  }

  const privi_colors = ['neutral', 'success', 'primary', 'warning', 'harmful']
</script>

<form {action} method="PUT" class="form" on:submit={submit}>
  <div class="form-field">
    <label class="form-label" for="privi">Chọn quyền hạn:</label>
    <div class="radio-group">
      {#each [1, 2, 3] as value}
        <label class="m-label _{value}" class:_active={value == form.privi}>
          <input type="radio" bind:group={form.privi} {value} />
          <span class="icon"><SIcon name="privi-{value}" iset="icons" /></span
          >Q.hạn {value}
        </label>
      {/each}
    </div>
  </div>

  <div class="form-field">
    <label class="form-label" for="privi">Chọn thời gian:</label>
    <div class="radio-group">
      {#each [0, 1, 2, 3] as value}
        <label class="m-label _{value}" class:_active={value == form.range}>
          <input type="radio" bind:group={form.range} {value} />
          <SIcon name="clock" class="u-show-pm" />
          <span>{ranges[value]}</span>
        </label>
      {/each}
    </div>
  </div>

  <div class="explain">
    Nâng cấp/gia hạn quyền hạn {form.privi} khoảng {ranges_days[form.range]} ngày.
  </div>

  {#if error}<div class="form-error">{error}</div>{/if}

  <footer class="form-action">
    <button
      type="submit"
      class="m-btn _fill _{privi_colors[form.privi]}"
      disabled={_onload || cost > $_user.vcoin}>
      <span>Nâng cấp</span>
      <span>{cost}</span>
      <SIcon iset="icons" name="vcoin" />
    </button>
  </footer>

  <div class="explain">
    {#if cost > $_user.vcoin}
      <p>
        <strong>Bạn chưa đủ số vcoin cần thiết để nâng cấp tài khoản!</strong>
      </p>
    {/if}
    <p>Ủng hộ Chivi để được tặng vcoin: <a href="/hd/donation">Hướng dẫn</a></p>
  </div>
</form>

<style lang="scss">
  .radio-group {
    @include flex-ca($gap: 0.375rem);
  }

  .explain {
    @include fgcolor(tert);
    font-style: italic;
    text-align: center;
    margin-top: 0.5rem;

    @include ftsize(sm);
  }

  .form-action {
    margin-top: 0.25rem;
  }

  a {
    @include fgcolor(primary);
  }
</style>
