<script context="module">
  const pduras = ['2 tuần', '1 tháng', '2 tháng', '3 tháng']
  const pduras_days = [14, 30, 60, 90]

  const costs = [
    [7, 15, 30, 45],
    [20, 40, 75, 100],
    [40, 80, 150, 210],
    [80, 160, 300, 420],
  ]
</script>

<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { api_call } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let p_now = $_user.privi
  let pform = { privi: p_now < 0 ? 0 : p_now > 3 ? 3 : p_now, pdura: 1 }

  let error = ''
  let state = 0
  $: if (pform) state = 0

  $: cost = costs[pform.privi][pform.pdura]

  const action = '/_db/uprivis/upgrade'

  async function submit() {
    state = 1
    error = ''

    try {
      $_user = await api_call(action, pform, 'PUT')
    } catch (ex) {
      error = ex.body.message
    }

    state = 2
  }

  const privi_colors = ['neutral', 'success', 'primary', 'warning', 'harmful']
</script>

<article class="article island">
  <h1>Quyền hạn hiện tại của bạn là {$_user.privi}</h1>

  <h2>Nâng cấp/Gia hạn</h2>
  <form {action} method="PUT" class="form" on:submit|preventDefault={submit}>
    <div class="form-field">
      <label class="form-label" for="privi">Chọn quyền hạn:</label>
      <div class="radio-group">
        {#each [0, 1, 2, 3] as value}
          <label class="m-label _{value}" class:_active={value == pform.privi}>
            <input type="radio" bind:group={pform.privi} {value} />
            <span class="icon"><SIcon name="privi-{value}" iset="icons" /></span
            >Q. hạn {value}
          </label>
        {/each}
      </div>
    </div>

    <div class="form-field">
      <label class="form-label" for="privi">Chọn thời gian:</label>
      <div class="radio-group">
        {#each [0, 1, 2, 3] as value}
          <label
            class="m-label pdura _{value}"
            class:_active={value == pform.pdura}>
            <div>
              <input type="radio" bind:group={pform.pdura} {value} />

              <SIcon name="clock" class="u-show-pm" />
              <span>{pduras[value]}</span>
            </div>
            <div>
              <SIcon name="vcoin" iset="icons" />
              <span>{costs[pform.privi][value]}</span>
            </div>
          </label>
        {/each}
      </div>
    </div>

    <p class="explain">
      Dùng <strong class="x-vcoin">{cost} vcoin</strong> để nâng cấp/gia hạn
      quyền hạn {pform.privi}
      thêm khoảng {pduras_days[pform.pdura]} ngày.
    </p>

    {#if error}<div class="form-error">{error}</div>{/if}

    <footer class="form-action">
      <button
        type="submit"
        class="m-btn _lg _fill _{privi_colors[pform.privi]}"
        data-umami-event="upgrade-privi"
        disabled={state > 0 || cost > $_user.vcoin}>
        <SIcon name={['send', 'loader-2', 'check'][state]} spin={state == 1} />
        <span>{$_user.privi >= pform.privi ? 'Gia hạn' : 'Nâng cấp'}</span>
        <SIcon name="privi-{pform.privi}" iset="icons" />
      </button>
    </footer>

    <div class="explain">
      {#if cost > $_user.vcoin}
        <p>
          <strong>Bạn chưa đủ số vcoin cần thiết để nâng cấp tài khoản!</strong>
        </p>
      {/if}
      <p>
        Ủng hộ Chivi để được tặng vcoin: <a href="/hd/donation">Hướng dẫn</a>
      </p>
    </div>
  </form>
</article>

<style lang="scss">
  .form {
    max-width: 30rem;
  }

  .radio-group {
    margin-top: 0.5rem;
    @include flex-ca($gap: 0.5rem);
    flex-wrap: wrap;
  }

  .explain {
    @include fgcolor(tert);
    font-style: italic;
    text-align: center;
    margin: 0.75rem 0;

    // @include ftsize(sm);
  }

  .form-action {
    margin-top: 0.25rem;
  }

  a {
    @include fgcolor(primary);
  }

  .pdura {
    display: flex;
    flex-direction: column;
    height: 3rem;
    line-height: 1rem;
    > div {
      @include flex-ca($gap: 0.125rem);
    }
  }
</style>
