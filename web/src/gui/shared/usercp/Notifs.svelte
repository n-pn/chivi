<script lang="ts">
  import { onMount } from 'svelte'
  import type { Writable } from 'svelte/store'
  import { api_get } from '$lib/api_call'

  import { rel_time } from '$utils/time_utils'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  export let actived = false

  export let _user: Writable<App.CurrentUser>

  let data: CV.UnotifPage = {
    notifs: [],
    pgidx: 1,
    total: 0,
    pgmax: 0,
  }

  onMount(load_notifs)

  async function load_notifs(pg = 1) {
    $_user.unread_notif = 0

    const api_url = `/_db/_self/notifs?&pg=${pg}&lm=15`
    try {
      data = await api_get<CV.UnotifPage>(api_url, fetch)
    } catch (error) {
      console.log(error)
    }
  }
</script>

<Slider bind:actived class="notifs" --slider-width="24rem">
  <svelte:fragment slot="header-left">
    <span class="-icon"><SIcon name="bell" /></span>
    <span class="-text">Thông báo ({data.total})</span>
    <a class="link" href="/me/notif">Xem tất cả</a>
  </svelte:fragment>

  <div class="notifs">
    {#each data.notifs as notif}
      <div class="notif" class:_fresh={!notif.reached_at}>
        {@html notif.content}
        <footer class="notif-foot">
          <time>{rel_time(notif.created_at)}</time>
        </footer>
      </div>
    {/each}
  </div>

  <footer class="foot">
    <a class="m-btn _primary _fill _sm" href="/me/notif">Tất cả thông báo</a>
  </footer>
</Slider>

<style lang="scss">
  .label {
    @include flex-cy();
    gap: 0.25rem;

    // padding-left: 0.25rem;
    margin-bottom: 0.75rem;
    // margin: 0.25rem 0;

    // line-height: 2.25rem;
    font-weight: 500;

    @include fgcolor(tert);
  }

  .notif {
    font-size: rem(15px);
    padding: 0.5rem;

    line-height: 1.375rem;
    @include border(--bd-soft, $loc: top);

    &._fresh {
      @include bgcolor(warning, 5, 1);
    }

    :global(.cv-user) {
      @include fgcolor(primary, 5);
    }
  }

  .link {
    margin-left: auto;
    font-weight: 400;
    font-style: italic;
    font-size: rem(15px);
    @include fgcolor(tert);

    &:hover {
      @include fgcolor(primary, 4);
    }
  }

  .notif-foot {
    margin-top: 0.25rem;
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  .foot {
    text-align: center;
    margin-bottom: 1rem;
  }
</style>
