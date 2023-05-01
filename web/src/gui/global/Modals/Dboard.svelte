<script lang="ts">
  import { browser } from '$app/environment'
  import { api_get } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'
  import RpnodeList from '$gui/parts/dboard/RpnodeList.svelte'

  export let actived = false
  export let thread = ''

  type Data = { gdroot: CV.Gdroot; rplist: CV.Rplist }
  let data: Data

  $: if (browser && actived && thread) load_data(thread)

  async function load_data(thread: string) {
    const path = `/_db/droots/show/${thread}`

    try {
      data = await api_get<Data>(path, fetch)
    } catch (ex) {
      console.log(ex.mesage)
    }
  }
</script>

<Slider class="dboard" bind:actived --slider-width="32rem">
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name="message-circle" /></div>
    <div class="-text">{data?.gdroot?.dtype || 'Bình luận chung'}</div>
  </svelte:fragment>

  {#if data}
    <header class="head">
      <h3>{data.gdroot.title}</h3>
    </header>

    <section class="body">
      <RpnodeList
        touser={data.gdroot.user_id}
        gdroot={thread}
        rplist={data.rplist} />
    </section>
  {/if}
</Slider>

<style lang="scss">
  // .-btn._active {
  // @include fgcolor(primary, 5);
  // }

  .type:first-letter {
    text-transform: upper;
  }

  .-text {
    @include clamp($width: null);
  }

  .head {
    padding: 0.75rem;
  }

  h3 {
    line-height: 1.5rem;
  }

  .body {
    display: flex;
    flex-direction: column;
    height: 100%;

    padding: 0.75rem;
  }
</style>
