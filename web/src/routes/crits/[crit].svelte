<script context="module" lang="ts">
  import { appbar } from '$lib/stores'
  export async function load({ fetch, params: { crit } }) {
    appbar.set({
      left: [
        ['Đánh giá', 'stars', '/crits'],
        [`[${crit}]`, null, null, null, '_seed'],
      ],
    })

    const api_res = await fetch(`/api/crits/${crit}`)
    return await api_res.json()
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritCard from '$gui/parts/Yscrit.svelte'

  export let yscrit: CV.Yscrit
</script>

<svelte:head>
  <title>Đánh giá - Chivi</title>
</svelte:head>

<nav class="h3 navi">
  <a class="-link" href="/crits">
    <SIcon name="messages" />
    <span>Đánh giá</span>
  </a>
  <span class="-sep">/</span>
  <a class="-link" href="/crits?user={yscrit.uslug}">
    <SIcon name="user" />
    <span>{yscrit.uname}</span>
  </a>
  <span class="-sep">/</span>
  <a class="-link" href="/crits?book={yscrit.bid}">
    <SIcon name="book" />
    <span>{yscrit.bname}</span>
  </a>
</nav>

<YscritCard crit={yscrit} view_all={true} big_text={true} />

<style lang="scss">
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
