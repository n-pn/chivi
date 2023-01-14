<script context="module">
  const tspans = ['2 tuần', '1 tháng', '2 tháng', '3 tháng']

  const costs = [
    [0, 0, 0, 0],
    [10, 20, 35, 50],
    [30, 50, 90, 130],
    [50, 100, 175, 250],
  ]
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { session } from '$lib/stores'

  import { api_call } from '$lib/api_call'

  import { SIcon } from '$gui'

  export let tab = 2

  let error = ''

  let privi = $session.privi < 3 ? $session.privi + 1 : 3
  let tspan = 1
  $: vcoin = costs[privi][tspan]

  const action = '/api/_self/upgrade-privi'

  async function submit() {
    error = ''

    try {
      const body = await api_call(action, { privi, tspan }, 'PUT')
      $page.data._user = body
      tab = 0
    } catch (ex) {
      console.log(ex)
      error = ex.body.message
    }
  }
</script>

<form {action} method="PUT">
  <div class="form-field">
    <label class="form-label" for="privi">Chọn quyền hạn:</label>
    <div class="radio-group">
      {#each [1, 2, 3] as value}
        <label class="m-label _{value}" class:_active={value == privi}>
          <input type="radio" bind:group={privi} {value} />
          <span class="icon"><SIcon name="crown" /></span>Q.hạn {value}
        </label>
      {/each}
    </div>
  </div>

  <div class="form-field">
    <label class="form-label" for="privi">Chọn thời gian:</label>
    <div class="radio-group">
      {#each [0, 1, 2, 3] as value}
        <label class="m-label _1" class:_active={value == tspan}>
          <input type="radio" bind:group={tspan} {value} />
          <SIcon name="clock" />{tspans[value]}
        </label>
      {/each}
    </div>
  </div>

  {#if error}
    <div class="form-error">{error}</div>
  {/if}

  <footer class="form-action">
    <button
      type="submit"
      class="m-btn _success  _fill"
      disabled={vcoin > $session.vcoin}
      on:click|preventDefault={submit}>
      <span>Nâng cấp</span>
      <SIcon name="coin" />{vcoin}
    </button>
  </footer>
</form>

<style lang="scss">
  .radio-group {
    @include flex-ca($gap: 0.5rem);
  }

  .form-action {
    margin-top: 1.5rem;
  }
</style>
