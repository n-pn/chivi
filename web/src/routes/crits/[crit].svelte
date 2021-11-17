<script context="module">
  import { api_call } from '$api/_api_call'
  import { enabled as lookup_enabled } from '$parts/Lookup.svelte'

  export async function load({ fetch, page }) {
    const [status, crit] = await api_call(fetch, `crits/${page.params.crit}`)
    if (status) return { status, error: crit }
    else return { props: { crit } }
  }
</script>

<script>
  import { session } from '$app/stores'
  import { invalidate } from '$app/navigation'

  import SIcon from '$atoms/SIcon.svelte'
  import Appbar from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Yscrit from '$parts/Yscrit.svelte'
  import Cvdata from '$sects/Cvdata.svelte'

  export let crit

  const on_change = () => {
    if ($session.privi > 0) invalidate(`api/crits/${crit.id}`)
  }
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

<Appbar>
  <svelte:fragment slot="left">
    <a href="/crits" class="header-item">
      <SIcon name="messages" />
      <span class="header-text">Đánh giá</span>
    </a>

    <button class="header-item _active">
      <span class="header-text _seed">[{crit.id}]</span>
    </button>
  </svelte:fragment>

  <svelte:fragment slot="right">
    <button
      class="header-item"
      class:_active={$lookup_enabled}
      on:click={() => lookup_enabled.update((x) => !x)}
      data-kbd="\">
      <SIcon name="compass" />
      <span class="header-text _show-md">Giải nghĩa</span>
    </button>
  </svelte:fragment>
</Appbar>

<Vessel>
  <section class="main">
    <nav class="h3 navi">
      <a class="-link" href="/crits">
        <SIcon name="messages" />
        <span>Đánh giá</span>
      </a>
      <span class="-sep">/</span>
      <a class="-link" href="/crits?user={crit.uslug}">
        <SIcon name="user" />
        <span>{crit.uname}</span>
      </a>
      <span class="-sep">/</span>
      <a class="-link" href="/crits?book={crit.bid}">
        <SIcon name="book" />
        <span>{crit.bname}</span>
      </a>
    </nav>

    <Yscrit {crit} view_all={true}>
      <Cvdata
        zhtext={crit.ztext.split('\n')}
        cvdata={crit.vhtml}
        wtitle={false}
        dname={crit.bhash}
        d_dub={crit.bname}
        {on_change} />
    </Yscrit>
  </section>
</Vessel>

<style lang="scss">
  .main {
    border-radius: 0.5rem;
    @include bgcolor(tert);

    margin-top: 1rem;
    @include bps(margin-left, calc(var(--gutter) * -1), 0);
    @include bps(margin-right, calc(var(--gutter) * -1), 0);
    padding: var(--gutter) calc(var(--gutter) * 2);
  }

  .navi {
    a {
      @include fgcolor(secd);
      @include hover {
        @include fgcolor(primary, 5);
      }
    }

    .-sep {
      @include fgcolor(tert);
    }

    :global(svg) {
      margin-top: -0.25rem;
      margin-right: -0.125rem;
    }
  }
</style>
