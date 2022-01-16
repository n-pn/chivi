<script context="module">
  import { api_call } from '$api/_api_call'
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ fetch, params }) {
    const [status, crit] = await api_call(fetch, `crits/${params.crit}`)
    if (status) return { status, error: crit }

    appbar.set({
      left: [
        ['Đánh giá', 'stars', '/crits'],
        [`[${crit.id}]`, null, null, null, '_seed'],
      ],
    })
    return { props: { crit } }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import Yscrit from '$parts/Yscrit.svelte'

  export let crit
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

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

    <Yscrit {crit} view_all={true} big_text={true} />
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
